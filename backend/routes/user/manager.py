import hmac
from typing import Dict, Final, Optional
from time import time
import secrets


from fastapi_mail.fastmail import FastMail
from fastapi_mail.schemas import MessageSchema


from responses import Error
from data.models import User
from globals import server_url, pwd_ctx
from data.services.user_service import UserService
from routes.user.registrator import EMAIL_CONF

RESET_INTERVAL = 900  # 15min


HTML = """
<html>
    <title>SurveyPlatform</title>
    <body>
        <div>
            <h1>SurveyPlatform - Reset password request</h1>
            <a href="{url}">Click this link to reset your password.</a>
            <p style="font-style: italic;">
                If you did not send this request, please ignore this email.
                <br/>
                Note that you can only change your password every 15 minutes.
                <br/>
            </p>
        </div>
    </body>
</html>
"""


def createUrl(token: str) -> str:
    return f"{server_url}forgot?token={token}"


class ForgottenPasswordManager:
    def __init__(self) -> None:
        self._ts: Dict[str, int] = dict()
        self._tokens: Dict[str, int] = dict()  # token: uid

    def generateToken(self, uid: int):
        token = secrets.token_urlsafe(10)
        self._tokens[token] = uid
        return token

    def verifyToken(self, uid: int, token: str) -> Optional[int]:

        u = self._tokens.get(token)
        if u is None:
            return None

        same = uid == u
        if same:
            self._tokens.pop(token)

        return uid

    def canResetForgottenPassword(self, uid: int) -> bool:
        t: int = self._ts.get(uid)
        if t is None:
            return True
        can = not ((time() - t) < RESET_INTERVAL)

        if can:
            self._ts.pop(uid)

        return can

    async def startResetUserForgottenPassword(self, value: str):
        user: User = None
        async with UserService() as service:
            user = await service.userFromUsernameOrEmail(value)
        if user is None:
            return

        can = self.canResetForgottenPassword(user.uid)
        if not can:
            return

        token = self.generateToken(user.uid)
        html = HTML.format(url=createUrl(token))

        msg = MessageSchema(
            subject="SurveyPlatform",
            recipients=[user.email],
            body=html,
            subtype="html",
        )
        fm = FastMail(EMAIL_CONF)
        await fm.send_message(msg)
        self._ts[user.uid] = time()

    async def resetUserForgottenPassword(
        self,
        token: str,
        password: str,
    ):
        uid = self._tokens.get(token)

        if uid is None:
            raise Error("Invalid reset token")

        async with UserService() as service:
            user = await service.userFromUid(uid, full=True)

            if pwd_ctx.verify(password, user.password):
                raise Error("Passwords should not match any previous passwords")

            self.verifyToken(uid, token)

            await service.setPassword(
                user.uid,
                pwd_ctx.hash(password),
            )


forgottenPasswordManager: Final[ForgottenPasswordManager] = ForgottenPasswordManager()

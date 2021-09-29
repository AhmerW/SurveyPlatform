import os
import secrets
from dataclasses import dataclass
from typing import Dict, Final, Optional
from time import time

from dotenv import load_dotenv

from fastapi_mail import ConnectionConfig
from fastapi_mail.fastmail import FastMail
from fastapi_mail.schemas import MessageSchema

from data.models import User

load_dotenv(".env")
_CONF = ConnectionConfig(
    MAIL_USERNAME="surveyplatform.mail@gmail.com",
    MAIL_PASSWORD=os.getenv("email-pass"),
    MAIL_FROM="surveyplatform.mail@gmail.com",
    MAIL_PORT=587,
    MAIL_SERVER="smtp.gmail.com",
    MAIL_TLS=True,
    MAIL_SSL=False,
    USE_CREDENTIALS=True,
    VALIDATE_CERTS=True,
)
html = """
<html>
    <title>SurveyPlatform</title>
    <body>
        <div>
            <h1>Verification Code</h1>
            <h3 style="">{code}</h3>
        </div>
    </body>
</html>
"""


@dataclass
class VerEntry:
    __slots__ = "uid", "code", "timestamp"

    uid: int
    code: str
    timestamp: int


EXPIRY_TIME = 1800  # s
SEND_BREAKS = 600  # s
NBYTES = 5


class UserRegistrator:
    def __init__(self) -> None:
        self._entries: Dict[int, VerEntry] = dict()
        self._mailts: Dict[int, int] = dict()

    def _createEntry(self, uid: int) -> None:
        _token = secrets.token_urlsafe(NBYTES).upper()
        self._entries[uid] = VerEntry(
            uid=uid,
            code=_token,
            timestamp=int(
                time(),
            ),
        )

    def _isExpired(self, uid: int) -> bool:
        entry: Optional[VerEntry] = self._entries.get(uid)

        return (
            True if entry is None else ((int(time()) - entry.timestamp) > EXPIRY_TIME)
        )

    def generate(self, uid: int) -> VerEntry:
        if self._isExpired(uid):
            self._createEntry(uid)

        return self._entries[uid]

    def isValid(self, uid: int, code: str) -> bool:
        entry: Optional[VerEntry] = self._entries.get(uid)
        if entry is None:
            return False
        print(code, entry.code)
        return (uid == entry.uid) and secrets.compare_digest(code, entry.code)

    def verify(self, uid: int, code: str) -> bool:
        result = self.isValid(uid, code)
        if result:
            self._entries.pop(uid, None)

        return result

    async def sendMail(self, user: User, entity: VerEntry):
        if user.verified:
            return False
        last = self._mailts.get(user.uid)
        if last is not None:
            if (time() - last) < SEND_BREAKS:
                return False

        else:
            self._mailts[user.uid] = time()
        msg = MessageSchema(
            subject="SurveyPlatform registrering",
            recipients=[user.email],
            body=html.format(code=entity.code),
            subtype="html",
        )
        fm = FastMail(_CONF)
        await fm.send_message(msg)
        return True


registrator: Final[UserRegistrator] = UserRegistrator()

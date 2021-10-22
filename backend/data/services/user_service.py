import secrets
from typing import Any, Dict, Optional, Union
from datetime import datetime, timedelta


from pydantic.main import BaseModel


from data.db.queries import UserQueries
from data.models import User, UserFull
from data.services.base import BaseService, StateContainer

from globals import pwd_ctx


class UserStateContainer(StateContainer):
    ...


class UserService(BaseService):
    _state = UserStateContainer()

    @classmethod
    @property
    def state(cls) -> UserStateContainer:
        return cls._state

    async def __aenter__(self) -> "UserService":
        return await super().__aenter__()

    async def createUser(self, username: str, email: str, password: str):
        await self.execute(
            UserQueries.CreateUser,
            (username, email, pwd_ctx.hash(password)),
        )

    async def _userFrom(
        self,
        query: str,
        value: Any,
        full=False,
    ) -> Optional[Union[User, UserFull]]:
        raw = await self.fetchone(query, (value,))
        if not raw:
            return None
        try:
            return UserFull(**raw) if full else User(**raw)
        except:
            return None

    async def userFromUsername(
        self,
        username: str,
        full=False,
    ) -> Optional[Union[User, UserFull]]:
        return await self._userFrom(UserQueries.FromUsername, username, full=full)

    async def userFromUid(
        self,
        uid: int,
        full=False,
    ) -> Optional[Union[User, UserFull]]:
        return await self._userFrom(UserQueries.FromUid, uid, full=full)

    async def verifyUser(self, user: User):
        user.verified = True
        await self.execute(UserQueries.UpdateVerificationState, (True, user.uid))

    async def existsAny(self, username: str, email: str) -> bool:
        raw = await self.fetchone(UserQueries.AnyExists, (username, email))
        return not (raw == None)


RESET_CODE_BYTES = 20
RESET_CODE_EXPIRE = 900


class ResetCode(BaseModel):
    code: str
    expire: int


class UserManager:
    def __init__(self) -> None:
        self._reset_codes: Dict[int, ResetCode] = dict()  # uid : code

    def generateCode(self, uid: int) -> str:
        code = secrets.token_urlsafe(RESET_CODE_BYTES)
        self._reset_codes[uid] = ResetCode(
            code=code,
            expire=(datetime.now() + timedelta(seconds=RESET_CODE_EXPIRE)).timestamp,
        )

    def checkCode(self, uid: int, code: str) -> bool:
        rc = self._reset_codes.get(uid)
        if rc is None:
            return False

        if (datetime.now().timestamp - rc.expire) > RESET_CODE_EXPIRE:
            del self._reset_codes[uid]
            return False

        valid = code == rc.code
        if valid:
            del self._reset_codes[uid]

        return valid


userManager = UserManager()

from datetime import datetime, timedelta
from os import replace
from typing import Optional

from fastapi.param_functions import Depends
from fastapi.security import OAuth2PasswordBearer


from jose import jwt
from starlette.requests import Request


from data.models import User, UserFull
from data.services.user_service import UserService

from globals import SECRET, pwd_ctx, admins, owners
from responses import Error

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")
optional_oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token", auto_error=False)
credentials_exception = Error("Invalid credentials")


async def getUser(token: str = Depends(oauth2_scheme)) -> User:
    print(token)
    payload = decodeToken(
        token,
        default=dict(),
    )
    if payload is None or payload.get("sub") is None:
        raise credentials_exception

    user: User = None
    async with UserService() as service:

        user = await service.userFromUsername(payload.get("sub"))

    if user is None:
        raise credentials_exception

    user.admin = user.username in admins
    user.owner = user.username in owners

    return user


async def optionalUser(token: str = Depends(optional_oauth2_scheme)) -> Optional[User]:
    if token is None:
        return None
    return await getUser(token)


async def getVerifiedUser(
    token: str = Depends(oauth2_scheme),
) -> Optional[User]:
    user = await getUser(token)
    if not user.verified:
        raise credentials_exception

    return user


async def getAdmin(
    token: str = Depends(oauth2_scheme),
) -> Optional[User]:
    user = await getUser(token)
    if not user.admin:
        raise credentials_exception

    return user


async def verifyUser(username: str, password: str) -> Optional[User]:
    user: UserFull = None
    async with UserService() as service:
        user = await service.userFromUsername(username, full=True)
    if not isinstance(user, UserFull):
        return None
    return (
        None
        if not pwd_ctx.verify(password, user.password)
        else User(
            **user.dict(),
        )
    )


# token stuff


def decodeToken(
    token: str,
    key=SECRET,
    algorithms=[
        "HS256",
    ],
    default=None,
):
    try:
        return jwt.decode(token, key, algorithms=algorithms)
    except jwt.JWTError:
        pass

    return default


def createToken(
    subject: str,
    expires_delta: timedelta = timedelta(minutes=60),
    access_token: str = None,
    claims: dict = {},
) -> str:
    expire = datetime.utcnow() + expires_delta
    data = {"sub": subject, "exp": expire, **claims}
    return jwt.encode(
        data,
        SECRET,
        access_token=access_token,
        algorithm="HS256",
    )

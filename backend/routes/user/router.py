from typing import Optional
from fastapi import APIRouter
from fastapi.param_functions import Depends, Form
from fastapi.security import OAuth2PasswordRequestForm

from email_validator import validate_email as _validateEmail
from email_validator import EmailNotValidError
from pydantic.main import BaseModel

from responses import Error, BaseResponse, Success

from auth.jwt import getUser
from data.models import User
from data.services.user_service import UserService
from routes.user import registrator as _registrator_module
from routes.user.registrator import registrator

router = APIRouter()


@router.get("/")
async def _getUser(
    uid: Optional[int] = None,
    user: Optional[User] = Depends(getUser),
):
    if uid is None and user is None:
        raise Error()

    if user:
        return Success(dict(user))

    async with UserService() as service:
        user = await service.userFromUid(uid)

    return Success(dict(user))


def checkEmailError(email: str) -> Optional[str]:
    try:
        _validateEmail(email)
    except EmailNotValidError as error:
        return str(error)


@router.post(
    "/",
    response_class=BaseResponse,
)
async def registerUser(
    form: OAuth2PasswordRequestForm = Depends(),
    email: str = Form(...),
):
    username: str = form.username
    password: str = form.password

    if len(username) >= 20:
        raise Error("Username length must be less than 20 characaters.")

    if len(password) >= 71:
        raise Error(
            "Please keep the length of the password to less than 70 characters."
        )

    email_err = checkEmailError(email)
    if not email_err is None:
        raise Error(email_err)

    async with UserService() as service:
        if await service.existsAny(username, email):
            raise Error(
                "Username or email already exists",
            )

        await service.createUser(username, email, password)

    return Success(detail="Account has been registered.")


class VerificationModel(BaseModel):
    code: str


@router.get("/verification")
async def generateVer(user: User = Depends(getUser)):

    if user.verified:
        return Success(detail="User already verified.")

    entity = registrator.generate(user.uid)
    result = await registrator.sendMail(user, entity)
    return Success(detail=("Email sent." if result else "Email already sent."))


@router.post("/verification")
async def verifyUser(
    model: VerificationModel,
    user: User = Depends(getUser),
):
    if user.verified:
        return Success(detail="User already verified")

    result = registrator.verify(user.uid, model.code)
    if not result:
        raise Error(
            "There was an error while attempting to verify you. Double check the verification-code."
        )

    async with UserService() as service:
        await service.verifyUser(user)

    return Success(detail="Account verified!")

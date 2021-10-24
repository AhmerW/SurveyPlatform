from fastapi import APIRouter
from fastapi.param_functions import Depends
from fastapi.security.oauth2 import OAuth2PasswordRequestForm


from auth.jwt import (
    createToken,
    getUser,
    getVerifiedUser,
    verifyUser,
    credentials_exception,
)
from data.models import User, ValueModel
from globals import app
from responses import BaseResponse, Success


router = APIRouter()

UserValueModel = ValueModel.new(user=(User, ...))
TokenValueModel = ValueModel.new(token=(str, ...))


class TokenResponse(BaseResponse):
    data: TokenValueModel


@router.post(
    "/",
    response_model=TokenResponse,
)
async def authLogin(
    form: OAuth2PasswordRequestForm = Depends(),
):
    user = await verifyUser(form.username, form.password)

    if user is None:
        raise credentials_exception

    return TokenResponse(data=TokenValueModel(token=createToken(user.username)))


class UserResponse(BaseResponse):
    data: UserValueModel


@router.get(
    "/",
    response_model=UserResponse,
)
async def authenticatedRoute(user: User = Depends(getUser)):
    print(user)
    return UserResponse(data=UserValueModel(user=user))

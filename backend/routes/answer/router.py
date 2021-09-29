from typing import Generic, List, Optional
from fastapi import APIRouter
from fastapi.params import Depends
from pydantic.generics import GenericModel
from pydantic.main import BaseModel
from data.services.answer_service import AnswerService

from responses import BaseResponse, Error, Success

from auth.jwt import getAdmin, getUser, optionalUser

from data.models import (
    OptionalSurveyID,
    QuestionOut,
    Survey,
    SurveyAnswerIn,
    SurveyIn,
    SurveyOut,
    User,
    ValueModel,
)
from data.services.survey_service import SurveyService
from routes.auth import authLogin

router = APIRouter()


@router.post("/")
async def postAnswer(
    answer: SurveyAnswerIn,
    user: User = Depends(getUser),
):
    print(user)
    async with AnswerService() as service:
        survey_exists = await service.existsSurvey(answer.survey_id)
        if not survey_exists:
            raise Error("Survey does not exist")

        exists = await service.existsAnswer(answer.survey_id, user.uid)
        if exists is not None:
            raise Error("You have already answered this survey.")

    return Success()


ExistsValueModel = ValueModel.new(exists=(bool, ...))


class ExistsModel(BaseResponse):
    data: ExistsValueModel


@router.get("/")
async def getAnswer(
    survey: int,
    user: User = Depends(getUser),
):
    print(user)
    exists = False
    async with AnswerService() as service:
        exists = bool(
            await service.existsAnswer(
                survey,
                user.uid,
            )
        )

    return Success(dict(exists=exists))

from typing import Generic, List, Optional, Union
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
    SurveyAnswerOut,
    SurveyIn,
    SurveyOut,
    User,
    ValueModel,
)
from data.services.survey_service import SurveyService
from routes.auth import authLogin

router = APIRouter()

AnswerValueModel = ValueModel.new(
    answers=(
        Union[SurveyAnswerOut, List[SurveyAnswerOut]],
        ...,
    )
)


class AnswerResponse(BaseResponse):
    data: AnswerValueModel


@router.get(
    "/{survey_id}/answers",
    response_model=AnswerResponse,
)
async def getAnswers(
    survey_id: int,
    page: Optional[int] = None,
    user: User = Depends(getAdmin),
):
    answers: Union[SurveyAnswerOut, List[SurveyAnswerOut]] = list()

    async with AnswerService() as service:

        answers = await service.getAnswers(survey_id, page)

    return AnswerResponse(data=AnswerValueModel(answers=answers))


@router.get("/{survey_id}/answered")
async def isAnswered(
    survey_id: int,
    user: User = Depends(getUser),
):
    answered: bool = False
    async with AnswerService() as service:
        answered = await service.userHasAnswered(survey_id, user.uid)

    return Success(dict(answered=answered))


@router.post("/{survey_id}/answers/")
async def postAnswer(
    survey_id: int,
    answer: SurveyAnswerIn,
    user: Optional[User] = Depends(optionalUser),
):
    print(user)

    async with AnswerService() as service:
        await service.submitAnswer(
            survey_id,
            answer,
            None if user is None else user.uid,
        )

    return Success()

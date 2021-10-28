from typing import Any, Generic, List, Optional, Union
from enum import Enum, auto

from fastapi import APIRouter
from fastapi.params import Depends
from fastapi.responses import FileResponse, Response

from pydantic.generics import GenericModel
from pydantic.main import BaseModel
from auth.captcha_service import requireSolvedCaptcha
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


class SurveyAnswersFormat(Enum):
    json = "json"
    csv = "csv"


@router.get(
    "/{survey_id}/answers/",
)
async def getAnswers(
    survey_id: int,
    page: Optional[int] = None,
    format: SurveyAnswersFormat = SurveyAnswersFormat.json,
):
    answers: Union[SurveyAnswerOut, List[SurveyAnswerOut]] = list()
    response = dict()
    path: str = None
    media_type = "text/json"
    file_format = "json"

    async with AnswerService() as service:
        await service.getSurvey(survey_id)

        if format == SurveyAnswersFormat.csv:
            response = await service.getRawAnswers(survey_id, page)
        else:
            answers = await service.getAnswers(survey_id, page)
            response = AnswerResponse(data=AnswerValueModel(answers=answers))

    if format == SurveyAnswersFormat.csv:
        path = await service.answersAsCSV(survey_id, response)
        media_type = "text/csv"
        file_format = "csv"

    else:
        path = await service.saveAnswersAsJson(
            survey_id,
            response.data.dict(),
        )

    if not path:
        raise Error("Not saved")

    return FileResponse(
        path,
        media_type=media_type,
        filename=f"{survey_id}_answers.{file_format}",
    )


@router.get("/{survey_id}/answered")
async def isAnswered(
    survey_id: int,
    user: User = Depends(getUser),
):
    answered: bool = False
    async with AnswerService() as service:
        answered = await service.userHasAnswered(survey_id, user.uid)

    return Success(dict(answered=answered))


@router.post(
    "/{survey_id}/answers/",
    dependencies=[
        Depends(requireSolvedCaptcha),
    ],
)
async def postAnswer(
    survey_id: int,
    answer: SurveyAnswerIn,
    user: Optional[User] = Depends(optionalUser),
):

    async with AnswerService() as service:
        await service.submitAnswer(
            survey_id,
            answer,
            None if user is None else user.uid,
        )

    return Success()

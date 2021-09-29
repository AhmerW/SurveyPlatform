from typing import Generic, List, Optional
from fastapi import APIRouter
from fastapi.params import Depends
from pydantic.generics import GenericModel
from pydantic.main import BaseModel

from responses import BaseResponse, Error, Success

from auth.jwt import getAdmin, getUser

from data.models import (
    OptionalSurveyID,
    QuestionOut,
    Survey,
    SurveyIn,
    SurveyOut,
    User,
    ValueModel,
)
from data.services.survey_service import SurveyService
from routes.auth import authLogin

router = APIRouter()


SurveyValueModel = ValueModel.new(surveys=(List[SurveyOut], ...))


class SurveyResponse(BaseResponse):
    data: SurveyValueModel


@router.get(
    "/",
    response_model=SurveyResponse,
)
async def getSurveys(page: int = 1):
    surveys: List[SurveyOut] = list()

    async with SurveyService() as service:
        surveys = await service.getSurveys(page)

    return SurveyResponse(data=SurveyValueModel(surveys=surveys))


@router.post("/")
async def createSurvey(
    survey: OptionalSurveyID,
    _: User = Depends(getAdmin),
) -> None:

    async with SurveyService() as service:
        if survey.survey_id is None:
            so = await service.createSurvey(survey)
        else:
            await service.updateSurvey(survey)
            return Success(
                detail="If there is a survey with that ID, it has been updated."
            )

    if not so:
        raise Error("Invalid survey data")

    return Success(dict(id=so.survey_id))


@router.delete(
    "/",
)
async def deleteSurvey(
    surveyid: int,
    user: User = Depends(getAdmin),
):
    async with SurveyService() as service:
        await service.delete(surveyid)

    return Success(detail="If there was a survey with that id, it has been deleted.")

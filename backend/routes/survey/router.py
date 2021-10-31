from typing import Generic, List, Optional, Union
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
from routes.survey.answer.router import router as answer_router

router = APIRouter()


SurveyValueModel = ValueModel.new(surveys=(Union[List[SurveyOut], SurveyOut], ...))
OptionalSurveyIDValueModel = ValueModel.new(survey=(OptionalSurveyID, ...))


class OptionalSurveyIDResponse(BaseResponse):
    data: OptionalSurveyIDValueModel


class SurveyResponse(BaseResponse):
    data: SurveyValueModel


@router.get(
    "/{surveyid}",
    response_model=SurveyResponse,
)
@router.get(
    "/{surveyid}/",
    response_model=SurveyResponse,
)
@router.get(
    "/",
    response_model=SurveyResponse,
)
async def getSurveys(
    surveyid: int = None,
    page: int = 1,
):
    surveys: Union[List[SurveyOut], SurveyOut] = list()

    async with SurveyService() as service:
        if surveyid is not None:
            surveys = await service.getSurvey(surveyid)
            if surveys is None:
                raise Error("Survey not found")
        else:
            surveys = await service.getSurveys(page)

    return SurveyResponse(data=SurveyValueModel(surveys=surveys))


@router.post(
    "/",
    response_model=OptionalSurveyIDResponse,
)
async def createSurvey(
    survey: OptionalSurveyID,
    _: User = Depends(getAdmin),
) -> None:

    async with SurveyService() as service:
        if survey.survey_id is None:
            so = await service.createSurvey(survey)
        else:
            await service.updateSurvey(survey)
            return OptionalSurveyIDResponse(
                data=OptionalSurveyIDValueModel(survey=survey),
                detail="If there was a survey with that ID, it has been updated.",
            )

    if not so:
        raise Error("Invalid survey data")

    return OptionalSurveyIDResponse(data=OptionalSurveyIDValueModel(survey=so))


@router.delete(
    "/{survey_id}",
)
async def deleteSurvey(
    survey_id: int,
    user: User = Depends(getAdmin),
):
    async with SurveyService() as service:
        await service.delete(survey_id)

    return Success(detail="If there was a survey with that id, it has been deleted.")


@router.patch("/{survey_id}")
async def patchSurvey(survey_id: int, user: User = Depends(getAdmin)):
    pass


router.include_router(answer_router)

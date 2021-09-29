from typing import List
from fastapi import APIRouter
from fastapi.params import Depends
from auth.jwt import getAdmin

from data.models import Survey, SurveyIn, SurveyOut, User
from data.services.survey_service import SurveyService
from routes.survey.router import SurveyResponse, SurveyValueModel

# prefix : drafts
router = APIRouter()


# authenticated route for fetching surveys
@router.get(
    "/",
    response_model=SurveyResponse,
)
async def getSurveys(
    page: int = 1,
    _: User = Depends(getAdmin),
):

    surveys: List[SurveyOut] = list()

    async with SurveyService() as service:
        surveys = await service.getSurveyDrafts(page)

    return SurveyResponse(data=SurveyValueModel(surveys=surveys))

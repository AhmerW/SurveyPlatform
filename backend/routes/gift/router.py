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


@router.get("/")
async def getGifts():
    pass

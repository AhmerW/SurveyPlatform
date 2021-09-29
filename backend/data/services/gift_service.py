from time import time

from data.db.queries import AnswerQueries, SurveyQueries
from data.services.base import BaseService
from data.models import Gift, SurveyAnswer, SurveyAnswerIn, SurveyAnswerOut
from data.services.survey_service import SurveyService


class GiftService(BaseService):
    async def __aenter__(self) -> "GiftService":
        return await super().__aenter__()

    async def createGift(self, gift: Gift):
        pass

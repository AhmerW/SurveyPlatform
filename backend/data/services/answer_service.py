from time import time

from data.db.queries import AnswerQueries, SurveyQueries
from data.services.base import BaseService
from data.models import SurveyAnswer, SurveyAnswerIn, SurveyAnswerOut, SurveyOut
from data.services.survey_service import SurveyService
from responses import Error


class AnswerService(BaseService):
    async def __aenter__(self) -> "AnswerService":
        return await super().__aenter__()

    async def validateAnswer(self, answer: SurveyAnswer, survey: SurveyOut):

        answer_ids = {a.question_id for a in answer.answers}
        for question in survey.questions:
            if question.mandatory:
                if not question.question_id in answer_ids:
                    raise Error(f"{question.question_id} not answered!")

    async def submitAnswer(self, answer: SurveyAnswer, uid: int = None) -> int:
        answer_id: int = await self.fetch(
            AnswerQueries.SubmitAnswer, (uid, answer.survey_id, int(time()))
        )

        query_values = [
            (
                qa.question_id,
                answer_id,
                qa.value,
            )
            for qa in answer.answers
        ]
        self.executemany(AnswerQueries.SubmitQuestionAnswer, query_values)

        return answer_id

    async def existsAnswer(self, survey_id: int, uid: int):
        response = await self.execute(AnswerQueries.GetUserAnswer, (survey_id, uid))
        row = await response.fetchone()
        return row

    async def existsSurvey(self, survey_id: int):
        service = SurveyService(self.con)
        return (await service.getSurvey(survey_id)) is not None

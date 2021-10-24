from typing import Dict, Final, List, Optional
from dataclasses import dataclass, field
import json


from data.db.queries import QuestionQueries, SurveyQueries
from data.services.base import BaseService, BaseServiceFactory, StateContainer
from data.models import OptionalSurveyID, QuestionOut, Survey, SurveyIn, SurveyOut
from data.services.pagination import getOffsetLimitFromPage, page_count, paginateList
from data.services.question_service import questionFromDict
from responses import Error


@dataclass
class SurveyStateContainer(StateContainer):
    _surveys: List[SurveyOut] = field(default_factory=list)
    _drafts: List[SurveyOut] = field(default_factory=list)


class SurveyService(BaseService):
    _state = SurveyStateContainer()

    def __init__(self, *args, **kwargs) -> None:
        super().__init__(*args, **kwargs)

    @classmethod
    @property
    def state(cls) -> SurveyStateContainer:
        return super().state

    async def __aenter__(self) -> "SurveyService":
        return await super().__aenter__()

    async def _insertSurveyRecord(self, survey: Survey) -> Optional[SurveyOut]:

        survey_out_id = await self.fetch(
            SurveyQueries.CreateSurvey,
            (
                survey.title,
                survey.pages,
                survey.points,
                survey.duration,
                survey.draft,
            ),
        )

        if not survey_out_id:
            return None

        query_values = [
            (
                survey_out_id,
                question.text,
                question.widget,
                json.dumps(question.widget_values),
                question.position,
            )
            for question in survey.questions
        ]
        await self.executemany(QuestionQueries.CreateQuestion, query_values)

        survey_out = survey.copy()
        survey_out.questions = await self.getSurveyQuestions(survey_out_id)
        survey_d = dict(survey_out)
        survey_d["survey_id"] = survey_out_id

        return SurveyOut(**survey_d)

    async def delete(self, survey_id: int):
        deleted = False

        for i, survey in enumerate(self.state._surveys):
            if survey.survey_id == survey_id:
                self.state._surveys.pop(i)
                deleted = True

        if not deleted:
            for i, draft in enumerate(self.state._drafts):
                if draft.survey_id == survey_id:
                    self.state._surveys.pop(i)
                    deleted = True

        if (not deleted) and self.state._surveys:
            raise Error("Survey does not exist")

        await self.execute(SurveyQueries.DeleteWhereId, (survey_id,))

    async def getSurveyQuestions(self, survey_id: int) -> List[QuestionOut]:
        questions = await self.fetchall(
            QuestionQueries.GetAllQuestionsWithSurveyId,
            (survey_id,),
        )

        return [questionFromDict(question) for question in questions]

    async def getSurvey(self, survey_id: int) -> Optional[Survey]:
        await self.getSurveys()

        surveys = [
            survey for survey in self.state._surveys if survey.survey_id == survey_id
        ]
        if not surveys:
            return None

        return surveys[0]

    async def createSurvey(self, survey: SurveyIn) -> Optional[SurveyOut]:
        so: SurveyOut = await self._insertSurveyRecord(survey)

        if not so:
            return None

        self.state._surveys.append(so)
        return so

    async def updateSurvey(self, survey: OptionalSurveyID):
        if survey.survey_id is not None:
            await self.execute(
                SurveyQueries.UpdateSurvey,
                (
                    survey.title,
                    survey.pages,
                    survey.points,
                    survey.duration,
                    survey.draft,
                    survey.survey_id,
                ),
            )

    async def getSurveys(
        self,
        page: int = 1,
    ) -> List[Survey]:

        if not self.state._surveys:
            await self.refreshSurveysCache(
                attr="_surveys",
                query=SurveyQueries.GetAllVisibleSurveys,
            )

        return paginateList(self.state._surveys, page)

    async def getSurveyDrafts(
        self,
        page: int = 1,
    ) -> List[Survey]:

        if not self.state._drafts:
            await self.refreshSurveysCache(
                attr="_drafts",
                query=SurveyQueries.GetAllSurveyDrafts,
            )

        return paginateList(self.state._drafts, page)

    async def refreshSurveysCache(
        self,
        attr: str,
        query: str,
    ):
        # Refreshes self.state._surveys

        records = await self.fetchall(query)
        surveys: Dict[int, SurveyOut] = dict()
        for record in records:
            # transform
            survey = SurveyOut(**{"questions": list(), **record})
            record["widget_values"] = {}
            question = QuestionOut(**{"text": record["question_text"], **record})

            if not surveys.get(survey.survey_id):
                surveys[survey.survey_id] = survey
            surveys[survey.survey_id].questions.append(question)

        if attr == "_surveys":
            self.state._surveys = list(surveys.values())
        else:
            self.state._drafts = list(surveys.values())


# ..Singleton services (one con per service), experimental
class SurveyServiceFactory(BaseServiceFactory):
    ...


surveyServiceFactory: Final[SurveyServiceFactory] = SurveyServiceFactory(SurveyService)

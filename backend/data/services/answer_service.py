import os
import json
from time import time
from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional

import pandas

from data.db.queries import AnswerQueries, SurveyQueries
from data.services.base import BaseService, StateContainer
from data.models import (
    QuestionAnswer,
    SurveyAnswer,
    SurveyAnswerIn,
    SurveyAnswerOut,
    SurveyOut,
    User,
)
from data.services.pagination import paginateList
from data.services.survey_service import SurveyService
from data.services.user_service import UserService
from responses import Error


@dataclass
class AnswerStateContainer(StateContainer):
    _answers: Dict[int, List[int]] = field(default_factory=dict)  # survey_id: List[uid]


class AnswerService(BaseService):
    _state = AnswerStateContainer()

    async def __aenter__(self) -> "AnswerService":
        return await super().__aenter__()

    @classmethod
    @property
    def state(cls) -> AnswerStateContainer:
        return super().state

    async def getAnswers(
        self,
        survey_id: int,
        page: int = None,
    ) -> List[SurveyAnswerOut]:
        records = await self.fetchall(AnswerQueries.GetSurveyAnswers, (survey_id,))

        aqs: Dict[int, List[QuestionAnswer]] = {}
        answers: Dict[int, SurveyAnswerOut] = {}

        for record in records:
            qa = QuestionAnswer(**record)
            answer = SurveyAnswerOut(**record, answers=list())

            if not answer.answer_id in answers:
                answers[answer.answer_id] = answer

            if not answer.answer_id in aqs:
                aqs[answer.answer_id] = [qa]
                continue

            aqs[answer.answer_id].append(qa)

        final = {}

        for answer_id, answer in answers.items():
            a = SurveyAnswerOut(**dict(answer))
            a.answers = aqs.get(answer_id, list())
            if final.get(answer.survey_id):
                final[answer.survey_id].append(a)

            else:
                final[answer.survey_id] = [a]

        answers = final.get(survey_id, list())
        if page is None:
            return answers

        return paginateList(
            answers,
            page=page,
        )

    async def getRawAnswers(
        self,
        survey_id: int,
        page: int = None,
    ) -> List[Dict[Any, Any]]:
        records = await self.fetchall(AnswerQueries.GetSurveyAnswers, (survey_id,))
        if page is None:
            return records

        return paginateList(records, page)

    async def answersAsCSV(
        self,
        survey_id: int,
        answers: Dict[Any, Any],
    ):
        df = pandas.json_normalize(answers)
        path = os.path.join("data", "raw", "answers", f"{survey_id}.csv")
        df.to_csv(path)
        return path

    async def saveAnswersAsJson(
        self,
        survey_id: int,
        answers: Dict[Any, Any],
    ):

        path = os.path.join("data", "raw", "answers", f"{survey_id}.json")
        with open(path, "w+") as f:
            json.dump(
                answers,
                f,
                indent=4,
            )

        return path

    async def userHasAnswered(
        self,
        survey_id: int,
        uid: int,
    ) -> bool:
        if uid in self.state._answers.get(survey_id, list()):
            return True

        record = await self.fetchone(AnswerQueries.GetUserAnswer, (survey_id, uid))

        if not record:
            return False

        if not survey_id in self.state._answers:
            self.state._answers[survey_id] = [uid]
        else:
            self.state._answers[survey_id].append(uid)

        return True

    def validateAnswer(
        self,
        answer: SurveyAnswer,
        survey: SurveyOut,
    ):

        answer_ids = {a.question_id for a in answer.answers}
        answers = {a.question_id: a for a in answer.answers}
        for i, question in enumerate(survey.questions):
            not_answered = Error(
                f"Question {i+1} not answered! (ID: {question.question_id})"
            )

            if not question.mandatory:
                continue

            if not question.question_id in answer_ids:
                raise not_answered

            a = answers.get(question.question_id)

            if not a.value:
                raise not_answered

            _min, _max = question.widget_values.get(
                "minChars"
            ), question.widget_values.get(
                "maxChars",
            )

            if isinstance(_min, int) and len(a.value) < _min:
                raise Error(f"Minimum length: {_min}")

            if isinstance(_max, int) and len(a.value) > _max:
                raise Error(f"Maximum length: {_max}")

            _minV, _maxV = question.widget_values.get(
                "minValue", 0
            ), question.widget_values.get(
                "maxValue",
            )
            if a.value.isdigit():
                try:
                    v = int(a.value)
                    if v < _minV:
                        raise Error(f"Minimum value {_minV}")

                    if isinstance(_maxV, int) and v > _maxV:
                        raise Error(f"Maximum value {_maxV}")

                except ValueError:
                    raise Error("Invalid value type")

    async def insertAnswer(
        self,
        survey_id,
        answer: SurveyAnswer,
        uid: int = None,
    ) -> SurveyAnswerOut:

        answer_id: int = await self.fetch(
            AnswerQueries.SubmitAnswer,
            (
                uid,
                survey_id,
                int(time()),
            ),
        )

        query_values = [
            (
                qa.question_id,
                answer_id,
                qa.value,
            )
            for qa in answer.answers
        ]
        await self.executemany(AnswerQueries.SubmitQuestionAnswer, query_values)

        sao = SurveyAnswerOut(
            **dict(answer),
            answer_id=answer_id,
            uid=uid,
            timestamp=time(),
            survey_id=survey_id,
        )
        if not survey_id in self.state._answers:
            self.state._answers[survey_id] = [uid]
        else:
            self.state._answers[survey_id].append(uid)
        return sao

    async def submitAnswer(
        self,
        survey_id: int,
        answer: SurveyAnswer,
        uid: Optional[int] = None,
    ) -> SurveyAnswerOut:

        survey = await self.getSurvey(survey_id)

        self.validateAnswer(answer, survey)
        if uid is not None:
            existing = await self.userHasAnswered(
                survey_id,
                uid,
            )
            if existing:
                raise Error("You have already answered this survey.")

        sao: SurveyAnswerOut = await self.insertAnswer(
            survey_id,
            answer,
            uid,
        )
        if sao:
            us = UserService(await self.con)
            await us.incrementPoints(uid, survey.points)

        return sao

    async def getSurvey(self, survey_id: int) -> SurveyOut:
        ss = SurveyService(await self.con)
        survey = await ss.getSurvey(survey_id)
        if not survey:
            raise Error("Survey does not exist")

        return survey

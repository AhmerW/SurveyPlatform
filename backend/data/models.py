from enum import Enum
from typing import Any, Dict, Generic, List, Optional, T, TypeVar

from pydantic import BaseModel, create_model
from pydantic.generics import GenericModel


# General


class ValueModel(BaseModel):
    @classmethod
    def new(cls, **fields) -> "ValueModel":
        return create_model("ValueModel", __base__=cls, **fields)


# User


class User(BaseModel):
    uid: Optional[int] = None
    points: Optional[int] = 0
    username: str
    email: str
    verified: bool
    admin: bool = False  # can create surveys, etc
    owner: bool = False  # all perms


class UserFull(User):
    password: str


# Questions


class QuestionWidget(Enum):
    RatingScale = "RatingScale"  # Likert scale
    MultipleChoice = "MultipleChoice"
    Dropdown = "Dropdown"
    OpenEnded = "OpenEnded"
    Ranking = "Ranking"
    Slider = "Slider"


class QuestionIn(BaseModel):
    text: str
    widget_values: Optional[Dict[str, Any]] = {}
    widget: QuestionWidget
    page: int = 1
    position: int
    mandatory: bool = True

    class Config:
        use_enum_values = True


class QuestionOut(QuestionIn):
    question_id: int


Question = QuestionIn

# Surveys


class SurveyIn(BaseModel):
    questions: List[QuestionIn]
    title: str
    duration: Optional[int] = None
    pages: int = 1
    points: int = 0
    draft: bool = False


class SurveyOut(SurveyIn):
    survey_id: int
    questions: List[QuestionOut]


class OptionalSurveyID(SurveyIn):
    survey_id: Optional[int]


Survey = SurveyIn

# Answers


class QuestionAnswer(BaseModel):
    question_id: int
    value: str


# Survey Answer


class SurveyAnswerIn(BaseModel):

    answers: List[QuestionAnswer]


class SurveyAnswerOut(SurveyAnswerIn):
    survey_id: int
    answer_id: int
    timestamp: int
    uid: Optional[int] = None


SurveyAnswer = SurveyAnswerIn


# Gift


class Gift(BaseModel):
    price: int
    title: str
    description: Optional[str]


class GiftOut(Gift):
    uid: int  # created by
    gift_id: int
    item_count: Optional[int] = 0


class Item(BaseModel):
    value: str


class ItemOut(Item):
    gift_id: int
    item_id: int
    claimed: Optional[bool] = False
    claimed_by: Optional[int] = None

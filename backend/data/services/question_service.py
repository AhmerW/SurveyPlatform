import json
from data.services.base import BaseService
from data.models import QuestionOut


class QuestionService(BaseService):
    async def __aenter__(self) -> "QuestionService":
        return await super().__aenter__()


def questionFromDict(data: dict, cls=QuestionOut):
    return cls(
        **{
            "text": data["question_text"],
            "widget_values": json.loads(data.pop("widget_values")),
            **data,
        }
    )

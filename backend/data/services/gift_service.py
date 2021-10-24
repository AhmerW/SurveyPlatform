from enum import IntFlag
from time import time
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass, field

from starlette.background import BackgroundTask, BackgroundTasks

from data.db.queries import AnswerQueries, GiftQueries, SurveyQueries
from data.services.base import BaseService, StateContainer
from data.models import (
    Gift,
    GiftOut,
    Item,
    ItemOut,
    SurveyAnswer,
    SurveyAnswerIn,
    SurveyAnswerOut,
    User,
)
from data.services.gift_service_impl import (
    _GiftItemServiceImplementation,
    _GiftServiceImplementation,
)
from data.services.pagination import paginateList

from responses import Error


@dataclass
class _GiftItemStateContainer(StateContainer):
    _updated: bool = False
    _items: Dict[int, List[ItemOut]] = field(default_factory=dict)
    _claimed: Dict[int, List[ItemOut]] = field(default_factory=dict)


class _GiftItemService(_GiftItemServiceImplementation):
    _state = _GiftItemStateContainer()

    def __init__(
        self,
        gift_service: "GiftService",
        *args,
        **kwargs,
    ) -> None:
        self._giftsrvc = gift_service
        super().__init__(*args, **kwargs)

    async def __aenter__(self) -> "_GiftItemService":
        return await super().__aenter__()

    @classmethod
    @property
    def state(cls) -> _GiftItemStateContainer:
        return super().state


@dataclass()
class GiftStateContainer(StateContainer):
    _gifts: List[Gift] = field(default_factory=list)


class GiftService(_GiftServiceImplementation):
    _state = GiftStateContainer()

    def __init__(self, *args, **kwargs) -> None:
        super().__init__(*args, **kwargs)

        self._item_service: _GiftItemService = None
        self.state._updated = False

    @property
    def itemService(self) -> _GiftItemService:
        return self._item_service

    @classmethod
    @property
    def state(cls) -> GiftStateContainer:
        return super().state

    async def __aenter__(self) -> "GiftService":
        await super().__aenter__()

        self._item_service = _GiftItemService(
            self,
            con=self._con,
        )
        return self

    async def __aexit__(self, *_, **__) -> None:
        return await super().__aexit__(*_, *__)

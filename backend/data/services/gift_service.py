from enum import IntFlag
from time import time
from typing import Dict, List, Optional, Tuple
import random

from starlette.background import BackgroundTask, BackgroundTasks

from data.db.queries import AnswerQueries, GiftQueries, SurveyQueries
from data.services.base import BaseService
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
from data.services.pagination import paginateList
from data.services.survey_service import SurveyService
from responses import Error

_PRCHS_GIFT_NOT_EXISTS = Error(msg="Purchase failed. This gift does not exist")


class _GiftItemService(BaseService):
    def __init__(self, gift_serivce: "GiftService", *args, **kwargs) -> None:
        self._giftsrvc = gift_serivce
        super().__init__(*args, **kwargs)

        self._items: Dict[int, List[ItemOut]] = dict()
        self._claimed: Dict[int, List[ItemOut]] = dict()
        self._updated = False

    async def __aenter__(self) -> "_GiftItemService":
        return await super().__aenter__()

    async def ensureUpdated(self, gift_id: int):
        if not self._updated:
            self._updated = True
            await self._updateGiftItems(gift_id)

    async def _updateGiftItems(self, gift_id: int):
        _items = await self.fetchall(GiftQueries.GetGiftItems, (gift_id,))
        items = [ItemOut(**item) for item in _items]
        for item in items:
            self.appendItem(
                item,
                self._claimed if item.claimed else self._items,
            )

    async def _updateUnclaimedItems(self, gift_id: int):
        _items = await self.fetchall(GiftQueries.GetClaimedGiftItems, (gift_id,))
        items = [ItemOut(**item) for item in _items]
        for item in items:
            self.appendItem(
                item,
                unclaimed=True,
            )

    def appendItem(self, item: ItemOut, d: Dict):

        if d.get(item.gift_id) is None:
            d[item.gift_id] = [item]
            return

        d[item.gift_id].append(item)

    async def addItem(self, gift_id: int, item: Item):
        gift: GiftOut = await self._giftsrvc.getGift(gift_id)
        if gift is None:
            raise Error(msg="Gift does not exist")

        item_id = await self.fetch(GiftQueries.AddGiftItem, (gift_id, item.value))
        io = ItemOut(**dict(gift_id=gift_id, item_id=item_id, **dict(item)))
        return io

    async def _baseClaimItem(self, user: User, gift_id: int):
        gift: GiftOut = await self._giftsrvc.getGift(gift_id)
        if gift is None:
            raise _PRCHS_GIFT_NOT_EXISTS

        if gift.price > user.points:
            raise Error(msg="Purchase failed. Don't have enough points.")

        await self.ensureUpdated(gift_id)

    async def claimItem(
        self,
        user: User,
        item_id: int,
        gift_id: int,
    ) -> ItemOut:

        await self._baseClaimItem(
            user,
            gift_id,
        )
        item: Optional[ItemOut] = None

        for i, _item in enumerate(self._items[gift_id]):
            if _item.item_id == item_id:
                self._items[gift_id].pop(i)
                item = _item
                break

        if item is None:
            raise Error(msg="Purchase failed. Item does not eixst")

        await self.execute(GiftQueries.ClaimGiftItem, (user.uid, item_id))
        item.claimed = True
        item.claimed_by = user.uid
        self._claimed[gift_id].append(item)
        return item

    async def claimAnyItem(
        self,
        user: User,
        gift_id: int,
    ) -> ItemOut:
        await self._baseClaimItem(user, gift_id)

        items = self._items.get(gift_id)
        if not items:
            raise Error(msg="Purchase failed. No available items.")

        item = random.choice(items)
        for i, _item in enumerate(self._items[gift_id]):
            if _item.item_id == item.item_id:
                self._items[gift_id].pop(i)

        item.claimed_by = user.uid
        item.claimed = True

        await self.execute(GiftQueries.ClaimGiftItem, (user.uid, item.item_id))
        self._claimed[gift_id].append(item)
        return item

    async def getItems(
        self,
        gift_id: int,
        page: int = 1,
    ) -> List[ItemOut]:

        await self.ensureUpdated(gift_id)
        items = self._items.get(gift_id)

        if not gift_id in self._items:
            raise Error(msg="Gift does not exist")

        if page is None:
            return items

        return paginateList(
            items,
            page,
        )

    async def getAllItems(self, gift_id: int, page: int):
        claimed = await self.getClaimedItems(gift_id, None)
        unclaimed = await self.getItems(gift_id, None)

        merged = claimed + unclaimed
        if page is None:
            return merged

        return paginateList(merged, page)

    async def getClaimedItems(
        self,
        gift_id: int,
        page: int = 1,
    ) -> List[ItemOut]:

        await self.ensureUpdated(gift_id)
        items = self._claimed.get(gift_id)

        if not gift_id in self._claimed:
            raise Error(msg="Gift does not exist")

        if page is None:
            return items

        return paginateList(
            items,
            page,
        )

    async def getItem(
        self,
        gift_id: int,
        item_id: int,
    ) -> Optional[ItemOut]:
        await self.ensureUpdated(gift_id)
        if not gift_id in self._items:
            raise Error("Gift does not exist")

        items = self._items.get(gift_id)
        if not items:
            raise Error("No items available for this gift")

        parsed = [item for item in items if item.item_id == item_id]
        if not parsed:
            raise Error("Item does not exist")

        return parsed[0]

    async def _finishDeletingItem(self, gift_id: int, item_id: int):
        await self.execute(
            GiftQueries.DeleteGiftItem,
            (item_id,),
        )

    async def deleteItem(
        self,
        gift_id: int,
        item_id: int,
        bt: BackgroundTasks,
    ) -> bool:
        await self.ensureUpdated(gift_id)
        items = self._items.get(gift_id)

        if items is None:
            raise Error("Gift does not exist")

        for i, item in enumerate(items):
            if item.item_id == item_id:
                self._items[gift_id].pop(i)
                self._giftsrvc._autoclose = False
                self._addTask(
                    bt,
                    self._finishDeletingItem,
                    gift_id,
                    item_id,
                )
                return True

        raise Error("Item does not exist")

    async def totalItems(self, gift_id: int):
        await self.ensureUpdated(gift_id)
        return len(self._items.get(gift_id, list()))


class GiftService(BaseService):
    def __init__(self, *args, **kwargs) -> None:
        super().__init__(*args, **kwargs)

        self._gifts: List[Gift] = list()
        self._item_service: _GiftItemService = None
        self._updated = False

    @property
    def itemService(self) -> _GiftItemService:
        return self._item_service

    async def __aenter__(self) -> "GiftService":
        await super().__aenter__()

        self._item_service = _GiftItemService(self, con=self._con)
        return self

    async def __aexit__(self, *_, **__) -> None:
        return await super().__aexit__(*_, *__)

    async def ensureUpdated(self):
        if not self._updated:
            self._updated = True
            await self.getAllGifts()

    async def getAllGifts(self, refresh: bool = False) -> List[Gift]:
        if refresh or not self._gifts:

            gifts = await self.fetchall(GiftQueries.GetGifts)
            self._gifts = [GiftOut(**gift) for gift in gifts]

        return self._gifts

    async def getGifts(self, page: Optional[int] = None):
        if page is None:
            return await self.getAllGifts()

        return paginateList(
            await self.getAllGifts(),
            page=page,
        )

    async def getGift(self, gift_id: int) -> Optional[GiftOut]:
        gifts = await self.getGifts()
        _gifts = [gift for gift in gifts if gift.gift_id == gift_id]
        return None if not _gifts else _gifts[0]

    async def getGiftClaims(self, gift_id: int) -> List[ItemOut]:
        claims = await self.fetchall(GiftQueries.GetClaimedGiftItems, (gift_id,))
        if not claims:
            return list()
        return [ItemOut(**claim) for claim in claims]

    async def _finishDeletingGift(self, gift_id: int):
        await self.itemService.ensureUpdated(gift_id)
        self.itemService._items.pop(gift_id, None)
        await self.execute(GiftQueries.DeleteGiftItems, (gift_id,))
        await self.execute(GiftQueries.DeleteGift, (gift_id,))

    async def deleteGift(self, gift_id: int, bt: BackgroundTasks) -> bool:
        await self.ensureUpdated()

        for i, gift in enumerate(self._gifts):
            if gift.gift_id == gift_id:
                self._gifts.pop(i)

                self._item_service._autoclose = False
                self._addTask(
                    bt,
                    self._finishDeletingGift,
                    gift_id,
                )
                return True

        return False

    async def createGift(self, author: int, gift: Gift):
        if gift.price < 0:
            raise Error(msg="Gift price must be greater than 0")

        if len(gift.title) > 30:
            raise Error(msg="Gift title must be shorter than 30 characters")

        if len(gift.description) > 500:
            raise Error(
                msg="Gift description should be less than 20 characters",
            )

        await self.execute(
            GiftQueries.CreateGift, (author, gift.price, gift.title, gift.description)
        )
        self.getAllGifts(refresh=True)  # Refresh cache

from enum import Enum
from typing import Generic, List, Optional, Union
from fastapi import APIRouter, BackgroundTasks
from fastapi.params import Depends
from pydantic.generics import GenericModel
from pydantic.main import BaseModel

from data.services.answer_service import AnswerService
from data.services.base import ensureResponseType

from responses import (
    BaseResponse,
    Error,
    Success,
    returnResponse,
)

from auth.jwt import getAdmin, getUser, optionalUser

from data.models import (
    Gift,
    GiftOut,
    Item,
    ItemOut,
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
from data.services.gift_service import GiftService
from routes.auth import authLogin

# /gifts
router = APIRouter()


GiftValueModel = ValueModel.new(gifts=(Union[GiftOut, List[GiftOut]], ...))


class GiftResponse(BaseResponse):
    data: GiftValueModel


@router.get(
    "/",
    response_model=GiftResponse,
)
async def getGifts(
    gift_id: Optional[int] = None,
    page: Optional[int] = None,
):
    gifts: List[GiftOut] = list()

    async with GiftService() as service:
        if gift_id is not None:
            gift = await service.getGift(gift_id)
            if gift is None:
                return Error("A gift with that ID was not found")
            return GiftResponse(data=GiftValueModel(gifts=gift))

        gifts = await service.getGifts(page)

    return GiftResponse(data=GiftValueModel(gifts=gifts))


@router.post("/", response_model=GiftResponse)
async def createGift(
    gift: Gift,
    user: User = Depends(getAdmin),
):
    go: GiftOut = None

    async with GiftService() as service:
        go = await service.createGift(user.uid, gift)

    if go is not None:
        return GiftResponse(
            data=GiftValueModel(gifts=go),
            detail="Gift has been created",
        )

    raise Error("Unexpected")


@router.delete("/{gift_id}")
async def deleteGift(
    gift_id: int,
    background_task: BackgroundTasks,
    user: User = Depends(getAdmin),
):
    deleted: bool = False

    async with GiftService() as service:
        deleted = await service.deleteGift(gift_id, background_task)

    if not deleted:
        raise Error("Could not delete gift.")

    return Success(detail="Gift has been deleted")


# /gifts/{gifft_id}/items

ItemValueModel = ValueModel.new(items=(Union[List[ItemOut], ItemOut], ...))
SingleItemModel = ValueModel.new(item=(ItemOut, ...))
TotalValueModel = ValueModel.new(total=(int, ...))


class ItemResponse(BaseResponse):
    data: ItemValueModel


class SingleItemResponse(BaseResponse):
    data: SingleItemModel


class ItemOrValueResponse(BaseResponse):
    data: Union[ItemValueModel, TotalValueModel]


class _GetGiftItemsType(Enum):
    claimed = "claimed"
    unclaimed = "unclaimed"
    all = "all"


@router.get("/{gift_id}/items/{item_id}", response_model=ItemOrValueResponse)
@router.get("/{gift_id}/items", response_model=ItemOrValueResponse)
async def getItems(
    gift_id: int,
    item_id: Optional[int] = None,
    page: Optional[int] = None,
    total: bool = False,
    type: _GetGiftItemsType = _GetGiftItemsType.all,
    user: User = Depends(getUser),
):

    if (not user.admin) or (user.admin and total):
        async with GiftService() as service:
            total = await service.itemService.totalItems(gift_id)
            return ItemOrValueResponse(data=TotalValueModel(total=total))

    items: Union[List[ItemOut], ItemOut] = list()

    async with GiftService() as service:
        if item_id is not None:
            items = await service.itemService.getItem(gift_id, item_id)
        elif type == _GetGiftItemsType.claimed:
            items = await service.itemService.getClaimedItems(gift_id, page)
        elif type == _GetGiftItemsType.unclaimed:
            items = await service.itemService.getItems(gift_id, page)
        else:  # _GetGiftItemsType.all
            items = await service.itemService.getAllItems(gift_id, page)

    return ItemOrValueResponse(detail="Item added", data=ItemValueModel(items=items))


@router.post(
    "/{gift_id}/items",
    response_model=SingleItemResponse,
)
async def postItems(
    gift_id: int,
    item: Item,
    user: User = Depends(getAdmin),
):
    io: ItemOut = None

    async with GiftService() as service:
        io = await service.itemService.addItem(
            gift_id,
            item,
        )
    if io is None:
        raise Error("Unexpected null value")

    return SingleItemResponse(data=SingleItemModel(item=io))


@router.delete("/{gift_id}/items/{item_id}")
async def deleteItem(
    gift_id: int,
    item_id: int,
    background_task: BackgroundTasks,
    user: User = Depends(getAdmin),
):
    async with GiftService() as service:
        await service.itemService.deleteItem(
            gift_id,
            item_id,
            background_task,
        )

    return Success(detail="Item has been deleted")


@router.post("/{gift_id}/items/{item_id}/claims", response_model=ItemResponse)
@router.post("/{gift_id}/items/claims", response_model=ItemResponse)
async def claimItem(
    gift_id: int,
    item_id: Optional[int] = None,
    user: User = Depends(getUser),
):
    item: Optional[ItemOut] = None
    async with GiftService() as service:
        if item_id is not None:
            item = await service.itemService.claimItem(user, item_id, gift_id)

        else:
            item = await service.itemService.claimAnyItem(user, gift_id)

    if item is None:
        raise Error("Internal error")

    return ItemResponse(data=ItemValueModel(items=item))


@router.get("/{gift_id}/items/claims", response_model=ItemResponse)
@router.get("/items/claims", response_model=ItemResponse)
async def getItemClaims(
    gift_id: Optional[int] = None,
    user: User = Depends(getUser),
):
    claims: List[ItemOut] = list()
    async with GiftService() as service:

        if user.admin and gift_id is not None:
            print("getting claims")
            claims = await service.getGiftClaims(gift_id)
        else:
            claims = await service.itemService.getUserClaims(user.uid)

    return ItemResponse(data=ItemValueModel(items=claims))

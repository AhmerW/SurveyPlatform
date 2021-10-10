import typing
from math import ceil

_T = typing.TypeVar("_T")

page_count = 10
start_page = 1
min_page = 1
# How many pages a pagination includes


def getOffsetLimitFromPage(
    page: int,
    page_count: int = page_count,
    start_page: int = start_page,
    min_page: int = min_page,
) -> typing.Tuple[int, int]:
    if page < min_page:
        page = start_page
    page -= 1
    offset = page * page_count
    return (offset, offset + page_count)


def paginateList(
    l: typing.List[_T],
    page: int = 1,
    **kwargs: int,
) -> typing.List[_T]:
    offset, limit = getOffsetLimitFromPage(page, **kwargs)
    return l[offset:limit]


def totalSections(pages: int) -> int:
    return ceil(pages, page_count)

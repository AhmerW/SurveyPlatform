import typing
from math import ceil


page_count = 10
start_page = 1
min_page = 1
# How many pages a pagination includes


def getOffsetLimitFromPage(page: int) -> typing.Tuple[int, int]:
    if page < min_page:
        page = start_page
    page -= 1
    offset = page * page_count
    return (offset, offset + page_count)


def totalSections(pages: int) -> int:
    return ceil(pages, page_count)

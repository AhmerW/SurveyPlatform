from typing import Any, List, Optional, Tuple

import aiosqlite


from globals import db_file_path


def dictFactory(cursor, row) -> dict:
    return {
        col[0]: row[index]
        for index, col in enumerate(
            cursor.description,
        )
    }


class BaseService:
    def __init__(
        self,
        con: aiosqlite.Connection = None,
    ) -> None:
        self._con = con

    async def __aenter__(self) -> "BaseService":
        if self._con is None:
            self._con = await aiosqlite.connect(db_file_path)
            self._con.row_factory = dictFactory

        return self

    async def __aexit__(self, *_, **__) -> None:
        if isinstance(self._con, aiosqlite.Connection):
            await self._con.close()

    def getCon(self) -> aiosqlite.Connection:
        return self._con

    async def execute(
        self,
        query: str,
        values: Tuple[Any] = tuple(),
    ) -> aiosqlite.Cursor:

        cur = await self._con.execute(query, values)
        await self._con.commit()
        return cur

    async def executemany(
        self,
        query: str,
        values: Tuple[Any] = tuple(),
    ) -> aiosqlite.Cursor:

        cur = await self._con.executemany(query, values)
        await self._con.commit()
        return cur

    async def fetchall(
        self,
        query: str,
        values: Tuple[Any] = tuple(),
    ):
        return await self._con.execute_fetchall(
            query,
            values,
        )

    async def fetchone(self, *args, **kwargs) -> Optional[aiosqlite.Row]:
        cur = await self.execute(*args, **kwargs)
        return await cur.fetchone()

    async def fetch(self, *args, **kwargs) -> Optional[aiosqlite.Row]:
        cur = await self.execute(*args, **kwargs)
        return cur.lastrowid

    async def commit(self):
        await self._con.commit()

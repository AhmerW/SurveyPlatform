from typing import Any, Callable, Generic, List, Optional, Tuple, TypeVar, Awaitable
import inspect
import aiosqlite
from starlette.background import BackgroundTasks


from globals import db_file_path
from responses import InternalServiceResponse


def dictFactory(cursor, row) -> dict:
    return {
        col[0]: row[index]
        for index, col in enumerate(
            cursor.description,
        )
    }


_T = TypeVar("_T")
_T2 = TypeVar("_T2")
_T3 = TypeVar("_T3")


def ensureResponseType(T: _T):
    async def deco(fn: Awaitable):
        async def wrapper(*args, **kwargs):
            _response: T = await fn(*args, **kwargs)

            if not isinstance(_response, T):
                return InternalServiceResponse(
                    success=False,
                    msg="Invalid type returned from service.",
                )

            return _response

        return wrapper

    return deco


class _ResponseCheckMeta(type):
    def __new__(cls, name, base, attrs):

        _callback = attrs.get("response_callback")

        if _callback is not None:
            for key, value in attrs.items():
                if callable(value):
                    attrs[key] = _callback(value)

        return super().__new__(cls, name, base, attrs)


class BaseServiceFactory(Generic[_T2]):
    def __init__(self, cls: "BaseService") -> None:
        self._cls = cls
        self._service: _T2 = None

    async def get(self) -> _T2:
        if self._service is None:
            self._service = await self._cls.create()

        return self._service


# A state container will keep global state for all services of that type.


class StateContainer:
    ...


async def createConnection() -> aiosqlite.Connection:
    con = await aiosqlite.connect(db_file_path)
    con.row_factory = dictFactory
    return con


class BaseService(metaclass=_ResponseCheckMeta):
    _state: StateContainer

    def __init__(
        self,
        con: aiosqlite.Connection = None,
        response_callback: Optional[Callable] = None,
        autoclose: bool = True,
    ) -> None:
        self._response_callback = response_callback
        self._con: aiosqlite.Connection = con
        self._autoclose = autoclose

    @classmethod
    @property
    def state(cls) -> StateContainer:
        return cls._state

    @property
    async def con(self) -> aiosqlite.Connection:
        if self._con is None:
            self._con = await createConnection()
        return self._con

    @classmethod
    async def create(self) -> "BaseService":
        return BaseService(await createConnection())

    async def checkCon(self):
        if self._con is None:
            self._con = await createConnection()

    async def __aenter__(self) -> "BaseService":
        return self

    async def __aexit__(self, *_, **__) -> None:

        if self._autoclose and isinstance(self._con, aiosqlite.Connection):
            await self._con.close()

    async def _taskManager(self, fn, *args, **kwargs):
        await self.checkCon()
        await fn(*args, **kwargs)
        if not self._autoclose:

            await self._con.close()

    def _addTask(
        self,
        bt: BackgroundTasks,
        fn: Callable,
        *args,
        **kwargs,
    ):

        self._autoclose = False

        bt.add_task(
            self._taskManager,
            fn,
            *args,
            **kwargs,
        )

    async def execute(
        self,
        query: str,
        values: Tuple[Any] = tuple(),
    ) -> aiosqlite.Cursor:
        await self.checkCon()

        cur = await self._con.execute(query, values)
        await self._con.commit()
        return cur

    async def executemany(
        self,
        query: str,
        values: Tuple[Any] = tuple(),
    ) -> aiosqlite.Cursor:
        await self.checkCon()

        cur = await self._con.executemany(query, values)
        await self._con.commit()
        return cur

    async def fetchall(
        self,
        query: str,
        values: Tuple[Any] = tuple(),
    ):
        await self.checkCon()

        return await self._con.execute_fetchall(
            query,
            values,
        )

    async def fetchone(self, *args, **kwargs) -> Optional[aiosqlite.Row]:
        await self.checkCon()
        cur = await self.execute(*args, **kwargs)
        return await cur.fetchone()

    async def fetch(self, *args, **kwargs) -> Optional[aiosqlite.Row]:
        await self.checkCon()
        cur = await self.execute(*args, **kwargs)
        return cur.lastrowid

    async def commit(self):
        await self.checkCon()
        await self._con.commit()

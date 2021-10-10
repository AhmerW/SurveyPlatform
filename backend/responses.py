from typing import Any, Dict, Generic, Optional, TypeVar

from dataclasses import dataclass

from fastapi import Request
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError

from pydantic.main import BaseModel

from globals import app


@dataclass(slots=True, frozen=True)
class InternalServiceResponse:
    success: Optional[bool] = False
    msg: Optional[str] = ""
    data: Optional[Any] = None


def returnResponse(response: InternalServiceResponse):
    if not response.success:
        raise Error(msg=response.msg)

    return Success(msg=response.msg)


def Success(
    data: dict = dict(),
    detail: str = "ok",
    status_code: int = 200,
):
    return JSONResponse(
        content={
            "ok": True,
            "detail": detail,
            "data": data,
            "error": {},
        },
        status_code=status_code,
    )


def Error(
    msg: str,
    detail: str = "error",
    status_code: int = 400,
):
    return JSONResponse(
        content={
            "ok": False,
            "detail": detail,
            "data": {},
            "error": {
                "msg": msg,
            },
        },
        status_code=status_code,
    )


class Error(Exception):
    __slots__ = "error", "detail", "status", "headers"

    def __init__(
        self,
        msg: str = "",
        detail="",
        status=400,
        headers={},
    ):
        self.msg = msg
        self.headers = headers
        self.status = status
        self.detail = detail

    def json(self):
        return {
            "msg": self.msg,
            "type": "exception",
        }


@app.exception_handler(Error)
async def Error_handler(_: Request, exc: Error):
    return JSONResponse(
        status_code=exc.status,
        headers=exc.headers,
        content={
            "ok": False,
            "error": exc.json(),
            "detail": exc.detail,
            "data": {},
        },
    )


@app.exception_handler(RequestValidationError)
async def validationErrorHandler(request, exc):
    return JSONResponse(
        status_code=400,
        headers={},
        content={
            "ok": False,
            "error": {"msg": str(exc)},
            "detail": "",
            "data": {},
        },
    )


class BaseResponse(BaseModel):
    detail: Optional[str] = ""
    ok: Optional[bool] = True
    data: Optional[Dict[Any, Any]] = {}
    error: Optional[Dict[str, Any]] = {}

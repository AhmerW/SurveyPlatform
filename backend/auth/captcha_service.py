from dataclasses import dataclass, field
from enum import Enum, auto
from typing import Dict, Final, Optional, Set
import operator
import secrets
import os

from PIL import Image, ImageDraw, ImageFont, ImageFilter

from fastapi import Request
from pydantic import BaseModel


from data.state.state_manager import stateManager
from data.services.base import StateContainer
from responses import Error


MAX_N1 = 20
MAX_N2 = 10

_words = [
    "zero",
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine",
    "ten",
    "eleven",
    "twelve",
    "thirteen",
    "fourteen",
    "fifteen",
    "sixteen",
    "seventeen",
    "eighteen",
    "nineteen",
    "twenty",
]


captchaOperations = [
    "plus",
    "minus",
]


class Captcha(BaseModel):
    id: str
    n1: int
    n2: int
    operation: str


class CaptchaFactory:
    @classmethod
    def getId(cls) -> int:
        return secrets.token_urlsafe(10)

    @classmethod
    def get(cls) -> Captcha:
        return Captcha(
            id=cls.getId(),
            n1=secrets.randbelow(MAX_N1),
            n2=secrets.randbelow(MAX_N2),
            operation=secrets.choice(
                captchaOperations,
            ),
        )


# Add automatic methods and connection with StateManager through StateContainer
"""
class CaptchaStateContainer(StateContainer):
    def __init__(
        self,
        _captchas: Dict[int, Captcha] = dict(),
        _tokens: Set[str] = set(),
    ) -> None:
        self._captchas = _captchas
        self._tokens = _tokens
"""


@dataclass
class CaptchaStateContainer(StateContainer):
    captchas_id: int  # dict
    tokens_id: int  # set


class CaptchaService:
    _state = CaptchaStateContainer(
        captchas_id=1,
        tokens_id=2,
    )

    @classmethod
    @property
    def state(cls) -> CaptchaStateContainer:
        return cls._state

    async def verifyToken(self, token: str) -> bool:
        try:
            await stateManager.setRemove(self.state.tokens_id, token)

            return True
        except KeyError:
            return False

    async def generateToken(self) -> str:
        token = secrets.token_urlsafe(10)
        await stateManager.setSet(self.state.tokens_id, token)
        return token

    async def createCaptcha(self) -> Captcha:
        captcha = CaptchaFactory.get()
        await stateManager.dictSetMultiple(captcha.id, captcha.dict())

        return captcha

    def calculateCaptcha(self, captcha: Captcha) -> int:

        if captcha.operation == "plus":
            return operator.add(captcha.n1, captcha.n2)
        elif captcha.operation == "minus":

            return operator.sub(captcha.n1, captcha.n2)

        return 0

    def captchaIsValid(
        self,
        captcha: Captcha,
        value: int,
    ) -> bool:

        return isinstance(value, int) and (value == self.calculateCaptcha(captcha))

    async def processCaptcha(
        self,
        captcha: Captcha,
        value: int,
    ):

        if not self.captchaIsValid(captcha, value):
            raise Error("Invalid Captcha")

        await stateManager.dictDelete(captcha.id)
        return await self.generateToken()

    async def solve(self, captcha_id: str, value: int) -> bool:

        captcha = await stateManager.dictGetMultiple(captcha_id)

        if not captcha:
            raise Error("Captcha does not exist")
        captcha = Captcha(**captcha)

        return await self.processCaptcha(captcha, value)

    def generateCaptchaImage(self, captcha: Captcha) -> Image.Image:
        im = Image.new("RGBA", (450, 100), (0, 0, 0, 0))
        canvas = ImageDraw.Draw(im)

        try:
            n1 = _words[captcha.n1]
            n2 = _words[captcha.n2]
        except IndexError:
            n1, n2 = captcha.n1, captcha.n2

        canvas.text(
            (10, 40),
            f"{n1} {captcha.operation} {n2}",
            font=ImageFont.truetype(getFontPath(), 40),
        )
        canvas.line(
            [0, 65, 450, 65],
            width=3,
            fill=(0, 255, 0),
        )

        return im.filter(ImageFilter.BoxBlur(3.5))


captchaService: Final[CaptchaService] = CaptchaService()


# Valid captcha dependency


# solve_token
# issued when a captcha is solved (OTT)

mapped_fonts = {}


def getFontPath() -> str:
    if os.name == "nt":
        return "arial.ttf"

    return os.path.join("usr", "share", "fonts", "truetype", "dejavu", "DejaVuSans.ttf")


async def requireSolvedCaptcha(request: Request) -> Optional[str]:
    st = request.headers.get("solve-token")
    if st is None:
        raise Error("Solve token not provided")

    if await captchaService.verifyToken(st):
        return st

    raise Error("Invalid solve-token")

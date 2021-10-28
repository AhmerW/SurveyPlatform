from dataclasses import dataclass, field
from itertools import count
from enum import Enum, auto
from typing import Dict, Final, Optional, Set
import operator
import secrets

from PIL import Image, ImageDraw, ImageFont, ImageFilter

from fastapi import Request
from pydantic import BaseModel


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


class CaptchaOperation(Enum):
    add = "plus"
    sub = "minus"


class Captcha(BaseModel):
    id: str
    n1: int
    n2: int
    operation: CaptchaOperation


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
            operation=secrets.choice(list(CaptchaOperation)),
        )


@dataclass
class CaptchaStateContainer(StateContainer):
    _captchas: Dict[int, Captcha] = field(default_factory=dict)
    _tokens: Set[str] = field(default_factory=set)


class CaptchaService:
    _state = CaptchaStateContainer()

    @classmethod
    @property
    def state(cls) -> CaptchaStateContainer:
        return cls._state

    def verifyToken(self, token: str) -> bool:
        try:
            self.state._tokens.remove(token)
            return True
        except KeyError:
            return False

    def generateToken(self) -> str:
        token = secrets.token_urlsafe(10)
        self.state._tokens.add(token)
        return token

    def createCaptcha(self) -> Captcha:
        captcha = CaptchaFactory.get()
        self.state._captchas[captcha.id] = captcha

        return captcha

    def calculateCaptcha(self, captcha: Captcha) -> int:
        if captcha.operation == CaptchaOperation.add:
            return operator.add(captcha.n1, captcha.n2)
        elif captcha.operation == CaptchaOperation.sub:
            return operator.sub(captcha.n1, captcha.n2)

        return 0

    def captchaIsValid(
        self,
        captcha: Captcha,
        value: int,
    ) -> bool:
        return isinstance(value, int) and value == self.calculateCaptcha(captcha)

    def processCaptcha(
        self,
        captcha_id: str,
        value: int,
    ):
        captcha = self.state._captchas.get(captcha_id)
        if captcha is None:
            raise Error("Captcha does not exist")

        if not self.captchaIsValid(captcha, value):
            raise Error("Invalid Captcha")

        self.state._captchas.pop(captcha.id)
        return self.generateToken()

    def solve(self, captcha_id: int, value: int) -> bool:
        captcha: Optional[Captcha] = self.state._captchas.get(captcha_id)
        if captcha is None:
            raise Error("Invalid Captcha")

        return self.processCaptcha(captcha, value)

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
            f"{n1} {captcha.operation.value} {n2}",
            font=ImageFont.truetype("arial.ttf", 40),
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


def requireSolvedCaptcha(request: Request) -> Optional[str]:
    st = request.headers.get("solve-token")
    if st is None:
        raise Error("Solve token not provided")

    if captchaService.verifyToken(st):
        return st

    raise Error("Invalid solve-token")

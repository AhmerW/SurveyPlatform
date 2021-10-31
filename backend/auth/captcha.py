from io import BytesIO
from PIL import Image

from fastapi import APIRouter
from fastapi import responses
from fastapi.params import Depends
from fastapi.responses import HTMLResponse, StreamingResponse, Response
from pydantic.main import BaseModel

from auth.captcha_service import captchaService, requireSolvedCaptcha


from globals import SITE_KEY
from responses import Success

router = APIRouter()


class CaptchaIn(BaseModel):
    captcha_id: str
    value: int


@router.get("/")
async def getCaptcha():
    captcha = captchaService.createCaptcha()
    image = captchaService.generateCaptchaImage(captcha)
    buffer = BytesIO()

    image.save(buffer, "PNG")
    buffer.seek(0)
    return StreamingResponse(
        buffer,
        headers={
            "CAPTCHA-ID": captcha.id,
        },
        media_type=f"image/png",
    )


@router.post("/")
async def solveCaptcha(captcha: CaptchaIn):

    response = captchaService.solve(captcha.captcha_id, captcha.value)

    return Success(dict(solve_token=response), detail="Captcha solved")

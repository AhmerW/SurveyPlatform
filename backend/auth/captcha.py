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


class CaptchaIn(BaseModel):
    captcha_id: str
    value: int


@router.post("/")
async def verifyCaptcha(captcha: CaptchaIn):

    response = captchaService.processCaptcha(captcha.captcha_id, captcha.value)

    return Success(dict(solve_token=response))


@router.get("/test")
async def testCaptcha(token: str = Depends(requireSolvedCaptcha)):
    return token


"""
    <html>
  <head>
    <title>hCaptcha</title>
    <script src="https://hcaptcha.com/1/api.js" async defer></script>
  </head>
  <body style='background-color: none;'>
    <div style='height: 60px;'></div>
    <form action="?" method="POST">
      <div class="h-captcha" 
        data-sitekey="{sitekey}"
        data-callback="captchaCallback"></div>

    </form>
    <script>
      function captchaCallback(response) {{
        if (typeof Captcha!=="undefined") {{
          Captcha.postMessage(response);
        }}
      }}
    </script>
  </body>
</html>
    """

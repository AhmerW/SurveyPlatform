from fastapi import APIRouter
from fastapi.responses import HTMLResponse


from globals import SITE_KEY

router = APIRouter()


@router.get("/")
async def captcha():
    return HTMLResponse(
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
    """.format(
            sitekey=SITE_KEY
        )
    )


@router.post("/")
async def verifyCaptcha():
    pass

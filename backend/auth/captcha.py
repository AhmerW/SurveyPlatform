import os
from fastapi import APIRouter

from globals import SITE_KEY

app = APIRouter()


@app.get("/")
async def captcha():
    return """
    <html>
  <head>
    <title>hCaptcha</title>
    <script src="https://hcaptcha.com/1/api.js" async defer></script>
  </head>
  <body style='background-color: aqua;'>
    <div style='height: 60px;'></div>
    <form action="?" method="POST">
      <div class="h-captcha" 
        data-sitekey="{sitekey}"
        data-callback="captchaCallback"></div>

    </form>
    <script>
      function captchaCallback(response) {
        if (typeof Captcha!=="undefined") {
          Captcha.postMessage(response);
        }
      }
    </script>
  </body>
</html>
    """.format(
        sitekey=SITE_KEY
    )


@app.get("/verify")
async def verifyCaptcha():
    pass

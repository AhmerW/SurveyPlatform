from logging import root
import os
import dotenv
from typing import Final, List

from passlib.context import CryptContext
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

DEV: Final[bool] = True
base_path: Final[str] = "/api/v1"


if DEV:
    server_url = "http://localhost:8000/"
else:
    server_url = "https://surveyplatform.net/#/"


app = FastAPI(
    root_path=None if DEV else base_path,
    openapi_url=None,
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


db_file_name: Final[str] = "data.db"
db_file_path: Final[str] = os.path.join(
    "data",
    "raw",
    db_file_name,
)

dotenv.load_dotenv(".env")
SECRET: str = os.getenv("secret")
SITE_KEY: str = os.getenv("sitekey")
CAPTCHA_SECRET: str = os.getenv("captchasecretkey")


pwd_ctx = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto",
)


admins: List[str] = [
    "admin",
]

owners: List[str] = [
    "admin",
]

import os
import dotenv
from typing import Final, List

from passlib.context import CryptContext
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware


project = "SurveyPlatform"
app = FastAPI()
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

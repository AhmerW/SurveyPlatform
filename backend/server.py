from typing import List
from dataclasses import dataclass

from fastapi import APIRouter


from responses import Success
from globals import DEV, app, base_path
from data.db import sql

from routes.survey.router_drafts import router as drafts_router

from routes.survey.router import router as survey_router
from auth.captcha import router as captcha_router
from routes.gift.router import router as gift_router
from routes.user.router import router as user_router
from routes.auth import router as auth_router


@app.route(base_path)
async def home(_):
    print([{"path": route.path, "name": route.name} for route in app.routes])
    return Success()


@dataclass
class Route:
    prefix: str
    router: APIRouter


routes: List[Route] = [
    Route(
        "surveys",
        survey_router,
    ),
    Route(
        "auth",
        auth_router,
    ),
    Route(
        "users",
        user_router,
    ),
    Route(
        "drafts",
        drafts_router,
    ),
    Route(
        "gifts",
        gift_router,
    ),
    Route(
        "captcha",
        captcha_router,
    ),
]

_base_prefix = base_path if DEV else ""
for route in routes:
    app.include_router(
        route.router,
        prefix=f"{_base_prefix}/{route.prefix}",
    )

# gunicorn deployment
# gunicorn -w 4 -k uvicorn.workers.UvicornWorker --daemon server:app

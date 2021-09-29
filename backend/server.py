from typing import List
from dataclasses import dataclass

from fastapi import APIRouter


from responses import Success
from globals import app
from data.db import sql

from routes.survey.router_drafts import router as drafts_router
from routes.answer.router import router as answer_router
from routes.survey.router import router as survey_router
from routes.user.router import router as user_router
from routes.auth import router as auth_router


@app.route("/")
async def home(_):
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
        "answers",
        answer_router,
    ),
]

for route in routes:
    app.include_router(
        route.router,
        prefix=f"/{route.prefix}",
    )

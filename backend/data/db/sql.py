from typing import Final, List

from data.services.base import BaseService

from globals import app

pre_queries: Final[List[str]] = ["PRAGMA foreign_keys = ON;"]

table_queries: Final[List[str]] = [
    """
    CREATE TABLE IF NOT EXISTS Users 
    (
        uid INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        points INTEGER DEFAULT 5,
        verified BOOLEAN DEFAULT False
    )
    """,
    """
    CREATE TABLE IF NOT EXISTS Surveys
    (
        survey_id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        pages INTEGER DEFAULT 1,
        points INTEGER DEFAULT 0,
        duration INTEGER,
        draft BOOLEAN DEFAULT False
    )
    """,
    """
    CREATE TABLE IF NOT EXISTS Drafts (
        draft_id INTEGER PRIMARY KEY,
        last_edited TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        survey_id INTEGER,
        FOREIGN KEY(survey_id) REFERENCES Surveys(survey_id)
    )
    """,
    """
    CREATE TABLE IF NOT EXISTS Questions
    (
        question_id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        question_text TEXT NOT NULL,
        widget TEXT NOT NULL,
        widget_values TEXT,
        position INTEGER,
        FOREIGN KEY(survey_id) REFERENCES Surveys(survey_id)
    )
    """,
    """
    CREATE TABLE IF NOT EXISTS SurveyAnswers
    (
        answer_id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid INTEGER,
        survey_id INTEGER,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY(uid) REFERENCES Users(uid)
        FOREIGN KEY(survey_id) REFERENCES Surveys(survey_id)
    )
    """,
    """
    CREATE TABLE IF NOT EXISTS QuestionAnswers
    (   
        question_id INTEGER,
        answer_id INTEGER,
        value TEXT NOT NULL, 
        FOREIGN KEY(question_id) REFERENCES Questions(question_id),
        FOREIGN KEY(answer_id) REFERENCES SurveyAnswers(answer_id)
    )
    """,
    # UID: Gift author
    """ 
    CREATE TABLE IF NOT EXISTS Gifts
    (
        gift_id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid INTEGER,
        price INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        FOREIGN KEY(uid) REFERENCES Users(uid)
    )
    """,
    """ 
    CREATE TABLE IF NOT EXISTS GiftItems
    (
        item_id INTEGER PRIMARY KEY AUTOINCREMENT,
        gift_id INTEGER,
        value TEXT NOT NULL,
        claimed_by INTEGER,
        claimed BOOLEAN DEFAULT False,
        FOREIGN KEY(gift_id) REFERENCES Gifts(gift_id),
        FOREIGN KEY(claimed_by) REFERENCES Users(uid)
    )
    """,
]


@app.on_event("startup")
async def startup() -> None:
    async with BaseService() as service:
        for query in pre_queries + table_queries:
            await service.execute(query)

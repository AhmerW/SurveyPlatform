from fastapi import APIRouter

router = APIRouter()


@router.get("/{survey_id}")
async def getSurveyData():
    pass

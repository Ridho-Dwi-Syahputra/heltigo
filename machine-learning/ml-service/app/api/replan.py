from fastapi import APIRouter, Depends
from app.deps import verify_ml_key
from app.schemas.replan import ReplanRequest, ReplanResponse
from app.services.replan_service import predict_replan

router = APIRouter()


@router.post("/predict/replan", response_model=ReplanResponse)
async def replan(req: ReplanRequest, _: str = Depends(verify_ml_key)):
    result = predict_replan(
        weekly_score=req.weekly_score,
        weight_diff_kg=req.weight_diff_kg,
        bmi=req.bmi,
        experience_level=req.experience_level,
        age=req.age,
        workout_frequency=req.workout_frequency,
    )
    return ReplanResponse(**result)

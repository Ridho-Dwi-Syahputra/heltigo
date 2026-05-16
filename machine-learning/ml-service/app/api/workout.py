from fastapi import APIRouter, Depends
from app.deps import verify_ml_key
from app.schemas.workout import WorkoutPlanRequest, WorkoutPlanResponse, WorkoutDayOut, ExerciseOut
from app.services.workout_service import predict_workout_plan

router = APIRouter()


@router.post("/predict/workout-plan", response_model=WorkoutPlanResponse)
async def workout_plan(req: WorkoutPlanRequest, _: str = Depends(verify_ml_key)):
    days_raw = predict_workout_plan(
        fitness_level=req.fitness_level,
        goal=req.goal,
        bmi=req.bmi,
        age=req.age,
        gender=req.gender,
        workout_mode=req.workout_mode,
        days_per_week=req.days_per_week,
        session_minutes=req.session_minutes,
        has_injury=req.has_injury,
        has_chronic=req.has_chronic,
        conditions=req.conditions,
    )
    days = [
        WorkoutDayOut(
            day_index=d["day_index"],
            workout_type=d["workout_type"],
            intensity=d["intensity"],
            is_rest_day=d["is_rest_day"],
            estimated_minutes=d["estimated_minutes"],
            exercises=[ExerciseOut(**e) for e in d["exercises"]],
        )
        for d in days_raw
    ]
    return WorkoutPlanResponse(days=days)

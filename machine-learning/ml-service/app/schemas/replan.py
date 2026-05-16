from pydantic import BaseModel, Field


class ReplanRequest(BaseModel):
    weekly_score: float = Field(..., ge=0, le=100)
    weight_diff_kg: float = Field(default=0.0)
    bmi: float = Field(..., ge=10, le=60)
    experience_level: int = Field(..., ge=1, le=3, description="1=BEGINNER 2=INTERMEDIATE 3=ADVANCED")
    age: int = Field(default=25)
    workout_frequency: int = Field(default=4, ge=1, le=7)


class ReplanResponse(BaseModel):
    volume_multiplier: float
    recommendation: str
    action: str
    model_version: str = "xgb-regressor"

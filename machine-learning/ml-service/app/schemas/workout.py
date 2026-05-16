from pydantic import BaseModel, Field


class WorkoutPlanRequest(BaseModel):
    fitness_level: str = Field(..., description="BEGINNER | INTERMEDIATE | ADVANCED")
    goal: str = Field(..., description="WEIGHT_LOSS | MUSCLE_GAIN | MAINTENANCE | PERFORMANCE")
    bmi: float = Field(..., ge=10, le=60)
    age: int = Field(..., ge=10, le=100)
    gender: str = Field(default="MALE", description="MALE | FEMALE")
    workout_mode: str = Field(default="GYM", description="HOME | GYM | HYBRID")
    days_per_week: int = Field(default=4, ge=1, le=7)
    session_minutes: int = Field(default=60, ge=15, le=180)
    has_injury: bool = Field(default=False)
    has_chronic: bool = Field(default=False)
    conditions: list[str] = Field(default_factory=list)


class ExerciseOut(BaseModel):
    name: str
    phase: str
    sets: int
    reps: int
    rest_seconds: int


class WorkoutDayOut(BaseModel):
    day_index: int
    workout_type: str
    intensity: str
    is_rest_day: bool
    estimated_minutes: int
    exercises: list[ExerciseOut] = []


class WorkoutPlanResponse(BaseModel):
    days: list[WorkoutDayOut]
    model_version: str = "v3-knowledge-distillation"

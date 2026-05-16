# Machine Learning — FastAPI Serving

> 📌 **Update 2026-05-16** — FastAPI ML service expose **4 endpoint** untuk **3 model**:
>
> | Endpoint | Model | Timeout |
> |---|---|---|
> | `POST /predict/workout-plan` | Model_Rekomendasi_Latihan (RF) | < 800 ms |
> | `POST /predict/meal-plan` | Model_Perencana_Makan (Knapsack) | < 500 ms |
> | `POST /predict/meal-alternatives` | Model_Perencana_Makan (Knapsack subset) | < 200 ms |
> | `POST /predict/replan` | Model_Adaptif_Perencanaan_Ulang (Rule + DT) | < 600 ms |
> | `GET /health` | — | — |
>
> **Tidak ada** `/predict/intensity` di FastAPI — logika intensity adjuster ada di **backend Express** (`07_BUSINESS_LOGIC.md`).
>
> Schema lengkap: [`FE-model-requirement/01_MODELS_SPEC.md`](FE-model-requirement/01_MODELS_SPEC.md).

---

## 1. Overview

FastAPI microservice yang **stateless** dengan 3 model yang di-load saat startup. Dipanggil oleh Express via HTTP dengan header `X-ML-KEY` (shared secret).

Default port: **8001**.

## 2. requirements.txt

```txt
fastapi==0.110.0
uvicorn[standard]==0.27.1
pydantic==2.6.1
scikit-learn==1.4.0
numpy==1.26.4
pandas==2.2.0
pyarrow==15.0.0          # untuk parquet
joblib==1.3.2
scipy==1.12.0
python-dotenv==1.0.1
httpx==0.27.0            # untuk testing
pytest==8.0.0
pytest-asyncio==0.23.5
```

Pin versi untuk stabilitas hackathon. Update pasca-demo.

## 3. main.py (Entry Point)

```python
from fastapi import FastAPI
from app.api import workout, meal, replan, health
from app.services.workout_recommender import workout_recommender
from app.services.meal_planner import meal_planner
from app.config import settings
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s [%(levelname)s] %(name)s: %(message)s')
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Heltigo ML Service",
    version="1.0.0",
    docs_url="/docs" if settings.ENABLE_DOCS else None,
    redoc_url=None,
)

@app.on_event("startup")
async def startup_event():
    # Trigger lazy load models (atau eager load di module)
    logger.info("✅ ML service starting up")
    logger.info(f"  Workout RF loaded: {workout_recommender.is_loaded}")
    logger.info(f"  Meal planner ready: {meal_planner.is_ready}")
    logger.info(f"  Service URL: http://0.0.0.0:8001")

# Routers
app.include_router(health.router, tags=["Health"])
app.include_router(workout.router, prefix="/infer", tags=["Workout"])
app.include_router(meal.router, prefix="/infer", tags=["Meal"])
app.include_router(replan.router, prefix="/infer", tags=["Replan"])
```

## 4. Config

File: `app/config.py`

```python
from pydantic_settings import BaseSettings
from pathlib import Path

class Settings(BaseSettings):
    ML_SERVICE_KEY: str = "dev-shared-secret"
    ENABLE_DOCS: bool = True
    LOG_LEVEL: str = "INFO"
    DATA_DIR: Path = Path(__file__).parent / "data"

    class Config:
        env_file = ".env"

settings = Settings()
```

`.env`:
```
ML_SERVICE_KEY=dev-shared-secret
ENABLE_DOCS=true
LOG_LEVEL=DEBUG
```

Production: set via env var, jangan commit.

## 5. Auth Dependency

File: `app/deps.py`

```python
from fastapi import Header, HTTPException
from app.config import settings

async def verify_ml_key(x_ml_key: str = Header(...)):
    if x_ml_key != settings.ML_SERVICE_KEY:
        raise HTTPException(status_code=401, detail="Invalid ML key")
    return True
```

Pasang di tiap endpoint:
```python
from fastapi import Depends
from app.deps import verify_ml_key

@router.post("/workout", dependencies=[Depends(verify_ml_key)])
async def infer_workout(req: WorkoutInferRequest):
    ...
```

## 6. Pydantic Schemas

File: `app/schemas/workout.py`

```python
from pydantic import BaseModel, Field
from typing import Literal

Gender = Literal["MALE", "FEMALE"]
BmiCategory = Literal["UNDERWEIGHT", "NORMAL", "OVERWEIGHT", "OBESE"]
FitnessLevel = Literal["BEGINNER", "INTERMEDIATE", "ADVANCED"]
WorkoutMode = Literal["HOME", "GYM"]
SleepBand = Literal["<5", "5-6", "6-7", "7-8", ">8"]
ExercisePhase = Literal["WARMUP", "MAIN", "COOLDOWN"]
WorkoutType = Literal["CARDIO", "STRENGTH", "HIIT", "FLEXIBILITY", "REST"]

class WorkoutProfile(BaseModel):
    bmi: float = Field(..., ge=12, le=50)
    bmi_category: BmiCategory
    gender: Gender
    age: int = Field(..., ge=10, le=100)
    fitness_level: FitnessLevel
    workout_mode: WorkoutMode
    days_per_week: int = Field(..., ge=3, le=5)
    session_minutes: int = Field(..., ge=15, le=60)
    conditions: list[str] = []

class WorkoutInferRequest(BaseModel):
    profile: WorkoutProfile

class PlanExercise(BaseModel):
    exercise_item_id: str
    order_in_day: int
    phase: ExercisePhase
    sets: int
    reps: int
    rest_seconds: int
    ai_tip: str | None = None

class WorkoutDay(BaseModel):
    day_index: int = Field(..., ge=0, le=6)
    is_rest_day: bool
    estimated_minutes: int
    estimated_calories: int
    exercises: list[PlanExercise]

class WorkoutInferResponse(BaseModel):
    days: list[WorkoutDay]

# --- Adjust ---

class WorkoutAdjustRequest(BaseModel):
    original_workout: WorkoutDay
    mood: int = Field(..., ge=1, le=5)
    energy: int = Field(..., ge=1, le=5)
    sleep_band: SleepBand

class WorkoutAdjustResponse(BaseModel):
    adjustment: float = Field(..., ge=-0.5, le=0.2)
    adjusted_workout: WorkoutDay
```

File: `app/schemas/meal.py`

```python
from pydantic import BaseModel, Field
from typing import Literal

DietRestriction = Literal["halal", "vegetarian", "no-nuts", "no-dairy"]
MealType = Literal["BREAKFAST", "LUNCH", "DINNER", "SNACK"]

class MealProfile(BaseModel):
    tdee: int = Field(..., ge=800, le=5000)
    target_calorie_adj: int = Field(..., ge=-500, le=500)
    budget_per_day_idr: int = Field(..., ge=5000, le=300000)
    meal_frequency: int = Field(..., ge=2, le=4)
    diet_restrictions: list[DietRestriction] = []

class MealInferRequest(BaseModel):
    profile: MealProfile
    excluded_food_ids: list[str] = []

class PlanMealFood(BaseModel):
    food_item_id: str
    servings: float
    calories_kcal: int
    cost_idr: int

class PlanMeal(BaseModel):
    meal_type: MealType
    calories_kcal: int
    cost_idr: int
    ai_explanation: str | None = None
    foods: list[PlanMealFood]

class MealDay(BaseModel):
    day_index: int = Field(..., ge=0, le=6)
    total_calories: int
    total_protein_g: float
    total_carb_g: float
    total_fat_g: float
    total_cost_idr: int
    meals: list[PlanMeal]

class MealInferResponse(BaseModel):
    days: list[MealDay]

# --- Alternative ---

class MealAlternativeRequest(BaseModel):
    plan_meal_id: str
    target_calories: int = Field(..., ge=100, le=2000)
    budget_idr: int = Field(..., ge=5000, le=200000)
    diet_restrictions: list[DietRestriction] = []
    exclude_food_ids: list[str] = []

class MealAlternativeResponse(BaseModel):
    meal: PlanMeal
```

File: `app/schemas/replan.py`

```python
from pydantic import BaseModel, Field

class ReplanRequest(BaseModel):
    previous_plan: dict   # opaque shape, JSON dari Express
    score_percent: float = Field(..., ge=0, le=100)
    workout_done_count: int
    workout_total_count: int
    meal_done_count: int
    meal_total_count: int
    weight_change_kg: float
    weight_target_change_kg: float
    most_skipped_exercise_ids: list[str] = []
    profile: dict          # opaque, complete profile dict

class ReplanResponse(BaseModel):
    ai_notes: str
    ai_recommendation: str
    workout_days: list[dict]
    meal_days: list[dict]
```

## 7. Routers

File: `app/api/health.py`

```python
from fastapi import APIRouter
from app.services.workout_recommender import workout_recommender
from app.services.meal_planner import meal_planner

router = APIRouter()

@router.get("/healthz")
async def healthz():
    return {
        "status": "ok",
        "models_loaded": [
            f"workout_rf={workout_recommender.is_loaded}",
            f"meal_master={meal_planner.is_ready}",
        ],
    }
```

File: `app/api/workout.py`

```python
from fastapi import APIRouter, Depends, HTTPException
from app.schemas.workout import (
    WorkoutInferRequest, WorkoutInferResponse,
    WorkoutAdjustRequest, WorkoutAdjustResponse,
)
from app.services.workout_recommender import workout_recommender
from app.services.workout_adjuster import compute_adjustment, apply_adjustment
from app.deps import verify_ml_key
import logging

logger = logging.getLogger(__name__)
router = APIRouter()

@router.post("/workout", response_model=WorkoutInferResponse, dependencies=[Depends(verify_ml_key)])
async def infer_workout(req: WorkoutInferRequest):
    try:
        result = workout_recommender.infer(req.profile.model_dump())
        return result
    except ValueError as e:
        raise HTTPException(422, str(e))
    except Exception as e:
        logger.exception("Workout inference failed")
        raise HTTPException(500, "Internal inference error")

@router.post("/workout/adjust", response_model=WorkoutAdjustResponse, dependencies=[Depends(verify_ml_key)])
async def adjust_workout(req: WorkoutAdjustRequest):
    adjustment = compute_adjustment(req.mood, req.energy, req.sleep_band)
    adjusted = apply_adjustment(req.original_workout.model_dump(), adjustment)
    return {
        "adjustment": adjustment,
        "adjusted_workout": adjusted,
    }
```

File: `app/api/meal.py`

```python
from fastapi import APIRouter, Depends, HTTPException
from app.schemas.meal import (
    MealInferRequest, MealInferResponse,
    MealAlternativeRequest, MealAlternativeResponse,
)
from app.services.meal_planner import meal_planner
from app.deps import verify_ml_key
import logging

logger = logging.getLogger(__name__)
router = APIRouter()

@router.post("/meal", response_model=MealInferResponse, dependencies=[Depends(verify_ml_key)])
async def infer_meal(req: MealInferRequest):
    try:
        result = meal_planner.infer_week(req.profile.model_dump(), req.excluded_food_ids)
        return result
    except ValueError as e:
        raise HTTPException(422, str(e))

@router.post("/meal/alternative", response_model=MealAlternativeResponse, dependencies=[Depends(verify_ml_key)])
async def alternative_meal(req: MealAlternativeRequest):
    try:
        meal = meal_planner.find_alternative(
            target_calories=req.target_calories,
            budget_idr=req.budget_idr,
            diet_restrictions=req.diet_restrictions,
            exclude_food_ids=req.exclude_food_ids,
        )
        return {"meal": meal}
    except ValueError as e:
        raise HTTPException(422, str(e))
```

File: `app/api/replan.py`

```python
from fastapi import APIRouter, Depends
from app.schemas.replan import ReplanRequest, ReplanResponse
from app.services.replanner import replan as replan_service
from app.deps import verify_ml_key

router = APIRouter()

@router.post("/replan", response_model=ReplanResponse, dependencies=[Depends(verify_ml_key)])
async def replan(req: ReplanRequest):
    return replan_service(req.model_dump())
```

## 8. Service Layer Stub

File: `app/services/workout_recommender.py`

```python
from pathlib import Path
import joblib
import pandas as pd
from app.config import settings
from app.services.feature_eng import extract_feature
from app.services.workout_composer import compose_workout_day

class WorkoutRecommender:
    def __init__(self):
        self.is_loaded = False
        try:
            bundle_path = settings.DATA_DIR / 'workout_rf.joblib'
            bundle = joblib.load(bundle_path)
            self.model = bundle['model']
            self.le_type = bundle['le_type']
            self.le_intensity = bundle['le_intensity']
            self.features = bundle['features']

            self.exercise_master = pd.read_parquet(settings.DATA_DIR / 'exercise_master.parquet')
            self.is_loaded = True
        except FileNotFoundError as e:
            print(f"⚠️  Model file missing: {e}")
            print("Workout recommender akan fail saat inference. Train model dulu di notebook.")

    def infer(self, profile: dict) -> dict:
        if not self.is_loaded:
            raise ValueError("Model belum dimuat. Cek logs server.")

        # Build feature matrix 7 hari
        rows = []
        for day_index in range(7):
            row = {f: extract_feature(profile, day_index, f) for f in self.features}
            rows.append(row)
        X = pd.DataFrame(rows)

        # Predict
        preds = self.model.predict(X)
        types = self.le_type.inverse_transform(preds[:, 0])
        intensities = self.le_intensity.inverse_transform(preds[:, 1])

        # Compose
        days = []
        for day_index in range(7):
            day = compose_workout_day(types[day_index], intensities[day_index], profile, self.exercise_master)
            day['day_index'] = day_index
            days.append(day)

        return {"days": days}

# Singleton
workout_recommender = WorkoutRecommender()
```

File: `app/services/meal_planner.py`

```python
from pathlib import Path
import pandas as pd
from app.config import settings
from app.services.meal_composer import compose_meal_day, find_alternative_meal

class MealPlanner:
    def __init__(self):
        self.is_ready = False
        try:
            self.foods_master = pd.read_parquet(settings.DATA_DIR / 'food_master.parquet')
            self.is_ready = True
        except FileNotFoundError as e:
            print(f"⚠️  Foods master missing: {e}")

    def infer_week(self, profile: dict, excluded_food_ids: list[str]) -> dict:
        if not self.is_ready:
            raise ValueError("Foods master belum dimuat.")

        days = []
        seen_main_foods = set()  # diversifier
        for day_index in range(7):
            day = compose_meal_day(profile, day_index, self.foods_master, excluded_food_ids, seen_main_foods)
            days.append(day)
        return {"days": days}

    def find_alternative(self, target_calories, budget_idr, diet_restrictions, exclude_food_ids):
        return find_alternative_meal(
            self.foods_master, target_calories, budget_idr, diet_restrictions, exclude_food_ids,
        )

meal_planner = MealPlanner()
```

## 9. Dockerfile

File: `ml-service/Dockerfile`

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# System deps untuk pyarrow
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app
COPY main.py .

# Model files harus sudah ada di app/data/ (dari hasil training notebook)
# Jangan masukkan ke .dockerignore

EXPOSE 8001

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8001", "--workers", "2"]
```

`.dockerignore`:
```
.venv
__pycache__
*.pyc
notebooks/
.pytest_cache
.env
```

## 10. Smoke Test

```bash
# Start service
uvicorn main:app --reload --port 8001

# Test health
curl http://localhost:8001/healthz

# Test workout inference
curl -X POST http://localhost:8001/infer/workout \
  -H "X-ML-KEY: dev-shared-secret" \
  -H "Content-Type: application/json" \
  -d '{
    "profile": {
      "bmi": 26.5,
      "bmi_category": "OVERWEIGHT",
      "gender": "MALE",
      "age": 22,
      "fitness_level": "BEGINNER",
      "workout_mode": "GYM",
      "days_per_week": 4,
      "session_minutes": 45,
      "conditions": []
    }
  }'

# Expected: 200 OK + {"days": [...]}

# Test meal inference
curl -X POST http://localhost:8001/infer/meal \
  -H "X-ML-KEY: dev-shared-secret" \
  -H "Content-Type: application/json" \
  -d '{
    "profile": {
      "tdee": 2200,
      "target_calorie_adj": -350,
      "budget_per_day_idr": 35000,
      "meal_frequency": 3,
      "diet_restrictions": ["halal"]
    },
    "excluded_food_ids": []
  }'
```

## 11. pytest Test

File: `tests/test_workout.py`

```python
import pytest
from httpx import AsyncClient, ASGITransport
from main import app

@pytest.mark.asyncio
async def test_health():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        r = await client.get("/healthz")
        assert r.status_code == 200
        assert r.json()["status"] == "ok"

@pytest.mark.asyncio
async def test_workout_unauthorized():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        r = await client.post("/infer/workout", json={"profile": {}})
        assert r.status_code == 401  # missing X-ML-KEY

@pytest.mark.asyncio
async def test_workout_inference():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        payload = {
            "profile": {
                "bmi": 24.0, "bmi_category": "NORMAL",
                "gender": "FEMALE", "age": 28,
                "fitness_level": "INTERMEDIATE",
                "workout_mode": "HOME",
                "days_per_week": 4, "session_minutes": 30,
                "conditions": [],
            }
        }
        r = await client.post("/infer/workout", json=payload, headers={"X-ML-KEY": "dev-shared-secret"})
        assert r.status_code == 200
        data = r.json()
        assert len(data["days"]) == 7
        assert all(0 <= d["day_index"] <= 6 for d in data["days"])
```

Run:
```bash
pytest tests/ -v
```

## 12. Deployment ke Render

1. New Web Service → Connect GitHub repo (folder `ml-service/`)
2. Runtime: **Docker**
3. Add env vars: `ML_SERVICE_KEY`, `ENABLE_DOCS=false`, `LOG_LEVEL=INFO`
4. Free tier sleep 15 menit idle. Untuk demo, ping `/healthz` setiap 5 menit (UptimeRobot).

Atau Railway:
1. New Project → Deploy from GitHub repo
2. Pilih folder `ml-service`
3. Build command: `pip install -r requirements.txt`
4. Start command: `uvicorn main:app --host 0.0.0.0 --port $PORT --workers 2`
5. Env vars sama

## 13. Logging in Production

Setiap inference dicatat:
```python
logger.info(f"workout_infer: bmi={profile['bmi']}, level={profile['fitness_level']}, mode={profile['workout_mode']}")
```

Saat error edge case:
```python
logger.warning(f"empty_pool: profile={profile}, mode={mode}")
```

Pino-style structured logging dengan `python-json-logger` opsional pasca-hackathon.

## 14. CORS

ML service **tidak** terima request dari mobile langsung — hanya dari Express. Tidak perlu CORS middleware. Kalau perlu (testing), tambahkan di `main.py`:

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_methods=["*"],
    allow_headers=["*"],
)
```

from contextlib import asynccontextmanager
from fastapi import FastAPI
from app.api import health, workout, meal, replan, food_scan


@asynccontextmanager
async def lifespan(app: FastAPI):
    print("[ML] Pre-loading models on startup...")

    try:
        from app.services.workout_service import _load_models
        _load_models()
        print("[ML] OK Workout model loaded")
    except Exception as e:
        print(f"[ML] WARN Workout model failed: {e}")

    try:
        from app.services.meal_service import _load_data
        _load_data()
        print("[ML] OK Meal data loaded")
    except Exception as e:
        print(f"[ML] WARN Meal data failed: {e}")

    try:
        from app.services.replan_service import _load
        _load()
        print("[ML] OK Replanner model loaded")
    except Exception as e:
        print(f"[ML] WARN Replanner failed: {e}")

    try:
        from app.services.food_scan_service import _load
        _load()
        print("[ML] OK Food scan model loaded")
    except Exception as e:
        print(f"[ML] WARN Food scan failed: {e}")

    print("[ML] All models ready. Serving on port 8001.")
    yield
    print("[ML] Shutting down.")


app = FastAPI(
    title="Heltigo ML Service",
    description="Internal ML inference API — workout, meal, replan, food scan (+ Gemini Vision).",
    version="1.0.0",
    docs_url="/docs",
    redoc_url=None,
    lifespan=lifespan,
)

app.include_router(health.router,    tags=["Health"])
app.include_router(workout.router,   tags=["Workout"])
app.include_router(meal.router,      tags=["Meal"])
app.include_router(replan.router,    tags=["Replan"])
app.include_router(food_scan.router, tags=["Food Scan"])


if __name__ == "__main__":
    import uvicorn
    from app.config import get_settings
    uvicorn.run("main:app", host="0.0.0.0", port=get_settings().PORT, reload=True)

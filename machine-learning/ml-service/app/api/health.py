from fastapi import APIRouter
from datetime import datetime, timezone

router = APIRouter()


@router.get("/health")
async def health():
    return {
        "status":    "ok",
        "service":   "heltigo-ml",
        "version":   "1.0.0",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "models":    ["workout-v3", "meal-knapsack-ga-v3", "replanner-xgb", "food-scan-tfidf+gemini"],
    }

from fastapi import APIRouter, Depends, HTTPException
from app.deps import verify_ml_key
from app.schemas.food_scan import FoodScanRequest, FoodScanResponse, FoodMatchOut, NutritionTotalOut
from app.services.food_scan_service import analyze_food_scan, identify_foods_with_gemini
from app.config import get_settings

router   = APIRouter()
settings = get_settings()


@router.post("/predict/food-scan", response_model=FoodScanResponse)
async def food_scan(req: FoodScanRequest, _: str = Depends(verify_ml_key)):
    identified_by_gemini = None

    if req.image_base64:
        if not settings.GEMINI_API_KEY:
            raise HTTPException(
                status_code=503,
                detail={"code": "GEMINI_NOT_CONFIGURED", "message": "Set GEMINI_API_KEY di .env"},
            )
        identified_by_gemini = await identify_foods_with_gemini(req.image_base64)
        foods_to_analyze = identified_by_gemini
    elif req.identified_foods:
        foods_to_analyze = req.identified_foods
    else:
        raise HTTPException(
            status_code=400,
            detail={"code": "NO_INPUT", "message": "Provide image_base64 OR identified_foods"},
        )

    result = analyze_food_scan(
        identified_foods=foods_to_analyze,
        user_goal=req.user_goal,
        user_condition=req.user_condition,
        portions=req.portions,
    )
    return FoodScanResponse(
        identified_by_gemini=identified_by_gemini,
        matches=[FoodMatchOut(**m) for m in result["matches"]],
        nutrition_total=NutritionTotalOut(**result["nutrition_total"]),
        health_score=result["health_score"],
        assessment=result["assessment"],
        user_goal=result["user_goal"],
        user_condition=result["user_condition"],
    )

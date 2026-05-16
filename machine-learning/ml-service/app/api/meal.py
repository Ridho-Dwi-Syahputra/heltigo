from fastapi import APIRouter, Depends
from app.deps import verify_ml_key
from app.schemas.meal import (
    MealPlanRequest, MealPlanResponse, MealDayOut, MealOut, FoodItemOut,
    MealAlternativeRequest, MealAlternativeResponse,
)
from app.services.meal_service import predict_meal_plan, get_meal_alternatives

router = APIRouter()


@router.post("/predict/meal-plan", response_model=MealPlanResponse)
async def meal_plan(req: MealPlanRequest, _: str = Depends(verify_ml_key)):
    result = predict_meal_plan(
        tdee=req.tdee,
        target_calorie_adj=req.target_calorie_adj,
        budget_per_day_idr=req.budget_per_day_idr,
        meal_frequency=req.meal_frequency,
        goal=req.goal,
        dietary_restrictions=req.dietary_restrictions,
        excluded_food_ids=req.excluded_food_ids,
        user_condition=req.user_condition,
    )
    days = [
        MealDayOut(
            day_index=d["day_index"],
            total_calories=d["total_calories"],
            total_protein_g=d["total_protein_g"],
            total_fat_g=d["total_fat_g"],
            total_carbs_g=d["total_carbs_g"],
            total_cost_idr=d["total_cost_idr"],
            meals=[
                MealOut(
                    meal_type=m["meal_type"],
                    total_calories=m["total_calories"],
                    total_cost_idr=m["total_cost_idr"],
                    foods=[FoodItemOut(**f) for f in m["foods"]],
                )
                for m in d["meals"]
            ],
        )
        for d in result["days"]
    ]
    return MealPlanResponse(
        days=days,
        diversity_score=result["diversity_score"],
        calorie_coverage_pct=result["calorie_coverage_pct"],
    )


@router.post("/predict/meal-alternatives", response_model=MealAlternativeResponse)
async def meal_alternatives(req: MealAlternativeRequest, _: str = Depends(verify_ml_key)):
    alts = get_meal_alternatives(
        food_id=req.food_id,
        meal_type=req.meal_type,
        goal=req.goal,
        dietary_restrictions=req.dietary_restrictions,
        budget_max=req.budget_max_idr,
    )
    return MealAlternativeResponse(alternatives=[FoodItemOut(**a) for a in alts])

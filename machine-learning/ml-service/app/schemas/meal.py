from pydantic import BaseModel, Field


class MealPlanRequest(BaseModel):
    tdee: int = Field(..., ge=800, le=5000)
    target_calorie_adj: int = Field(default=0, ge=-800, le=800)
    budget_per_day_idr: int = Field(default=35000, ge=10000, le=200000)
    meal_frequency: int = Field(default=3, ge=2, le=4)
    goal: str = Field(default="MAINTENANCE")
    dietary_restrictions: list[str] = Field(default_factory=list)
    excluded_food_ids: list[int] = Field(default_factory=list)
    user_condition: str = Field(default="None")


class FoodItemOut(BaseModel):
    food_id: int
    name: str
    category: str
    calories: float
    protein_g: float
    fat_g: float
    carbs_g: float
    price_idr: int
    is_halal: bool


class MealOut(BaseModel):
    meal_type: str
    total_calories: float
    total_cost_idr: int
    foods: list[FoodItemOut]


class MealDayOut(BaseModel):
    day_index: int
    total_calories: float
    total_protein_g: float
    total_fat_g: float
    total_carbs_g: float
    total_cost_idr: int
    meals: list[MealOut]


class MealPlanResponse(BaseModel):
    days: list[MealDayOut]
    diversity_score: float
    calorie_coverage_pct: float
    algorithm: str = "knapsack-ga-v3"


class MealAlternativeRequest(BaseModel):
    food_id: int
    meal_type: str
    goal: str = "MAINTENANCE"
    dietary_restrictions: list[str] = Field(default_factory=list)
    budget_max_idr: int = 20000


class MealAlternativeResponse(BaseModel):
    alternatives: list[FoodItemOut]

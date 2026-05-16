from pydantic import BaseModel, Field
from typing import Optional


class FoodScanRequest(BaseModel):
    image_base64: Optional[str] = Field(None, description="Base64 encoded image dari kamera")
    identified_foods: Optional[list[str]] = Field(None, description="Nama makanan jika sudah diidentifikasi")
    user_goal: str = Field(default="MAINTENANCE")
    user_condition: str = Field(default="None")
    portions: Optional[list[float]] = None


class FoodMatchOut(BaseModel):
    query: str
    matched: Optional[str] = None
    confidence: float
    calories: Optional[float] = None
    protein_g: Optional[float] = None
    fat_g: Optional[float] = None
    carbs_g: Optional[float] = None
    category: Optional[str] = None
    is_halal: Optional[bool] = None


class NutritionTotalOut(BaseModel):
    calories: float
    protein_g: float
    fat_g: float
    carbs_g: float


class FoodScanResponse(BaseModel):
    identified_by_gemini: Optional[list[str]] = None
    matches: list[FoodMatchOut]
    nutrition_total: NutritionTotalOut
    health_score: float
    assessment: str
    user_goal: str
    user_condition: str

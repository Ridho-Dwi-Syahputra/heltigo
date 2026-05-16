from pydantic_settings import BaseSettings
from pathlib import Path
from functools import lru_cache


class Settings(BaseSettings):
    ML_SERVICE_KEY: str = "dev-shared-secret"
    PORT: int = 8001
    GEMINI_API_KEY: str = ""
    MODEL_BASE_PATH: str = ""

    class Config:
        env_file = ".env"

    @property
    def model_base(self) -> Path:
        if self.MODEL_BASE_PATH:
            return Path(self.MODEL_BASE_PATH)
        # Auto-detect: ml-service/ → machine-learning/notebook/training_model/
        return Path(__file__).parent.parent.parent / "notebook" / "training_model"

    # ── Model 1: Workout ──
    @property
    def WORKOUT_TYPE_PKL(self) -> Path:
        return self.model_base / "Model_Rekomendasi_Latihan/output/models/workout_xgb_v3_type.pkl"

    @property
    def WORKOUT_INTENSITY_PKL(self) -> Path:
        return self.model_base / "Model_Rekomendasi_Latihan/output/models/workout_xgb_v3_intensity.pkl"

    @property
    def WORKOUT_SCALER_PKL(self) -> Path:
        return self.model_base / "Model_Rekomendasi_Latihan/output/models/scaler_v3.pkl"

    @property
    def WORKOUT_RULES_JSON(self) -> Path:
        return self.model_base / "Model_Rekomendasi_Latihan/output/models/workout_rules_config.json"

    # ── Model 2: Meal ──
    @property
    def FOOD_MASTER_PARQUET(self) -> Path:
        return self.model_base / "Model_Perencana_Makan/output/preprocessed/food_master_v3.parquet"

    @property
    def KNAPSACK_CONFIG_JSON(self) -> Path:
        return self.model_base / "Model_Perencana_Makan/output/models/knapsack_config_v3.json"

    # ── Model 4: Food Scan (Analisa Makanan) ──
    @property
    def FOOD_VECTORIZER_PKL(self) -> Path:
        return self.model_base / "Model_Analisa_Makanan/output/models/food_tfidf_vectorizer.pkl"

    @property
    def FOOD_MATRIX_NPY(self) -> Path:
        return self.model_base / "Model_Analisa_Makanan/output/models/food_name_matrix.npy"

    @property
    def NUTRITION_SCORER_PKL(self) -> Path:
        return self.model_base / "Model_Analisa_Makanan/output/models/nutrition_scorer.pkl"

    @property
    def SCANNER_CONFIG_JSON(self) -> Path:
        return self.model_base / "Model_Analisa_Makanan/output/models/scanner_config.json"

    @property
    def ALIAS_MAP_JSON(self) -> Path:
        return self.model_base / "Model_Analisa_Makanan/output/preprocessed/alias_map.json"

    @property
    def FOOD_PROCESSED_PARQUET(self) -> Path:
        return self.model_base / "Model_Analisa_Makanan/output/preprocessed/food_processed.parquet"

    # ── Model 3: Adaptif Replanner ──
    @property
    def REPLANNER_PKL(self) -> Path:
        return self.model_base / "Model_Adaptif_Perencanaan_Ulang/output/models/replanner_xgb.pkl"


@lru_cache()
def get_settings() -> Settings:
    return Settings()

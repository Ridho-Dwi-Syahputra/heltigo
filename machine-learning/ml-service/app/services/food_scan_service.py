import joblib
import json
import numpy as np
import pandas as pd
import unicodedata
import re
import base64
from sklearn.metrics.pairwise import cosine_similarity
from app.config import get_settings

settings     = get_settings()
_vectorizer  = None
_food_matrix = None
_scorer      = None
_df_food     = None
_alias_map   = None
_config      = None


def _load():
    global _vectorizer, _food_matrix, _scorer, _df_food, _alias_map, _config
    if _vectorizer is None:
        _vectorizer  = joblib.load(settings.FOOD_VECTORIZER_PKL)
        _food_matrix = np.load(settings.FOOD_MATRIX_NPY)
        _scorer      = joblib.load(settings.NUTRITION_SCORER_PKL)
        _df_food     = pd.read_parquet(settings.FOOD_PROCESSED_PARQUET)
        with open(settings.ALIAS_MAP_JSON, encoding="utf-8") as f:
            _alias_map = json.load(f)
        with open(settings.SCANNER_CONFIG_JSON) as f:
            _config = json.load(f)


def _normalize(text: str) -> str:
    text = str(text).lower().strip()
    text = unicodedata.normalize("NFD", text)
    text = "".join(c for c in text if unicodedata.category(c) != "Mn")
    text = re.sub(r"[^a-z0-9\s]", " ", text)
    return re.sub(r"\s+", " ", text).strip()


async def identify_foods_with_gemini(image_base64: str) -> list[str]:
    """Panggil Gemini Vision API untuk identifikasi makanan dari gambar."""
    import google.generativeai as genai
    genai.configure(api_key=settings.GEMINI_API_KEY)
    model    = genai.GenerativeModel("gemini-1.5-flash")
    response = model.generate_content([{
        "parts": [
            {"text": (
                "Identifikasi semua makanan yang terlihat dalam gambar ini. "
                "Berikan jawaban hanya berupa daftar nama makanan dalam Bahasa Indonesia, "
                "satu per baris, tanpa penjelasan tambahan.\n"
                "Contoh:\nnasi goreng\ntelur ceplok\nes teh"
            )},
            {"inline_data": {"mime_type": "image/jpeg", "data": image_base64}},
        ]
    }])
    return [line.strip() for line in response.text.strip().split("\n") if line.strip()]


def analyze_food_scan(
    identified_foods: list[str],
    user_goal: str = "MAINTENANCE",
    user_condition: str = "None",
    portions: list[float] = None,
) -> dict:
    _load()
    portions = portions or [1.0] * len(identified_foods)
    matches  = []
    total_cal = total_prot = total_fat = total_carb = 0.0

    LABEL_MAP = _config["label_map"]
    GOAL_MAP  = {v: int(k) for k, v in _config["goal_map"].items()}
    COND_MAP  = _config["condition_map"]

    for food_name, portion in zip(identified_foods, portions):
        norm = _normalize(food_name)
        if norm in _alias_map:
            norm = _alias_map[norm]

        q_vec  = _vectorizer.transform([norm])
        sims   = cosine_similarity(q_vec, _food_matrix).flatten()
        best_i = int(np.argmax(sims))
        conf   = float(sims[best_i])

        if conf >= 0.20:
            row = _df_food.iloc[best_i]
            cal = float(row["calories_per_portion"]) * portion
            matches.append({
                "query": food_name, "matched": row["name"], "confidence": round(conf, 4),
                "calories": round(cal, 1),
                "protein_g": round(float(row["protein_g"]) * portion, 1),
                "fat_g":     round(float(row["fat_g"])     * portion, 1),
                "carbs_g":   round(float(row["carbs_g"])   * portion, 1),
                "category":  row["category"], "is_halal": bool(row["is_halal"]),
            })
            total_cal  += cal
            total_prot += float(row["protein_g"]) * portion
            total_fat  += float(row["fat_g"])     * portion
            total_carb += float(row["carbs_g"])   * portion
        else:
            matches.append({"query": food_name, "matched": None, "confidence": round(conf, 4)})

    X_in = np.array([[total_cal, total_prot, total_fat, total_carb,
                      len(identified_foods),
                      GOAL_MAP.get(user_goal, 0),
                      COND_MAP.get(user_condition, 0)]])
    pred_label = int(_scorer.predict(X_in)[0])
    pred_proba = _scorer.predict_proba(X_in)[0]

    return {
        "matches": matches,
        "nutrition_total": {
            "calories": round(total_cal, 1), "protein_g": round(total_prot, 1),
            "fat_g": round(total_fat, 1),    "carbs_g":   round(total_carb, 1),
        },
        "health_score":   round(float(max(pred_proba)), 4),
        "assessment":     LABEL_MAP.get(str(pred_label), "MODERATE"),
        "user_goal":      user_goal,
        "user_condition": user_condition,
    }

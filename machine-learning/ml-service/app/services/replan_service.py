import joblib
import numpy as np
from app.config import get_settings

settings   = get_settings()
_replanner = None


def _load():
    global _replanner
    if _replanner is None:
        _replanner = joblib.load(settings.REPLANNER_PKL)


def predict_replan(
    weekly_score: float,
    weight_diff_kg: float,
    bmi: float,
    experience_level: int,
    age: int,
    workout_frequency: int,
) -> dict:
    _load()
    X = np.array([[weekly_score, weight_diff_kg, bmi, experience_level, age, workout_frequency]])
    multiplier = float(_replanner.predict(X)[0])
    multiplier = round(max(0.5, min(1.5, multiplier)), 4)

    if multiplier < 0.85:
        action = "REDUCE"
        rec    = f"Kurangi volume latihan {round((1 - multiplier) * 100)}%. Tubuh perlu lebih banyak recovery minggu ini."
    elif multiplier > 1.10:
        action = "INTENSIFY"
        rec    = f"Tingkatkan volume {round((multiplier - 1) * 100)}%. Progress bagus, siap untuk tantangan lebih besar!"
    else:
        action = "MAINTAIN"
        rec    = "Pertahankan ritme yang ada. Konsistensi adalah kunci keberhasilan."

    return {"volume_multiplier": multiplier, "recommendation": rec, "action": action}

import joblib
import json
from app.config import get_settings

settings = get_settings()

_model_type = None
_model_intensity = None
_scaler = None
_rules = None


def _load_models():
    global _model_type, _model_intensity, _scaler, _rules
    if _model_type is None:
        _model_type      = joblib.load(settings.WORKOUT_TYPE_PKL)
        _model_intensity = joblib.load(settings.WORKOUT_INTENSITY_PKL)
        _scaler          = joblib.load(settings.WORKOUT_SCALER_PKL)
        with open(settings.WORKOUT_RULES_JSON) as f:
            _rules = json.load(f)


CONDITION_OVERRIDES = {
    "INJURY":     {"HIIT": "FLEXIBILITY", "CARDIO": "FLEXIBILITY", "default_intensity": "LOW"},
    "JOINT_PAIN": {"HIIT": "FLEXIBILITY", "default_intensity": "LOW"},
    "PREGNANT":   {"HIIT": "FLEXIBILITY", "STRENGTH": "FLEXIBILITY", "default_intensity": "LOW"},
}

EXERCISE_MAP = {
    "CARDIO":      [("Jogging", "MAIN"), ("Jump Rope", "MAIN"), ("Jumping Jacks", "MAIN")],
    "HIIT":        [("Burpees", "MAIN"), ("Mountain Climbers", "MAIN"), ("Box Jump", "MAIN")],
    "STRENGTH":    [("Push Up", "MAIN"), ("Squat", "MAIN"), ("Plank", "COOLDOWN")],
    "FLEXIBILITY": [("Cat-Cow", "WARMUP"), ("Child Pose", "MAIN"), ("Pigeon Pose", "COOLDOWN")],
}


def _build_exercises(workout_type: str, template: dict, session_minutes: int) -> list[dict]:
    sets      = template.get("sets", 3)
    reps      = template.get("reps", 10)
    rest_secs = template.get("rest_seconds", 60)

    all_ex = [("Dynamic Stretching", "WARMUP")] + EXERCISE_MAP.get(workout_type, [("Jogging", "MAIN")]) + [("Static Stretching", "COOLDOWN")]
    return [
        {"name": name, "phase": phase, "sets": sets if phase == "MAIN" else 1, "reps": reps, "rest_seconds": rest_secs}
        for name, phase in all_ex
    ]


def predict_workout_plan(
    fitness_level: str,
    goal: str,
    bmi: float,
    age: int,
    gender: str = "MALE",
    workout_mode: str = "GYM",
    days_per_week: int = 4,
    session_minutes: int = 60,
    has_injury: bool = False,
    has_chronic: bool = False,
    conditions: list = None,
) -> list[dict]:
    _load_models()
    conditions = conditions or []

    key = f"{fitness_level}_{goal}"
    schedule = _rules["schedule_templates"].get(
        key, ["CARDIO", "REST", "STRENGTH", "REST", "HIIT", "REST", "REST"]
    )
    base_intensity = _rules["intensity_base"].get(fitness_level, "LOW")

    days_out = []
    for day_idx, wtype in enumerate(schedule):
        intensity = base_intensity
        is_rest   = (wtype == "REST")

        if has_injury or "INJURY" in conditions:
            override  = CONDITION_OVERRIDES["INJURY"]
            wtype     = override.get(wtype, wtype)
            intensity = override.get("default_intensity", intensity)

        if bmi >= 35 or "OBESE" in conditions:
            wtype = {"HIIT": "CARDIO"}.get(wtype, wtype)
            int_steps = ["LOW", "MID", "HIGH"]
            intensity = int_steps[max(0, int_steps.index(intensity) - 1)]

        if "PREGNANT" in conditions:
            override  = CONDITION_OVERRIDES["PREGNANT"]
            wtype     = override.get(wtype, wtype)
            intensity = override.get("default_intensity", intensity)

        exercises = []
        if not is_rest:
            tmpl      = _rules["sets_reps_template"].get(intensity, {})
            exercises = _build_exercises(wtype, tmpl, session_minutes)

        days_out.append({
            "day_index":         day_idx,
            "workout_type":      wtype,
            "intensity":         intensity,
            "is_rest_day":       is_rest,
            "estimated_minutes": 0 if is_rest else session_minutes,
            "exercises":         exercises,
        })

    return days_out

"""
Workout Recommender — Rule-Based Engine
"""
SCHEDULE_TEMPLATES = {
    ("BEGINNER",     "WEIGHT_LOSS"):  ["CARDIO","STRENGTH","REST","CARDIO","FLEXIBILITY","REST","REST"],
    ("BEGINNER",     "MUSCLE_GAIN"):  ["STRENGTH","CARDIO","REST","STRENGTH","FLEXIBILITY","REST","REST"],
    ("BEGINNER",     "MAINTENANCE"):  ["STRENGTH","CARDIO","REST","FLEXIBILITY","CARDIO","REST","REST"],
    ("BEGINNER",     "PERFORMANCE"):  ["CARDIO","STRENGTH","REST","HIIT","FLEXIBILITY","REST","REST"],
    ("INTERMEDIATE", "WEIGHT_LOSS"):  ["CARDIO","STRENGTH","CARDIO","REST","STRENGTH","HIIT","REST"],
    ("INTERMEDIATE", "MUSCLE_GAIN"):  ["STRENGTH","STRENGTH","REST","CARDIO","STRENGTH","FLEXIBILITY","REST"],
    ("INTERMEDIATE", "MAINTENANCE"):  ["STRENGTH","CARDIO","FLEXIBILITY","REST","STRENGTH","CARDIO","REST"],
    ("INTERMEDIATE", "PERFORMANCE"):  ["HIIT","STRENGTH","CARDIO","REST","HIIT","STRENGTH","REST"],
    ("ADVANCED",     "WEIGHT_LOSS"):  ["HIIT","STRENGTH","CARDIO","HIIT","STRENGTH","CARDIO","REST"],
    ("ADVANCED",     "MUSCLE_GAIN"):  ["STRENGTH","STRENGTH","CARDIO","REST","STRENGTH","STRENGTH","HIIT"],
    ("ADVANCED",     "MAINTENANCE"):  ["STRENGTH","CARDIO","HIIT","REST","STRENGTH","FLEXIBILITY","CARDIO"],
    ("ADVANCED",     "PERFORMANCE"):  ["HIIT","STRENGTH","HIIT","CARDIO","STRENGTH","HIIT","REST"],
}

INTENSITY_RULES = {
    "BEGINNER":     {"CARDIO":"LOW","STRENGTH":"LOW","FLEXIBILITY":"LOW","HIIT":"LOW","REST":"REST"},
    "INTERMEDIATE": {"CARDIO":"MID","STRENGTH":"MID","FLEXIBILITY":"LOW","HIIT":"MID","REST":"REST"},
    "ADVANCED":     {"CARDIO":"HIGH","STRENGTH":"HIGH","FLEXIBILITY":"LOW","HIIT":"HIGH","REST":"REST"},
}

CONDITION_OVERRIDES = {
    # Group 1: has_injury (JOINT_PAIN, INJURY, BONE_ISSUE)
    "JOINT_PAIN": {"HIIT":"FLEXIBILITY","STRENGTH":"FLEXIBILITY","CARDIO":"FLEXIBILITY"},
    "INJURY":     {"HIIT":"FLEXIBILITY","STRENGTH":"FLEXIBILITY","CARDIO":"FLEXIBILITY"},
    "BONE_ISSUE": {"HIIT":"FLEXIBILITY","STRENGTH":"FLEXIBILITY","CARDIO":"FLEXIBILITY"},
    
    # Group 2: has_chronic (PREGNANT, HYPERTENSION, DIABETES)
    "PREGNANT":   {"HIIT":"CARDIO","STRENGTH":"FLEXIBILITY"},
    "HYPERTENSION":{"HIIT":"CARDIO","STRENGTH":"FLEXIBILITY"},
    "DIABETES":   {"HIIT":"CARDIO","STRENGTH":"FLEXIBILITY"},
}

def _apply_conditions(workout_type, conditions):
    for cond in conditions:
        overrides = CONDITION_OVERRIDES.get(cond, {})
        if workout_type in overrides:
            workout_type = overrides[workout_type]
    return workout_type

def generate_workout_plan(profile):
    fl = profile["fitness_level"]
    goal = profile["goal"]
    conditions = profile.get("conditions", [])
    template = SCHEDULE_TEMPLATES.get((fl, goal), ["REST"]*7)
    intensity_map = INTENSITY_RULES[fl]
    days = []
    for i, wtype in enumerate(template):
        wtype = _apply_conditions(wtype, conditions)
        intensity = "REST" if wtype == "REST" else intensity_map.get(wtype, "LOW")
        days.append({"day_index": i, "workout_type": wtype, "intensity": intensity})
    return {"days": days}

import pandas as pd
import json
import random
from deap import base, creator, tools, algorithms
from app.config import get_settings

settings = get_settings()

_df_food      = None
_knapsack_cfg = None

GOAL_WEIGHTS = {
    "WEIGHT_LOSS": {"protein": 0.4, "fiber": 0.3, "fat_penalty": 0.2, "cal_bonus": 0.1},
    "MUSCLE_GAIN":  {"protein": 0.5, "fiber": 0.1, "fat_penalty": 0.1, "cal_bonus": 0.3},
    "MAINTENANCE":  {"protein": 0.35, "fiber": 0.2, "fat_penalty": 0.2, "cal_bonus": 0.25},
    "PERFORMANCE":  {"protein": 0.4, "fiber": 0.1, "fat_penalty": 0.15, "cal_bonus": 0.35},
}

MEAL_SPLITS = {
    2: {"BREAKFAST": 0.40, "DINNER": 0.60},
    3: {"BREAKFAST": 0.28, "LUNCH": 0.40, "DINNER": 0.32},
    4: {"BREAKFAST": 0.22, "LUNCH": 0.35, "SNACK": 0.10, "DINNER": 0.33},
}


def _load_data():
    global _df_food, _knapsack_cfg
    if _df_food is None:
        _df_food = pd.read_parquet(settings.FOOD_MASTER_PARQUET)
        with open(settings.KNAPSACK_CONFIG_JSON) as f:
            _knapsack_cfg = json.load(f)


def _score(row, goal: str) -> float:
    w     = GOAL_WEIGHTS.get(goal, GOAL_WEIGHTS["MAINTENANCE"])
    price = max(float(row["estimated_price_idr"]), 100)
    return (
        w["protein"]     * row["protein_g"]           / (price / 1000)
        + w["cal_bonus"] * row["calories_per_portion"] / (price / 1000)
        - w["fat_penalty"] * row["fat_g"]             / (price / 1000)
    )


def _filter_pool(goal: str, dietary_restrictions: list, excluded_ids: list) -> pd.DataFrame:
    df = _df_food.copy()
    restr = [r.upper() for r in dietary_restrictions]
    if "HALAL"      in restr: df = df[df["is_halal"]]
    if "VEGETARIAN" in restr: df = df[df["is_vegetarian"]]
    if "VEGAN"      in restr: df = df[df["is_vegan"]]
    if excluded_ids:          df = df[~df["id"].isin(excluded_ids)]
    df = df.reset_index(drop=True)
    df["_score"] = df.apply(lambda r: _score(r, goal), axis=1)
    return df


def _plan_one_meal(df_pool: pd.DataFrame, budget: float, cal_target: float, n_items: int = 3) -> list[dict]:
    selected, total_cal, total_price = [], 0.0, 0.0
    for _, row in df_pool.sort_values("_score", ascending=False).iterrows():
        if len(selected) >= n_items: break
        if total_price + row["estimated_price_idr"] > budget: continue
        if total_cal + row["calories_per_portion"] > cal_target * 1.15: continue
        selected.append(row)
        total_cal   += row["calories_per_portion"]
        total_price += row["estimated_price_idr"]
    return [
        {"food_id": int(r["id"]), "name": r["name"], "category": r["category"],
         "calories": float(r["calories_per_portion"]), "protein_g": float(r["protein_g"]),
         "fat_g": float(r["fat_g"]), "carbs_g": float(r["carbs_g"]),
         "price_idr": int(r["estimated_price_idr"]), "is_halal": bool(r["is_halal"])}
        for r in selected
    ]


def predict_meal_plan(
    tdee: int,
    target_calorie_adj: int = 0,
    budget_per_day_idr: int = 35000,
    meal_frequency: int = 3,
    goal: str = "MAINTENANCE",
    dietary_restrictions: list = None,
    excluded_food_ids: list = None,
    user_condition: str = "None",
) -> dict:
    _load_data()
    dietary_restrictions = dietary_restrictions or []
    excluded_food_ids    = excluded_food_ids or []

    target_cal = tdee + target_calorie_adj
    splits     = MEAL_SPLITS.get(meal_frequency, MEAL_SPLITS[3])
    df_pool    = _filter_pool(goal, dietary_restrictions, excluded_food_ids)
    pool_size  = len(df_pool)
    chromo_len = 7 * meal_frequency

    # DEAP setup (guard against re-registration on hot-reload)
    if not hasattr(creator, "FitnessMax"):
        creator.create("FitnessMax", base.Fitness, weights=(1.0,))
    if not hasattr(creator, "Individual"):
        creator.create("Individual", list, fitness=creator.FitnessMax)

    toolbox = base.Toolbox()
    toolbox.register("food_pick", random.randint, 0, max(pool_size - 1, 0))
    toolbox.register("individual", tools.initRepeat, creator.Individual, toolbox.food_pick, n=chromo_len)
    toolbox.register("population", tools.initRepeat, list, toolbox.individual)

    def fitness(individual):
        score   = sum(float(df_pool.iloc[min(i, pool_size-1)]["_score"]) for i in individual)
        penalty = 0.0
        for d in range(7):
            day_slice = individual[d * meal_frequency: (d + 1) * meal_frequency]
            prev = []
            for p in range(max(0, d - 2), d):
                prev.extend(individual[p * meal_frequency: (p + 1) * meal_frequency])
            for idx in day_slice:
                if df_pool.iloc[min(idx, pool_size-1)]["category"] in ["STAPLE", "PROTEIN"] and idx in prev:
                    penalty += 2.0
        return (score - penalty,)

    toolbox.register("evaluate", fitness)
    toolbox.register("mate",   tools.cxOnePoint)
    toolbox.register("mutate", tools.mutUniformInt, low=0, up=max(pool_size - 1, 0), indpb=0.05)
    toolbox.register("select", tools.selTournament, tournsize=3)

    pop = toolbox.population(n=20)
    pop, _ = algorithms.eaSimple(pop, toolbox, cxpb=0.7, mutpb=0.2, ngen=30, verbose=False)
    best_ind = tools.selBest(pop, k=1)[0]

    meal_types = list(splits.keys())
    days_out, all_names = [], []

    for d in range(7):
        seeds = best_ind[d * meal_frequency: (d + 1) * meal_frequency]
        meals_out = []
        day_cal = day_prot = day_fat = day_carb = 0.0
        day_cost = 0

        for seed, mtype in zip(seeds, meal_types):
            foods    = _plan_one_meal(df_pool, budget_per_day_idr * splits[mtype], target_cal * splits[mtype])
            m_cal    = sum(f["calories"]  for f in foods)
            m_cost   = sum(f["price_idr"] for f in foods)
            meals_out.append({"meal_type": mtype, "total_calories": m_cal, "total_cost_idr": m_cost, "foods": foods})
            day_cal  += m_cal
            day_prot += sum(f["protein_g"] for f in foods)
            day_fat  += sum(f["fat_g"]     for f in foods)
            day_carb += sum(f["carbs_g"]   for f in foods)
            day_cost += m_cost
            all_names.extend(f["name"] for f in foods)

        days_out.append({
            "day_index": d, "total_calories": round(day_cal, 1),
            "total_protein_g": round(day_prot, 1), "total_fat_g": round(day_fat, 1),
            "total_carbs_g": round(day_carb, 1), "total_cost_idr": day_cost, "meals": meals_out,
        })

    diversity = len(set(all_names)) / max(len(all_names), 1)
    avg_cal   = sum(d["total_calories"] for d in days_out) / 7
    return {"days": days_out, "diversity_score": round(diversity, 4), "calorie_coverage_pct": round(avg_cal / max(target_cal, 1) * 100, 1)}


def get_meal_alternatives(food_id: int, meal_type: str, goal: str, dietary_restrictions: list, budget_max: int) -> list[dict]:
    _load_data()
    df_pool = _filter_pool(goal, dietary_restrictions, [])
    target  = _df_food[_df_food["id"] == food_id]
    df_cat  = df_pool[df_pool["category"] == target.iloc[0]["category"]] if not target.empty else df_pool
    df_cat  = df_cat[(df_cat["estimated_price_idr"] <= budget_max) & (df_cat["id"] != food_id)]
    return [
        {"food_id": int(r["id"]), "name": r["name"], "category": r["category"],
         "calories": float(r["calories_per_portion"]), "protein_g": float(r["protein_g"]),
         "fat_g": float(r["fat_g"]), "carbs_g": float(r["carbs_g"]),
         "price_idr": int(r["estimated_price_idr"]), "is_halal": bool(r["is_halal"])}
        for _, r in df_cat.sort_values("_score", ascending=False).head(3).iterrows()
    ]

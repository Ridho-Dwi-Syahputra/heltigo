# Machine Learning — Feature Engineering

> 📌 **Standardisasi naming 2026-05-15:**
> - **Sleep band:** gunakan ID `LT5`, `B5_6`, `B6_7`, `B7_8`, `GT8` (bukan `<5`, `5-6`, dst) untuk DB enum compatibility.
> - **Workout type:** `STRENGTH`, `CARDIO`, `HIIT`, `FLEXIBILITY`, `REST` (5 kelas).
> - **Intensity:** `LOW`, `MID`, `HIGH` (3 kelas).
> - **Goal:** `WEIGHT_LOSS`, `MUSCLE_GAIN`, `MAINTENANCE`, `PERFORMANCE` (4 values, sesuai DB enum `health_profiles.goal`).
>
> Feature lengkap per model: [`FE-model-requirement/01_MODELS_SPEC.md`](FE-model-requirement/01_MODELS_SPEC.md).
>
> Post-processing rules tambahan (exercise mapping + contraindication, e.g., `low_back_pain` → exclude squat/deadlift): lihat `01_MODELS_SPEC.md` §Model 1 Post-Processing.

---

Daftar fitur yang dipakai per model, transformasi yang diperlukan, dan handling missing/edge cases.

## 1. Workout Recommender Features

13 fitur input.

### 1.1 Numerikal

| Fitur | Range | Sumber | Catatan |
|---|---|---|---|
| `bmi` | 12-50 | profile.bmi (precomputed) | Clip ke [12, 50], di luar = invalid |
| `age` | 10-100 | profile.age | Validasi server |
| `days_per_week` | 3-5 | profile.days_per_week | Limit dari setup |
| `session_minutes` | 15-60 | profile.session_minutes | Enum |
| `day_index` | 0-6 | derived (urutan hari Senin..Minggu) | Untuk membedakan hari ke-1 vs ke-5 |

### 1.2 Kategorikal Encoded

| Fitur | Encoding | Sumber |
|---|---|---|
| `bmi_cat_enc` | UNDERWEIGHT=0, NORMAL=1, OVERWEIGHT=2, OBESE=3 | profile.bmi_category |
| `gender_enc` | MALE=0, FEMALE=1 | profile.gender |
| `age_band_enc` | <25=0, 25-35=1, 35-50=2, >50=3 | derived dari age |
| `fitness_level_enc` | BEGINNER=0, INTERMEDIATE=1, ADVANCED=2 | profile.fitness_level |
| `mode_enc` | HOME=0, GYM=1 | profile.workout_mode |

### 1.3 Boolean

| Fitur | Encoding | Sumber |
|---|---|---|
| `is_first_day_of_week` | True=1, False=0 | day_index == 0 |
| `has_injury` | bool | "JOINT_PAIN" or "INJURY" in conditions |
| `has_chronic_condition` | bool | "DIABETES" or "HYPERTENSION" or "BONE_ISSUE" or "PREGNANT" in conditions |

### 1.4 Helper untuk Extract Features

```python
def extract_feature(profile: dict, day_index: int, feature_name: str):
    if feature_name == 'bmi':
        return min(50, max(12, profile['bmi']))
    if feature_name == 'bmi_cat_enc':
        return {'UNDERWEIGHT': 0, 'NORMAL': 1, 'OVERWEIGHT': 2, 'OBESE': 3}[profile['bmi_category']]
    if feature_name == 'gender_enc':
        return 0 if profile['gender'] == 'MALE' else 1
    if feature_name == 'age':
        return profile['age']
    if feature_name == 'age_band_enc':
        age = profile['age']
        if age < 25: return 0
        if age < 35: return 1
        if age < 50: return 2
        return 3
    if feature_name == 'fitness_level_enc':
        return {'BEGINNER': 0, 'INTERMEDIATE': 1, 'ADVANCED': 2}[profile['fitness_level']]
    if feature_name == 'mode_enc':
        return 0 if profile['workout_mode'] == 'HOME' else 1
    if feature_name == 'days_per_week':
        return profile['days_per_week']
    if feature_name == 'session_minutes':
        return profile['session_minutes']
    if feature_name == 'day_index':
        return day_index
    if feature_name == 'is_first_day_of_week':
        return 1 if day_index == 0 else 0
    if feature_name == 'has_injury':
        return 1 if any(c in ['JOINT_PAIN', 'INJURY', 'BONE_ISSUE'] for c in profile.get('conditions', [])) else 0
    if feature_name == 'has_chronic_condition':
        chronic = ['DIABETES', 'HYPERTENSION', 'PREGNANT']
        return 1 if any(c in chronic for c in profile.get('conditions', [])) else 0
    raise ValueError(f"Unknown feature: {feature_name}")
```

## 2. Meal Planner Features

Knapsack tidak butuh ML training, tapi tetap pakai fitur untuk filtering & scoring.

### 2.1 Per-Food Features (untuk scoring)

| Fitur | Tipe | Sumber | Catatan |
|---|---|---|---|
| `calories_kcal` | int | foods_master | Per porsi |
| `protein_g` | float | foods_master | Per porsi |
| `carb_g` | float | foods_master | Per porsi |
| `fat_g` | float | foods_master | Per porsi |
| `fiber_g` | float | foods_master | Sering missing → fillna(0) |
| `estimated_price_idr` | int | foods_master (augmented) | Heuristic |
| `category` | string enum | foods_master (augmented) | STAPLE/PROTEIN/VEGETABLE/etc |
| `is_halal` | bool | foods_master (augmented) | Filter |
| `is_vegetarian` | bool | foods_master (augmented) | Filter |
| `contains_nuts` | bool | augmented | Filter |
| `contains_dairy` | bool | augmented | Filter |

### 2.2 Per-Profile Features (untuk constraint)

| Fitur | Sumber |
|---|---|
| `tdee` | profile.tdee |
| `target_calorie_adj` | profile.target_calorie_adj (signed) |
| `budget_per_day_idr` | profile.budget_per_day |
| `meal_frequency` | profile.meal_frequency (2-4) |
| `diet_restrictions` | profile.diet_restrictions (list) |
| `goal` | profile.goal (untuk scoring weight) |

### 2.3 Computed: Daily Calorie Target

```python
def daily_calorie_target(profile: dict) -> int:
    return profile['tdee'] + profile['target_calorie_adj']
```

### 2.4 Computed: Per-Meal Allocation

```python
ALLOCATION_TABLE = {
    2: {'BREAKFAST': 0.45, 'DINNER': 0.55},
    3: {'BREAKFAST': 0.30, 'LUNCH': 0.40, 'DINNER': 0.30},
    4: {'BREAKFAST': 0.25, 'LUNCH': 0.35, 'SNACK': 0.10, 'DINNER': 0.30},
}
```

### 2.5 Score Function (Per Item)

```python
GOAL_WEIGHTS = {
    'LOSE_WEIGHT': {'protein': 0.5, 'calories': 0.2, 'fiber': 0.3, 'fat_penalty': -0.2},
    'MAINTAIN':    {'protein': 0.4, 'calories': 0.3, 'fiber': 0.2, 'fat_penalty': -0.1},
    'GAIN_MUSCLE': {'protein': 0.6, 'calories': 0.3, 'fiber': 0.1, 'fat_penalty': 0.0},
}

def score_food(food: pd.Series, goal: str) -> float:
    w = GOAL_WEIGHTS[goal]
    price = max(food['estimated_price_idr'], 1000)  # avoid div by zero
    score = (
        w['protein'] * food['protein_g'] / price * 1000 +
        w['calories'] * food['calories_kcal'] / price * 1000 +
        w['fiber'] * food.get('fiber_g', 0) / price * 1000 +
        w['fat_penalty'] * food['fat_g'] / price * 1000
    )
    return score
```

## 3. Replanner Features

### 3.1 Numerikal

| Fitur | Range | Sumber |
|---|---|---|
| `score_percent` | 0-100 | dihitung di backend (scoring.service.ts) |
| `workout_done_count` | 0-N | checklist aggregation |
| `workout_total_count` | 0-N | plan workout days |
| `meal_done_count` | 0-N | checklist meal aggregation |
| `meal_total_count` | 0-N | plan meal days × meals/day |
| `weight_change_kg` | signed float | weight_logs delta |
| `weight_target_change_kg` | signed float | derived dari profile target |

### 3.2 Categorical / List

| Fitur | Tipe | Sumber |
|---|---|---|
| `most_skipped_exercise_ids` | list[str] | aggregation top-3 |
| `profile.fitness_level` | enum | profile |
| `profile.goal` | enum | profile |
| `previous_plan.workout_days` | list of dicts | plan |
| `previous_plan.meal_days` | list of dicts | plan |

### 3.3 Derived: Strategy

```python
def determine_strategy(score_percent: float) -> str:
    if score_percent < 50: return 'REDUCE'
    if score_percent <= 80: return 'MAINTAIN_SWAP'
    return 'INTENSIFY'
```

## 4. Workout Adjuster Features

### 4.1 Input

| Fitur | Range | Validasi |
|---|---|---|
| `mood` | 1-5 | int strict |
| `energy` | 1-5 | int strict |
| `sleep_band` | enum | one of '<5', '5-6', '6-7', '7-8', '>8' |

### 4.2 Output

| Fitur | Range | Catatan |
|---|---|---|
| `adjustment` | -0.5..+0.2 | Multiplier offset (factor = 1 + adjustment) |

Lookup dari `ADJUSTMENT_TABLE` di `03_MODELS.md` §2.3.

## 5. Handling Missing Values

### 5.1 Foods Dataset

| Field | Missing handling |
|---|---|
| `fiber_g` | fillna(0) — sebagian besar dataset memang tidak ada |
| `serving_grams` | fillna(150) — default ukuran porsi |
| `serving_label` | fillna("1 porsi") |
| `image_url` | fillna(None) — null di response |
| Kalori/protein/karbo/lemak | dropna() — wajib ada, drop row jika tidak |

### 5.2 Profile

Semua field profile **wajib** sebelum panggil ML. Backend harus validasi sebelum call FastAPI. Kalau ada yang null, raise `400 INVALID_PROFILE`.

### 5.3 Plan / Checklist (untuk Replanner)

- Tidak ada checklist sama sekali → `score = 0`, strategi = REDUCE
- Plan baru (week 1, belum pernah replan) → seharusnya cron tidak trigger; jika trigger, no-op

## 6. Edge Cases Penting

### 6.1 Workout Recommender

| Edge case | Penanganan |
|---|---|
| BMI < 12 atau > 50 | Reject di backend, error 422 |
| Conditions = ['PREGNANT'] | Force LOW intensity, hindari high-impact |
| Mode HOME tapi pool BODYWEIGHT kosong | Fallback: pakai exercises difficulty BEGINNER apa pun |
| session_minutes = 15 | Compose hanya MAIN exercises, skip warmup/cooldown formal |

### 6.2 Meal Planner

| Edge case | Penanganan |
|---|---|
| Budget < Rp10.000 | Tampilkan warning di response: "Budget sangat ketat, kualitas gizi terbatas" |
| Halal + Vegetarian + No-nuts + No-dairy → pool sangat kecil | Relax constraint terendah, log warning |
| Calorie target > 4000 (extreme bulk) | Cap ke 4000 untuk safety |
| Tidak ada food yang fit di bawah budget | Return empty `foods=[]`, log error untuk follow-up |

### 6.3 Replanner

| Edge case | Penanganan |
|---|---|
| score_percent = 0 (user pasif total) | Strategi REDUCE + AI message: "Mari mulai dari yang lebih ringan" |
| weight_change kontradiksi target (e.g. mau turun tapi naik 1kg) | Naikkan defisit kalori 100kkal, log alert |
| previous_plan kosong | No-op |

## 7. Scaling & Normalisasi

Karena pakai Random Forest (tree-based), **tidak perlu standardize/normalize**. RF tidak sensitive terhadap skala fitur.

Untuk model lain (jika nanti pakai linear/SVM): apply `StandardScaler` di pipeline:
```python
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline

pipe = Pipeline([
    ('scaler', StandardScaler()),
    ('clf', SomeModel()),
])
```

Untuk hackathon, RF sudah cukup, skip scaling.

## 8. Feature Importance (Validasi)

Setelah train RF, plot feature importance untuk validasi:

```python
import matplotlib.pyplot as plt

importances = best_model.estimators_[0].feature_importances_
fig, ax = plt.subplots(figsize=(10, 6))
ax.barh(features, importances)
ax.set_xlabel('Feature Importance')
ax.set_title('Workout Recommender — Feature Importance')
plt.tight_layout()
plt.savefig('../notebooks/figs/workout_feature_importance.png')
```

Expected top features: `bmi`, `fitness_level_enc`, `day_index`, `mode_enc`. Jika `gender_enc` atau `has_injury` di top, mungkin ada bias di synthetic data — tweak rules.

## 9. Encoding Consistency

**Penting:** label encoder yang dipakai saat training **harus sama** dengan saat inference. Karena itu disimpan di joblib bundle:

```python
joblib.dump({
    'model': model,
    'le_type': le_type,        # LabelEncoder fitted
    'le_intensity': le_intensity,
    'features': features,       # urutan kolom input
}, 'workout_rf.joblib')
```

Saat inference:
```python
bundle = joblib.load('workout_rf.joblib')
preds = bundle['model'].predict(X_df[bundle['features']])  # urutan harus match
type_str = bundle['le_type'].inverse_transform(preds[:, 0])
```

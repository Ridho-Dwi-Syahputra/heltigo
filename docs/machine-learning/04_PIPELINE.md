# Machine Learning — Training Pipeline

> 📌 **Detail augmentation 2026-05-15** — Lihat [`FE-model-requirement/02_DATASETS_INVENTORY.md`](FE-model-requirement/02_DATASETS_INVENTORY.md) §3.2:
>
> - **Workout RF augmentation:** 973 rows → ~6,800 rows via expand-to-7-day per user + synthetic label rules (`Beginner+BMI>27` → CARDIO/LOW; `Advanced+BMI<25` → STRENGTH+HIIT/MID-HIGH).
> - **Nutrition augmentation:** `nutrition.csv` (1,346 rows) + heuristic columns (`category`, `estimated_price_idr = base_price[cat] * (1 + calories/500)`, `is_halal`, `is_vegetarian`, `is_vegan`, `is_gluten_free`).
> - **600K+ programs file (294 MB):** chunked loading (`pd.read_csv(..., chunksize=10000)`) → filter ~200 entri kurasi.
> - **Random seed = 42** untuk semua training (reproducibility).

---

## 1. Pipeline Overview

```
┌──────────────┐
│  Raw CSV     │  notebook/dataset/Model_*/
│  Datasets    │
└──────┬───────┘
       │ (Day 1-2: EDA)
       ▼
┌──────────────┐
│  Cleaning    │  notebook/03_clean_workout.ipynb
│              │  notebook/04_clean_nutrition.ipynb
└──────┬───────┘
       │ → notebook/dataset/clean/*.parquet
       ▼
┌──────────────────┐
│ Feature          │  app/services/feature_eng.py
│ Engineering      │  (helper functions, dipanggil saat training & inference)
└──────┬───────────┘
       │
       ▼
┌──────────────┐
│ Training     │  notebook/05_train_workout_rf.ipynb
│ (offline)    │  notebook/06_meal_optimizer_dev.ipynb
│              │  notebook/07_replanner_logic.ipynb
└──────┬───────┘
       │ → app/data/*.joblib
       ▼
┌──────────────────┐
│ FastAPI Service  │  app/services/*.py
│ (load di startup)│  app/api/*.py
└──────┬───────────┘
       │
       ▼
┌──────────────┐
│  Inference   │  POST /infer/* via Express
│  Real-time   │
└──────────────┘
```

## 2. Notebook Sequence (Per Day)

### Day 1 — EDA

`notebooks/01_eda_workout.ipynb`:
- Load `gym_member_exercise_dataset/gym_members_exercise_tracking.csv`
- `df.info()`, `df.describe()`, `df.isnull().sum()`
- Visualisasi: distribusi BMI, gender ratio, workout type counts
- Korelasi antar fitur fisiologis
- Output: catatan data quality issues

`notebooks/02_eda_nutrition.ipynb`:
- Load `nutrition.csv`
- Cek format kolom (string vs numerik)
- Distribusi kalori/protein/karbo per kategori (jika ada)
- Identifikasi food yang outlier (kalori >2000 atau <10)

### Day 2 — Cleaning

`notebooks/03_clean_workout.ipynb`:
- Drop missing target
- Encode kategorikal
- Drop outlier (BMI <12 atau >50, session >4 jam)
- Save: `dataset/clean/workout_clean.parquet`

`notebooks/04_clean_nutrition.ipynb`:
- Parse numeric columns
- Augmentasi `category`, `estimated_price_idr`, `is_halal`, `is_vegetarian`
- Save: `dataset/clean/foods_master.parquet`
- Export ke `backend/prisma/seed-data/foods.csv` untuk seeder

### Day 3-4 — Workout Model Training

`notebooks/05_train_workout_rf.ipynb`:

```python
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.ensemble import RandomForestClassifier
from sklearn.multioutput import MultiOutputClassifier
from sklearn.metrics import classification_report, confusion_matrix
from sklearn.preprocessing import LabelEncoder
import joblib

# 1. Load cleaned data
df = pd.read_parquet('../dataset/clean/workout_clean.parquet')

# 2. Synthesize 7-day training rows
def synthesize_training_data(df_gym):
    rows = []
    for _, person in df_gym.iterrows():
        for day_index in range(7):
            row = make_features(person, day_index)
            row['workout_type'] = decide_type(person, day_index)
            row['intensity_band'] = decide_intensity(person, day_index)
            rows.append(row)
    return pd.DataFrame(rows)

df_train = synthesize_training_data(df)
print(f"Training rows: {len(df_train)}")

# 3. Features & target
features = [
    'bmi', 'bmi_cat_enc', 'gender_enc', 'age', 'age_band_enc',
    'fitness_level_enc', 'mode_enc', 'days_per_week', 'session_minutes',
    'day_index', 'is_first_day_of_week', 'has_injury', 'has_chronic_condition',
]
target = ['workout_type', 'intensity_band']

X = df_train[features]
y = df_train[target]

# 4. Encode targets
le_type = LabelEncoder().fit(y['workout_type'])
le_intensity = LabelEncoder().fit(y['intensity_band'])
y_enc = pd.DataFrame({
    'workout_type': le_type.transform(y['workout_type']),
    'intensity_band': le_intensity.transform(y['intensity_band']),
})

# 5. Split
X_train, X_test, y_train, y_test = train_test_split(X, y_enc, test_size=0.2, random_state=42, stratify=y_enc['workout_type'])

# 6. Baseline RF
base_rf = RandomForestClassifier(n_estimators=100, max_depth=10, random_state=42, class_weight='balanced')
model = MultiOutputClassifier(base_rf)
model.fit(X_train, y_train)

# 7. Eval
y_pred = model.predict(X_test)
print("=== Workout Type ===")
print(classification_report(y_test['workout_type'], y_pred[:, 0], target_names=le_type.classes_))
print("=== Intensity Band ===")
print(classification_report(y_test['intensity_band'], y_pred[:, 1], target_names=le_intensity.classes_))

# 8. (Day 4) Tune hyperparameter
param_grid = {
    'estimator__n_estimators': [50, 100, 200],
    'estimator__max_depth': [5, 10, 15, None],
    'estimator__min_samples_split': [2, 5, 10],
}
gs = GridSearchCV(model, param_grid, cv=3, scoring='accuracy', n_jobs=-1)
gs.fit(X_train, y_train)
print(f"Best: {gs.best_params_}, score: {gs.best_score_}")

# 9. Save
best_model = gs.best_estimator_
joblib.dump({
    'model': best_model,
    'le_type': le_type,
    'le_intensity': le_intensity,
    'features': features,
}, '../app/data/workout_rf.joblib')
print("Saved workout_rf.joblib")
```

### Day 5 — Meal Optimizer Dev

`notebooks/06_meal_optimizer_dev.ipynb`:

Tidak butuh "training" karena knapsack rule-based. Tetap notebook untuk:
- Load foods_master
- Smoke test `knapsack_meal()` dengan profile dummy
- Validasi output (budget compliance, calorie match)
- Tweaking score weights

```python
import pandas as pd
from app.services.meal_planner import knapsack_meal, compose_meal_day

foods = pd.read_parquet('../dataset/clean/foods_master.parquet')

# Test profile
profile = {
    'tdee': 2200,
    'target_calorie_adj': -350,  # lose weight
    'budget_per_day_idr': 35000,
    'meal_frequency': 3,
    'diet_restrictions': ['halal'],
}

day = compose_meal_day(profile, day_index=0, food_master=foods)
print(f"Total kalori: {day['total_calories']}")
print(f"Total cost: {day['total_cost_idr']}")
print(f"Macro: P={day['total_protein_g']}, K={day['total_carb_g']}, F={day['total_fat_g']}")
for m in day['meals']:
    print(f"\n{m['meal_type']}: {m['calories_kcal']} kkal, Rp{m['cost_idr']}")
    for f in m['foods']:
        food_name = foods.loc[foods['id'] == f['food_id'], 'name'].iloc[0]
        print(f"  - {food_name} × {f['servings']} = {f['calories_kcal']} kkal")

# Validasi
assert day['total_cost_idr'] <= profile['budget_per_day_idr'], "Budget exceeded!"
target_cal = profile['tdee'] + profile['target_calorie_adj']
assert abs(day['total_calories'] - target_cal) / target_cal < 0.20, "Calorie way off"
```

### Day 7 — Replanner Logic

`notebooks/07_replanner_logic.ipynb`:

Smoke test 3 strategi (REDUCE, MAINTAIN_SWAP, INTENSIFY) dengan dummy plans:

```python
from app.services.replanner import replan

# Test strategi REDUCE
input_low = {
    'previous_plan': dummy_plan(),
    'score_percent': 35,
    'weight_change_kg': -0.1,
    'weight_target_change_kg': -0.5,
    'most_skipped_exercise_ids': ['ex-001', 'ex-002'],
    'profile': dummy_profile(),
}
out = replan(input_low)
print(f"Strategy: REDUCE")
print(f"Notes: {out['ai_notes']}")
# Verify volume reduced
total_vol_before = sum(ex['sets'] * ex['reps'] for d in input_low['previous_plan']['workout_days'] for ex in d['exercises'])
total_vol_after = sum(ex['sets'] * ex['reps'] for d in out['workout_days'] for ex in d['exercises'])
assert total_vol_after < total_vol_before * 0.85, "Volume should reduce significantly"

# Test INTENSIFY
input_high = {**input_low, 'score_percent': 90}
out = replan(input_high)
total_vol_after = sum(ex['sets'] * ex['reps'] for d in out['workout_days'] for ex in d['exercises'])
assert total_vol_after > total_vol_before * 1.05, "Volume should increase"
```

## 3. Deliverable per Notebook

Setiap notebook harus produce:
1. **Output file** (parquet/joblib) di lokasi yang tepat
2. **Markdown summary** di akhir notebook: ringkasan hasil, metrik, edge cases
3. **Cell yang reproducible**: tidak ada hardcoded path absolute, pakai relative

## 4. Reproducibility

- Set `random_state=42` di mana pun ada randomness (RF, train_test_split, sample).
- Pin versi library di `requirements.txt`.
- Save model + label encoders + feature list dalam **satu joblib file**.
- Jangan training ulang setiap deploy — joblib file ikut di-commit (atau di-fetch dari S3 saat startup).

## 5. Loading Model di FastAPI

File: `app/services/workout_recommender.py`

```python
import joblib
from pathlib import Path
import numpy as np
import pandas as pd

MODEL_PATH = Path(__file__).parent.parent / 'data' / 'workout_rf.joblib'

class WorkoutRecommender:
    def __init__(self):
        bundle = joblib.load(MODEL_PATH)
        self.model = bundle['model']
        self.le_type = bundle['le_type']
        self.le_intensity = bundle['le_intensity']
        self.features = bundle['features']
        self.exercise_master = pd.read_parquet(
            Path(__file__).parent.parent / 'data' / 'exercise_master.parquet'
        )

    def infer(self, profile: dict) -> dict:
        # 1. Build feature matrix untuk 7 hari
        X = []
        for day_index in range(7):
            row = {f: extract_feature(profile, day_index, f) for f in self.features}
            X.append(row)
        X_df = pd.DataFrame(X)

        # 2. Predict
        preds = self.model.predict(X_df)
        # 3. Decode
        types = self.le_type.inverse_transform(preds[:, 0])
        intensities = self.le_intensity.inverse_transform(preds[:, 1])

        # 4. Compose tiap hari
        days = []
        for day_index in range(7):
            day = compose_workout_day(types[day_index], intensities[day_index], profile, self.exercise_master)
            day['day_index'] = day_index
            days.append(day)

        return {'days': days}

# Singleton
workout_recommender = WorkoutRecommender()
```

Di `main.py` startup:
```python
from fastapi import FastAPI
from app.services.workout_recommender import workout_recommender
from app.services.meal_planner import meal_planner

app = FastAPI()

@app.on_event("startup")
async def startup():
    print("✅ Models loaded:")
    print(f"  - workout_recommender: {workout_recommender.model.__class__.__name__}")
    print(f"  - meal_planner: ready")
```

## 6. Re-training Strategy

Untuk hackathon, training **satu kali** sudah cukup. Pasca-hackathon, jika dataset di-update:

1. Update notebook (cleaning + training)
2. Run notebook → produce new joblib
3. Bump `MODEL_VERSION` di config
4. Redeploy FastAPI

Tidak perlu auto-retraining pipeline kompleks.

## 7. Evaluasi & Sanity Check

Selain accuracy/F1, lakukan **sanity check** manual saat training:

- Generate plan untuk 5 profile berbeda (overweight pemula, normal advanced, dll)
- Validasi:
  - Kalori plan dalam ±20% dari TDEE+adj
  - Budget plan ≤ budget user
  - Tidak ada workout berisi >70% di muscle group yang sama (overuse)
  - Tidak ada hari REST < 1 atau > 3 dalam minggu

Jika sanity check gagal, balik ke notebook & tweak rules atau hyperparameter.

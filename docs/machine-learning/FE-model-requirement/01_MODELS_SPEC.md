# Heltigo — ML Models Specification (Detailed)

> Detail spesifikasi **3 model ML** untuk Heltigo sesuai folder `notebook/training_model/`. Pendamping [`00_OVERVIEW.md`](00_OVERVIEW.md).
>
> **Catatan:** Logika Pre-Workout Intensity Adjuster (mood/energy/sleep → multiplier) bukan ML model — ini **backend rule** di `backend/services/intensity_adjuster.service.ts`. Tidak ada di sini.

**Versi:** 1.2 (SOTA stack upgrade 2026-05-16)

## Update Stack 2026-05-16

| Aspek | Sebelumnya | Sekarang |
|---|---|---|
| Model 1 algoritma | RandomForest (n=100) | **XGBoost + Optuna 50-trial TPE** |
| Model 1 dataset | 973 baris | **2,773 baris (combined real+synthetic) → 19,400 augmented** |
| Model 1 target F1 | ≥ 0.65 | **≥ 0.85** (per EightGym Indonesia 2024) |
| Model 2 algoritma | Knapsack only | **Knapsack + DEAP GA wrapper** (Springer 2024) |
| Model 2 diversity target | 0.70 | **0.85** |
| Model 3 algoritma | Decision Tree | **XGBoost Regressor + Thompson Sampling path** (DIAMANTE 2024) |
| Model 3 MAE target | < 0.05 | **< 0.04** |
| Preprocessing | basic | **RobustScaler + SMOTEENN + iterative-stratification** |
| Feature engineering | basic encoding | **+BMR/TDEE/FFMI + interaction features** (Nature 2025: +3-4pp AUC) |

Lihat [`03_RESEARCH_REFERENCES.md`](03_RESEARCH_REFERENCES.md) untuk daftar paper acuan.

---

## Model 1 — Workout Recommender

### Tujuan
Berdasarkan profil user (BMI, level fitness, mode latihan, hari tersedia, kondisi medis), prediksi 7-hari rencana workout (type per hari + intensity per hari).

### Input Features (13)

| Feature | Tipe | Range / Values | Sumber |
|---|---|---|---|
| `bmi` | float | 12 - 50 | `weightKg / (heightCm/100)²` |
| `bmi_cat` | int | 0=Under, 1=Normal, 2=Over, 3=Obese | Encoded dari bmi |
| `gender_enc` | int | 0=F, 1=M, 2=Other | From `health_profiles.gender` |
| `age` | int | 13 - 120 | From `health_profiles.age` |
| `age_band` | int | 0=<25, 1=25-34, 2=35-49, 3=≥50 | Encoded dari age |
| `fitness_level` | int | 1=Beginner, 2=Intermediate, 3=Advanced | Direct |
| `mode` | int | 0=HOME, 1=GYM, 2=HYBRID | Encoded dari `workout_mode` |
| `days_per_week` | int | 1 - 7 | Direct |
| `session_minutes` | int | 15, 20, 30, 45, 60, 90 | Direct |
| `day_index` | int | 0 - 6 (Mon - Sun) | Iterated 0-6 untuk generate 7 baris |
| `is_first_day` | int | 0 / 1 | `day_index == 0` |
| `has_injury` | int | 0 / 1 | `len(healthConditions) > 0` |
| `has_chronic` | int | 0 / 1 | `'DIABETES' in healthConditions OR 'HYPERTENSION' in ...` |

### Output (multi-output)

| Output | Tipe | Values |
|---|---|---|
| `workout_type` | string | `CARDIO`, `STRENGTH`, `HIIT`, `FLEXIBILITY`, `REST` (5 kelas) |
| `intensity_band` | string | `LOW`, `MID`, `HIGH` (3 kelas) |

Tambahan untuk REST day: `intensity_band` di-force ke `null`/`LOW`.

### Algoritma

```python
from sklearn.ensemble import RandomForestClassifier
from sklearn.multioutput import MultiOutputClassifier

model = MultiOutputClassifier(
    RandomForestClassifier(
        n_estimators=100,
        max_depth=10,
        min_samples_split=5,
        min_samples_leaf=2,
        class_weight='balanced',
        random_state=42,
        n_jobs=-1,
    )
)

model.fit(X_train, y_train)  # y_train shape (n, 2)
```

### Training Data

**Primary:** [`notebook/dataset/Model_rekomendasi_Pelatihan/gym_member_exercise_dataset/gym_members_exercise_tracking.csv`](../../../notebook/dataset/Model_rekomendasi_Pelatihan/gym_member_exercise_dataset/) (973 rows real gym data).

**Augmentation strategy (973 → ~6,800 rows):**
1. Setiap user di dataset → expand jadi 7 baris (1 baris per `day_index`).
2. Generate synthetic label `workout_type` + `intensity` berdasarkan rule:
   - User dengan `Experience_Level=1, BMI>27` → mostly CARDIO + LOW
   - User dengan `Experience_Level=3, BMI<25` → mix STRENGTH + HIIT, MID-HIGH
   - REST day: hari 3 atau 7 (depending pada `Workout_Frequency`)
3. Tambah noise 10% pada feature numerik untuk diversitas.

### Evaluation Metrics

| Metric | Target |
|---|---|
| Overall accuracy (avg) | > 70% |
| F1-macro `workout_type` | > 0.65 |
| F1-macro `intensity_band` | > 0.65 |
| Confusion matrix balance | tidak ada kelas yang fully missed |
| Cross-validation | 5-fold stratified |

### Train/Test Split

- 80/20 random split, stratified pada `workout_type`
- Train: ~5,440 rows
- Test: ~1,360 rows

### Post-Processing

Output 7-day workout type + intensity → mapping ke exercise list:
1. Backend query `exercise_master WHERE difficulty <= user.fitness_level AND equipment INTERSECT user.preferred_equipment`.
2. Filter by `workout_type` (mis. type=STRENGTH → exercises tagged "main", muscle_groups sesuai split).
3. Pick `total_exercises = 6` per workout (1 warmup + 4 main + 1 cooldown) tergantung intensity.
4. Apply rule for special conditions: `has_chronic AND injury='LOW_BACK_PAIN'` → exclude squat/deadlift.

### API Contract

```python
# FastAPI route
@router.post("/predict/workout-plan")
def predict_workout_plan(req: WorkoutPlanRequest) -> WorkoutPlanResponse:
    ...
```

**Request schema:**
```python
class WorkoutPlanRequest(BaseModel):
    bmi: float
    gender: Literal['M', 'F', 'OTHER']
    age: int
    fitness_level: Literal['BEGINNER', 'INTERMEDIATE', 'ADVANCED']
    workout_mode: Literal['HOME', 'GYM', 'HYBRID']
    days_per_week: int = Field(ge=1, le=7)
    session_minutes: int = Field(ge=15, le=120)
    health_conditions: list[str] = []
    preferred_equipment: list[str] = []
```

**Response schema:**
```python
class WorkoutDay(BaseModel):
    day_number: int  # 1-7
    workout_type: str
    intensity: Optional[str]
    suggested_exercises: list[str]  # list of exercise slugs

class WorkoutPlanResponse(BaseModel):
    days: list[WorkoutDay]
```

### Performance Budget
- Inference per request: < 50 ms (RF on 13 features × 7 days)
- Total endpoint latency: < 800 ms (termasuk exercise mapping query)

---

## Model 2 — Meal Planner

### Tujuan
Pilih makanan per meal (sarapan/siang/malam) untuk 7 hari, optimasi: maksimal protein-per-rupiah, pas calorie target ±15%, dalam budget, sambil diversitas antar hari.

### Input

| Field | Tipe | Deskripsi |
|---|---|---|
| `budget_per_day_idr` | float | E.g., 50000 |
| `target_calories_per_day` | int | Computed TDEE (e.g., 1900) |
| `target_protein_g` | int | E.g., 130 |
| `target_carbs_g` | int | E.g., 210 |
| `target_fat_g` | int | E.g., 65 |
| `dietary_restrictions` | list[str] | E.g., `['HALAL', 'NO_PORK']` |
| `allergies` | list[str] | E.g., `['PEANUTS']` |
| `disliked_foods` | list[str] | Optional exclusion |
| `preferred_cuisine` | str | `INDONESIAN` (default) |

### Output

Per hari (×7), 3 meal (breakfast/lunch/dinner):
```json
{
  "day": 1,
  "meals": {
    "BREAKFAST": [
      { "food_master_id": 42, "name": "Nasi uduk", "portion": "1 piring",
        "calories": 350, "protein_g": 8, "carbs_g": 60, "fat_g": 8, "cost_idr": 12000 }
    ],
    "LUNCH": [...],
    "DINNER": [...]
  },
  "totals": { "calories": 1850, "protein": 128, "carbs": 215, "fat": 60, "cost": 47500 }
}
```

### Algoritma

**Tahap 1: Filter** — eliminate makanan yang tidak halal/vegetarian/glutenfree (sesuai user) dan alergi.

**Tahap 2: Allocate budget per meal** (default 30/40/30):
- BREAKFAST: 30% budget → ~15,000 IDR
- LUNCH: 40% budget → ~20,000 IDR
- DINNER: 30% budget → ~15,000 IDR

**Tahap 3: Allocate calories per meal** (sama 30/40/30):
- BREAKFAST: ~570 kcal
- LUNCH: ~760 kcal
- DINNER: ~570 kcal

**Tahap 4: Score function (greedy knapsack):**
```python
def score(food, weights):
    p = food['protein_g'] / max(food['estimated_price_idr'] / 1000, 1)
    c = food['calories'] / max(food['estimated_price_idr'] / 1000, 1)
    fi = food['fiber_g'] / max(food['estimated_price_idr'] / 1000, 1)
    fa = food['fat_g'] / max(food['estimated_price_idr'] / 1000, 1)
    return (
        weights['protein'] * p +
        weights['calories'] * c +
        weights['fiber'] * fi -
        weights['fat'] * fa
    )

# Weight per goal:
WEIGHTS = {
    'WEIGHT_LOSS':   {'protein': 0.5,  'calories': 0.2, 'fiber': 0.3, 'fat': 0.2},
    'MUSCLE_GAIN':   {'protein': 0.45, 'calories': 0.4, 'fiber': 0.1, 'fat': 0.05},
    'MAINTENANCE':   {'protein': 0.35, 'calories': 0.35,'fiber': 0.2, 'fat': 0.1},
    'PERFORMANCE':   {'protein': 0.4,  'calories': 0.45,'fiber': 0.1, 'fat': 0.05},
}
```

**Tahap 5: Picker untuk satu meal**:
1. Mulai dengan empty set.
2. Loop kategori urutan: `[STAPLE, PROTEIN, VEGETABLE, FRUIT/BEVERAGE]`.
3. Per kategori, pilih top-scoring food yang fit dalam remaining budget + remaining calories ±15%.
4. Stop ketika 3 items terkumpul atau calorie ≥ 85% target.

**Tahap 6: Constraints validation:**
```
total_calories ∈ [target ± 15%]
total_cost ≤ budget
protein_g ≥ 15% × target_calories / 4  (i.e., min protein ratio)
fat_g ≤ 35% × target_calories / 9        (i.e., max fat ratio)
```

Jika violation → backtrack & swap 1 item.

**Tahap 7: Cross-day diversifier** — penalize duplicate `STAPLE` atau `PROTEIN` di hari berurutan:
```python
diversity_penalty = -2.0 per food yang sama dengan kemarin
```

### Dataset

**Primary:** [`notebook/dataset/Model_Perencana Makan_dan_Nutrisi/Indonesian Food & Drink Nutrition Dataset/nutrition.csv`](../../../notebook/dataset/Model_Perencana%20Makan_dan_Nutrisi/Indonesian%20Food%20%26%20Drink%20Nutrition%20Dataset/) — 1,346 Indonesian foods.

**Validation:** [`notebook/dataset/Model_Perencana Makan_dan_Nutrisi/Diet Recommendations Dataset/diet_recommendations_dataset.csv`](../../../notebook/dataset/Model_Perencana%20Makan_dan_Nutrisi/Diet%20Recommendations%20Dataset/) — 1,000 patient records.

### Augmentation (MUST DO)

Notebook: `notebook/03_clean_nutrition.ipynb`. Tambahkan ke `nutrition.csv`:

1. **`category`** — heuristic dari nama:
   - `STAPLE`: nasi, mie, kentang, jagung, roti, pasta, ubi
   - `PROTEIN`: ayam, sapi, ikan, telur, tahu, tempe
   - `VEGETABLE`: sayur, bayam, kangkung, brokoli, wortel
   - `FRUIT`: buah, apel, mangga, pisang, jeruk, semangka
   - `BEVERAGE`: minum, teh, kopi, jus, susu, air
   - `DESSERT`: kue, puding, es krim, dodol
   - `SNACK`: keripik, biskuit, kerupuk
   - Fallback: `STAPLE`

2. **`estimated_price_idr`** — heuristic per category × calories:
   ```python
   base_price = {
       'STAPLE': 8000, 'PROTEIN': 18000, 'VEGETABLE': 6000,
       'FRUIT': 7000, 'BEVERAGE': 5000, 'DESSERT': 10000, 'SNACK': 5000
   }
   price = base_price[cat] * (1 + calories / 500)  # +1x per 500 kcal
   ```

3. **`is_halal`** — `False` jika nama mengandung: babi, pork, bacon, ham, lard, wine, anggur (untuk minuman beralkohol).

4. **`is_vegetarian`** — `True` jika nama TIDAK mengandung: daging, ayam, sapi, ikan, udang, telur (telur jadi vegetarian ovo), seafood.

5. **`is_vegan`** — vegetarian AND tidak mengandung telur, susu, keju, mentega, madu.

6. **`is_gluten_free`** — `False` jika mengandung: roti, pasta, mie (kecuali "mie soun" / "bihun"), gandum.

### Evaluation

| Metric | Target |
|---|---|
| Calorie deviation per hari | ≤ 15% |
| Budget compliance | 100% (tidak overshoot) |
| Macro balance (protein %, fat %) | dalam range AHA/WHO guidelines |
| Food diversity score per 7 hari | > 0.7 (unique foods / total picks) |
| Validation vs `diet_recommendations` | ≥ 80% match disease_type → recommended_diet |

### API Contract

```python
@router.post("/predict/meal-plan")
def predict_meal_plan(req: MealPlanRequest) -> MealPlanResponse:
    ...

@router.post("/predict/meal-alternatives")
def predict_alternatives(req: MealAltRequest) -> MealAltResponse:
    ...
```

**Tidak butuh `.pkl` file** — deterministic, baca master food dari Parquet/DB.

### Performance Budget
- Full 7-day plan: < 500 ms (1346 foods × filter ~50% × 21 picks)
- Single alternatives query: < 150 ms

---

## Model 3 — Adaptive Replanner (Model_Adaptif_Perencanaan_Ulang)

### Tujuan
Setelah 7 hari plan selesai, evaluasi performa user dan generate plan minggu depan yang disesuaikan.

### Input

| Field | Tipe | Deskripsi |
|---|---|---|
| `weekly_score` | int (0-100) | Compliance score, computed: `(workouts_done + meals_logged) / total × 100` |
| `weight_diff_kg` | float | `current_weight - last_week_weight` |
| `skipped_exercise_ids` | list[int] | Exercise yang gagal diselesaikan ≥ 2 kali |
| `previous_plan` | object | Plan minggu lalu (workout_type+intensity per hari) |
| `user_profile` | object | Snapshot health_profile current |
| `goal` | str | `WEIGHT_LOSS` / `MUSCLE_GAIN` / dst |
| `user_choice` | str | `KEEP` / `MODERATE` / `AGGRESSIVE` (dari S-34c Replanning Choose) |

### Output

Plan baru 7 hari (sama format dengan `predict_workout_plan` + `predict_meal_plan` output).

### Algoritma — Rule 3-Cabang

```python
def classify_strategy(weekly_score: int) -> str:
    if weekly_score < 50:   return 'REDUCE'
    if weekly_score <= 80:  return 'MAINTAIN_SWAP'
    return 'INTENSIFY'

def apply_strategy(previous_plan, strategy, skipped_ids, user_choice):
    new_plan = deepcopy(previous_plan)
    
    if strategy == 'REDUCE':
        # User struggling — kurangi volume 30%, intensity ke LOW-MID, swap susah
        volume_multiplier = 0.7
        intensity_shift = -1   # MID → LOW, HIGH → MID
        swap_difficult = True
        
    elif strategy == 'MAINTAIN_SWAP':
        # User OK — pertahankan volume, swap exercise yang sering di-skip
        volume_multiplier = 1.0
        intensity_shift = 0
        swap_skipped = True
        
    else:  # INTENSIFY
        # User excelling — naikkan volume 15%, intensity 1 step up
        volume_multiplier = 1.15
        intensity_shift = +1
        unlock_advanced = True
    
    # User choice override
    if user_choice == 'KEEP':
        # User minta keep, abaikan strategy → multiplier 1.0
        return new_plan
    if user_choice == 'AGGRESSIVE':
        # Boost lebih agresif
        volume_multiplier *= 1.10
        intensity_shift += 1
    
    # Apply ke setiap workout_day di plan
    for day in new_plan['days']:
        day['exercises'] = adjust_exercises(
            day['exercises'],
            volume_multiplier=volume_multiplier,
            intensity_shift=intensity_shift,
            skipped_ids=skipped_ids,
        )
    
    return new_plan
```

### Optional ML Refinement (Decision Tree)

Untuk fine-tune `volume_multiplier` lebih granular (continuous 0.6-1.3) berdasarkan kombinasi `weekly_score`, `weight_diff`, `goal`:

```python
from sklearn.tree import DecisionTreeRegressor

dt = DecisionTreeRegressor(max_depth=3, min_samples_leaf=5)
dt.fit(X_train, y_train)  # y = continuous multiplier
```

**Training data:** synthetic — generate label berdasarkan rule + noise dari [`gym_members_exercise_tracking_synthetic_data.csv`](../../../notebook/dataset/Model_Adaptif_Perencanaan_Ulang/Fitness%20Tracker%20Dataset/) (1,800 rows).

### Weight Trajectory Adjustment

Selain workout, replanner juga adjust meal target:

```python
if goal == 'WEIGHT_LOSS' and weight_diff > -0.2:
    # Target 0.5 kg/week, actual hanya -0.2 → defisit kurang
    new_target_calories -= 100
elif goal == 'WEIGHT_LOSS' and weight_diff < -1.0:
    # Turun terlalu cepat (>1 kg/week tidak healthy)
    new_target_calories += 100
elif goal == 'MUSCLE_GAIN' and weight_diff < 0.1:
    # Surplus kurang
    new_target_calories += 150
    new_target_protein += 10
```

### Evaluation

| Metric | Target |
|---|---|
| Coverage rule 3-cabang | 100% input → output (no NaN/error) |
| Output validity | calorie ≥ 1200, protein ≥ 1.2 g/kg body weight, multiplier ∈ [0.6, 1.3] |
| Simulated adherence improvement | ≥ 10% next week (simulasi sintetik) |
| Exercise diversity vs prev week | ≥ 30% different exercises kalau strategy = MAINTAIN_SWAP atau INTENSIFY |

### API Contract

```python
@router.post("/predict/replan")
def predict_replan(req: ReplanRequest) -> ReplanResponse:
    ...

class ReplanRequest(BaseModel):
    weekly_score: int = Field(ge=0, le=100)
    weight_diff_kg: float
    skipped_exercise_ids: list[int] = []
    previous_plan: dict
    user_profile: HealthProfile
    user_choice: Literal['KEEP', 'MODERATE', 'AGGRESSIVE']

class ReplanResponse(BaseModel):
    new_workout_plan: WorkoutPlanResponse
    new_meal_plan: MealPlanResponse
    strategy_used: str  # 'REDUCE' | 'MAINTAIN_SWAP' | 'INTENSIFY'
    rationale: str       # Human-readable explanation
```

### Performance Budget
- < 600 ms (re-use cached predict_workout_plan + predict_meal_plan)

---

## Cross-Cutting Concerns

### Versioning
- Model artifact: `workout_rf_v1.0.0.pkl`, etc.
- API path: `/predict/v1/workout-plan`
- Backend can call latest version explicitly.

### Logging
- Setiap request → log structured (JSON): timestamp, user_id (hashed), endpoint, input hash, output hash, latency_ms.
- ML service log dipisah dari backend log (Pino vs Python logging).

### Monitoring
- Health check: `GET /health` → return `{ status: "ok", models_loaded: [...] }`.
- Prometheus metrics (Phase 4): request count, latency histogram, error rate per endpoint.

### Testing
- Unit test per model: minimal 10 test case dengan input known.
- Integration test: backend call mock ML service.
- Smoke test E2E (Phase 5): Flutter → backend → ML service → assert response shape.

### Reproducibility
- Random seed = 42 untuk semua RF/DT.
- Notebook commit sertakan output cell.
- Data version tag di README notebook.

---

**Lihat juga:**
- [`00_OVERVIEW.md`](00_OVERVIEW.md) — arsitektur sistem ML
- [`02_DATASETS_INVENTORY.md`](02_DATASETS_INVENTORY.md) — daftar dataset & quality assessment
- [`../03_MODELS.md`](../03_MODELS.md) — versi lain spec model (jika ada)

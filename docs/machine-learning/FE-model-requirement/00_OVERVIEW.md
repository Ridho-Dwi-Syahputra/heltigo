# Heltigo — ML Model Requirements (Derived from Frontend)

> Overview 3 model ML yang dibutuhkan agar fitur AI-powered di frontend Heltigo dapat berjalan: rekomendasi workout, perencana makan, dan adaptive replanning mingguan.
>
> Logika **pre-workout intensity adjustment** (mood/energy/sleep → multiplier volume) adalah **rule-based di backend**, bukan ML model terpisah — lihat `docs/backend/07_BUSINESS_LOGIC.md` §Intensity Adjuster.

**Versi:** 1.2
**Update:** 2026-05-16 — SOTA stack upgrade (XGBoost + Optuna + SMOTEENN + GA), based on jurnal review 2024-2025. Lihat [`03_RESEARCH_REFERENCES.md`](03_RESEARCH_REFERENCES.md).
**Target demo:** 2026-05-21
**Audience:** ML Engineer, Backend Engineer.

## 🎯 SOTA Stack (2024-2025 — research-driven)

| Komponen | Library | Versi | Why |
|---|---|---|---|
| Workout Recommender | **XGBoost** + Optuna | 3.x + 4.x | Beats RF di EightGym Indonesia 2024 (95% acc) |
| Meal Planner | Knapsack + **DEAP GA** | 1.4 | Hybrid pattern Springer Soft Computing 2024 |
| Adaptive Replanner | Rule + **XGBoost Regressor** + Thompson Sampling path | 3.x | Combine reliability rule dengan ML fine-tune |
| Feature Scaling | **RobustScaler** | sklearn 1.7 | i-MRI 2024: best for health data outliers |
| Imbalance | **SMOTEENN** | imbalanced-learn 0.14 | Springer 2024: best for medical |
| Multi-label CV | **iterative-stratification** | 0.1.9 | Proper multi-label split |
| Indonesian NLP (opt) | IndoBERT/NusaBERT | transformers 5.x | Food name embedding |

## Folder Training & Notebook Setup

```
notebook/
├── .venv/                    ← Python 3.10 virtualenv
├── requirements.txt          ← Pin dependencies
├── README.md                 ← Setup instructions
└── training_model/
    ├── Model_Rekomendasi_Latihan/   ← Model 1 (4 notebook)
    ├── Model_Perencana_Makan/       ← Model 2 (4 notebook)
    └── Model_Adaptif_Perencanaan_Ulang/ ← Model 3 (3 notebook)
```

Aktivasi env: `cd notebook && .\.venv\Scripts\Activate.ps1`

---

## 1. Tujuan Sistem ML

Heltigo memanfaatkan ML/AI untuk **personalisasi** alur user end-to-end:

1. **Setup awal → Plan 7-hari pertama:** Begitu user selesai setup wizard, sistem ML generate plan workout + plan meal yang sesuai profil.
2. **Meal swap:** User minta alternatif makanan → ML kasih opsi dengan macro & budget mirip.
3. **Weekly replanning:** Setiap minggu, ML evaluasi performa user → adjust plan minggu depan.

> **Catatan S-19 Pre-Workout Check-in:** Adjustment intensitas (mood/energy/sleep → ±volume) ditangani sebagai **rule table di backend Express**, bukan ML model. Backend apply multiplier langsung tanpa memanggil FastAPI.

---

## 2. 3 Model Utama

| # | Model | Folder Training | Tipe | Trigger di Frontend |
|---|---|---|---|---|
| 1 | **Rekomendasi Latihan** | `notebook/training_model/Model_Rekomendasi_Latihan/` | RandomForest multi-output | `/plan/generate`, `/plan/replan` |
| 2 | **Perencana Makan** | `notebook/training_model/Model_Perencana_Makan/` | Knapsack 0/1 greedy + diversifier | `/plan/generate`, `/meal/swap` |
| 3 | **Adaptif Perencanaan Ulang** | `notebook/training_model/Model_Adaptif_Perencanaan_Ulang/` | Rule 3-cabang + optional Decision Tree | `/plan/replan` |

---

## 3. Inference Architecture

```
┌──────────────────┐  HTTPS   ┌────────────────────┐   HTTP    ┌───────────────────────┐
│  Flutter App     │ ───────► │  Backend Express   │ ────────► │  ML Service (FastAPI) │
│  (Heltigo)       │  + JWT   │  Node + MySQL      │  internal │  Python 3.11          │
└──────────────────┘          └────────────────────┘   only    │  + scikit-learn       │
                                                                │  + Pandas + Pydantic  │
                                                                └───────────────────────┘
                                                                          │
                                                                          ▼
                                                          ┌──────────────────────────┐
                                                          │  artifacts/              │
                                                          │  ├── workout_rf.pkl      │
                                                          │  ├── food_master.parquet │
                                                          │  └── replanner_dt.pkl    │
                                                          └──────────────────────────┘
```

**Prinsip:**
- ML service tidak exposed public — hanya backend yang panggil.
- Backend enrich request dengan user profile dari MySQL → POST ke ML → simpan hasil → return ke FE.
- ML service stateless (model loaded saat startup, no DB access).
- Timeout backend → ML: 5 detik. Fallback rule-based default jika ML down.
- **Intensity adjuster** jalan di backend (bukan ML service) → tidak ada HTTP call tambahan.

---

## 4. Integration Points

### 4.1 `POST /plan/generate` (Backend → ML)
Trigger: setelah user selesai setup wizard atau manual generate.

**Request body (backend → ML service):**
```json
{
  "userId": 42,
  "profile": {
    "age": 28, "gender": "M", "heightCm": 175, "weightKg": 75.5,
    "bmi": 24.7, "fitnessLevel": "INTERMEDIATE",
    "goal": "WEIGHT_LOSS",
    "availableDaysPerWeek": 4, "sessionDurationMin": 30,
    "workoutMode": "HOME",
    "healthConditions": ["LOW_BACK_PAIN"],
    "allergies": [],
    "dietaryRestrictions": ["HALAL"],
    "budgetPerDayIdr": 50000,
    "targetCaloriesPerDay": 1900,
    "targetProteinG": 130
  }
}
```

**Response (ML → backend):**
```json
{
  "workoutPlan": {
    "days": [
      { "dayNumber": 1, "workoutType": "STRENGTH", "intensity": "MID",
        "exercises": [...] }
    ]
  },
  "mealPlan": {
    "days": [
      { "dayNumber": 1,
        "meals": { "BREAKFAST": [...foodItems], "LUNCH": [...], "DINNER": [...] }
      }
    ]
  }
}
```

ML call internal secara berurutan:
1. **Model 1 (Workout RF)** → 7-day workout_type + intensity → mapping ke exercise list dari `exercise_master`
2. **Model 2 (Meal Planner)** → 7-day meal items dari `food_master`

### 4.2 `POST /workout/:dayId/check-in` (Backend only — NO ML call)
Trigger: S-19 Pre-Workout Check-in (mood/energy/sleep).

**Backend langsung apply rule:**
```js
// backend/services/intensity_adjuster.service.ts
const multiplier = lookupIntensity(mood, energy, sleepBand); // rule table
const adjusted = applyMultiplier(planExercises, multiplier);
// return adjusted exercises ke frontend
```

Tidak ada HTTP call ke FastAPI — handled sepenuhnya di backend Express.

### 4.3 `POST /meal/:mealId/swap` (Backend → ML)
Trigger: user tap "Minta Alternatif" di meal detail.

```json
POST /predict/meal-alternatives
{ "currentMealId": 123, "macroTarget": {...}, "budgetIdr": 17000, "exclude": ["babi"] }
```

**Response:**
```json
{ "alternatives": [{...foodItem}, {...}, {...}] }
```

### 4.4 `POST /plan/replan` (Backend → ML)
Trigger: S-34 Replanning Evaluation.

```json
POST /predict/replan
{
  "previousPlanId": 42,
  "weeklyScore": 75,
  "weightDiff": -0.6,
  "skippedExerciseIds": [12, 15],
  "userChoice": "MODERATE"
}
```

**Response:** sama format dengan output `/predict/plan` tapi di-adjust sesuai rule 3-cabang.

---

## 5. Tech Stack

| Komponen | Versi | Alasan |
|---|---|---|
| Python | 3.11 | LTS, kompatibel scikit-learn |
| scikit-learn | 1.4+ | RandomForest, DecisionTree |
| Pandas | 2.2+ | Data prep, feature engineering |
| NumPy | 1.26+ | Required by sklearn |
| FastAPI | 0.110+ | Web framework, async, OpenAPI auto |
| Pydantic | 2.x | Request/response schema validation |
| uvicorn | 0.27+ | ASGI server |
| joblib | 1.3+ | Model serialization (.pkl) |
| pytest | 7.x | Unit test |
| jupyter | latest | EDA + training notebooks |

---

## 6. Training & Inference Pipeline

```
[Offline]   notebook/01_eda_gym_members.ipynb   ← EDA + clean workout dataset
                    ↓
            notebook/02_eda_nutrition.ipynb       ← EDA nutrition
                    ↓
            notebook/03_clean_nutrition.ipynb     ← augment nutrition.csv → food_master.parquet
                    ↓
            notebook/04_train_workout_rf.ipynb    ← train RF → workout_rf.pkl
                    ↓
            notebook/05_test_meal_planner.ipynb   ← test knapsack (no .pkl needed)
                    ↓
            notebook/06_train_replanner.ipynb     ← optional DT → replanner_dt.pkl

            artifacts/
              ├── workout_rf.pkl            ← Model 1
              ├── food_master.parquet       ← seed food_master DB table
              └── replanner_dt.pkl          ← Model 3 (optional)

[Online]    FastAPI startup → load artifacts ke memory
                    ↓
            Backend POST → FastAPI handler → predict() → return JSON
```

---

## 7. Performance Budget

| ML Endpoint | Target p95 | Keterangan |
|---|---|---|
| `POST /predict/workout-plan` | < 800 ms | 7-day plan generate (RF inference) |
| `POST /predict/meal-plan` | < 500 ms | Knapsack 7 hari |
| `POST /predict/meal-alternatives` | < 200 ms | Knapsack subset ~100 item |
| `POST /predict/replan` | < 600 ms | Re-generate plan mingguan |
| Intensity adjuster (backend, no ML) | < 10 ms | Lookup table in-memory |

---

## 8. Phasing & Priorities

### Phase 1 (Days 1-2) — Data Prep
- Augment `nutrition.csv` → `food_master.parquet` (category, price, halal, veg flags)
- EDA + validate `gym_members_exercise_tracking.csv` outliers
- Filter exercise library dari 600K+ dataset → 200 item kurasi

### Phase 2 (Days 3-4) — Model_Rekomendasi_Latihan
- Augment 973 → 6,800 rows via 7-day expansion
- Train MultiOutput RandomForest
- Eval: F1-macro > 0.65, accuracy > 70%
- Export `workout_rf.pkl`

### Phase 3 (Days 5-6) — Model_Perencana_Makan
- Implement greedy knapsack + score function per goal
- Cross-day diversifier (penalize duplicate staple)
- Validasi terhadap `diet_recommendations_dataset.csv`

### Phase 4 (Days 7-8) — Model_Adaptif_Perencanaan_Ulang
- Implement rule 3-cabang (REDUCE/MAINTAIN_SWAP/INTENSIFY)
- Optional: train Decision Tree depth-3
- Intensity adjuster rule table → backend service (bukan di sini)

### Phase 5 (Days 9-14) — Integration & Demo
- FastAPI wrapper 3 model
- Backend call test
- E2E smoke test Flutter ↔ Backend ↔ ML

---

## 9. Success Criteria

- **Workout RF:** F1-macro ≥ 0.65, accuracy ≥ 70%
- **Meal Planner:** calorie deviation ≤ 15%, budget compliance 100%, diversity score ≥ 0.7
- **Replanner:** adherence improvement ≥ 10% pada simulasi
- **Fallback:** jika ML down → backend pakai default rule (no crash)

---

## 10. Risks & Mitigations

| Risiko | Severity | Mitigasi |
|---|---|---|
| Dataset workout 973 row kecil | MEDIUM | Synthetic augmentation 7×, 5-fold CV |
| Food pricing tidak ada di nutrition.csv | HIGH | Heuristic price (category × calories) ~70% akurasi |
| Knapsack output monoton | MEDIUM | Cross-day diversifier |
| Replanner rule terlalu kaku | LOW | Optional DT fine-tune |
| ML latency spike | MEDIUM | Cache plan di Redis TTL 1 jam |

---

## 11. Folder & File Convention

```
notebook/training_model/
├── Model_Rekomendasi_Latihan/      ← Model 1 training files
├── Model_Perencana_Makan/          ← Model 2 training files
└── Model_Adaptif_Perencanaan_Ulang/ ← Model 3 training files

heltigo-ml-service/
├── app/
│   ├── main.py
│   ├── routes/
│   │   ├── workout.py          ← /predict/workout-plan
│   │   ├── meal.py             ← /predict/meal-plan + /predict/meal-alternatives
│   │   └── replan.py           ← /predict/replan
│   ├── models/                 ← Pydantic schemas
│   ├── services/
│   │   ├── workout_recommender.py
│   │   ├── meal_planner.py
│   │   └── replanner.py
│   └── data/
│       ├── workout_rf.pkl
│       ├── food_master.parquet
│       └── replanner_dt.pkl
├── tests/
├── requirements.txt
└── Dockerfile
```

> **Tidak ada** `intensity.py` route atau `intensity_adjuster.py` service di ML — logika ini ada di backend Express: `backend/services/intensity_adjuster.service.ts`.

---

**Lihat juga:**
- [`01_MODELS_SPEC.md`](01_MODELS_SPEC.md) — detail per model (3 model)
- [`02_DATASETS_INVENTORY.md`](02_DATASETS_INVENTORY.md) — inventaris dataset
- [`../../backend/07_BUSINESS_LOGIC.md`](../../backend/07_BUSINESS_LOGIC.md) — intensity adjuster rule (backend)

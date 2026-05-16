# Heltigo ML — Documentation Index

> Folder ini berisi dokumentasi 4 model ML untuk Heltigo (Workout Recommender, Meal Planner, Pre-Workout Intensity Adjuster, Adaptive Replanner), training pipeline, dan FastAPI serving.
> **Source of truth terbaru:** [`FE-model-requirement/`](FE-model-requirement/) (2026-05-15).

---

## 📂 File di folder ini

### ✅ Source of Truth (latest, 2026-05-16)

| File | Topik | Status |
|---|---|---|
| [`FE-model-requirement/00_OVERVIEW.md`](FE-model-requirement/00_OVERVIEW.md) | Arsitektur ML, 3 model summary, integration points dengan backend, SOTA stack | ✅ **AUTHORITATIVE** |
| [`FE-model-requirement/01_MODELS_SPEC.md`](FE-model-requirement/01_MODELS_SPEC.md) | Detail per model: input/output, algoritma (XGBoost+Optuna), dataset combined | ✅ **AUTHORITATIVE** |
| [`FE-model-requirement/02_DATASETS_INVENTORY.md`](FE-model-requirement/02_DATASETS_INVENTORY.md) | Inventaris 10 dataset + combined strategy + augmentation | ✅ **AUTHORITATIVE** |
| [`FE-model-requirement/03_RESEARCH_REFERENCES.md`](FE-model-requirement/03_RESEARCH_REFERENCES.md) | **NEW** — 30+ paper acuan jurnal 2022-2025 + code snippets | ✅ **AUTHORITATIVE** |

### ✅ Aktif (di-patch dengan sync notes)

| File | Topik | Catatan |
|---|---|---|
| [`01_OVERVIEW.md`](01_OVERVIEW.md) | Tujuan ML, tech stack, model list | Patch: 3→4 model, endpoint rename `/infer` → `/predict` |
| [`02_DATASETS.md`](02_DATASETS.md) | Draft awal inventaris dataset | Banner: gunakan `02_DATASETS_INVENTORY.md` |
| [`03_MODELS.md`](03_MODELS.md) | Draft awal spec model | Banner: gunakan `01_MODELS_SPEC.md` |
| [`04_PIPELINE.md`](04_PIPELINE.md) | Training pipeline 2-minggu | Patch: detail augmentation 973→6800, chunked loading |
| [`05_FEATURE_ENGINEERING.md`](05_FEATURE_ENGINEERING.md) | Feature per model + transformasi | Patch: standardize sleep_band naming, post-processing rules |
| [`06_SERVING_FASTAPI.md`](06_SERVING_FASTAPI.md) | FastAPI service deployment | Patch: rename endpoint ke `/predict/*` |
| [`07_NOTEBOOKS.md`](07_NOTEBOOKS.md) | Inventaris notebook | Patch: notebook sequence final + artifact naming |

---

## 🎯 3 Model Utama

| # | Model | Folder Training | Tipe | Endpoint FastAPI |
|---|---|---|---|---|
| 1 | **Rekomendasi Latihan** | `Model_Rekomendasi_Latihan/` | RandomForest multi-output | `POST /predict/workout-plan` |
| 2 | **Perencana Makan** | `Model_Perencana_Makan/` | Knapsack 0/1 greedy | `POST /predict/meal-plan` + `/predict/meal-alternatives` |
| 3 | **Adaptif Perencanaan Ulang** | `Model_Adaptif_Perencanaan_Ulang/` | Rule 3-cabang + optional DT | `POST /predict/replan` |

> **Intensity adjuster** (S-19 Pre-Workout Check-in) = rule table di **backend Express**, bukan ML model. Tidak ada endpoint di FastAPI untuk ini.

---

## 📖 Reading Order

1. **Konteks high-level:** `../00_ARCHITECTURE.md`
2. **Overview ML:** `FE-model-requirement/00_OVERVIEW.md`
3. **Per model detail:** `FE-model-requirement/01_MODELS_SPEC.md`
4. **Dataset & training:** `FE-model-requirement/02_DATASETS_INVENTORY.md`
5. **Pipeline implementation:** `04_PIPELINE.md` + `07_NOTEBOOKS.md`
6. **FastAPI deploy:** `06_SERVING_FASTAPI.md`

---

## 🛠️ Workflow Singkat

```
[Dataset inspection]
   01_eda_gym_members.ipynb
   02_eda_nutrition.ipynb
        ↓
[Data cleaning + augmentation]
   03_clean_nutrition.ipynb   → food_master.parquet
        ↓
[Training models]
   04_train_workout_rf.ipynb  → workout_rf.pkl
   05_test_meal_planner.ipynb (algoritma deterministic, no .pkl)
   06_test_intensity_adjuster.ipynb (rule table, no training)
   07_train_replanner_dt.ipynb (optional)  → replanner_dt.pkl
        ↓
[Smoke test E2E]
   08_eval_endtoend.ipynb
        ↓
[Deploy ke FastAPI]
   ml-service/app/ load artifacts from data/
```

---

## 🤝 Cross-References

- **Backend integration:** [`../backend/06_ML_INTEGRATION.md`](../backend/06_ML_INTEGRATION.md), [`../backend/FE_requirement/00_API_REQUIREMENTS.md`](../backend/FE_requirement/00_API_REQUIREMENTS.md)
- **Frontend triggers:** [`../frontend/05_SCREENS_SPEC.md`](../frontend/05_SCREENS_SPEC.md) §S-19 Pre-Workout Check-in, §S-34 Replanning
- **Top-level:** [`../00_ARCHITECTURE.md`](../00_ARCHITECTURE.md)

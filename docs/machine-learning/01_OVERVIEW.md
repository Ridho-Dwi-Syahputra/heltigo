# Machine Learning — Overview

> 📌 **Update 2026-05-15** — Spec final ML:
> - Total **4 model** (bukan 3): Workout RF, Meal Planner Knapsack, **Pre-Workout Intensity Adjuster** (NEW, rule table), Adaptive Replanner.
> - FastAPI endpoint **rename** dari `/infer/*` → `/predict/*-plan`:
>   - `POST /predict/workout-plan`
>   - `POST /predict/meal-plan`
>   - `POST /predict/intensity` ⬅ NEW
>   - `POST /predict/meal-alternatives` ⬅ NEW
>   - `POST /predict/replan`
>
> Source of truth: [`FE-model-requirement/00_OVERVIEW.md`](FE-model-requirement/00_OVERVIEW.md) dan [`01_MODELS_SPEC.md`](FE-model-requirement/01_MODELS_SPEC.md).
>
> File overview di bawah ini masih valid untuk konteks tujuan & arsitektur high-level. Patch ditandai dengan ▶.

---

## 1. Tujuan

Tim ML menyediakan **3 model inferensi** sebagai microservice Python (FastAPI) yang dipanggil oleh backend Express.js untuk menghasilkan rekomendasi personal Heltigo:

| # | Model | Folder Training | Fungsi | Endpoint FastAPI |
|---|---|---|---|---|
| 1 | **Rekomendasi Latihan** | `Model_Rekomendasi_Latihan/` | Generate 7-day workout plan (RF multi-output) | `POST /predict/workout-plan` |
| 2 | **Perencana Makan** | `Model_Perencana_Makan/` | Generate 7-day meal + swap alternatives (Knapsack) | `POST /predict/meal-plan` + `/predict/meal-alternatives` |
| 3 | **Adaptif Perencanaan Ulang** | `Model_Adaptif_Perencanaan_Ulang/` | Re-generate plan mingguan (rule 3-cabang + optional DT) | `POST /predict/replan` |

> **Intensity adjuster** (mood/energy/sleep → volume multiplier) adalah rule table di **backend Express**, bukan ML model. Tidak ada training folder-nya karena bukan ML.

Untuk pergeseran arsitektur ke server-side: kita TIDAK lagi terikat pada model TFLite ringan 1-5 MB. **Model penuh** scikit-learn (Random Forest, Decision Tree) di-load langsung dari `.joblib` saat startup FastAPI.

## 2. Tech Stack

| Layer | Pilihan | Alasan |
|---|---|---|
| Bahasa | **Python 3.11+** | Native ekosistem ML |
| Framework API | **FastAPI 0.110+** | Async, Pydantic auto-validation, OpenAPI gratis |
| ML | **scikit-learn 1.4+** | Random Forest, Decision Tree, Pipeline |
| Numerik | **numpy 1.26+, pandas 2.2+** | Data manipulation |
| Optimization | **scipy.optimize** + custom knapsack | Untuk meal planning |
| Serialization | **joblib** | Save/load model |
| Validation | **pydantic 2.x** | Schemas request/response |
| Server | **uvicorn[standard]** | ASGI |
| Testing | **pytest** + httpx async client | Smoke test endpoints |
| Optional | **lightgbm / xgboost** | Jika RF tidak cukup akurat |

Versi pinned di `ml-service/requirements.txt` (lihat `06_SERVING_FASTAPI.md`).

## 3. Pemetaan Gap Penelitian → Model

Sesuai `Heltigo_Deskripsi_Aplikasi_Updated.docx` §4:

| Gap | Yang diisi Heltigo | Model |
|---|---|---|
| G1: Tidak ada integrasi latihan + nutrisi + budget | Single pipeline orchestration di Express → kedua ML model | All 3 |
| G2: Tidak ada solusi AI offline tanpa wearable | *Disesuaikan: hybrid offline-first dengan cached plan* | All 3 |
| G3: Database makanan western-centric | Dataset 1.346 item Indonesia | Meal Planner |
| G4: Faktor psikologis tidak terintegrasi | Mood + energy + sleep sebagai input | Workout adjust |
| G5: Privasi cloud-based AI | Model isolated, data dienkripsi | Semua di server isolated |

## 4. Struktur Proyek ML

```
ml-service/
├── main.py                          # FastAPI app entry
├── requirements.txt
├── Dockerfile
├── pyproject.toml (opsional, jika pakai poetry)
│
├── app/
│   ├── __init__.py
│   ├── config.py                    # Env, paths, secrets
│   ├── deps.py                      # FastAPI dependencies (auth header)
│   │
│   ├── api/                         # Routers
│   │   ├── __init__.py
│   │   ├── workout.py               # /infer/workout, /adjust
│   │   ├── meal.py                  # /infer/meal, /alternative
│   │   ├── replan.py                # /infer/replan
│   │   └── health.py                # /healthz
│   │
│   ├── schemas/                     # Pydantic models
│   │   ├── __init__.py
│   │   ├── workout.py
│   │   ├── meal.py
│   │   └── replan.py
│   │
│   ├── services/                    # Business logic ML
│   │   ├── __init__.py
│   │   ├── workout_recommender.py
│   │   ├── workout_adjuster.py
│   │   ├── meal_planner.py          # Knapsack + RF re-rank
│   │   ├── replanner.py
│   │   └── feature_eng.py
│   │
│   └── data/                        # Static lookups (loaded saat startup)
│       ├── exercise_master.parquet  # ~200 exercises hasil curasi
│       ├── food_master.parquet      # 1.346 Indonesian foods
│       ├── workout_rf.joblib        # Trained Random Forest
│       └── workout_adj_rules.json   # Rule-based adjustment table
│
├── notebooks/                        # Training & EDA (mirror dari root notebook/)
│   ├── 01_eda_workout.ipynb
│   ├── 02_eda_nutrition.ipynb
│   ├── 03_clean_workout.ipynb
│   ├── 04_clean_nutrition.ipynb
│   ├── 05_train_workout_rf.ipynb
│   ├── 06_meal_optimizer_dev.ipynb
│   └── 07_replanner_logic.ipynb
│
└── tests/
    ├── test_workout.py
    ├── test_meal.py
    └── test_replan.py
```

## 5. Filosofi Desain Model

### 5.1 Pragmatic over Sophisticated

Untuk hackathon 2 minggu, **utamakan model yang berjalan & memberi output masuk akal** daripada deep learning kompleks. Random Forest scikit-learn cukup untuk kebanyakan task.

### 5.2 Hybrid: ML + Rules

Beberapa task lebih cocok rule-based:
- **Workout adjust** dari mood/energy/sleep → rule-based table (5×5×5 = 125 kombinasi mungkin, mapping ke multiplier 0.5..1.2). Tidak butuh ML.
- **Replanning skor 3-cabang** (<50%, 50-80%, >80%) → rule-based dengan small DT optional untuk tweaking.

ML murni hanya untuk:
- **Workout recommender** (Random Forest classifier multi-output)
- **Meal optimizer** (knapsack + scoring berbasis bobot ML opsional)

### 5.3 Server-Side Processing

Karena tidak ada constraint TFLite 1-5 MB:
- Boleh pakai semua fitur dataset (tidak perlu prune untuk size)
- Boleh ensemble (RF dengan 100 trees) — latensi tetap <100ms
- Boleh post-processing kompleks (filter + scoring + diversifikasi)

## 6. Data Pipeline

```
Dataset Kaggle (CSV)
    │
    ▼
Cleaning (notebook 03, 04)
    │
    ▼
Feature Engineering (services/feature_eng.py)
    │
    ▼
Training (notebook 05) → joblib model
    │
    ▼
ml-service/app/data/*.joblib (load saat FastAPI startup)
    │
    ▼
Inference (services/workout_recommender.py, etc)
    │
    ▼
Response JSON ke Express
```

Lihat detail di:
- `02_DATASETS.md` — sumber data
- `04_PIPELINE.md` — training pipeline
- `05_FEATURE_ENGINEERING.md` — fitur yang dipakai

## 7. Kontrak dengan Backend

ML service **tidak punya database** — stateless. Semua context dikirim Express di body request:

```python
# Contoh request dari Express ke FastAPI
{
  "profile": {
    "bmi": 26.27,
    "bmi_category": "OVERWEIGHT",
    "gender": "MALE",
    "age": 22,
    "fitness_level": "BEGINNER",
    "workout_mode": "GYM",
    "days_per_week": 4,
    "session_minutes": 45,
    "conditions": ["NONE"]
  }
}
```

ML service mengembalikan plan yang akan dipersist Express ke MySQL.

## 8. Quick Start (Local Dev)

```bash
cd ml-service
python -m venv .venv
source .venv/bin/activate  # Linux/Mac
# .venv\Scripts\activate    # Windows PowerShell

pip install -r requirements.txt

# Pastikan model files sudah ada di app/data/
# Jika belum, jalankan training notebook dulu

uvicorn main:app --reload --port 8001
```

Smoke test:
```bash
curl http://localhost:8001/healthz
# {"status":"ok","models_loaded":["workout_rf","food_master","exercise_master"]}
```

## 9. Definition of Done — Model

Model dianggap selesai jika:
1. Training accuracy >70% pada validation set (untuk classifier).
2. Inference latency <500ms per request (single user).
3. Endpoint FastAPI terpasang dengan Pydantic schema valid.
4. Smoke test dari Postman/curl berhasil dengan input realistis.
5. Edge case ditangani (empty list, extreme BMI, kondisi conflicting).
6. Logging via stdlib `logging` module (info untuk inference, error untuk fail).

## 10. Catatan Performa & Skalabilitas

- **Model load di startup**, bukan per-request. Joblib load satu kali, simpan global.
- **No GPU needed** — RF dan knapsack CPU-bound, single-thread sudah cukup cepat.
- **Workers**: `uvicorn --workers 2` cukup untuk hackathon. Production scale ke 4-8.
- **Caching**: tidak perlu Redis. Plan generation sangat sporadis (1x per signup, 1x per minggu).

## 11. Hubungan dengan File Lain

- `02_DATASETS.md` — daftar dataset & source path
- `03_MODELS.md` — arsitektur tiap model
- `04_PIPELINE.md` — pipeline training
- `05_FEATURE_ENGINEERING.md` — fitur engineering
- `06_SERVING_FASTAPI.md` — kontrak API endpoint
- `07_NOTEBOOKS.md` — daftar notebook & output yang dihasilkan

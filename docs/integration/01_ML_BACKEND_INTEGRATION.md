# Integrasi ML Service ↔ Backend Heltigo

> **Sumber kebenaran kontrak ML.**
> Dokumen ini menjelaskan bagaimana Express.js backend (`backend/`) berkomunikasi dengan FastAPI ML service (`machine-learning/ml-service/`), termasuk **enrichment layer Gemini** yang dijalankan di sisi backend untuk memperkaya output numerik ML menjadi narasi personal Bahasa Indonesia.

---

## 1. Arsitektur Tingkat Tinggi

```
┌────────────────┐  HTTPS+JWT   ┌────────────────────┐  HTTP+X-ML-KEY   ┌──────────────────────┐
│ Flutter App    │ ───────────► │ Express Backend    │ ──────────────►  │ FastAPI ML Service   │
│ (Frontend)     │              │ (Node 20, Prisma)  │                  │ (Python 3.11, sklearn│
│                │ ◄─────────── │                    │ ◄──────────────  │  + XGBoost + Gemini) │
└────────────────┘   JSON       │  ┌──────────────┐  │   JSON           └──────────────────────┘
                                │  │ Gemini       │  │
                                │  │ Enrichment   │  │── HTTPS+API_KEY ─► Gemini 1.5 Flash
                                │  └──────────────┘  │
                                └────────────────────┘
```

* **Backend tidak pernah expose ML service ke FE.** FE hanya bicara ke backend.
* **Gemini dipanggil dari backend, bukan dari FE.** Ini menjaga API key aman dan memungkinkan caching/throttling sentral.
* **ML service tetap punya akses Gemini sendiri**, khusus untuk Gemini Vision di `/predict/food-scan` (image → daftar nama makanan). Tugas tekstual lain (motivasi, narasi mingguan) dilakukan di backend.

---

## 2. Konfigurasi & Autentikasi

### 2.1 Environment

`backend/.env`:

```ini
ML_SERVICE_URL=http://localhost:8001
ML_SERVICE_KEY=shared-secret-with-fastapi    # HARUS sama persis dengan ml-service .env
GEMINI_API_KEY=                              # Optional; jika kosong → fallback statis
GEMINI_MODEL=gemini-1.5-flash
GEMINI_TIMEOUT_MS=3000
```

`machine-learning/ml-service/.env`:

```ini
ML_SERVICE_KEY=shared-secret-with-fastapi    # cocokkan dengan backend
GEMINI_API_KEY=...                           # untuk Gemini Vision di food-scan
```

> **Cara dapat `GEMINI_API_KEY`:**
> Login ke <https://aistudio.google.com/apikey> dengan akun Google, "Create API Key", copy. Tier gratis sudah cukup untuk demo (rate limit ~15 RPM untuk `gemini-1.5-flash`).

### 2.2 Header autentikasi

Setiap request dari backend ke ML wajib menyertakan header:

```
X-ML-KEY: <ML_SERVICE_KEY>
Content-Type: application/json
```

Server akan menolak request tanpa header valid dengan `401 INVALID_ML_KEY`.

### 2.3 Reliability layer

`backend/src/ml-client/ml.client.ts` membungkus axios dengan:

| Aspect       | Setting                                                  |
|--------------|----------------------------------------------------------|
| Timeout      | `10s` (per request)                                      |
| Retry        | 2x untuk status `5xx` atau network error                 |
| Backoff      | exponential, `300ms → 600ms → 1200ms`                    |
| Error mapping| `ECONNABORTED` → `502 ML_TIMEOUT`                        |
|              | No response → `502 ML_UNREACHABLE`                       |
|              | `5xx` → `502 ML_ERROR`                                   |

FE selalu melihat `502` dari backend (bukan langsung dari ML), agar bisa retry-aware.

---

## 3. Kontrak Endpoint ML

> Base URL: `${ML_SERVICE_URL}` (default `http://localhost:8001`)

### 3.1 `POST /predict/workout-plan`

Generate program latihan 7 hari berbasis profil user.

**Request**

```json
{
  "fitness_level": "BEGINNER | INTERMEDIATE | ADVANCED",
  "goal":          "WEIGHT_LOSS | MUSCLE_GAIN | MAINTENANCE | PERFORMANCE",
  "bmi":            22.5,
  "age":            28,
  "gender":         "MALE | FEMALE",
  "workout_mode":   "HOME | GYM | HYBRID",
  "days_per_week":  4,
  "session_minutes": 45,
  "has_injury":    false,
  "has_chronic":   false,
  "conditions":    ["asma"]
}
```

**Response**

```json
{
  "days": [
    {
      "day_index": 0,
      "workout_type": "STRENGTH",
      "intensity":    "MID",
      "is_rest_day":  false,
      "estimated_minutes": 45,
      "exercises": [
        { "name": "Bodyweight Squat", "phase": "WARMUP", "sets": 2, "reps": 12, "rest_seconds": 30 }
      ]
    }
  ],
  "model_version": "v3-knowledge-distillation"
}
```

**Dipakai oleh:** `POST /api/v1/plan/generate` (di backend → `planService.generate`).

---

### 3.2 `POST /predict/meal-plan`

Generate menu 7 hari dengan algoritma Knapsack + GA.

**Request**

```json
{
  "tdee":               2200,
  "target_calorie_adj": -500,
  "budget_per_day_idr": 35000,
  "meal_frequency":     3,
  "goal":               "WEIGHT_LOSS",
  "dietary_restrictions": ["halal"],
  "excluded_food_ids":   [],
  "user_condition":      "None"
}
```

**Response**

```json
{
  "days": [
    {
      "day_index": 0,
      "total_calories": 1720,
      "total_protein_g": 92.4,
      "total_fat_g":     48.1,
      "total_carbs_g":  220.3,
      "total_cost_idr": 33500,
      "meals": [
        {
          "meal_type": "BREAKFAST",
          "total_calories": 480,
          "total_cost_idr": 9000,
          "foods": [
            { "food_id": 12, "name": "Nasi uduk", "category": "STAPLE", "calories": 250, "protein_g": 5, "fat_g": 3, "carbs_g": 50, "price_idr": 5000, "is_halal": true }
          ]
        }
      ]
    }
  ],
  "diversity_score": 0.78,
  "calorie_coverage_pct": 98.5,
  "algorithm": "knapsack-ga-v3"
}
```

**Catatan budget:** ML akan tetap menghormati `budget_per_day_idr` sebagai HARD constraint; kalori adalah SOFT target. Minimum yang valid: `Rp 10.000/hari` (FE/BE me-validate ini sebelum call).

---

### 3.3 `POST /predict/meal-alternatives`

Cari alternatif untuk 1 food item (dipakai saat user "swap meal").

**Request**

```json
{
  "food_id":    12,
  "meal_type":  "BREAKFAST",
  "goal":       "WEIGHT_LOSS",
  "dietary_restrictions": ["halal"],
  "budget_max_idr": 15000
}
```

**Response**

```json
{
  "alternatives": [
    { "food_id": 88, "name": "Bubur kacang ijo", "category": "STAPLE", "calories": 230, "protein_g": 6, "fat_g": 2, "carbs_g": 48, "price_idr": 7000, "is_halal": true }
  ]
}
```

Backend mengambil **3 alternatif teratas** dan meng-enrich masing-masing dengan Gemini (alasan kenapa cocok). Lihat §5.

---

### 3.4 `POST /predict/replan`

Hitung volume adjustment mingguan dari skor kepatuhan + delta berat.

**Request**

```json
{
  "weekly_score":     78,
  "weight_diff_kg":  -0.4,
  "bmi":             22.5,
  "experience_level": 1,
  "age": 28,
  "workout_frequency": 4
}
```

**Response**

```json
{
  "volume_multiplier": 1.10,
  "recommendation":    "Naikkan volume 10% minggu depan",
  "action":            "INCREASE_VOLUME",
  "model_version":     "xgb-regressor"
}
```

`experience_level`: 1=BEGINNER, 2=INTERMEDIATE, 3=ADVANCED.

Backend menambah narasi personal via Gemini (lihat `enrichReplanNarrative`).

---

### 3.5 `POST /predict/food-scan`

Identifikasi makanan dari foto + estimasi nutrisi + health score.

**Request** (salah satu dari 2 mode):

Mode A — image base64:
```json
{
  "image_base64":   "<base64 PNG/JPG, tanpa prefix data:image/...>",
  "user_goal":      "MAINTENANCE",
  "user_condition": "diabetes",
  "portions":       null
}
```

Mode B — list nama makanan (sudah pre-identified):
```json
{
  "identified_foods": ["nasi goreng", "telur dadar"],
  "user_goal":        "WEIGHT_LOSS",
  "user_condition":   "None",
  "portions":         [1.0, 1.0]
}
```

**Response**

```json
{
  "identified_by_gemini": ["nasi goreng", "telur dadar"],
  "matches": [
    { "query": "nasi goreng", "matched": "Nasi goreng kampung", "confidence": 0.91, "calories": 350, "protein_g": 12, "fat_g": 10, "carbs_g": 55, "category": "STAPLE", "is_halal": true }
  ],
  "nutrition_total": { "calories": 530, "protein_g": 20, "fat_g": 18, "carbs_g": 62 },
  "health_score":    0.62,
  "assessment":      "MODERATE",
  "user_goal":       "WEIGHT_LOSS",
  "user_condition":  "None"
}
```

**Catatan Gemini Vision:**
* Aktif hanya kalau `GEMINI_API_KEY` ada di ml-service `.env`. Kalau kosong → endpoint mengembalikan `503 GEMINI_NOT_CONFIGURED`.
* Model: `gemini-1.5-flash` (free tier cukup untuk demo).
* Prompt ML: meminta daftar nama makanan tanpa penjelasan, satu per baris.
* Setelah Gemini balas list, ML melakukan **TF-IDF + cosine similarity** ke `food_master` lokal untuk lookup nutrisi.

---

### 3.6 `GET /health`

Liveness probe (no auth).

```json
{ "status": "ok", "service": "ml-service", "version": "v1", "models": { "workout": true, "meal": true, "replan": true, "food_scan": true } }
```

---

## 4. Pemetaan Endpoint Backend → ML

Backend tidak pernah expose ML mentah ke FE. Setiap endpoint backend yang membutuhkan ML mem-bundle:
profile → payload → ML call → DB persist → (opsional) Gemini enrich → response.

| Endpoint Backend                  | ML Endpoint(s)                                  | Gemini? | Lokasi service                          |
|-----------------------------------|-------------------------------------------------|---------|-----------------------------------------|
| `POST /api/v1/plan/generate`      | `workout-plan` + `meal-plan` (parallel)         | —       | `services/plan.service.ts`              |
| `POST /api/v1/plan/replan`        | `replan`                                        | ✅      | `services/replanning.service.ts`        |
| `POST /api/v1/meal/:id/swap`      | `meal-alternatives`                             | ✅      | `services/meal.service.ts → swapMeal`   |
| `POST /api/v1/meal/food-scan`     | `food-scan` (passthrough)                       | ✅      | `services/meal.service.ts → foodScan`   |
| `POST /api/v1/workout/.../complete` | —                                             | ✅      | `services/workout.service.ts → completeSession` |

---

## 5. Gemini Enrichment Layer

### 5.1 Filosofi

> "**ML jawab dengan angka, Gemini jawab dengan kata-kata.**"

ML model dilatih khusus untuk akurasi numerik (volume, kalori, kategori). Gemini bertugas menerjemahkan angka itu menjadi pesan personal yang user-friendly dalam Bahasa Indonesia. Ini meningkatkan user perception tanpa mengorbankan reliability.

### 5.2 Implementasi

`backend/src/services/gemini.service.ts` mengekspos 4 method:

| Method                          | Dipakai di                       | Output                                              |
|---------------------------------|----------------------------------|------------------------------------------------------|
| `enrichWorkoutComplete(stats)`  | `workoutService.completeSession` | 1-2 kalimat selamat + tips recovery                  |
| `enrichMealRecommendation(food)`| `mealService.swapMeal` (tiap alt)| 1 kalimat alasan kenapa makanan ini cocok            |
| `enrichReplanNarrative(metrics)`| `replanningService.runReplan`    | 2 kalimat summary minggu + alasan rekomendasi        |
| `enrichFoodScanAdvice(scan)`    | `mealService.foodScan`           | 2 kalimat penilaian + 1 tips konkret                 |

### 5.3 Reliability

* **Timeout**: `GEMINI_TIMEOUT_MS=3000` (default 3 detik).
* **Fallback**: setiap method punya **template statis** Bahasa Indonesia yang dipakai kalau:
  * `GEMINI_API_KEY` kosong
  * Timeout
  * Gemini balas error
  * Response kosong / tidak parseable
* **Tidak pernah blocking**: endpoint user-facing tidak gagal hanya karena Gemini down.
* **Tidak pernah throw**: error di-log via `pino` (`logger.warn`), tetap return fallback ke caller.

### 5.4 Prompt design

Semua prompt:
* Berbahasa Indonesia.
* Eksplisit melarang emoji, heading, dan list (supaya FE bisa render plain text di mana saja).
* Maksimum 2 kalimat (kontrol panjang output → kontrol biaya).
* Menyertakan data numerik konkret supaya output personal, bukan generik.

---

## 6. Menjalankan ML Service dari Backend

### 6.1 Setup ml-service (sekali saja)

```powershell
cd machine-learning\ml-service
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
copy .env.example .env   # isi ML_SERVICE_KEY & GEMINI_API_KEY
```

### 6.2 Jalankan

```powershell
# Terminal 1 — ML service (port 8001)
cd machine-learning\ml-service
.\.venv\Scripts\Activate.ps1
uvicorn main:app --reload --port 8001

# Terminal 2 — Backend (port 3000)
cd backend
npm install                # sekali saja (sekarang sudah termasuk @google/generative-ai)
npx prisma migrate dev     # sekali saja
npm run dev
```

### 6.3 Smoke test

```powershell
# Health check ML (no auth)
curl http://localhost:8001/health

# Health check backend (no auth)
curl http://localhost:3000/health

# Tes integrasi ML lewat backend (perlu JWT)
curl -X POST http://localhost:3000/api/v1/plan/generate `
  -H "Authorization: Bearer <JWT>" `
  -H "Content-Type: application/json" `
  -d '{}'
```

---

## 7. Error Handling End-to-End

| Skenario                                  | ML response       | Backend translasi           | Yang dilihat FE                       |
|-------------------------------------------|-------------------|-----------------------------|----------------------------------------|
| ML service down                           | (connection err)  | `502 ML_UNREACHABLE`        | "Layanan AI tidak dapat dihubungi"     |
| ML timeout > 10s                          | (timeout)         | `502 ML_TIMEOUT`            | "Layanan AI lambat, coba lagi"         |
| ML payload invalid (Pydantic fail)        | `422`             | propagated as `502 ML_ERROR`| "Permintaan AI gagal"                  |
| Backend payload sengaja salah             | `422`             | `400 VALIDATION_ERROR` (zod)| "Input tidak valid"                    |
| Gemini API key invalid/quota habis        | n/a               | fallback statis dipakai     | Pesan template (tidak ada error)       |
| Gemini timeout                            | n/a               | fallback statis dipakai     | Pesan template (tidak ada error)       |

**Prinsip**: kegagalan Gemini **tidak pernah** menjadi error user-facing. Kegagalan ML **selalu** dimapping ke `502` dengan kode spesifik.

---

## 8. Versioning & Observability

* Setiap ML response punya `model_version` (workout: `v3-knowledge-distillation`, replan: `xgb-regressor`, meal: `knapsack-ga-v3`). Backend menyimpan ini di `workout_plans.ml_metadata.model_version` untuk audit.
* Setiap call ke ML di-log via `pino` dengan field `{ url, attempt, backoff }`.
* Saat ML gagal, error response di-log dengan status + body untuk debugging.

---

## 9. Roadmap Singkat

| Item                                                       | Status     | Catatan                                  |
|------------------------------------------------------------|------------|------------------------------------------|
| Auth `X-ML-KEY` + retry/backoff                            | ✅ Selesai | `ml.client.ts`                           |
| 5 endpoint ML production-ready                             | ✅ Selesai | semua artifact ada di repo               |
| Gemini enrichment 4 method                                 | ✅ Selesai | `gemini.service.ts`                      |
| Caching response ML (mis. plan persist)                    | ✅ Selesai | `plan.service.ts` simpan ke MySQL        |
| Circuit breaker untuk Gemini (di luar timeout)             | ⏳ Future  | sekarang fallback per-call               |
| Rate-limit endpoint food-scan per user                     | ⏳ Future  | mencegah abuse Gemini quota              |
| Streaming response Gemini untuk endpoint chat              | ⏳ Future  | jika kelak ada feature "AI coach chat"   |

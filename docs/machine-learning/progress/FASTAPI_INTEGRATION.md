# Heltigo ML Service — FastAPI Integration Guide

> **Service:** `machine-learning/ml-service/`  
> **Port:** `8001` (internal only, tidak terekspos ke publik)  
> **Auth:** Header `X-ML-KEY` (shared secret antara backend Express dan FastAPI)

---

## 1. Setup & Menjalankan FastAPI

### Menggunakan .venv yang sudah ada

```powershell
# 1. Aktifkan virtual environment (di folder notebook/)
cd "d:\Local Disk D\Tugas\hackathon core3d\machine-learning\notebook"
.\.venv\Scripts\Activate.ps1

# 2. Install dependencies FastAPI (jika belum)
pip install fastapi "uvicorn[standard]" pydantic-settings google-generativeai python-multipart

# 3. Buat file .env dari template
cd ..\ml-service
copy .env.example .env
# Edit .env: isi ML_SERVICE_KEY dan GEMINI_API_KEY

# 4. Jalankan server
uvicorn main:app --host 0.0.0.0 --port 8001 --reload
```

### Environment Variables (`.env`)

```env
ML_SERVICE_KEY=dev-shared-secret       # Harus sama dengan ML_SERVICE_KEY di backend/.env
PORT=8001
GEMINI_API_KEY=AIza...                 # Dari https://aistudio.google.com/app/apikey
MODEL_BASE_PATH=                       # Kosong = auto-detect dari lokasi ml-service/
```

---

## 2. Endpoints

### `GET /health`
Cek status service + model yang ter-load.

```bash
curl http://localhost:8001/health
```

**Response:**
```json
{
  "status": "ok",
  "service": "heltigo-ml",
  "version": "1.0.0",
  "timestamp": "2026-05-16T10:00:00Z",
  "models": ["workout-v3", "meal-knapsack-ga-v3", "replanner-xgb", "food-scan-tfidf+gemini"]
}
```

---

### `POST /predict/workout-plan`
Generate 7-day workout schedule berdasarkan profil user.

**Request:**
```json
{
  "fitness_level": "BEGINNER",
  "goal": "WEIGHT_LOSS",
  "bmi": 27.5,
  "age": 28,
  "gender": "MALE",
  "workout_mode": "GYM",
  "days_per_week": 4,
  "session_minutes": 60,
  "has_injury": false,
  "has_chronic": false,
  "conditions": []
}
```

**Field options:**
- `fitness_level`: `BEGINNER` | `INTERMEDIATE` | `ADVANCED`
- `goal`: `WEIGHT_LOSS` | `MUSCLE_GAIN` | `MAINTENANCE` | `PERFORMANCE`
- `workout_mode`: `HOME` | `GYM` | `HYBRID`
- `conditions`: `["INJURY", "JOINT_PAIN", "OBESE", "PREGNANT"]`

**Response:**
```json
{
  "days": [
    {
      "day_index": 0,
      "workout_type": "CARDIO",
      "intensity": "LOW",
      "is_rest_day": false,
      "estimated_minutes": 60,
      "exercises": [
        {"name": "Dynamic Stretching", "phase": "WARMUP", "sets": 1, "reps": 10, "rest_seconds": 60},
        {"name": "Jogging",            "phase": "MAIN",   "sets": 2, "reps": 10, "rest_seconds": 60},
        {"name": "Static Stretching",  "phase": "COOLDOWN", "sets": 1, "reps": 10, "rest_seconds": 60}
      ]
    },
    {
      "day_index": 1,
      "workout_type": "REST",
      "intensity": "LOW",
      "is_rest_day": true,
      "estimated_minutes": 0,
      "exercises": []
    }
  ],
  "model_version": "v3-knowledge-distillation"
}
```

---

### `POST /predict/meal-plan`
Generate 7-day meal plan menggunakan Knapsack + Genetic Algorithm.

> **Catatan:** Endpoint ini bisa memakan waktu ~5-8 detik karena GA optimization. Backend sudah dikonfigurasi dengan timeout 10s.

**Request:**
```json
{
  "tdee": 1900,
  "target_calorie_adj": -300,
  "budget_per_day_idr": 35000,
  "meal_frequency": 3,
  "goal": "WEIGHT_LOSS",
  "dietary_restrictions": ["HALAL"],
  "excluded_food_ids": [],
  "user_condition": "None"
}
```

**Field options:**
- `goal`: `WEIGHT_LOSS` | `MUSCLE_GAIN` | `MAINTENANCE` | `PERFORMANCE`
- `dietary_restrictions`: `["HALAL", "VEGETARIAN", "VEGAN"]`
- `user_condition`: `"None"` | `"Diabetes"` | `"Hypertension"` | `"Obesity"`

**Response:**
```json
{
  "days": [
    {
      "day_index": 0,
      "total_calories": 1612.5,
      "total_protein_g": 87.3,
      "total_fat_g": 42.1,
      "total_carbs_g": 198.5,
      "total_cost_idr": 33500,
      "meals": [
        {
          "meal_type": "BREAKFAST",
          "total_calories": 451.0,
          "total_cost_idr": 9400,
          "foods": [
            {
              "food_id": 123,
              "name": "Nasi putih",
              "category": "STAPLE",
              "calories": 242.0,
              "protein_g": 4.4,
              "fat_g": 0.4,
              "carbs_g": 53.4,
              "price_idr": 5000,
              "is_halal": true
            }
          ]
        }
      ]
    }
  ],
  "diversity_score": 0.857,
  "calorie_coverage_pct": 84.9,
  "algorithm": "knapsack-ga-v3"
}
```

---

### `POST /predict/meal-alternatives`
Dapatkan 3 alternatif makanan untuk 1 item yang ingin diganti.

**Request:**
```json
{
  "food_id": 123,
  "meal_type": "LUNCH",
  "goal": "WEIGHT_LOSS",
  "dietary_restrictions": ["HALAL"],
  "budget_max_idr": 15000
}
```

**Response:**
```json
{
  "alternatives": [
    {
      "food_id": 456,
      "name": "Nasi merah",
      "category": "STAPLE",
      "calories": 216.0,
      "protein_g": 5.0,
      "fat_g": 1.8,
      "carbs_g": 45.0,
      "price_idr": 7000,
      "is_halal": true
    }
  ]
}
```

---

### `POST /predict/replan`
Adaptive replanning berdasarkan performa minggu lalu.

**Request:**
```json
{
  "weekly_score": 45.0,
  "weight_diff_kg": 0.5,
  "bmi": 27.5,
  "experience_level": 1,
  "age": 28,
  "workout_frequency": 3
}
```

**Field options:**
- `experience_level`: `1` (BEGINNER) | `2` (INTERMEDIATE) | `3` (ADVANCED)
- `weekly_score`: 0-100 (seberapa banyak workout/meal yang diselesaikan)

**Response:**
```json
{
  "volume_multiplier": 0.85,
  "recommendation": "Kurangi volume latihan 15%. Tubuh perlu lebih banyak recovery minggu ini.",
  "action": "REDUCE",
  "model_version": "xgb-regressor"
}
```

**action values:** `REDUCE` | `MAINTAIN` | `INTENSIFY`

---

### `POST /predict/food-scan`
Analisis makanan dari foto (via Gemini Vision) atau dari nama makanan langsung.

**Option A — Dengan gambar (Gemini Vision):**
```json
{
  "image_base64": "/9j/4AAQSkZJRgAB...",
  "user_goal": "WEIGHT_LOSS",
  "user_condition": "None"
}
```

**Option B — Tanpa gambar (nama makanan dari teks):**
```json
{
  "identified_foods": ["nasi goreng", "telur ceplok", "es teh"],
  "user_goal": "WEIGHT_LOSS",
  "user_condition": "Diabetes",
  "portions": [1, 1, 1]
}
```

**Response:**
```json
{
  "identified_by_gemini": ["nasi goreng", "telur ceplok", "es teh"],
  "matches": [
    {
      "query": "nasi goreng",
      "matched": "Nasi goreng",
      "confidence": 0.9341,
      "calories": 296.0,
      "protein_g": 6.2,
      "fat_g": 9.7,
      "carbs_g": 45.3,
      "category": "STAPLE",
      "is_halal": true
    },
    {
      "query": "es teh",
      "matched": null,
      "confidence": 0.1823
    }
  ],
  "nutrition_total": {
    "calories": 589.5,
    "protein_g": 27.4,
    "fat_g": 18.3,
    "carbs_g": 67.8
  },
  "health_score": 0.6214,
  "assessment": "MODERATE",
  "user_goal": "WEIGHT_LOSS",
  "user_condition": "Diabetes"
}
```

**assessment values:** `GOOD` | `MODERATE` | `POOR`

---

## 3. Integrasi di Backend Express

### Setup ML Client (sudah ada di `backend/src/ml-client/ml.client.ts`)

```typescript
// backend/.env
ML_SERVICE_URL=http://localhost:8001
ML_SERVICE_KEY=dev-shared-secret   // Harus sama dengan ML_SERVICE_KEY di ml-service/.env
```

### Contoh memanggil workout plan

```typescript
// backend/src/ml-client/workout.ml.ts
import { mlClient } from './ml.client';

export async function inferWorkoutPlan(profile: WorkoutMLInput) {
  return mlClient.post<WorkoutPlanResponse>('/predict/workout-plan', {
    fitness_level: profile.fitnessLevel,
    goal:          profile.goal,
    bmi:           profile.bmi,
    age:           profile.age,
    gender:        profile.gender,
    workout_mode:  profile.workoutMode,
    days_per_week: profile.availableDaysPerWeek,
    session_minutes: profile.sessionDurationMin,
    has_injury:    profile.healthConditions.includes('INJURY'),
    conditions:    profile.healthConditions,
  });
}
```

### Contoh memanggil meal plan

```typescript
// backend/src/ml-client/meal.ml.ts
import { mlClient } from './ml.client';

export async function inferMealPlan(input: MealMLInput) {
  return mlClient.post<MealPlanResponse>('/predict/meal-plan', {
    tdee:               input.tdee,
    target_calorie_adj: input.targetCalorieAdj,
    budget_per_day_idr: input.budgetPerDayIdr,
    meal_frequency:     input.mealFrequency,
    goal:               input.goal,
    dietary_restrictions: input.dietaryRestrictions,
    excluded_food_ids:  input.excludedFoodIds ?? [],
    user_condition:     input.medicalCondition ?? 'None',
  }, { timeout: 12000 }); // 12s timeout karena GA ~5-8s
}
```

### Contoh memanggil food scan

```typescript
// backend/src/ml-client/food_scan.ml.ts
import { mlClient } from './ml.client';

// Option A: kirim gambar base64 (Gemini akan identifikasi dulu)
export async function scanFoodImage(imageBase64: string, userGoal: string, condition: string) {
  return mlClient.post('/predict/food-scan', {
    image_base64:   imageBase64,
    user_goal:      userGoal,
    user_condition: condition,
  }, { timeout: 15000 }); // 15s karena ada Gemini API call
}

// Option B: kirim nama makanan langsung (lebih cepat)
export async function analyzeFoods(foods: string[], userGoal: string, condition: string) {
  return mlClient.post('/predict/food-scan', {
    identified_foods: foods,
    user_goal:        userGoal,
    user_condition:   condition,
  });
}
```

### Contoh endpoint Express untuk food scan

```typescript
// backend/src/routes/food.routes.ts
import express from 'express';
import { requireAuth } from '../middleware/auth.middleware';
import { asyncHandler } from '../middleware/async.middleware';
import { scanFoodImage } from '../ml-client/food_scan.ml';

const router = express.Router();

// POST /api/v1/food/scan
// Body: { imageBase64: string }
router.post('/scan', requireAuth, asyncHandler(async (req, res) => {
  const { imageBase64 } = req.body;
  const user            = req.user!;

  // Ambil goal & condition dari health profile user
  const profile = await prisma.healthProfile.findUnique({
    where: { userId: user.id }
  });

  const result = await scanFoodImage(
    imageBase64,
    profile?.goal ?? 'MAINTENANCE',
    profile?.healthConditions?.[0] ?? 'None',
  );

  res.json(result);
}));

export default router;
```

---

## 4. Integrasi Gemini Vision — Cara Kerja

```
Flutter mengambil foto makanan
      ↓
Flutter encode gambar ke Base64
      ↓
POST /api/v1/food/scan  (ke Express backend)
  Body: { imageBase64: "..." }
      ↓
Express backend ambil user profile dari DB
      ↓
POST /predict/food-scan  (ke FastAPI, internal)
  Body: { image_base64: "...", user_goal: "WEIGHT_LOSS", user_condition: "None" }
      ↓
FastAPI (food_scan_service.py):
  1. Kirim gambar ke Gemini Vision API
  2. Gemini returns: ["nasi goreng", "telur ceplok"]
  3. TF-IDF match setiap nama ke food database (food_master_v3.parquet)
  4. XGBoost scorer evaluasi total nutrisi → GOOD/MODERATE/POOR
      ↓
FastAPI returns JSON lengkap
      ↓
Express forwards ke Flutter
      ↓
Flutter tampilkan:
  - Nama makanan teridentifikasi
  - Total kalori & makronutrien
  - Assessment: "MODERATE - Agak tinggi karbohidrat untuk goal weight loss kamu"
```

---

## 5. Cara Kerja Masing-masing Model

### Model 1 — Workout Recommender (v3 Knowledge Distillation)
- **Pendekatan:** Rule engine yang di-distilasi ke XGBoost
- **Input:** fitness_level, goal, BMI, age, conditions
- **Process:** Lookup schedule template dari `workout_rules_config.json` → apply condition overrides → return 7-day schedule
- **Artifacts:** `workout_xgb_v3_type.pkl`, `workout_xgb_v3_intensity.pkl`, `scaler_v3.pkl`, `workout_rules_config.json`

### Model 2 — Meal Planner (Knapsack + GA v3)
- **Pendekatan:** Greedy knapsack per meal + Genetic Algorithm untuk diversity 7 hari
- **Input:** TDEE, budget, goal, dietary restrictions
- **Process:** Filter food pool → GA optimize 7-day chromosome → expand each slot via knapsack
- **Artifacts:** `food_master_v3.parquet`, `knapsack_config_v3.json`
- **Catatan:** Tidak ada .pkl model — algoritma deterministik

### Model 3 — Adaptif Replanner (XGBoost Regressor)
- **Pendekatan:** XGBoost Regressor predict volume multiplier
- **Input:** weekly_score (0-100), weight_diff_kg, BMI, experience_level, age, workout_freq
- **Output:** multiplier 0.5-1.5 → action REDUCE/MAINTAIN/INTENSIFY
- **Artifacts:** `replanner_xgb.pkl`

### Model 4 — Food Scan Analyzer (TF-IDF + XGBoost + Gemini Vision)
- **Pendekatan:** 2-step pipeline
  1. **Gemini Vision** (jika input gambar) → identifikasi nama makanan
  2. **TF-IDF char ngram (2,4)** + cosine similarity → match nama ke database 1,346 makanan Indonesia
  3. **XGBoost 3-class classifier** → health assessment (POOR/MODERATE/GOOD)
- **Artifacts:** `food_tfidf_vectorizer.pkl`, `food_name_matrix.npy`, `nutrition_scorer.pkl`, `scanner_config.json`, `alias_map.json`, `food_processed.parquet`

---

## 6. Error Codes

| HTTP | Code | Penyebab |
|---|---|---|
| 401 | `INVALID_ML_KEY` | Header X-ML-KEY salah atau kosong |
| 400 | `NO_INPUT` | `/predict/food-scan` tanpa image_base64 maupun identified_foods |
| 503 | `GEMINI_NOT_CONFIGURED` | GEMINI_API_KEY tidak di-set di .env |
| 502 | `ML_TIMEOUT` | Request ke FastAPI timeout (dari backend Express) |
| 502 | `ML_UNREACHABLE` | FastAPI service tidak berjalan |

---

## 7. Latency Guide

| Endpoint | Latency | Catatan |
|---|---|---|
| `GET /health` | < 10ms | Instant |
| `POST /predict/workout-plan` | < 100ms | Rule-based lookup |
| `POST /predict/meal-plan` | 5-8 detik | GA 20 pop × 30 gen |
| `POST /predict/meal-alternatives` | < 100ms | Greedy filter |
| `POST /predict/replan` | < 50ms | XGBoost predict |
| `POST /predict/food-scan` (no image) | < 200ms | TF-IDF + XGBoost |
| `POST /predict/food-scan` (with image) | 3-6 detik | + Gemini Vision API call |

**Rekomendasi di backend Express:**
- Meal plan: set `timeout: 12000` (12 detik)
- Food scan dengan gambar: set `timeout: 15000` (15 detik)
- Semua endpoint lain: default 10 detik sudah cukup

---

## 8. Tips Production

1. **Jangan expose FastAPI ke internet** — hanya accessible dari localhost atau internal network
2. **Ganti ML_SERVICE_KEY** di production dengan random string ≥32 karakter
3. **Pre-load models di startup** — sudah dikonfigurasi di `main.py` via `lifespan`
4. **Meal plan caching** — pertimbangkan cache hasil `/predict/meal-plan` per user per minggu (TTL 7 hari)
5. **Gemini API rate limit** — free tier: 15 RPM. Cukup untuk demo, scale ke paid tier untuk production

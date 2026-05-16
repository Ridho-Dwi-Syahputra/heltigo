# Integrasi Fullstack Heltigo — Flutter ↔ Backend ↔ ML+Gemini

> Dokumen ini adalah **peta integrasi end-to-end**: bagaimana setiap layar Flutter mengalir ke endpoint Express, lalu ke ML FastAPI + Gemini, lalu kembali ke layar dengan data yang sudah diperkaya.
>
> Pasangkan dengan [`01_ML_BACKEND_INTEGRATION.md`](./01_ML_BACKEND_INTEGRATION.md) yang fokus ke kontrak BE↔ML.

---

## 1. Topologi 3 Service

```
   ┌────────────────────────┐
   │  Flutter App (Heltigo) │
   │  - lib/screens/        │
   │  - lib/data/api/       │
   └─────────┬──────────────┘
             │ HTTPS + JWT (Authorization: Bearer ...)
             │ Base URL: http://10.0.2.2:3000/api/v1   (emulator → host)
             │           http://localhost:3000/api/v1  (web/desktop)
             ▼
   ┌────────────────────────────────────────────┐
   │  Express Backend  (port 3000)              │
   │  - src/routes/*.routes.ts                  │
   │  - src/controllers/*.controller.ts         │
   │  - src/services/*.service.ts               │
   │  - src/ml-client/ml.client.ts              │
   │  - Prisma → MySQL (port 3306)              │
   └─────────┬─────────────────────┬────────────┘
             │ HTTP + X-ML-KEY     │ HTTPS + GEMINI_API_KEY
             ▼                     ▼
   ┌──────────────────────┐  ┌──────────────────────┐
   │ FastAPI ML  (8001)   │  │ Gemini 1.5 Flash     │
   │ - workout/meal/      │  │ (enrichment teks)    │
   │   replan/food-scan   │  │                      │
   │ - Gemini Vision      │  └──────────────────────┘
   │   utk food-scan      │
   └──────────────────────┘
```

* **FE hanya berbicara ke backend**, tidak pernah langsung ke ML atau Gemini.
* **Gemini API key tidak pernah disebar ke FE.** Semua call Gemini terjadi di backend (atau di ML untuk Vision).
* **Offline-first**: FE membuat queue lokal, lalu sync via `POST /api/v1/sync/batch` saat online.

---

## 2. Tabel Endpoint FE → BE (lengkap)

> Semua endpoint butuh `Authorization: Bearer <accessToken>` kecuali ditandai `(public)`.

### 2.1 Auth

| FE Screen                    | Method | Path                          | Body (ringkas)             | Catatan                              |
|------------------------------|--------|-------------------------------|----------------------------|--------------------------------------|
| `register_screen.dart`       | POST   | `/auth/register` (public)     | email, password, name      | Returns user + accessToken + refresh |
| `login_screen.dart`          | POST   | `/auth/login` (public)        | email, password            | Last-login dicatat                   |
| (interceptor)                | POST   | `/auth/refresh-token` (public)| refreshToken               | Rotates refresh token                |
| `settings_screen.dart`       | POST   | `/auth/logout`                | refreshToken               | Revoke refresh (server-side)         |
| `forgot_password_screen.dart`| POST   | `/auth/forgot-password` (public)| email                    | Dev: return token; prod: kirim email |
| —                            | POST   | `/auth/reset-password` (public)| token, newPassword        | (stub `501` untuk demo)              |
| `home_screen.dart` (boot)    | GET    | `/auth/me`                    | —                          | User + healthProfile                 |

### 2.2 User Profile & Onboarding

| FE Screen                          | Method | Path                              | Catatan                                       |
|------------------------------------|--------|-----------------------------------|-----------------------------------------------|
| `profile_screen.dart`              | GET    | `/user/profile`                   | user + healthProfile (BMI auto-hitung)        |
| `edit_profile_screen.dart`         | PUT    | `/user/profile`                   | name, avatarUrl                               |
| `setup_*_screen.dart` (terakhir)   | POST   | `/user/health-profile`            | seluruh onboarding (age, gender, goal, dll.)  |
| `edit_health_screen.dart`          | PUT    | `/user/health-profile`            | partial update                                |
| `health_metrics_screen.dart`       | GET    | `/user/health-metrics`            | weight + BMI sekarang                         |
| `health_metrics_screen.dart` (log) | POST   | `/user/health-metrics`            | weightKg                                      |
| `progress_screen.dart`             | GET    | `/user/health-metrics/history?days=30` | history 30 hari                          |

### 2.3 Plan Generation

| FE Screen                          | Method | Path                          | Catatan                                                                              |
|------------------------------------|--------|-------------------------------|--------------------------------------------------------------------------------------|
| `plan_generating_screen.dart`      | POST   | `/plan/generate`              | Backend baca profil → ML workout+meal paralel → persist → return plan lengkap        |
| `plan_ready_screen.dart` / home    | GET    | `/plan/active`                | Workout+meal plan yang sedang aktif (dari DB)                                        |
| `plan_history_screen.dart`         | GET    | `/plan/history`               | 20 plan terakhir                                                                     |
| `plan_detail_screen.dart`          | GET    | `/plan/:planId`               | Plan + nested days/exercises/meals                                                   |
| `replanning_update_data_screen.dart` | POST | `/plan/replan`                | Ambil 7-day metrics → ML replan → Gemini narrative → optional regenerate plan baru   |
| `replanning_update_data_screen.dart` (skip) | POST | `/plan/replan/skip`     | User memilih skip                                                                    |

### 2.4 Workout

| FE Screen                              | Method | Path                                            | Catatan                                                |
|----------------------------------------|--------|--------------------------------------------------|--------------------------------------------------------|
| `workout_list_screen.dart` / home      | GET    | `/workout/today`                                | Ambil workout_day yang `date = today` & plan aktif     |
| `workout_day_detail_screen.dart`       | GET    | `/workout/day/:dayId`                           | Day + exercises                                        |
| `exercise_detail_screen.dart`          | GET    | `/workout/exercise/:exerciseId`                 | Detail exercise + master (video/image/instructions)    |
| `pre_workout_checkin_screen.dart`      | POST   | `/workout/:dayId/check-in`                      | mood, energy, sleepBand → return sessionId + intensityMultiplier |
| `active_workout_screen.dart` (tiap set)| PATCH  | `/workout/session/:sessionId/exercise`          | exerciseId, setNumber, reps/duration/weight            |
| `active_workout_screen.dart` (pause)   | POST   | `/workout/session/:sessionId/pause`             | Catat di notes                                         |
| `workout_complete_screen.dart`         | POST   | `/workout/session/:sessionId/complete`          | effortScore, moodAfter → return stats + **Gemini message** + newBadges |
| `workout_session_detail_screen.dart`   | GET    | `/workout/session/:sessionId`                   | Session + logs                                         |
| `workout_history_screen.dart`          | GET    | `/workout/sessions?limit=20`                    | History sessions                                       |
| (exercise card) "Swap"                 | POST   | `/workout/exercise/:exerciseId/swap`            | (optional `masterExerciseId`)                          |

### 2.5 Meal

| FE Screen                              | Method | Path                                | Catatan                                                          |
|----------------------------------------|--------|-------------------------------------|------------------------------------------------------------------|
| `meal_list_screen.dart` / home         | GET    | `/meal/today`                       | Today's meal_day + meal_times + foods                            |
| `meal_day_detail_screen.dart`          | GET    | `/meal/day/:dayId`                  | Detail per hari                                                  |
| `meal_detail_screen.dart`              | GET    | `/meal/:mealId`                     | 1 meal_time + foods                                              |
| `meal_log_screen.dart`                 | POST   | `/meal/:mealId/log`                 | foodItemId, actualPortionGram → update daily_logs + cek badge    |
| `meal_swap_screen.dart`                | POST   | `/meal/:mealId/swap`                | ML alternatives + **Gemini reason** untuk top-3                  |
| `meal_swap_screen.dart` (apply)        | POST   | `/meal/:mealId/replace`             | Ganti food item                                                  |
| `food_item_detail_screen.dart`         | GET    | `/meal/food/:foodId`                | Detail food                                                      |
| `meal_history_screen.dart`             | GET    | `/meal/log?days=7`                  | History log                                                      |
| `budget_setting_screen.dart`           | PUT    | `/meal/budget`                      | budgetPerDayIdr (min 10.000)                                     |
| **`food_scan_screen.dart`** ⭐         | POST   | `/meal/food-scan`                   | base64 image → ML Gemini Vision → match nutrisi → **Gemini advice** |

### 2.6 Progress

| FE Screen                          | Method | Path                                    | Catatan                                              |
|------------------------------------|--------|------------------------------------------|------------------------------------------------------|
| `progress_screen.dart` (top card)  | GET    | `/progress/daily?date=YYYY-MM-DD`        | Default today                                        |
| (water glass button)               | PATCH  | `/progress/daily/water`                  | `{ glasses: 5 }` atau `{ delta: 1 }`                 |
| (mood selector)                    | POST   | `/progress/daily/mood`                   | `{ mood: 'GOOD' }`                                   |
| `progress_screen.dart` (chart)     | GET    | `/progress/weekly`                       | 7d aggregate + dailyBreakdown                        |
| `weekly_review_screen.dart`        | GET    | `/progress/weekly-review`                | Weekly + weight diff + goal                          |
| `streak_detail_screen.dart`        | GET    | `/progress/streak`                       | currentStreak, bestStreak, activeDates               |
| `badge_gallery_screen.dart`        | GET    | `/progress/badges`                       | All badges + isUnlocked flag                         |
| `badge_detail_screen.dart`         | GET    | `/progress/badge/:code`                  | Detail 1 badge                                       |
| (share button)                     | GET    | `/progress/share-image`                  | URL + payload untuk render share                     |

### 2.7 Settings, Notifications, Sync

| FE Screen                          | Method | Path                                    | Catatan                                              |
|------------------------------------|--------|------------------------------------------|------------------------------------------------------|
| `settings_screen.dart`             | GET    | `/settings`                              | Theme/language/timezone/reminders                    |
| `settings_screen.dart` (toggle)    | PUT    | `/settings`                              | Update sebagian field                                |
| `notifications_screen.dart`        | GET    | `/notifications?unreadOnly=true`         | List + unreadCount                                   |
| (tap notif)                        | PATCH  | `/notifications/:id/read`                | Mark single                                          |
| (mark all)                         | PATCH  | `/notifications/read-all`                | Mark semua                                           |
| (boot, register FCM)               | POST   | `/notifications/fcm-token`               | `{ token, platform: ANDROID/IOS/WEB }`               |
| (logout)                           | DELETE | `/notifications/fcm-token`               | `{ token }`                                          |
| (background)                       | POST   | `/sync/batch`                            | `{ operations: [{ opId, opType, payload }] }` idempotent |

---

## 3. Flow Demo — 4 Skenario Penting

### 3.1 Onboarding → Plan Generation

```
[register_screen]                 [setup_*_screen]                          [plan_generating]
       │                                  │                                        │
       │ POST /auth/register              │ POST /user/health-profile              │ POST /plan/generate
       │                                  │                                        │
       ▼                                  ▼                                        ▼
┌────────────┐                  ┌────────────────┐                       ┌──────────────────────┐
│ Backend    │                  │ Backend        │                       │ Backend              │
│ - hash pwd │                  │ - validate zod │                       │ - load HealthProfile │
│ - insert   │                  │ - insert       │                       │ - calc BMI/TDEE      │
│   users    │                  │   health_      │                       │ - parallel call ML:  │
│ - issue    │                  │   profiles     │                       │   workout-plan       │
│   JWT +    │                  │                │                       │   meal-plan          │
│   refresh  │                  │                │                       │ - prisma.$transaction│
└────────────┘                  └────────────────┘                       │   persist plan       │
                                                                         │ - archive old plans  │
                                                                         └──────────────────────┘
                                                                                  │
                                                                                  ▼
                                                                         [plan_ready] (FE)
                                                                         GET /plan/active
```

### 3.2 Workout Session (check-in → complete + Gemini)

```
[pre_workout_checkin]            [active_workout]                          [workout_complete]
       │                                  │                                        │
       │ POST /:dayId/check-in            │ PATCH /session/:id/exercise            │ POST /session/:id/complete
       │  mood, energy, sleepBand         │  setNumber, reps, weight               │  effortScore, moodAfter
       ▼                                  ▼                                        ▼
┌────────────────────────┐      ┌────────────────────────┐         ┌───────────────────────────────┐
│ Backend                │      │ Backend                │         │ Backend                       │
│ - intensity multiplier │      │ - upsert exercise_logs │         │ - compute duration + calories │
│ - INSERT workout_      │      │                        │         │ - mark workout_day completed  │
│   sessions             │      │                        │         │ - upsert daily_logs           │
│   (status=IN_PROGRESS) │      │                        │         │ - update streak (+1)          │
└────────────────────────┘      └────────────────────────┘         │ - badgeService.checkUnlocks   │
                                                                   │ - geminiService.enrich        │
                                                                   │   WorkoutComplete(stats)      │
                                                                   └──────────────┬────────────────┘
                                                                                  │
                                                              ┌───────────────────┘
                                                              ▼
                                                 [workout_complete_screen]
                                                 menampilkan: stats + Gemini msg +
                                                 newBadges (animasi confetti)
```

### 3.3 Food Scan (kamera → Gemini Vision → ML → Gemini advice)

```
[food_scan_screen] (kamera)
       │
       │ 1. user foto / pilih dari galeri
       │ 2. compress + base64 encode
       │
       │ POST /meal/food-scan { imageBase64, persist? }
       ▼
┌──────────────────────────────┐
│ Backend mealService.foodScan │
│ - load user profile          │
│ - MlService.predictFoodScan  │
└─────────────┬────────────────┘
              │ X-ML-KEY
              ▼
┌──────────────────────────────────────────────┐
│ FastAPI /predict/food-scan                   │
│ - Gemini Vision (gemini-1.5-flash)           │
│   → daftar nama makanan                      │
│ - TF-IDF + cosine match ke food_master       │
│ - sum nutrisi + XGBoost health_score         │
│ - assess: GOOD / MODERATE / POOR             │
└─────────────┬────────────────────────────────┘
              │
              ▼
┌──────────────────────────────────────────────┐
│ Backend                                      │
│ - geminiService.enrichFoodScanAdvice         │
│   → 2 kalimat saran personal                 │
│ - (opt) upsert daily_logs.caloriesConsumed   │
└─────────────┬────────────────────────────────┘
              │
              ▼
[food_scan_screen] menampilkan:
  - matches (food name + nutrition)
  - total kalori + macro
  - assessment + Gemini advice
```

### 3.4 Weekly Replan (otomatis tiap minggu, atau manual)

```
[replanning_update_data_screen]
       │ user konfirmasi data baru (berat, mood, dll.)
       │
       │ POST /plan/replan { applyImmediately: false }
       ▼
┌─────────────────────────────────────────┐
│ Backend replanningService.runReplan     │
│ - load 7-day workout_sessions           │
│ - load 7-day meal_logs                  │
│ - load 7-day daily_logs                 │
│ - weekly_score (scoringService)         │
│ - weight_diff = weightKg - startWeightKg│
│ - MlService.predictReplan(payload)      │
│ - geminiService.enrichReplanNarrative   │
└──────────┬──────────────────────────────┘
           │
           ▼  return { summary, ml, narrative }
[replanning preview screen]
           │ user setuju
           │
           │ POST /plan/replan { applyImmediately: true }
           │   atau POST /plan/generate
           ▼
[plan_ready_screen] dengan plan baru
```

---

## 4. Auth Flow + Interceptor Pattern (FE)

Yang harus di-wire di `lib/data/api/api_service.dart`:

1. **AuthInterceptor**: inject `Authorization: Bearer <accessToken>` ke semua request kecuali endpoint public.
2. **ErrorInterceptor**: kalau response `401 TOKEN_EXPIRED`, otomatis:
   ```
   POST /auth/refresh-token { refreshToken }
   → terima accessToken + refreshToken baru (rotated)
   → simpan ke secure storage
   → retry original request
   ```
   Kalau refresh juga `401 REFRESH_INVALID` → logout user lokal, navigate ke login.
3. **LoggingInterceptor**: log method, path, status (dev only).

Backend sudah memvalidasi `Bearer` token via middleware `requireAuth` di setiap router kecuali `auth.routes`.

---

## 5. Offline-First Sync

FE menyimpan operasi user dalam SQLite/Hive queue saat offline. Saat online, kirim batch:

```http
POST /api/v1/sync/batch
{
  "operations": [
    { "opId": "<uuid>", "opType": "log_meal", "payload": { "mealId": "...", "foodItemId": "...", "actualPortionGram": 120 } },
    { "opId": "<uuid>", "opType": "update_water", "payload": { "delta": 1 } },
    { "opId": "<uuid>", "opType": "complete_session", "payload": { "sessionId": "...", "effortScore": 8 } }
  ]
}
```

**Tipe op yang didukung** (`backend/src/services/sync.service.ts → dispatch`):

| opType                | Diteruskan ke                                              |
|-----------------------|------------------------------------------------------------|
| `log_meal`            | `mealService.logMeal`                                      |
| `update_water`        | `progressService.updateWater`                              |
| `log_mood`            | `progressService.logMood`                                  |
| `complete_session`    | `workoutService.completeSession` (akan trigger Gemini!)    |
| `update_exercise_log` | `workoutService.updateExerciseLog`                         |

**Idempotency:** setiap `opId` unik per-user disimpan di `sync_ops_log`. Kalau dikirim 2x, response ke-2 ditandai `DUPLICATE` dan mengembalikan snapshot hasil pertama. FE aman me-retry tanpa khawatir double-write.

---

## 6. Menjalankan Stack Lengkap (Demo Day)

3 terminal, urutan boot:

```powershell
# Terminal 1 — MySQL (kalau pakai XAMPP)
# Atau pastikan service mysql jalan di port 3306

# Terminal 2 — ML Service (port 8001)
cd machine-learning\ml-service
.\.venv\Scripts\Activate.ps1
uvicorn main:app --reload --port 8001

# Terminal 3 — Backend (port 3000)
cd backend
npx prisma migrate dev          # sekali saja, jika schema berubah
npm run dev

# Terminal 4 — Flutter (emulator/device)
cd frontend\heltigo
flutter run
```

**Sanity check sebelum demo:**

```powershell
curl http://localhost:8001/health        # ML hidup
curl http://localhost:3000/health        # BE hidup
# di app: register → onboarding → generate plan → workout check-in → food-scan
```

---

## 7. Konfigurasi Penting per Service

### 7.1 Backend (`backend/.env`)

```ini
NODE_ENV=development
PORT=3000
DATABASE_URL=mysql://root:@localhost:3306/heltigo
JWT_SECRET=supersecretjwtkey_minimum_32_chars_long
JWT_ACCESS_EXPIRES=900s
JWT_REFRESH_EXPIRES=604800s
BCRYPT_ROUNDS=12

ML_SERVICE_URL=http://localhost:8001
ML_SERVICE_KEY=shared-secret-with-fastapi
GEMINI_API_KEY=<dapatkan dari aistudio.google.com/apikey>
GEMINI_MODEL=gemini-1.5-flash
GEMINI_TIMEOUT_MS=3000

CORS_ORIGINS=http://localhost:*,http://10.0.2.2:*
LOG_LEVEL=debug
```

### 7.2 ML Service (`machine-learning/ml-service/.env`)

```ini
ML_SERVICE_KEY=shared-secret-with-fastapi
GEMINI_API_KEY=<sama dengan backend, atau key terpisah>
```

### 7.3 Flutter (`frontend/heltigo/lib/data/api/endpoints.dart`)

```dart
// Emulator Android → host machine
const String kBaseUrl = 'http://10.0.2.2:3000/api/v1';
// Desktop/web/iOS simulator
// const String kBaseUrl = 'http://localhost:3000/api/v1';
```

---

## 8. Checklist Kesiapan Demo

Backend
- [x] 47 endpoint terimplementasi (semua bukan stub lagi)
- [x] JWT access + refresh dengan rotation
- [x] ML client retry/backoff + error mapping
- [x] Gemini enrichment 4 method dengan fallback
- [x] Plan generation persist ke DB dengan transaction
- [x] Offline sync `POST /sync/batch` idempotent

ML
- [x] 5 endpoint production-ready
- [x] Semua artifact model ada di repo
- [x] Gemini Vision di food-scan
- [x] `X-ML-KEY` auth + `/health` liveness

Frontend (yang perlu diselesaikan terpisah)
- [ ] Wire AuthInterceptor + ErrorInterceptor di `api_service.dart`
- [ ] Ganti mock data per screen ke real API call
- [ ] Implement offline queue → call `/sync/batch`
- [ ] Implement camera capture di `food_scan_screen.dart` → base64 → POST `/meal/food-scan`

---

## 9. FAQ Cepat

**Q: Kenapa Gemini tidak langsung dipakai dari FE?**
Aman: API key tidak boleh di-bundle ke app. Cost control: backend bisa caching, throttling, observability. Latency: enrichment sering paralel dengan call DB di server.

**Q: Bagaimana kalau Gemini quota habis di tengah demo?**
Backend otomatis pakai fallback template Bahasa Indonesia. User tetap melihat pesan personal, hanya saja bukan generated. Tidak ada error.

**Q: Apa yang terjadi kalau ML service mati?**
Endpoint yang butuh ML akan return `502 ML_UNREACHABLE`. Endpoint lain (auth, profile, daily log, water, mood, badges) tetap jalan normal — itu sebabnya logika dipisah.

**Q: Plan generation memakai data hardcoded?**
Tidak lagi. `planService.generate` membaca `HealthProfile` user dari DB, menghitung BMI/BMR/TDEE pakai `healthService`, lalu membangun payload ML dari nilai real. Lihat `backend/src/services/plan.service.ts`.

**Q: Apakah refresh token aman?**
Refresh token disimpan **hashed (sha256)** di DB (`refresh_tokens.token_hash`). Token mentah hanya dikembalikan ke client sekali, tidak pernah dibaca ulang oleh server. Setiap refresh akan rotasi (revoke lama, issue baru).

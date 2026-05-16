# Heltigo — Backend API Requirements (Derived from Frontend)

> Dokumen ini menjelaskan semua endpoint backend yang dibutuhkan agar **seluruh alur bisnis di frontend Flutter (Heltigo)** dapat berjalan end-to-end. Disusun berdasarkan inventaris 47 screen di `frontend/heltigo/lib/screens/` per 2026-05-15.

**Versi:** 1.0
**Target demo:** 2026-05-21
**Audience:** Backend engineer (Express.js + MySQL), DevOps, QA.

---

## 1. Arsitektur Singkat

```
┌─────────────────────┐     HTTPS     ┌──────────────────────┐    HTTP     ┌──────────────────┐
│  Flutter Mobile     │ ◄──────────► │  Backend (Express)   │ ◄────────► │  ML Service       │
│  (Heltigo App)      │   REST + JWT │  Node 20 + MySQL 8   │  REST       │  (FastAPI)        │
└─────────────────────┘               └──────────────────────┘             └──────────────────┘
                                                │
                                                ├── MySQL 8.0 (users, plans, logs, ...)
                                                ├── Redis (optional, cache + rate limit)
                                                └── S3 / Local FS (avatar upload)
```

- **Base URL:** `https://api.heltigo.app/api/v1` (production), `http://localhost:3000/api/v1` (dev).
- **Auth:** JWT (`access_token` 15 min) + refresh token (7 day, di MySQL `refresh_tokens` table).
- **Format:** JSON, `Content-Type: application/json`. Avatar upload: `multipart/form-data`.
- **Timezone:** API menerima/mengembalikan ISO-8601 UTC. Frontend convert ke Asia/Jakarta untuk display.
- **Rate limit:** 60 req/min per IP (Redis). Auth endpoint 5 req/min.
- **Error format:**
  ```json
  { "error": { "code": "INVALID_CREDENTIALS", "message": "Email atau password salah", "details": {} } }
  ```

---

## 2. Authentication

| Method | Path | Auth | Body | Response | Notes |
|---|---|---|---|---|---|
| POST | `/auth/register` | — | `{email, password, name}` | `201 { accessToken, refreshToken, user }` | Email unique, password bcrypt cost 12 |
| POST | `/auth/login` | — | `{email, password}` | `200 { accessToken, refreshToken, user }` | Rate limit 5/min |
| POST | `/auth/refresh-token` | refresh | `{refreshToken}` | `200 { accessToken }` | Rotate refresh token |
| POST | `/auth/logout` | access | — | `204` | Revoke refresh token |
| POST | `/auth/forgot-password` | — | `{email}` | `200 { sent: true }` | Send reset link via email |
| POST | `/auth/reset-password` | reset_token | `{token, newPassword}` | `200 {}` | Token expire 1 hour |

**JWT payload:**
```json
{ "sub": "user_id", "email": "...", "iat": 1715760000, "exp": 1715760900 }
```

---

## 3. User Profile & Setup Wizard

| Method | Path | Auth | Body | Response | Notes |
|---|---|---|---|---|---|
| GET | `/user/profile` | access | — | `200 { user, healthProfile }` | Combine user + health_profile |
| PUT | `/user/profile` | access | `UpdateProfileDto` | `200 { user }` | Partial update |
| PATCH | `/user/profile/avatar` | access | `multipart` (`avatar` file) | `200 { avatarUrl }` | Max 5MB, jpg/png |
| POST | `/user/health-profile` | access | `HealthProfileDto` | `201 { healthProfile }` | Saat selesai setup wizard 7-step |
| PUT | `/user/health-profile` | access | `HealthProfileDto` (partial) | `200 { healthProfile }` | Replanning update data |
| GET | `/user/health-metrics` | access | — | `200 { current, target, bmi, tdee, macros }` | Computed values |
| POST | `/user/health-metrics` | access | `{ weightKg, recordedAt }` | `201 { entry }` | Log new weight |
| GET | `/user/health-metrics/history` | access | `?from&to` | `200 { entries: [...] }` | Time-series untuk chart |
| DELETE | `/user/account` | access | `{password}` | `204` | Soft delete (set `deleted_at`) |

**`HealthProfileDto`:**
```json
{
  "age": 28,
  "gender": "M",
  "heightCm": 175,
  "weightKg": 75.5,
  "fitnessLevel": "INTERMEDIATE",
  "goal": "WEIGHT_LOSS",
  "targetWeight": 68,
  "healthConditions": ["LOW_BACK_PAIN"],
  "budgetPerDay": 50000,
  "availableDaysPerWeek": 4,
  "sessionDurationMin": 30,
  "preferredEquipment": ["BODYWEIGHT", "DUMBBELL"]
}
```

**Setup wizard flow di frontend:** 7 screen lokal-only (`/setup-profile` → `/setup-physical` → BMI auto → `/setup-goal` → `/setup-conditions` → `/setup-fitness-level` → `/setup-preferences`). Final step: `POST /user/health-profile` → trigger `POST /plan/generate`.

---

## 4. Plan Generation & Active Plan

| Method | Path | Auth | Body | Response | Notes |
|---|---|---|---|---|---|
| POST | `/plan/generate` | access | — | `201 { workoutPlan, mealPlan }` | Call ML service internally; idempotent jika `is_active=true` exist |
| GET | `/plan/active` | access | — | `200 { workoutPlan, mealPlan, currentDay }` | Plan 7 hari aktif |
| GET | `/plan/history` | access | `?limit&offset` | `200 { plans: [...] }` | Pagination |
| GET | `/plan/:planId` | access | — | `200 { workoutPlan, mealPlan }` | Detail plan lama |
| POST | `/plan/replan` | access | `ReplanDto` | `201 { workoutPlan, mealPlan }` | Setelah evaluasi mingguan |
| POST | `/plan/replan/skip` | access | — | `200 {}` | "Lihat nanti" tunda 1 minggu |

**`ReplanDto`:**
```json
{
  "previousPlanId": 42,
  "weeklyScore": 75,
  "weightDiff": -0.6,
  "choice": "AGGRESSIVE",   // KEEP | MODERATE | AGGRESSIVE
  "skippedExerciseIds": [12, 15]
}
```

**Internal flow:** Backend collect health_profile + weekly progress → POST ke ML service `/predict/plan` → save hasil ke DB → return ke frontend.

---

## 5. Workout

| Method | Path | Auth | Body | Response | Notes |
|---|---|---|---|---|---|
| GET | `/workout/today` | access | — | `200 { workoutDay }` | Workout untuk tanggal hari ini |
| GET | `/workout/day/:dayId` | access | — | `200 { workoutDay, exercises }` | Untuk S-17 Workout Detail |
| GET | `/workout/exercise/:exerciseId` | access | — | `200 { exercise, tips, alternativeIds }` | Untuk S-18 Exercise Detail |
| POST | `/workout/:dayId/check-in` | access | `{mood, energy, sleepBand}` | `201 { sessionId, adjustedExercises }` | Trigger ML intensity adjuster |
| PATCH | `/workout/session/:sessionId/exercise` | access | `{exerciseId, actualSets, actualReps, restSeconds}` | `200 {}` | Log per-exercise progress |
| POST | `/workout/session/:sessionId/pause` | access | — | `200 { pausedAt }` | Local state, opsional sync |
| POST | `/workout/session/:sessionId/complete` | access | `{durationSec, caloriesBurned, effortScore, moodAfter, notes}` | `200 { session, badgesUnlocked }` | Hitung streak + badge |
| GET | `/workout/session/:sessionId` | access | — | `200 { session }` | Untuk S-21b Session Detail |
| GET | `/workout/sessions` | access | `?from&to&limit` | `200 { sessions }` | History list |
| POST | `/workout/exercise/:exerciseId/swap` | access | `{reason}` | `200 { alternatives }` | Get alternatif exercise dari ML |

---

## 6. Meal & Nutrition

| Method | Path | Auth | Body | Response | Notes |
|---|---|---|---|---|---|
| GET | `/meal/today` | access | — | `200 { mealDay }` | Meal hari ini (breakfast/lunch/dinner) |
| GET | `/meal/day/:dayId` | access | — | `200 { mealDay, meals, totals }` | Untuk S-22 Meal List |
| GET | `/meal/:mealId` | access | — | `200 { meal, foodItems }` | Untuk S-23 Meal Detail |
| POST | `/meal/:mealId/log` | access | `{loggedAt, actualPortion?}` | `200 { meal, dailyLog }` | Tandai sudah makan; idempotent via unique constraint |
| POST | `/meal/:mealId/swap` | access | `{reason}` | `200 { alternatives }` | Get alternatif dari ML knapsack |
| POST | `/meal/:mealId/replace` | access | `{newFoodItemIds}` | `200 { meal }` | Konfirmasi pilih alternatif |
| GET | `/meal/food/:foodId` | access | — | `200 { food, similarFoods }` | Untuk S-24 Food Detail |
| GET | `/meal/log` | access | `?date` | `200 { logs }` | Riwayat untuk S-25 Meal Log |
| PUT | `/meal/budget` | access | `{budgetPerDay}` | `200 { healthProfile }` | Alias ke PUT /user/health-profile |

---

## 7. Progress, Hydration & Gamification

| Method | Path | Auth | Body | Response | Notes |
|---|---|---|---|---|---|
| GET | `/progress/daily` | access | `?date` | `200 { log }` | Default hari ini |
| PATCH | `/progress/daily/water` | access | `{glassCount}` | `200 { log }` | Increment-only (validasi `new > current`) |
| POST | `/progress/daily/mood` | access | `{mood}` | `200 { log }` | Mood diary |
| GET | `/progress/weekly` | access | `?weekStart` | `200 { compliance, workoutsDone, mealsLogged, score, dailyScores }` | Untuk S-26 dashboard |
| GET | `/progress/weekly-review` | access | `?weekStart` | `200 { highlights, insights, charts }` | Untuk S-29 review screen |
| GET | `/progress/streak` | access | — | `200 { currentStreak, bestStreak, activeDates }` | Untuk S-28 streak detail |
| GET | `/progress/badges` | access | — | `200 { unlocked, locked }` | Untuk S-27 badge gallery |
| GET | `/progress/badge/:code` | access | — | `200 { badge, progress }` | Detail badge + progress menuju unlock |
| GET | `/progress/share-image` | access | `?type=weekly` | `200 { imageUrl }` | Generate share card image (opsional Phase 4) |

**Hydration rule:** PATCH `/progress/daily/water` HANYA accept increment. Jika `glassCount <= current`, return `400 INVALID_DECREMENT`.

---

## 8. Notifications

| Method | Path | Auth | Body | Response | Notes |
|---|---|---|---|---|---|
| GET | `/notifications` | access | `?unreadOnly` | `200 { notifications: [...] }` | Pagination 20/page |
| PATCH | `/notifications/:id/read` | access | — | `200 {}` | Mark as read |
| PATCH | `/notifications/read-all` | access | — | `200 {}` | Bulk mark |
| POST | `/notifications/fcm-token` | access | `{token, platform}` | `200 {}` | Register FCM device token |
| DELETE | `/notifications/fcm-token` | access | `{token}` | `204` | Unregister saat logout |

**Notification types:** `MOTIVATION`, `WORKOUT_REMINDER`, `MEAL_REMINDER`, `STREAK_MILESTONE`, `BADGE_UNLOCKED`, `REPLAN_DUE`.

---

## 9. Settings

| Method | Path | Auth | Body | Response | Notes |
|---|---|---|---|---|---|
| GET | `/settings` | access | — | `200 { settings }` | Theme, language, reminders |
| PUT | `/settings` | access | `SettingsDto` | `200 { settings }` | Partial update |

**`SettingsDto`:**
```json
{
  "theme": "dark",
  "language": "id",
  "notificationsEnabled": true,
  "dailyReminderTime": "07:30",
  "workoutReminderTime": "18:00",
  "mealReminderTime": "12:00"
}
```

---

## 10. Offline-First Sync

Frontend pakai queue lokal untuk aksi saat offline (log water, log meal, complete workout). Saat online kembali, batch-sync.

| Method | Path | Auth | Body | Response | Notes |
|---|---|---|---|---|---|
| POST | `/sync/batch` | access | `{operations: [...]}` | `200 { results: [...] }` | Idempotent via client `opId` |

**Batch payload:**
```json
{
  "operations": [
    {
      "opId": "uuid-1",
      "type": "WATER_LOG",
      "timestamp": "2026-05-15T07:30:00Z",
      "data": { "glassCount": 3 }
    },
    {
      "opId": "uuid-2",
      "type": "MEAL_LOG",
      "timestamp": "2026-05-15T08:00:00Z",
      "data": { "mealId": 42 }
    }
  ]
}
```

**Response per op:**
```json
{ "opId": "uuid-1", "status": "OK", "result": { ... } }
{ "opId": "uuid-2", "status": "DUPLICATE", "result": null }
{ "opId": "uuid-3", "status": "CONFLICT", "error": "DECREMENT_NOT_ALLOWED" }
```

---

## 11. Screen → Endpoints Matrix

| Screen (frontend) | Endpoints |
|---|---|
| Splash | `GET /user/profile` (jika token persisted) |
| Login | `POST /auth/login` |
| Register | `POST /auth/register` |
| Forgot Password | `POST /auth/forgot-password` |
| Setup Wizard final | `POST /user/health-profile` → `POST /plan/generate` |
| Plan Generating | poll `GET /plan/active` setelah generate |
| Plan Ready | — (data sudah ada dari /plan/active) |
| **S-15 Home Dashboard** | `GET /plan/active`, `GET /progress/daily`, `GET /user/health-metrics`, `PATCH /progress/daily/water` |
| **S-16 Workout List** | `GET /plan/active`, `GET /progress/weekly` |
| **S-17 Workout Detail** | `GET /workout/day/:id` |
| **S-18 Exercise Detail** | `GET /workout/exercise/:id` |
| **S-19 Pre-Workout Check-in** | `POST /workout/:dayId/check-in` |
| **S-20 Active Workout** | `PATCH /workout/session/:id/exercise` (per exercise) |
| **S-21 Workout Complete** | `POST /workout/session/:id/complete` |
| **S-21b Session Detail** | `GET /workout/session/:id` |
| **S-22 Meal List** | `GET /meal/today`, `GET /user/health-metrics`, `GET /progress/daily` |
| **S-23 Meal Detail** | `GET /meal/:id`, `POST /meal/:id/log` |
| **S-23b Meal Swap** | `POST /meal/:id/swap`, `POST /meal/:id/replace` |
| **S-24 Food Detail** | `GET /meal/food/:id` |
| **S-25 Meal Log** | `GET /meal/log` |
| Budget Settings | `PUT /user/health-profile` (only budget) |
| **S-26 Progress Dashboard** | `GET /progress/weekly`, `GET /user/health-metrics/history` |
| **S-27 Weekly Review** | `GET /progress/weekly-review` |
| **S-28 Badge Gallery** | `GET /progress/badges` |
| **S-29 Streak Detail** | `GET /progress/streak` |
| **S-30 Profile** | `GET /user/profile`, `GET /user/health-metrics/history` |
| **S-31 Edit Profile** | `PUT /user/profile`, `PATCH /user/profile/avatar` |
| **S-32 Health Metrics** | `POST /user/health-metrics` |
| **S-33 Plan History** | `GET /plan/history`, `GET /plan/:id` |
| **S-34 Replanning Evaluation** | `GET /progress/weekly` |
| **S-34b Replanning Update Data** | `PUT /user/health-profile` |
| **S-34c Replanning Choose** | `POST /plan/replan` |
| **S-35 Replanning Ready** | `GET /plan/active` |
| Settings | `GET /settings`, `PUT /settings` |
| Notifications | `GET /notifications`, `PATCH /notifications/:id/read` |
| Offline restore | `POST /sync/batch` |

---

## 12. Special Features & Constraints

### 12.1 Increment-only Hydration
- Validasi server-side: `daily_logs.water_intake` HANYA boleh naik dalam 1 hari.
- PATCH `/progress/daily/water` dengan `glassCount < current` → return `400`.
- Reset otomatis tiap pukul 00:00 (cron job).

### 12.2 7-Day Plan Window
- Setiap `workout_plan` dan `meal_plan` tepat 7 hari (Sen-Min).
- `is_active = true` hanya untuk 1 plan aktif per user.
- Generate plan baru → mark plan lama `status = 'completed'`.
- Tanggal hari ini di luar `[startDate, endDate]` → backend wajib trigger flag `should_replan = true`.

### 12.3 Replanning Trigger
- Saat user buka app di hari ke-8 plan aktif → `GET /plan/active` return `{ shouldReplan: true }`.
- Frontend route otomatis ke `/replanning/evaluation`.
- "Lihat nanti" → `POST /plan/replan/skip` set `next_replan_due = +7 days`.

### 12.4 File Upload (Avatar)
- Endpoint: `PATCH /user/profile/avatar` dengan `multipart/form-data`.
- Validasi: `image/jpeg` atau `image/png`, max 5MB.
- Storage: S3 bucket `heltigo-avatars` atau local `uploads/avatars/` (dev).
- Generate thumbnail 256x256 (Sharp library).
- Response: `{ avatarUrl: "https://..." }`.

### 12.5 Timezone Handling
- DB simpan timestamps di UTC (`TIMESTAMP` type).
- Frontend kirim tanggal lokal sebagai ISO-8601 dengan offset (e.g., `2026-05-15T07:00:00+07:00`).
- Backend convert ke UTC sebelum simpan.
- "Today" computed via user's timezone (simpan di `settings.timezone`, default `Asia/Jakarta`).

### 12.6 Idempotency
- `POST` endpoint yang side-effect (log meal, complete workout) WAJIB support header `Idempotency-Key`.
- Backend cek key di Redis (TTL 24 jam) → return cached response jika duplicate.

### 12.7 ML Service Integration
- Backend panggil ML service via internal network (tidak exposed public).
- Endpoints ML:
  - `POST http://ml:8000/predict/workout-plan` → return 7-day workout
  - `POST http://ml:8000/predict/meal-plan` → return 7-day meal
  - `POST http://ml:8000/predict/intensity` → return adjustment
  - `POST http://ml:8000/predict/replan` → return adjusted plan
- Timeout: 5s. Fallback: rule-based default plan jika ML down.

---

## 13. Implementation Priorities

### Phase 1 — MVP (Days 1-5)
- ✅ Auth (register/login/refresh/logout)
- ✅ User profile + health profile
- ✅ Plan generate + active plan retrieval
- ✅ Workout today + workout day detail
- ✅ Meal today + meal detail
- ✅ Daily log (hydration)

### Phase 2 — Tracking & Logging (Days 6-9)
- ✅ Workout session lifecycle (check-in, exercise log, complete)
- ✅ Meal log + swap
- ✅ Weight history
- ✅ Weekly progress aggregation

### Phase 3 — Gamification (Days 10-12)
- ✅ Streak calculation (daily cron)
- ✅ Badge unlock logic (event-driven)
- ✅ Notification generation
- ✅ Replanning flow

### Phase 4 — Polish & Offline (Days 13-14)
- ✅ Sync batch endpoint
- ✅ FCM push notifications
- ✅ Avatar upload
- ✅ Share image generation
- ✅ Performance optimization (indexes, Redis cache)

---

## 14. Non-Functional Requirements

- **Performance:** p95 latency < 300ms untuk read endpoints, < 800ms untuk write.
- **Availability:** 99.5% (acceptable downtime ~ 3.5 jam/bulan).
- **Security:**
  - Password bcrypt cost 12.
  - JWT secret 256-bit, rotate every 90 days.
  - HTTPS only (production).
  - Helmet.js + CORS whitelist.
  - SQL prepared statements (no string concat).
  - Rate limit auth endpoints (5/min).
- **Logging:** structured JSON (Pino/Winston), log level configurable via env.
- **Monitoring:** Health check `GET /health` return DB + ML service status.
- **Testing:** unit test coverage ≥ 70% untuk service layer.

---

**Lihat juga:**
- [`01_DATABASE_DESIGN.md`](01_DATABASE_DESIGN.md) — schema rinci + relasi
- [`schema.sql`](schema.sql) — DDL siap-eksekusi
- [`../06_ML_INTEGRATION.md`](../06_ML_INTEGRATION.md) — kontrak komunikasi backend ↔ ML service

> ⚠️ **DEPRECATED — 2026-05-15**
>
> Daftar endpoint di dokumen ini sudah **outdated**. Konflik utama (30+ perbedaan):
> - Base URL `/v1/*` → sekarang `/api/v1/*` (kebijakan baru).
> - Auth: `/v1/auth/signup` → `/auth/register`; tambah `/auth/refresh-token`.
> - Profile: `/v1/profile` (unified) → split jadi `/user/profile` + `/user/health-profile` + `/user/health-metrics`.
> - Hydration: `POST /v1/nutrition/hydration` → `PATCH /progress/daily/water` (increment-only validation).
> - Workout: single `/v1/workout/log` → granular `POST /workout/:dayId/check-in`, `PATCH .../exercise`, `POST .../complete`.
> - Meal: `/nutrition/alternative` → 2-step (`POST /meal/:id/swap` + `POST /meal/:id/replace`).
> - Body case: `snake_case` (lama) → `camelCase` (baru).
> - Tambah endpoint baru: `/plan/replan/skip`, `/workout/session/:id`, `/meal/food/:id`, `/notifications/fcm-token`, `/sync/batch`.
>
> **Source of truth saat ini:**
> - [`FE_requirement/00_API_REQUIREMENTS.md`](FE_requirement/00_API_REQUIREMENTS.md) — lengkap 14 group endpoint + screen-endpoint mapping
>
> File ini di-keep sebagai sejarah desain awal. **Jangan dipakai untuk implementasi.**

---

# Backend — API Endpoints (REST v1)

Base URL: `/v1`. Semua request/response JSON. snake_case di body.
Auth: header `Authorization: Bearer <jwt>` kecuali ditandai *(public)*.

Format error global:
```json
{ "error": { "code": "STRING_CODE", "message": "Pesan ID", "details": {...} } }
```

---

## 1. Health & Auth

### GET `/health` *(public)*
Cek server hidup.

**Response 200:**
```json
{ "status": "ok", "timestamp": "2026-05-07T10:30:00Z" }
```

---

### POST `/v1/auth/signup` *(public)*
Daftar user baru.

**Request:**
```json
{ "email": "user@example.com", "password": "min8char" }
```

**Validasi:**
- email: format email valid, unique
- password: min 8 karakter

**Response 201:**
```json
{
  "user": { "id": "uuid", "email": "user@example.com", "has_profile": false, "created_at": "..." },
  "token": "eyJhbGc..."
}
```

**Error:**
- `400 EMAIL_INVALID` — format email salah
- `409 EMAIL_TAKEN` — email sudah terdaftar
- `400 PASSWORD_TOO_SHORT`

---

### POST `/v1/auth/login` *(public)*
**Request:**
```json
{ "email": "user@example.com", "password": "..." }
```

**Response 200:**
```json
{
  "user": { "id": "...", "email": "...", "has_profile": true },
  "token": "eyJhbGc..."
}
```

**Error:**
- `401 INVALID_CREDENTIALS` — email/password salah

---

### GET `/v1/auth/me`
Dapatkan info user dari token.

**Response 200:**
```json
{
  "user": {
    "id": "uuid",
    "email": "...",
    "has_profile": true,
    "created_at": "..."
  }
}
```

---

### POST `/v1/auth/logout`
Stateless JWT — logout hanya hapus token client-side. Endpoint ini opsional (untuk audit log).

**Response 204** (no content).

---

## 2. Profile

### POST `/v1/profile`
Buat profile pertama kali (selesai setup S-12). Idempotent (call kedua akan update).

**Request:**
```json
{
  "name": "Andi",
  "age": 22,
  "gender": "MALE",
  "height_cm": 172.5,
  "weight_kg": 78.0,
  "waist_cm": 92.0,
  "goal": "LOSE_WEIGHT",
  "target_weight_kg": 68.0,
  "timeline_weeks": 16,
  "conditions": ["NONE"],
  "workout_mode": "GYM",
  "days_per_week": 4,
  "session_minutes": 45,
  "preferred_times": ["pagi", "sore"],
  "fitness_level": "BEGINNER",
  "budget_per_day": 35000,
  "currency": "IDR",
  "meal_frequency": 3,
  "diet_restrictions": ["halal"]
}
```

**Validasi server-side:**
- age: 10–100
- height: 100–250 cm
- weight: 30–200 kg
- target_weight realistis (±20% dari current)
- timeline_weeks: 4–52
- meal_frequency: 2–4

**Logika:**
1. Hitung `bmi = weight / (height/100)²`
2. Hitung `bmr` (Harris-Benedict) berdasarkan gender/age/height/weight
3. Hitung `tdee = bmr × activityFactor` (1.2 sedentary baseline + adjust by days_per_week)
4. Hitung `bodyFatPct` (U.S. Navy formula jika waist tersedia, else null)
5. Tentukan `bmi_category`
6. Hitung `target_calorie_adj` berdasarkan goal & timeline

**Response 201:**
```json
{
  "profile": {
    "id": "uuid",
    "name": "Andi",
    "bmi": 26.27,
    "bmr": 1800,
    "tdee": 2340,
    "body_fat_pct": 18.5,
    "bmi_category": "OVERWEIGHT",
    "target_calorie_adj": -350,
    "ideal_weight_kg": 70.5,
    "...": "..."
  }
}
```

**Error:**
- `400 VALIDATION_ERROR` (details: per field)

---

### GET `/v1/profile`
Ambil profile user.

**Response 200:**
```json
{ "profile": { /* same as above */ } }
```

**Error:**
- `404 PROFILE_NOT_FOUND` — belum setup

---

### PUT `/v1/profile`
Update sebagian field. Hitung ulang BMI/BMR/TDEE jika ada perubahan height/weight/age. Tracking weight log otomatis dibuat jika weight berubah.

**Request (partial):**
```json
{ "weight_kg": 76.5, "budget_per_day": 40000 }
```

**Response 200:** sama seperti GET.

---

### PUT `/v1/profile/notification-prefs`
**Request:**
```json
{
  "master_enabled": true,
  "workout_enabled": true,
  "workout_warmup_15min": true,
  "workout_time": "06:30",
  "meals": {
    "breakfast": { "enabled": true, "time": "07:00", "advance_10min": true },
    "lunch": { "enabled": true, "time": "12:30", "advance_10min": true },
    "dinner": { "enabled": true, "time": "19:00", "advance_10min": false }
  },
  "hydration_enabled": true,
  "hydration_interval_hours": 2,
  "weekly_report_enabled": true,
  "weekly_report_time": "20:00"
}
```

**Response 200:** `{ "notif_prefs": { ... } }`

---

## 3. Plan

### POST `/v1/plan/generate`
Generate plan minggu pertama. Dipanggil setelah profile dibuat (S-13).

**Request:** body kosong (user_id dari JWT).

**Logika:**
1. Validasi user punya profile
2. Cek tidak ada plan aktif (jika ada, throw `409 PLAN_ALREADY_EXISTS`)
3. Panggil `mlClient.workout.infer({ profile })` → list 7 workout days
4. Panggil `mlClient.meal.infer({ profile })` → list 7 meal days
5. Persist ke `weekly_plans` + child rows dalam satu transaksi
6. Return plan lengkap

**Response 201:** lihat skema lengkap di §5.1.

**Error:**
- `404 PROFILE_NOT_FOUND`
- `409 PLAN_ALREADY_EXISTS`
- `502 ML_UNAVAILABLE` — FastAPI down/timeout. Fallback rule-based opsional.

**Timeout:** 30 detik. Total panggilan ML: target <8 detik agar UI loading 6 detik di S-13 aman.

---

### GET `/v1/plan/current`
Ambil plan aktif user (yang `archivedAt` null).

**Response 200:**
```json
{
  "plan": {
    "id": "uuid",
    "week_number": 3,
    "start_date": "2026-05-19",
    "ai_notes": "Plan minggu ke-3 dengan intensitas naik 10%",
    "score_last_week": 85.0,
    "workout_days": [
      {
        "id": "...",
        "day_index": 0,
        "is_rest_day": false,
        "estimated_minutes": 45,
        "estimated_calories": 320,
        "exercises": [
          {
            "id": "...",
            "order_in_day": 1,
            "phase": "WARMUP",
            "name": "Jumping Jacks",
            "name_id": "Lompat Bintang",
            "muscle_group": "FULL_BODY",
            "equipment": "BODYWEIGHT",
            "sets": 1,
            "reps": 30,
            "rest_seconds": 30,
            "ai_tip": "Mulai pelan, tingkatkan tempo bertahap.",
            "image_url": null,
            "video_url": null
          }
        ]
      }
    ],
    "meal_days": [
      {
        "id": "...",
        "day_index": 0,
        "total_calories": 1980,
        "total_protein_g": 120.5,
        "total_carb_g": 235.0,
        "total_fat_g": 65.0,
        "total_cost_idr": 34500,
        "meals": [
          {
            "id": "...",
            "meal_type": "BREAKFAST",
            "calories_kcal": 520,
            "cost_idr": 8500,
            "ai_explanation": "Sarapan tinggi protein untuk recovery latihan kemarin.",
            "foods": [
              {
                "id": "...",
                "name": "Nasi Putih",
                "servings": 1.0,
                "calories_kcal": 200,
                "protein_g": 4.0,
                "carb_g": 44.0,
                "fat_g": 0.5,
                "estimated_price_idr": 3000
              }
            ]
          }
        ]
      }
    ]
  }
}
```

**Error:** `404 NO_ACTIVE_PLAN` — belum punya plan (perlu trigger generate).

---

### POST `/v1/plan/replan`
Trigger replanning manual (atau dipanggil cron Sunday 20:00).

**Request:** body kosong.

**Logika:**
1. Hitung skor minggu lalu (workout_done/total, meal_done/total)
2. Panggil `mlClient.replan.infer({ previousPlan, score, weightTrend, skippedExercises })`
3. Archive plan lama (set `archivedAt`)
4. Insert plan baru
5. Insert/update WeeklyReport
6. Return plan baru

**Response 201:** sama seperti `/plan/current`.

---

## 4. Workout

### POST `/v1/workout/checkin`
Pre-Workout Check-in (S-19) submit.

**Request:**
```json
{
  "plan_id": "uuid",
  "day_index": 2,
  "mood": 4,
  "energy": 3,
  "sleep_band": "6-7",
  "sync_id": "client-uuid-v4"
}
```

**Logika:**
1. Validate values (mood 1-5, energy 1-5, sleep_band enum)
2. Persist ke `workout_checkins` (idempotent dengan `sync_id`)
3. Panggil `mlClient.workout.adjust({ originalDay, mood, energy, sleepBand })` → adjustment factor
4. Return adjustedWorkout

**Response 200:**
```json
{
  "checkin_id": "uuid",
  "adjustment": -0.20,
  "adjusted_workout": {
    "exercises": [
      { "id": "...", "sets": 2, "reps": 8, "rest_seconds": 90, "ai_tip": "Energi rendah, fokus pada teknik." }
    ]
  }
}
```

---

### POST `/v1/workout/log`
Workout selesai (S-21). Idempotent dengan `sync_id`.

**Request:**
```json
{
  "plan_id": "uuid",
  "day_index": 2,
  "started_at": "2026-05-09T06:00:00Z",
  "completed_at": "2026-05-09T06:42:30Z",
  "duration_sec": 2550,
  "total_sets": 12,
  "total_reps": 128,
  "calories_estimate": 285,
  "sync_id": "client-uuid-v4"
}
```

**Response 201:**
```json
{
  "log_id": "uuid",
  "new_badges": [{ "code": "first_workout", "name": "Latihan Pertama", "icon_url": null }],
  "streak_days": 5
}
```

---

### POST `/v1/workout/mood-after`
Mood after di S-21.

**Request:**
```json
{ "log_id": "uuid", "mood_after": 4 }
```

**Response 204.**

---

### POST `/v1/workout/checklist`
Toggle exercise selesai (S-17 swipe atau checkbox).

**Request:**
```json
{
  "date": "2026-05-09",
  "item_type": "EXERCISE",
  "item_id": "exercise-uuid",
  "completed": true,
  "sync_id": "client-uuid-v4"
}
```

**Response 200:**
```json
{ "checklist_id": "uuid", "completed": true }
```

---

### GET `/v1/workout/week-stats`
Untuk S-16 stats grid.

**Query params:** `week_number` (default: aktif).

**Response 200:**
```json
{
  "stats": {
    "total_volume_kg": 4500,
    "estimated_calories": 1280,
    "total_minutes": 195,
    "consistency_pct": 80.0,
    "completed_sessions": 4,
    "total_sessions": 5
  }
}
```

---

## 5. Nutrition

### GET `/v1/nutrition/day?date=YYYY-MM-DD`
Untuk S-22.

**Response 200:**
```json
{
  "date": "2026-05-09",
  "budget": { "spent_idr": 28000, "limit_idr": 35000, "currency": "IDR" },
  "macros": {
    "calories": { "current": 1450, "target": 1980 },
    "protein_g": { "current": 90, "target": 120 },
    "carb_g": { "current": 180, "target": 235 },
    "fat_g": { "current": 45, "target": 65 }
  },
  "meals": [
    { "id": "...", "meal_type": "BREAKFAST", "completed": true, "foods": [...] },
    { "id": "...", "meal_type": "LUNCH", "completed": true, "foods": [...] },
    { "id": "...", "meal_type": "DINNER", "completed": false, "foods": [...] }
  ],
  "hydration": { "glasses": 5, "target": 8 }
}
```

---

### POST `/v1/nutrition/checklist`
Toggle meal selesai. Sama format dengan workout checklist (`item_type: "MEAL"`).

---

### POST `/v1/nutrition/hydration`
Catat gelas air.

**Request:**
```json
{ "date": "2026-05-09", "glasses": 6, "sync_id": "..." }
```

**Response 200:**
```json
{ "glasses": 6 }
```

---

### POST `/v1/nutrition/alternative`
Minta alternatif meal (S-23 tombol "Minta Alternatif").

**Request:**
```json
{
  "plan_meal_id": "uuid",
  "exclude_food_ids": ["food-id-1", "food-id-2"]
}
```

**Logika:**
1. Ambil constraints dari profile (budget, calorie target meal, diet restrictions)
2. Panggil `mlClient.meal.alternative({ mealId, excludeFoodIds, constraints })` → meal baru
3. Update `plan_meals` + `plan_meal_foods`

**Response 200:**
```json
{ "meal": { /* meal object lengkap */ } }
```

---

### GET `/v1/foods/:id`
Detail food item (S-24).

**Response 200:**
```json
{
  "food": {
    "id": "...",
    "name": "Nasi Goreng",
    "category": "STAPLE",
    "calories_kcal": 380,
    "protein_g": 8.0,
    "carb_g": 56.0,
    "fat_g": 12.0,
    "fiber_g": 2.5,
    "serving_label": "1 piring",
    "serving_grams": 250,
    "estimated_price_idr": 15000,
    "image_url": null,
    "ai_context": "Sumber karbohidrat utama yang sesuai budget pagi hari."
  }
}
```

---

### GET `/v1/foods?search=&category=&limit=20&offset=0`
List food (untuk fitur search nanti, opsional hackathon).

---

## 6. Progress

### GET `/v1/progress/summary`
Untuk S-15 stats sticky bar + S-26 dashboard.

**Response 200:**
```json
{
  "summary": {
    "today_calories": { "consumed": 1450, "target": 1980, "remaining": 530 },
    "today_hydration": { "glasses": 5, "target": 8 },
    "streak_days": 12,
    "weight_current_kg": 76.5,
    "weight_start_kg": 78.0,
    "weight_target_kg": 68.0,
    "weeks_to_target_estimate": 13,
    "total_workouts_completed": 18,
    "total_calories_burned": 5240,
    "total_workout_minutes": 720,
    "consistency_pct": 78.5
  }
}
```

---

### GET `/v1/progress/weight-history?weeks=4`
Untuk Weight Chart (S-26).

**Response 200:**
```json
{
  "history": [
    { "date": "2026-04-21", "weight_kg": 78.0 },
    { "date": "2026-04-28", "weight_kg": 77.4 },
    { "date": "2026-05-05", "weight_kg": 76.5 }
  ]
}
```

---

### POST `/v1/progress/weight`
S-27 add weight. Idempotent dengan `sync_id`.

**Request:**
```json
{ "date": "2026-05-09", "weight_kg": 76.2, "note": "After breakfast", "sync_id": "..." }
```

**Response 201:**
```json
{ "log_id": "uuid", "delta_from_yesterday_kg": -0.3 }
```

---

### GET `/v1/progress/badges`
S-28.

**Response 200:**
```json
{
  "badges": [
    {
      "code": "streak_7",
      "name": "Streak 7 Hari",
      "description": "Latihan 7 hari berturut-turut",
      "category": "CONSISTENCY",
      "icon_url": null,
      "threshold": 7,
      "unlocked_at": "2026-05-04T20:00:00Z"
    },
    {
      "code": "streak_30",
      "name": "Streak 30 Hari",
      "description": "Latihan 30 hari berturut-turut",
      "category": "CONSISTENCY",
      "icon_url": null,
      "threshold": 30,
      "unlocked_at": null
    }
  ]
}
```

---

## 7. Report

### GET `/v1/report/weekly?week=N`
S-29 weekly report.

**Response 200:**
```json
{
  "report": {
    "id": "uuid",
    "week_number": 3,
    "score_percent": 78.5,
    "workout": {
      "done_count": 4,
      "total_count": 5,
      "skipped_count": 1,
      "vs_last_week_pct": 15.2,
      "most_skipped_exercise": { "id": "...", "name": "Burpees" }
    },
    "nutrition": {
      "done_days": 6,
      "total_days": 7,
      "avg_calorie_adherence_pct": 92.0,
      "avg_budget_per_day_idr": 32500
    },
    "weight": {
      "change_kg": -0.5
    },
    "ai_recommendation": "Performamu naik 15% minggu ini. Saya akan menaikkan intensitas 10% minggu depan.",
    "next_plan_available": true,
    "created_at": "2026-05-12T20:00:00Z"
  }
}
```

---

## 8. Sync

### POST `/v1/sync/batch`
Drain offline queue dari mobile.

**Request:**
```json
{
  "items": [
    { "id": "uuid", "type": "workout_checklist", "payload": {...}, "created_at": "..." },
    { "id": "uuid", "type": "weight_log", "payload": {...}, "created_at": "..." }
  ]
}
```

**Logika:**
- Loop tiap item, dispatch ke service yang tepat berdasarkan `type`.
- Idempotent: cek `sync_id` di tabel target sebelum insert.
- Return per-item status.

**Response 200:**
```json
{
  "results": [
    { "id": "uuid-1", "status": "ok" },
    { "id": "uuid-2", "status": "duplicate" },
    { "id": "uuid-3", "status": "invalid", "error_code": "VALIDATION_ERROR" }
  ]
}
```

`status` enum: `ok`, `duplicate`, `invalid`, `retry`.

---

## 9. Standar HTTP Status

| Status | Kapan |
|---|---|
| 200 OK | GET sukses, PUT/POST yang return data |
| 201 Created | POST yang create resource baru |
| 204 No Content | DELETE atau update tanpa response body |
| 400 Bad Request | Validation error |
| 401 Unauthorized | JWT invalid/missing/expired |
| 403 Forbidden | Auth ok tapi tidak boleh akses resource |
| 404 Not Found | Resource tidak ada |
| 409 Conflict | Duplicate (email taken, plan exists) |
| 422 Unprocessable Entity | Validasi business logic gagal (BMI di luar rentang, dll) |
| 500 Internal Server Error | Bug server |
| 502 Bad Gateway | ML service down |
| 503 Service Unavailable | DB down |

## 10. Versioning

Semua endpoint di-prefix `/v1`. Jika ada breaking change di pasca-hackathon, buat `/v2` paralel; jangan ubah `/v1` yang sedang dipakai mobile.

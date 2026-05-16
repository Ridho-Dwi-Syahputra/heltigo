# Heltigo — Database Design (Derived from Frontend)

> Rancangan skema database MySQL 8.0 untuk Heltigo, di-derive dari kebutuhan 47 screen frontend Flutter + endpoint API di [`00_API_REQUIREMENTS.md`](00_API_REQUIREMENTS.md).

**DBMS:** MySQL 8.0+ (InnoDB engine, `utf8mb4` collation)
**Total tabel:** 19
**File DDL siap-pakai:** [`schema.sql`](schema.sql)

---

## 1. Konvensi Umum

| Aspek | Aturan |
|---|---|
| Nama tabel | `snake_case`, plural (e.g., `users`, `workout_plans`) |
| Nama kolom | `snake_case`, singular |
| Primary key | `id BIGINT UNSIGNED AUTO_INCREMENT` |
| Foreign key | `<table_singular>_id` (e.g., `user_id`, `workout_day_id`) |
| Timestamps | `created_at`, `updated_at` (auto via `DEFAULT CURRENT_TIMESTAMP ON UPDATE`) |
| Soft delete | `deleted_at TIMESTAMP NULL` (hanya tabel yang perlu retain history) |
| Enum | `ENUM(...)` MySQL native untuk value terbatas |
| Array/JSON | Tipe `JSON` MySQL native (untuk `health_conditions`, `active_dates`, dll) |
| Money | `DECIMAL(12, 2)` untuk IDR (rupiah, 2 decimal jika perlu sub-rupiah) |
| Weight/height | `DECIMAL(5, 2)` (max 999.99 kg / cm) |
| Engine | `InnoDB` (transactional, foreign key support) |
| Charset | `utf8mb4` + `utf8mb4_unicode_ci` (emoji-safe & locale-aware) |

---

## 2. ER Diagram

```
                          ┌──────────────────┐
                          │      users       │
                          └────────┬─────────┘
                                   │ 1:1
                          ┌────────┴─────────┐
                          │ health_profiles  │
                          └──────────────────┘
                                   │
              ┌────────────────────┼─────────────────────┐
              │                    │                     │
       ┌──────┴────────┐    ┌──────┴────────┐    ┌───────┴────────┐
       │ workout_plans │    │  meal_plans   │    │  daily_logs    │
       └──────┬────────┘    └──────┬────────┘    └────────────────┘
              │ 1:N                │ 1:N
       ┌──────┴────────┐    ┌──────┴────────┐
       │ workout_days  │    │   meal_days   │
       └──────┬────────┘    └──────┬────────┘
              │ 1:N                │ 1:N
       ┌──────┴────────┐    ┌──────┴────────┐
       │   exercises   │    │   meal_times  │
       └───────────────┘    └──────┬────────┘
                                   │ 1:N
                            ┌──────┴────────┐
                            │  food_items   │
                            └──────┬────────┘
                                   │ 1:N
                            ┌──────┴────────┐
                            │   meal_logs   │
                            └───────────────┘

   ┌──────────────────┐    ┌──────────────────┐
   │ workout_sessions │    │     badges       │
   └──────────────────┘    └────────┬─────────┘
                                    │ N:M
                           ┌────────┴─────────┐
                           │  user_badges     │
                           └──────────────────┘

   ┌──────────────────┐    ┌──────────────────┐    ┌─────────────────┐
   │     streaks      │    │  notifications   │    │    settings     │
   └──────────────────┘    └──────────────────┘    └─────────────────┘

   ┌──────────────────┐    ┌──────────────────┐
   │ refresh_tokens   │    │   fcm_tokens     │
   └──────────────────┘    └──────────────────┘

   ┌──────────────────┐
   │   sync_ops_log   │  (untuk idempotency batch sync)
   └──────────────────┘
```

---

## 3. Deskripsi Tabel

### 3.1 `users` — akun user
Tabel master akun. Soft delete supaya bisa restore kalau perlu.

| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | `BIGINT UNSIGNED` | PK, AUTO_INCREMENT | |
| `email` | `VARCHAR(255)` | NOT NULL, UNIQUE | Email login |
| `password_hash` | `VARCHAR(255)` | NOT NULL | bcrypt cost 12 |
| `name` | `VARCHAR(100)` | NOT NULL | Display name |
| `avatar_url` | `VARCHAR(500)` | NULL | URL S3 / local file |
| `email_verified_at` | `TIMESTAMP` | NULL | Untuk verifikasi email (Phase 4) |
| `last_login_at` | `TIMESTAMP` | NULL | Update tiap login |
| `created_at` | `TIMESTAMP` | NOT NULL DEFAULT CURRENT_TIMESTAMP | |
| `updated_at` | `TIMESTAMP` | NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE | |
| `deleted_at` | `TIMESTAMP` | NULL | Soft delete |

**Index:**
- `UNIQUE idx_users_email` ON (email)
- `INDEX idx_users_deleted_at` ON (deleted_at)

### 3.2 `health_profiles` — data kesehatan & preferensi
1:1 dengan `users`. Updated saat setup wizard + replanning update data.

| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | `BIGINT UNSIGNED` | PK | |
| `user_id` | `BIGINT UNSIGNED` | NOT NULL, FK → users.id, UNIQUE | 1 user 1 profile |
| `age` | `TINYINT UNSIGNED` | NOT NULL | 13-120 |
| `gender` | `ENUM('M','F','OTHER')` | NOT NULL | |
| `date_of_birth` | `DATE` | NULL | Untuk recompute age otomatis |
| `height_cm` | `DECIMAL(5,2)` | NOT NULL | |
| `weight_kg` | `DECIMAL(5,2)` | NOT NULL | Current weight |
| `start_weight_kg` | `DECIMAL(5,2)` | NOT NULL | Snapshot at signup |
| `target_weight_kg` | `DECIMAL(5,2)` | NULL | |
| `fitness_level` | `ENUM('BEGINNER','INTERMEDIATE','ADVANCED')` | NOT NULL | |
| `goal` | `ENUM('WEIGHT_LOSS','MUSCLE_GAIN','MAINTENANCE','PERFORMANCE')` | NOT NULL | |
| `health_conditions` | `JSON` | NOT NULL DEFAULT `('[]')` | Array string |
| `allergies` | `JSON` | NOT NULL DEFAULT `('[]')` | Array string |
| `dietary_restrictions` | `JSON` | NOT NULL DEFAULT `('[]')` | HALAL / VEGETARIAN / GLUTEN_FREE / dll |
| `preferred_equipment` | `JSON` | NOT NULL DEFAULT `('[]')` | BODYWEIGHT / DUMBBELL / GYM_FULL |
| `available_days_per_week` | `TINYINT UNSIGNED` | NOT NULL DEFAULT 3 | 1-7 |
| `session_duration_min` | `TINYINT UNSIGNED` | NOT NULL DEFAULT 30 | |
| `workout_mode` | `ENUM('HOME','GYM','HYBRID')` | NOT NULL DEFAULT 'HOME' | |
| `budget_per_day_idr` | `DECIMAL(12,2)` | NOT NULL DEFAULT 50000 | IDR |
| `created_at` | `TIMESTAMP` | NOT NULL DEFAULT CURRENT_TIMESTAMP | |
| `updated_at` | `TIMESTAMP` | NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE | |

**Index:** `UNIQUE idx_health_profiles_user_id` ON (user_id)

### 3.3 `workout_plans` — plan workout 7 hari
1:N dengan `users`. Satu user bisa punya banyak plan (history), tapi hanya 1 `is_active=true`.

| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | `BIGINT UNSIGNED` | PK | |
| `user_id` | `BIGINT UNSIGNED` | NOT NULL, FK → users.id | |
| `name` | `VARCHAR(100)` | NOT NULL | E.g., "Push & Core Week" |
| `start_date` | `DATE` | NOT NULL | Senin minggu plan |
| `end_date` | `DATE` | NOT NULL | Minggu (start + 6) |
| `status` | `ENUM('ACTIVE','COMPLETED','ARCHIVED','SKIPPED')` | NOT NULL DEFAULT 'ACTIVE' | |
| `is_active` | `BOOLEAN` | NOT NULL DEFAULT TRUE | Hanya 1 per user |
| `generated_by` | `ENUM('ML','RULE','MANUAL')` | NOT NULL DEFAULT 'ML' | |
| `ml_metadata` | `JSON` | NULL | Workout type & intensity per hari dari ML |
| `created_at` | `TIMESTAMP` | DEFAULT CURRENT_TIMESTAMP | |
| `updated_at` | `TIMESTAMP` | DEFAULT CURRENT_TIMESTAMP ON UPDATE | |

**Index:**
- `INDEX idx_workout_plans_user_active` ON (user_id, is_active)
- `INDEX idx_workout_plans_dates` ON (user_id, start_date, end_date)

### 3.4 `workout_days` — 1 hari workout dalam plan
1:N dengan `workout_plans`. Total 7 row per plan.

| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | `BIGINT UNSIGNED` | PK | |
| `plan_id` | `BIGINT UNSIGNED` | NOT NULL, FK → workout_plans.id | |
| `day_number` | `TINYINT UNSIGNED` | NOT NULL | 1-7 (Senin-Minggu) |
| `date` | `DATE` | NOT NULL | Tanggal absolut |
| `workout_type` | `ENUM('STRENGTH','CARDIO','HIIT','FLEXIBILITY','REST')` | NOT NULL | |
| `intensity` | `ENUM('LOW','MID','HIGH')` | NULL | NULL untuk REST day |
| `name` | `VARCHAR(100)` | NULL | "Push & Core Day" |
| `duration_min` | `SMALLINT UNSIGNED` | NULL | Estimasi total |
| `total_sets` | `SMALLINT UNSIGNED` | NULL | Estimasi total |
| `is_completed` | `BOOLEAN` | NOT NULL DEFAULT FALSE | |
| `completed_at` | `TIMESTAMP` | NULL | |
| `created_at` | `TIMESTAMP` | DEFAULT CURRENT_TIMESTAMP | |

**Index:**
- `UNIQUE idx_workout_days_plan_day` ON (plan_id, day_number)
- `INDEX idx_workout_days_date` ON (date)

### 3.5 `exercises` — gerakan latihan dalam workout_day

| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | `BIGINT UNSIGNED` | PK | |
| `workout_day_id` | `BIGINT UNSIGNED` | NOT NULL, FK → workout_days.id | |
| `master_exercise_id` | `BIGINT UNSIGNED` | NULL, FK → exercise_master.id | Referensi master library |
| `name` | `VARCHAR(100)` | NOT NULL | Snapshot nama saat plan dibuat |
| `category` | `ENUM('WARMUP','MAIN','COOLDOWN')` | NOT NULL | |
| `sets` | `TINYINT UNSIGNED` | NOT NULL | |
| `reps` | `SMALLINT UNSIGNED` | NULL | NULL untuk duration-based |
| `duration_sec` | `SMALLINT UNSIGNED` | NULL | Untuk plank/stretch |
| `rest_sec` | `SMALLINT UNSIGNED` | NOT NULL DEFAULT 60 | |
| `tempo` | `VARCHAR(20)` | NULL | E.g., "2-1-2-0" |
| `notes` | `TEXT` | NULL | |
| `order_index` | `SMALLINT UNSIGNED` | NOT NULL | Urutan tampilan |
| `created_at` | `TIMESTAMP` | DEFAULT CURRENT_TIMESTAMP | |

**Index:** `INDEX idx_exercises_workout_day` ON (workout_day_id, order_index)

### 3.6 `exercise_master` — library master gerakan
Seeded dari dataset workout (~200 entri kurasi). Read-only untuk user.

| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | `BIGINT UNSIGNED` | PK | |
| `slug` | `VARCHAR(80)` | NOT NULL UNIQUE | E.g., "push-up" |
| `name` | `VARCHAR(100)` | NOT NULL | |
| `description` | `TEXT` | NULL | |
| `instructions` | `JSON` | NULL | Array steps |
| `muscle_groups` | `JSON` | NULL | ["chest","triceps"] |
| `equipment` | `JSON` | NULL | ["bodyweight"] |
| `difficulty` | `ENUM('BEGINNER','INTERMEDIATE','ADVANCED')` | NOT NULL | |
| `tips` | `JSON` | NULL | Array string |
| `video_url` | `VARCHAR(500)` | NULL | |
| `image_url` | `VARCHAR(500)` | NULL | |
| `default_sets` | `TINYINT UNSIGNED` | NULL | |
| `default_reps` | `SMALLINT UNSIGNED` | NULL | |
| `default_rest_sec` | `SMALLINT UNSIGNED` | NULL | |
| `is_active` | `BOOLEAN` | NOT NULL DEFAULT TRUE | Untuk soft-deactivate |

**Index:** `UNIQUE idx_exercise_master_slug` ON (slug)

### 3.7 `workout_sessions` — actual session yang dijalankan
Bukan plan, tapi yang user benar-benar lakukan.

| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | `BIGINT UNSIGNED` | PK | |
| `user_id` | `BIGINT UNSIGNED` | NOT NULL, FK → users.id | |
| `workout_day_id` | `BIGINT UNSIGNED` | NOT NULL, FK → workout_days.id | |
| `started_at` | `TIMESTAMP` | NOT NULL | Saat check-in |
| `completed_at` | `TIMESTAMP` | NULL | Saat finish |
| `duration_sec` | `INT UNSIGNED` | NULL | Total durasi sesungguhnya |
| `calories_burned` | `SMALLINT UNSIGNED` | NULL | Estimasi |
| `effort_score` | `TINYINT UNSIGNED` | NULL | 1-10 slider |
| `mood_before` | `ENUM('VERY_BAD','BAD','NEUTRAL','GOOD','VERY_GOOD')` | NULL | |
| `energy_before` | `TINYINT UNSIGNED` | NULL | 1-5 |
| `sleep_band_before` | `ENUM('LT5','B5_6','B6_7','B7_8','GT8')` | NULL | |
| `mood_after` | `ENUM('VERY_BAD','BAD','NEUTRAL','GOOD','VERY_GOOD')` | NULL | |
| `intensity_multiplier` | `DECIMAL(4,2)` | NULL | Hasil ML adjuster |
| `status` | `ENUM('IN_PROGRESS','COMPLETED','ABANDONED')` | NOT NULL DEFAULT 'IN_PROGRESS' | |
| `notes` | `TEXT` | NULL | |
| `created_at` | `TIMESTAMP` | DEFAULT CURRENT_TIMESTAMP | |
| `updated_at` | `TIMESTAMP` | DEFAULT CURRENT_TIMESTAMP ON UPDATE | |

**Index:**
- `INDEX idx_sessions_user_date` ON (user_id, started_at)
- `INDEX idx_sessions_status` ON (status)

### 3.8 `exercise_logs` — log per-set per-exercise dalam session

| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | `BIGINT UNSIGNED` | PK | |
| `session_id` | `BIGINT UNSIGNED` | NOT NULL, FK → workout_sessions.id | |
| `exercise_id` | `BIGINT UNSIGNED` | NOT NULL, FK → exercises.id | |
| `set_number` | `TINYINT UNSIGNED` | NOT NULL | 1-N |
| `reps_actual` | `SMALLINT UNSIGNED` | NULL | |
| `duration_actual_sec` | `SMALLINT UNSIGNED` | NULL | |
| `weight_kg` | `DECIMAL(5,2)` | NULL | Untuk strength dengan beban |
| `rest_actual_sec` | `SMALLINT UNSIGNED` | NULL | |
| `is_completed` | `BOOLEAN` | NOT NULL DEFAULT FALSE | |
| `logged_at` | `TIMESTAMP` | DEFAULT CURRENT_TIMESTAMP | |

**Index:** `INDEX idx_exercise_logs_session` ON (session_id, exercise_id, set_number)

### 3.9 `meal_plans` — plan meal 7 hari

| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | `BIGINT UNSIGNED` | PK | |
| `user_id` | `BIGINT UNSIGNED` | NOT NULL, FK → users.id | |
| `workout_plan_id` | `BIGINT UNSIGNED` | NULL, FK → workout_plans.id | Pair dengan workout plan |
| `start_date` | `DATE` | NOT NULL | |
| `end_date` | `DATE` | NOT NULL | |
| `status` | `ENUM('ACTIVE','COMPLETED','ARCHIVED')` | NOT NULL DEFAULT 'ACTIVE' | |
| `is_active` | `BOOLEAN` | NOT NULL DEFAULT TRUE | |
| `target_calories_per_day` | `SMALLINT UNSIGNED` | NOT NULL | TDEE adjusted |
| `target_protein_g` | `SMALLINT UNSIGNED` | NOT NULL | |
| `target_carbs_g` | `SMALLINT UNSIGNED` | NOT NULL | |
| `target_fat_g` | `SMALLINT UNSIGNED` | NOT NULL | |
| `budget_per_day_idr` | `DECIMAL(12,2)` | NOT NULL | Snapshot saat plan dibuat |
| `created_at` | `TIMESTAMP` | DEFAULT CURRENT_TIMESTAMP | |
| `updated_at` | `TIMESTAMP` | DEFAULT CURRENT_TIMESTAMP ON UPDATE | |

**Index:** `INDEX idx_meal_plans_user_active` ON (user_id, is_active)

### 3.10 `meal_days` — 1 hari meal dalam meal_plan

| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | `BIGINT UNSIGNED` | PK | |
| `plan_id` | `BIGINT UNSIGNED` | NOT NULL, FK → meal_plans.id | |
| `day_number` | `TINYINT UNSIGNED` | NOT NULL | 1-7 |
| `date` | `DATE` | NOT NULL | |
| `total_calories` | `SMALLINT UNSIGNED` | NULL | Sum dari meal_times |
| `total_protein_g` | `DECIMAL(6,2)` | NULL | |
| `total_carbs_g` | `DECIMAL(6,2)` | NULL | |
| `total_fat_g` | `DECIMAL(6,2)` | NULL | |
| `total_cost_idr` | `DECIMAL(12,2)` | NULL | Sum dari food_items |
| `created_at` | `TIMESTAMP` | DEFAULT CURRENT_TIMESTAMP | |

**Index:** `UNIQUE idx_meal_days_plan_day` ON (plan_id, day_number)

### 3.11 `meal_times` — sarapan / makan siang / makan malam per hari

| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | `BIGINT UNSIGNED` | PK | |
| `meal_day_id` | `BIGINT UNSIGNED` | NOT NULL, FK → meal_days.id | |
| `meal_type` | `ENUM('BREAKFAST','LUNCH','DINNER','SNACK')` | NOT NULL | |
| `scheduled_time` | `TIME` | NULL | E.g., "07:30:00" |
| `is_logged` | `BOOLEAN` | NOT NULL DEFAULT FALSE | |
| `logged_at` | `TIMESTAMP` | NULL | |
| `order_index` | `TINYINT UNSIGNED` | NOT NULL | |
| `created_at` | `TIMESTAMP` | DEFAULT CURRENT_TIMESTAMP | |

**Index:** `INDEX idx_meal_times_day_type` ON (meal_day_id, meal_type)

### 3.12 `food_items` — item makanan dalam meal_time
Snapshot saat plan dibuat (bukan referensi langsung ke master karena bisa berubah).

| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | `BIGINT UNSIGNED` | PK | |
| `meal_time_id` | `BIGINT UNSIGNED` | NOT NULL, FK → meal_times.id | |
| `food_master_id` | `BIGINT UNSIGNED` | NULL, FK → food_master.id | Referensi master |
| `name` | `VARCHAR(150)` | NOT NULL | Snapshot |
| `portion` | `VARCHAR(50)` | NOT NULL | "1 piring", "150 g" |
| `portion_gram` | `SMALLINT UNSIGNED` | NULL | Untuk perhitungan akurat |
| `calories` | `SMALLINT UNSIGNED` | NOT NULL | |
| `protein_g` | `DECIMAL(6,2)` | NOT NULL DEFAULT 0 | |
| `carbs_g` | `DECIMAL(6,2)` | NOT NULL DEFAULT 0 | |
| `fat_g` | `DECIMAL(6,2)` | NOT NULL DEFAULT 0 | |
| `fiber_g` | `DECIMAL(6,2)` | NOT NULL DEFAULT 0 | |
| `estimated_cost_idr` | `DECIMAL(12,2)` | NOT NULL DEFAULT 0 | |
| `order_index` | `TINYINT UNSIGNED` | NOT NULL | |
| `created_at` | `TIMESTAMP` | DEFAULT CURRENT_TIMESTAMP | |

**Index:** `INDEX idx_food_items_meal_time` ON (meal_time_id, order_index)

### 3.13 `food_master` — library master makanan Indonesia
Seeded dari dataset `nutrition.csv` (1,346 items, di-augment dengan category/price/halal/veg).

| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | `BIGINT UNSIGNED` | PK | |
| `slug` | `VARCHAR(120)` | NOT NULL UNIQUE | |
| `name` | `VARCHAR(150)` | NOT NULL | |
| `category` | `ENUM('STAPLE','PROTEIN','VEGETABLE','FRUIT','BEVERAGE','DESSERT','SNACK')` | NOT NULL | |
| `cuisine` | `ENUM('INDONESIAN','ASIAN','WESTERN','OTHER')` | NOT NULL DEFAULT 'INDONESIAN' | |
| `base_portion` | `VARCHAR(50)` | NOT NULL | "1 piring" |
| `base_portion_gram` | `SMALLINT UNSIGNED` | NOT NULL DEFAULT 100 | |
| `calories_per_portion` | `SMALLINT UNSIGNED` | NOT NULL | |
| `protein_g` | `DECIMAL(6,2)` | NOT NULL | Per portion |
| `carbs_g` | `DECIMAL(6,2)` | NOT NULL | |
| `fat_g` | `DECIMAL(6,2)` | NOT NULL | |
| `fiber_g` | `DECIMAL(6,2)` | NOT NULL DEFAULT 0 | |
| `estimated_price_idr` | `DECIMAL(12,2)` | NOT NULL | Augmented heuristic |
| `is_halal` | `BOOLEAN` | NOT NULL DEFAULT TRUE | |
| `is_vegetarian` | `BOOLEAN` | NOT NULL DEFAULT FALSE | |
| `is_vegan` | `BOOLEAN` | NOT NULL DEFAULT FALSE | |
| `is_gluten_free` | `BOOLEAN` | NOT NULL DEFAULT FALSE | |
| `image_url` | `VARCHAR(500)` | NULL | |
| `is_active` | `BOOLEAN` | NOT NULL DEFAULT TRUE | |

**Index:**
- `UNIQUE idx_food_master_slug` ON (slug)
- `INDEX idx_food_master_category` ON (category, is_active)

### 3.14 `meal_logs` — riwayat user log makan

| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | `BIGINT UNSIGNED` | PK | |
| `user_id` | `BIGINT UNSIGNED` | NOT NULL, FK → users.id | |
| `meal_time_id` | `BIGINT UNSIGNED` | NOT NULL, FK → meal_times.id | |
| `food_item_id` | `BIGINT UNSIGNED` | NOT NULL, FK → food_items.id | |
| `logged_at` | `TIMESTAMP` | NOT NULL | |
| `actual_portion_gram` | `SMALLINT UNSIGNED` | NULL | Override jika beda |
| `notes` | `VARCHAR(500)` | NULL | |
| `created_at` | `TIMESTAMP` | DEFAULT CURRENT_TIMESTAMP | |

**Index:**
- `UNIQUE idx_meal_logs_user_time_food` ON (user_id, meal_time_id, food_item_id) — idempotent
- `INDEX idx_meal_logs_user_date` ON (user_id, logged_at)

### 3.15 `daily_logs` — agregat aktivitas per hari per user

| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | `BIGINT UNSIGNED` | PK | |
| `user_id` | `BIGINT UNSIGNED` | NOT NULL, FK → users.id | |
| `date` | `DATE` | NOT NULL | |
| `workout_completed` | `BOOLEAN` | NOT NULL DEFAULT FALSE | |
| `workout_session_id` | `BIGINT UNSIGNED` | NULL, FK → workout_sessions.id | |
| `meals_logged_count` | `TINYINT UNSIGNED` | NOT NULL DEFAULT 0 | |
| `meals_total` | `TINYINT UNSIGNED` | NOT NULL DEFAULT 3 | |
| `water_glasses` | `TINYINT UNSIGNED` | NOT NULL DEFAULT 0 | Increment-only |
| `water_target` | `TINYINT UNSIGNED` | NOT NULL DEFAULT 8 | |
| `mood` | `ENUM('VERY_BAD','BAD','NEUTRAL','GOOD','VERY_GOOD')` | NULL | |
| `daily_score` | `TINYINT UNSIGNED` | NULL | 0-100 computed |
| `calories_consumed` | `SMALLINT UNSIGNED` | NULL | Sum meal_logs |
| `calories_burned` | `SMALLINT UNSIGNED` | NULL | Dari workout session |
| `created_at` | `TIMESTAMP` | DEFAULT CURRENT_TIMESTAMP | |
| `updated_at` | `TIMESTAMP` | DEFAULT CURRENT_TIMESTAMP ON UPDATE | |

**Index:**
- `UNIQUE idx_daily_logs_user_date` ON (user_id, date)

### 3.16 `streaks` — current & best streak per user
1:1 dengan users. Updated by cron daily.

| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | `BIGINT UNSIGNED` | PK | |
| `user_id` | `BIGINT UNSIGNED` | NOT NULL, FK → users.id, UNIQUE | |
| `current_streak` | `SMALLINT UNSIGNED` | NOT NULL DEFAULT 0 | |
| `best_streak` | `SMALLINT UNSIGNED` | NOT NULL DEFAULT 0 | |
| `last_active_date` | `DATE` | NULL | |
| `active_dates` | `JSON` | NOT NULL DEFAULT `('[]')` | Array tanggal 30 hari terakhir untuk calendar |
| `updated_at` | `TIMESTAMP` | DEFAULT CURRENT_TIMESTAMP ON UPDATE | |

### 3.17 `badges` & `user_badges`

**`badges`** — master:

| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | `BIGINT UNSIGNED` | PK | |
| `code` | `VARCHAR(50)` | NOT NULL UNIQUE | E.g., "STREAK_7" |
| `title` | `VARCHAR(100)` | NOT NULL | |
| `description` | `VARCHAR(500)` | NOT NULL | |
| `icon_name` | `VARCHAR(50)` | NOT NULL | Material icon name |
| `icon_color` | `VARCHAR(7)` | NULL | Hex |
| `category` | `ENUM('STREAK','MILESTONE','GOAL','SPECIAL')` | NOT NULL | |
| `criterion_type` | `ENUM('STREAK','WORKOUTS_DONE','WEIGHT_LOST','MEALS_LOGGED','CUSTOM')` | NOT NULL | |
| `criterion_value` | `INT` | NOT NULL | E.g., 7 (for streak 7 days) |
| `order_index` | `SMALLINT UNSIGNED` | NOT NULL | |
| `is_active` | `BOOLEAN` | NOT NULL DEFAULT TRUE | |

**`user_badges`** — junction:

| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | `BIGINT UNSIGNED` | PK | |
| `user_id` | `BIGINT UNSIGNED` | NOT NULL, FK → users.id | |
| `badge_id` | `BIGINT UNSIGNED` | NOT NULL, FK → badges.id | |
| `unlocked_at` | `TIMESTAMP` | NOT NULL DEFAULT CURRENT_TIMESTAMP | |

**Index:** `UNIQUE idx_user_badges_user_badge` ON (user_id, badge_id)

### 3.18 `notifications` — in-app notifications

| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | `BIGINT UNSIGNED` | PK | |
| `user_id` | `BIGINT UNSIGNED` | NOT NULL, FK → users.id | |
| `type` | `ENUM('MOTIVATION','WORKOUT_REMINDER','MEAL_REMINDER','STREAK_MILESTONE','BADGE_UNLOCKED','REPLAN_DUE')` | NOT NULL | |
| `title` | `VARCHAR(150)` | NOT NULL | |
| `body` | `VARCHAR(500)` | NOT NULL | |
| `action_url` | `VARCHAR(255)` | NULL | E.g., "/workout/checkin/42" |
| `is_read` | `BOOLEAN` | NOT NULL DEFAULT FALSE | |
| `read_at` | `TIMESTAMP` | NULL | |
| `created_at` | `TIMESTAMP` | DEFAULT CURRENT_TIMESTAMP | |

**Index:**
- `INDEX idx_notifications_user_unread` ON (user_id, is_read, created_at)

### 3.19 `settings`

| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | `BIGINT UNSIGNED` | PK | |
| `user_id` | `BIGINT UNSIGNED` | NOT NULL, FK → users.id, UNIQUE | |
| `theme` | `ENUM('LIGHT','DARK','SYSTEM')` | NOT NULL DEFAULT 'DARK' | |
| `language` | `ENUM('id','en')` | NOT NULL DEFAULT 'id' | |
| `timezone` | `VARCHAR(50)` | NOT NULL DEFAULT 'Asia/Jakarta' | |
| `notifications_enabled` | `BOOLEAN` | NOT NULL DEFAULT TRUE | |
| `daily_reminder_time` | `TIME` | NULL | |
| `workout_reminder_time` | `TIME` | NULL | |
| `meal_reminder_time` | `TIME` | NULL | |
| `updated_at` | `TIMESTAMP` | DEFAULT CURRENT_TIMESTAMP ON UPDATE | |

### 3.20 `refresh_tokens`

| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | `BIGINT UNSIGNED` | PK | |
| `user_id` | `BIGINT UNSIGNED` | NOT NULL, FK → users.id | |
| `token_hash` | `VARCHAR(64)` | NOT NULL UNIQUE | SHA-256 hash |
| `expires_at` | `TIMESTAMP` | NOT NULL | |
| `revoked_at` | `TIMESTAMP` | NULL | |
| `user_agent` | `VARCHAR(255)` | NULL | |
| `created_at` | `TIMESTAMP` | DEFAULT CURRENT_TIMESTAMP | |

**Index:**
- `INDEX idx_refresh_tokens_user_active` ON (user_id, revoked_at)

### 3.21 `fcm_tokens` — device push tokens

| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | `BIGINT UNSIGNED` | PK | |
| `user_id` | `BIGINT UNSIGNED` | NOT NULL, FK → users.id | |
| `token` | `VARCHAR(255)` | NOT NULL UNIQUE | |
| `platform` | `ENUM('ANDROID','IOS','WEB')` | NOT NULL | |
| `created_at` | `TIMESTAMP` | DEFAULT CURRENT_TIMESTAMP | |

### 3.22 `sync_ops_log` — idempotency tracking
TTL 24 jam (cron prune).

| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | `BIGINT UNSIGNED` | PK | |
| `user_id` | `BIGINT UNSIGNED` | NOT NULL, FK → users.id | |
| `op_id` | `VARCHAR(36)` | NOT NULL | UUID dari client |
| `op_type` | `VARCHAR(50)` | NOT NULL | |
| `status` | `ENUM('OK','DUPLICATE','CONFLICT','ERROR')` | NOT NULL | |
| `result_snapshot` | `JSON` | NULL | Cached response |
| `created_at` | `TIMESTAMP` | DEFAULT CURRENT_TIMESTAMP | |

**Index:** `UNIQUE idx_sync_ops_user_op` ON (user_id, op_id)

---

## 4. Foreign Key Cascade Policy

| Parent | Child | ON DELETE | Alasan |
|---|---|---|---|
| users | semua child | RESTRICT (soft delete via `deleted_at`) | Audit trail |
| workout_plans | workout_days | CASCADE | Hapus plan = hapus days |
| workout_days | exercises | CASCADE | |
| meal_plans | meal_days | CASCADE | |
| meal_days | meal_times | CASCADE | |
| meal_times | food_items | CASCADE | |
| workout_sessions | exercise_logs | CASCADE | |
| exercise_master | exercises | SET NULL | Snapshot ada di exercises.name |
| food_master | food_items | SET NULL | Snapshot ada di food_items.* |

---

## 5. Migration Order

1. `users`
2. `health_profiles`
3. `settings`
4. `refresh_tokens`, `fcm_tokens`
5. `exercise_master`, `food_master`
6. `workout_plans` → `workout_days` → `exercises`
7. `meal_plans` → `meal_days` → `meal_times` → `food_items`
8. `workout_sessions` → `exercise_logs`
9. `meal_logs`
10. `daily_logs`
11. `streaks`
12. `badges` → `user_badges`
13. `notifications`
14. `sync_ops_log`

---

## 6. Indexes Summary (Composite & Critical)

| Tabel | Index | Kolom | Pakai untuk |
|---|---|---|---|
| users | `UNIQUE` | `email` | Login lookup |
| health_profiles | `UNIQUE` | `user_id` | 1:1 enforcement |
| workout_plans | composite | `user_id`, `is_active` | "Active plan?" query |
| workout_plans | composite | `user_id`, `start_date`, `end_date` | History queries |
| workout_days | composite | `plan_id`, `day_number` | Order |
| workout_days | single | `date` | "Today's workout" |
| exercises | composite | `workout_day_id`, `order_index` | List sorted |
| workout_sessions | composite | `user_id`, `started_at` | History |
| meal_plans | composite | `user_id`, `is_active` | |
| food_master | composite | `category`, `is_active` | Meal planner filter |
| meal_logs | composite | `user_id`, `logged_at` | History range |
| meal_logs | UNIQUE | `user_id`, `meal_time_id`, `food_item_id` | Idempotent log |
| daily_logs | UNIQUE | `user_id`, `date` | 1 row per hari |
| notifications | composite | `user_id`, `is_read`, `created_at` | Unread list |
| user_badges | UNIQUE | `user_id`, `badge_id` | Unlock idempotent |
| sync_ops_log | UNIQUE | `user_id`, `op_id` | Idempotency |

---

## 7. Seed Data Recommendations

### 7.1 `badges` (15 entri)
```
STREAK_3, STREAK_7, STREAK_30, STREAK_100,
WORKOUTS_10, WORKOUTS_50, WORKOUTS_100,
WEIGHT_LOST_1, WEIGHT_LOST_5, WEIGHT_LOST_10,
MEALS_LOGGED_50, MEALS_LOGGED_200,
FIRST_PLAN, COMPLETED_FIRST_WEEK, EARLY_BIRD
```

### 7.2 `exercise_master` (~200 entri)
Kurasi dari [600K+ Fitness Exercise dataset](../../notebook/dataset/Model_rekomendasi_Pelatihan/600K+%20Fitness%20Exercise%20%26%20Workout%20Program%20Dataset/) — fokus exercise bodyweight + basic equipment yang relevan untuk pemula-menengah.

### 7.3 `food_master` (1,346 entri)
Migrasi dari [nutrition.csv](../../notebook/dataset/Model_Perencana%20Makan_dan_Nutrisi/Indonesian%20Food%20%26%20Drink%20Nutrition%20Dataset/) setelah cleaning + augmentation (category, price, halal, vegetarian).

---

## 8. Backup & Retention

- **Backup harian:** mysqldump full → S3, retention 30 hari.
- **Snapshot mingguan:** retention 12 minggu.
- **Audit log:** `workout_sessions`, `meal_logs`, `daily_logs` di-retain selamanya.
- **Soft-deleted users:** auto-purge setelah 90 hari (`DELETE FROM users WHERE deleted_at < NOW() - INTERVAL 90 DAY`).

---

**Lihat juga:**
- [`00_API_REQUIREMENTS.md`](00_API_REQUIREMENTS.md) — daftar endpoint
- [`schema.sql`](schema.sql) — DDL siap-eksekusi

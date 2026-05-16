-- =====================================================================
-- Heltigo — MySQL Schema v1.0
-- Target: MySQL 8.0+
-- Engine: InnoDB, Charset: utf8mb4
-- Generated from: docs/backend/FE_requirement/01_DATABASE_DESIGN.md
-- Demo target: 2026-05-21
-- =====================================================================

SET NAMES utf8mb4;
SET time_zone = '+00:00';
SET FOREIGN_KEY_CHECKS = 0;

-- ---------------------------------------------------------------------
-- DROP EXISTING (urutan reverse migration)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS sync_ops_log;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS user_badges;
DROP TABLE IF EXISTS badges;
DROP TABLE IF EXISTS streaks;
DROP TABLE IF EXISTS daily_logs;
DROP TABLE IF EXISTS meal_logs;
DROP TABLE IF EXISTS exercise_logs;
DROP TABLE IF EXISTS workout_sessions;
DROP TABLE IF EXISTS food_items;
DROP TABLE IF EXISTS meal_times;
DROP TABLE IF EXISTS meal_days;
DROP TABLE IF EXISTS meal_plans;
DROP TABLE IF EXISTS exercises;
DROP TABLE IF EXISTS workout_days;
DROP TABLE IF EXISTS workout_plans;
DROP TABLE IF EXISTS food_master;
DROP TABLE IF EXISTS exercise_master;
DROP TABLE IF EXISTS fcm_tokens;
DROP TABLE IF EXISTS refresh_tokens;
DROP TABLE IF EXISTS settings;
DROP TABLE IF EXISTS health_profiles;
DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================================
-- CORE USER
-- =====================================================================

CREATE TABLE users (
    id                  BIGINT UNSIGNED       NOT NULL AUTO_INCREMENT,
    email               VARCHAR(255)          NOT NULL,
    password_hash       VARCHAR(255)          NOT NULL,
    name                VARCHAR(100)          NOT NULL,
    avatar_url          VARCHAR(500)          NULL,
    email_verified_at   TIMESTAMP             NULL,
    last_login_at       TIMESTAMP             NULL,
    created_at          TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at          TIMESTAMP             NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uniq_users_email (email),
    KEY idx_users_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE health_profiles (
    id                          BIGINT UNSIGNED       NOT NULL AUTO_INCREMENT,
    user_id                     BIGINT UNSIGNED       NOT NULL,
    age                         TINYINT UNSIGNED      NOT NULL,
    gender                      ENUM('M','F','OTHER') NOT NULL,
    date_of_birth               DATE                  NULL,
    height_cm                   DECIMAL(5,2)          NOT NULL,
    weight_kg                   DECIMAL(5,2)          NOT NULL,
    start_weight_kg             DECIMAL(5,2)          NOT NULL,
    target_weight_kg            DECIMAL(5,2)          NULL,
    fitness_level               ENUM('BEGINNER','INTERMEDIATE','ADVANCED') NOT NULL,
    goal                        ENUM('WEIGHT_LOSS','MUSCLE_GAIN','MAINTENANCE','PERFORMANCE') NOT NULL,
    health_conditions           JSON                  NOT NULL,
    allergies                   JSON                  NOT NULL,
    dietary_restrictions        JSON                  NOT NULL,
    preferred_equipment         JSON                  NOT NULL,
    available_days_per_week     TINYINT UNSIGNED      NOT NULL DEFAULT 3,
    session_duration_min        TINYINT UNSIGNED      NOT NULL DEFAULT 30,
    workout_mode                ENUM('HOME','GYM','HYBRID') NOT NULL DEFAULT 'HOME',
    budget_per_day_idr          DECIMAL(12,2)         NOT NULL DEFAULT 50000.00,
    created_at                  TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at                  TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uniq_health_profiles_user_id (user_id),
    CONSTRAINT fk_health_profiles_user FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT chk_health_profiles_age CHECK (age BETWEEN 13 AND 120),
    CONSTRAINT chk_health_profiles_avail_days CHECK (available_days_per_week BETWEEN 1 AND 7)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE settings (
    id                      BIGINT UNSIGNED       NOT NULL AUTO_INCREMENT,
    user_id                 BIGINT UNSIGNED       NOT NULL,
    theme                   ENUM('LIGHT','DARK','SYSTEM') NOT NULL DEFAULT 'DARK',
    language                ENUM('id','en')       NOT NULL DEFAULT 'id',
    timezone                VARCHAR(50)           NOT NULL DEFAULT 'Asia/Jakarta',
    notifications_enabled   BOOLEAN               NOT NULL DEFAULT TRUE,
    daily_reminder_time     TIME                  NULL,
    workout_reminder_time   TIME                  NULL,
    meal_reminder_time      TIME                  NULL,
    created_at              TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uniq_settings_user_id (user_id),
    CONSTRAINT fk_settings_user FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE refresh_tokens (
    id              BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    user_id         BIGINT UNSIGNED   NOT NULL,
    token_hash      VARCHAR(64)       NOT NULL,
    expires_at      TIMESTAMP         NOT NULL,
    revoked_at      TIMESTAMP         NULL,
    user_agent      VARCHAR(255)      NULL,
    created_at      TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uniq_refresh_tokens_hash (token_hash),
    KEY idx_refresh_tokens_user_active (user_id, revoked_at),
    CONSTRAINT fk_refresh_tokens_user FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE fcm_tokens (
    id          BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    user_id     BIGINT UNSIGNED   NOT NULL,
    token       VARCHAR(255)      NOT NULL,
    platform    ENUM('ANDROID','IOS','WEB') NOT NULL,
    created_at  TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uniq_fcm_tokens_token (token),
    KEY idx_fcm_tokens_user (user_id),
    CONSTRAINT fk_fcm_tokens_user FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- MASTER LIBRARIES
-- =====================================================================

CREATE TABLE exercise_master (
    id                  BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    slug                VARCHAR(80)       NOT NULL,
    name                VARCHAR(100)      NOT NULL,
    description         TEXT              NULL,
    instructions        JSON              NULL,
    muscle_groups       JSON              NULL,
    equipment           JSON              NULL,
    difficulty          ENUM('BEGINNER','INTERMEDIATE','ADVANCED') NOT NULL,
    tips                JSON              NULL,
    video_url           VARCHAR(500)      NULL,
    image_url           VARCHAR(500)      NULL,
    default_sets        TINYINT UNSIGNED  NULL,
    default_reps        SMALLINT UNSIGNED NULL,
    default_rest_sec    SMALLINT UNSIGNED NULL,
    is_active           BOOLEAN           NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uniq_exercise_master_slug (slug),
    KEY idx_exercise_master_difficulty (difficulty, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE food_master (
    id                      BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    slug                    VARCHAR(120)      NOT NULL,
    name                    VARCHAR(150)      NOT NULL,
    category                ENUM('STAPLE','PROTEIN','VEGETABLE','FRUIT','BEVERAGE','DESSERT','SNACK') NOT NULL,
    cuisine                 ENUM('INDONESIAN','ASIAN','WESTERN','OTHER') NOT NULL DEFAULT 'INDONESIAN',
    base_portion            VARCHAR(50)       NOT NULL,
    base_portion_gram       SMALLINT UNSIGNED NOT NULL DEFAULT 100,
    calories_per_portion    SMALLINT UNSIGNED NOT NULL,
    protein_g               DECIMAL(6,2)      NOT NULL,
    carbs_g                 DECIMAL(6,2)      NOT NULL,
    fat_g                   DECIMAL(6,2)      NOT NULL,
    fiber_g                 DECIMAL(6,2)      NOT NULL DEFAULT 0,
    estimated_price_idr     DECIMAL(12,2)     NOT NULL,
    is_halal                BOOLEAN           NOT NULL DEFAULT TRUE,
    is_vegetarian           BOOLEAN           NOT NULL DEFAULT FALSE,
    is_vegan                BOOLEAN           NOT NULL DEFAULT FALSE,
    is_gluten_free          BOOLEAN           NOT NULL DEFAULT FALSE,
    image_url               VARCHAR(500)      NULL,
    is_active               BOOLEAN           NOT NULL DEFAULT TRUE,
    created_at              TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uniq_food_master_slug (slug),
    KEY idx_food_master_category (category, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- WORKOUT PLAN TREE
-- =====================================================================

CREATE TABLE workout_plans (
    id              BIGINT UNSIGNED       NOT NULL AUTO_INCREMENT,
    user_id         BIGINT UNSIGNED       NOT NULL,
    name            VARCHAR(100)          NOT NULL,
    start_date      DATE                  NOT NULL,
    end_date        DATE                  NOT NULL,
    status          ENUM('ACTIVE','COMPLETED','ARCHIVED','SKIPPED') NOT NULL DEFAULT 'ACTIVE',
    is_active       BOOLEAN               NOT NULL DEFAULT TRUE,
    generated_by    ENUM('ML','RULE','MANUAL') NOT NULL DEFAULT 'ML',
    ml_metadata     JSON                  NULL,
    created_at      TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_workout_plans_user_active (user_id, is_active),
    KEY idx_workout_plans_dates (user_id, start_date, end_date),
    CONSTRAINT fk_workout_plans_user FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE workout_days (
    id              BIGINT UNSIGNED       NOT NULL AUTO_INCREMENT,
    plan_id         BIGINT UNSIGNED       NOT NULL,
    day_number      TINYINT UNSIGNED      NOT NULL,
    date            DATE                  NOT NULL,
    workout_type    ENUM('STRENGTH','CARDIO','HIIT','FLEXIBILITY','REST') NOT NULL,
    intensity       ENUM('LOW','MID','HIGH') NULL,
    name            VARCHAR(100)          NULL,
    duration_min    SMALLINT UNSIGNED     NULL,
    total_sets      SMALLINT UNSIGNED     NULL,
    is_completed    BOOLEAN               NOT NULL DEFAULT FALSE,
    completed_at    TIMESTAMP             NULL,
    created_at      TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uniq_workout_days_plan_day (plan_id, day_number),
    KEY idx_workout_days_date (date),
    CONSTRAINT fk_workout_days_plan FOREIGN KEY (plan_id)
        REFERENCES workout_plans(id) ON DELETE CASCADE,
    CONSTRAINT chk_workout_days_day_number CHECK (day_number BETWEEN 1 AND 7)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE exercises (
    id                  BIGINT UNSIGNED       NOT NULL AUTO_INCREMENT,
    workout_day_id      BIGINT UNSIGNED       NOT NULL,
    master_exercise_id  BIGINT UNSIGNED       NULL,
    name                VARCHAR(100)          NOT NULL,
    category            ENUM('WARMUP','MAIN','COOLDOWN') NOT NULL,
    sets                TINYINT UNSIGNED      NOT NULL,
    reps                SMALLINT UNSIGNED     NULL,
    duration_sec        SMALLINT UNSIGNED     NULL,
    rest_sec            SMALLINT UNSIGNED     NOT NULL DEFAULT 60,
    tempo               VARCHAR(20)           NULL,
    notes               TEXT                  NULL,
    order_index         SMALLINT UNSIGNED     NOT NULL,
    created_at          TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_exercises_workout_day (workout_day_id, order_index),
    CONSTRAINT fk_exercises_workout_day FOREIGN KEY (workout_day_id)
        REFERENCES workout_days(id) ON DELETE CASCADE,
    CONSTRAINT fk_exercises_master FOREIGN KEY (master_exercise_id)
        REFERENCES exercise_master(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- MEAL PLAN TREE
-- =====================================================================

CREATE TABLE meal_plans (
    id                          BIGINT UNSIGNED       NOT NULL AUTO_INCREMENT,
    user_id                     BIGINT UNSIGNED       NOT NULL,
    workout_plan_id             BIGINT UNSIGNED       NULL,
    start_date                  DATE                  NOT NULL,
    end_date                    DATE                  NOT NULL,
    status                      ENUM('ACTIVE','COMPLETED','ARCHIVED') NOT NULL DEFAULT 'ACTIVE',
    is_active                   BOOLEAN               NOT NULL DEFAULT TRUE,
    target_calories_per_day     SMALLINT UNSIGNED     NOT NULL,
    target_protein_g            SMALLINT UNSIGNED     NOT NULL,
    target_carbs_g              SMALLINT UNSIGNED     NOT NULL,
    target_fat_g                SMALLINT UNSIGNED     NOT NULL,
    budget_per_day_idr          DECIMAL(12,2)         NOT NULL,
    created_at                  TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at                  TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_meal_plans_user_active (user_id, is_active),
    KEY idx_meal_plans_dates (user_id, start_date, end_date),
    CONSTRAINT fk_meal_plans_user FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_meal_plans_workout FOREIGN KEY (workout_plan_id)
        REFERENCES workout_plans(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE meal_days (
    id                  BIGINT UNSIGNED       NOT NULL AUTO_INCREMENT,
    plan_id             BIGINT UNSIGNED       NOT NULL,
    day_number          TINYINT UNSIGNED      NOT NULL,
    date                DATE                  NOT NULL,
    total_calories      SMALLINT UNSIGNED     NULL,
    total_protein_g     DECIMAL(6,2)          NULL,
    total_carbs_g       DECIMAL(6,2)          NULL,
    total_fat_g         DECIMAL(6,2)          NULL,
    total_cost_idr      DECIMAL(12,2)         NULL,
    created_at          TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uniq_meal_days_plan_day (plan_id, day_number),
    KEY idx_meal_days_date (date),
    CONSTRAINT fk_meal_days_plan FOREIGN KEY (plan_id)
        REFERENCES meal_plans(id) ON DELETE CASCADE,
    CONSTRAINT chk_meal_days_day_number CHECK (day_number BETWEEN 1 AND 7)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE meal_times (
    id              BIGINT UNSIGNED       NOT NULL AUTO_INCREMENT,
    meal_day_id     BIGINT UNSIGNED       NOT NULL,
    meal_type       ENUM('BREAKFAST','LUNCH','DINNER','SNACK') NOT NULL,
    scheduled_time  TIME                  NULL,
    is_logged       BOOLEAN               NOT NULL DEFAULT FALSE,
    logged_at       TIMESTAMP             NULL,
    order_index     TINYINT UNSIGNED      NOT NULL,
    created_at      TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_meal_times_day_type (meal_day_id, meal_type),
    CONSTRAINT fk_meal_times_day FOREIGN KEY (meal_day_id)
        REFERENCES meal_days(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE food_items (
    id                      BIGINT UNSIGNED       NOT NULL AUTO_INCREMENT,
    meal_time_id            BIGINT UNSIGNED       NOT NULL,
    food_master_id          BIGINT UNSIGNED       NULL,
    name                    VARCHAR(150)          NOT NULL,
    portion                 VARCHAR(50)           NOT NULL,
    portion_gram            SMALLINT UNSIGNED     NULL,
    calories                SMALLINT UNSIGNED     NOT NULL,
    protein_g               DECIMAL(6,2)          NOT NULL DEFAULT 0,
    carbs_g                 DECIMAL(6,2)          NOT NULL DEFAULT 0,
    fat_g                   DECIMAL(6,2)          NOT NULL DEFAULT 0,
    fiber_g                 DECIMAL(6,2)          NOT NULL DEFAULT 0,
    estimated_cost_idr      DECIMAL(12,2)         NOT NULL DEFAULT 0,
    order_index             TINYINT UNSIGNED      NOT NULL,
    created_at              TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_food_items_meal_time (meal_time_id, order_index),
    CONSTRAINT fk_food_items_meal_time FOREIGN KEY (meal_time_id)
        REFERENCES meal_times(id) ON DELETE CASCADE,
    CONSTRAINT fk_food_items_master FOREIGN KEY (food_master_id)
        REFERENCES food_master(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- SESSION & LOGS
-- =====================================================================

CREATE TABLE workout_sessions (
    id                      BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    user_id                 BIGINT UNSIGNED   NOT NULL,
    workout_day_id          BIGINT UNSIGNED   NOT NULL,
    started_at              TIMESTAMP         NOT NULL,
    completed_at            TIMESTAMP         NULL,
    duration_sec            INT UNSIGNED      NULL,
    calories_burned         SMALLINT UNSIGNED NULL,
    effort_score            TINYINT UNSIGNED  NULL,
    mood_before             ENUM('VERY_BAD','BAD','NEUTRAL','GOOD','VERY_GOOD') NULL,
    energy_before           TINYINT UNSIGNED  NULL,
    sleep_band_before       ENUM('LT5','B5_6','B6_7','B7_8','GT8') NULL,
    mood_after              ENUM('VERY_BAD','BAD','NEUTRAL','GOOD','VERY_GOOD') NULL,
    intensity_multiplier    DECIMAL(4,2)      NULL,
    status                  ENUM('IN_PROGRESS','COMPLETED','ABANDONED') NOT NULL DEFAULT 'IN_PROGRESS',
    notes                   TEXT              NULL,
    created_at              TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_sessions_user_date (user_id, started_at),
    KEY idx_sessions_workout_day (workout_day_id),
    KEY idx_sessions_status (status),
    CONSTRAINT fk_sessions_user FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_sessions_workout_day FOREIGN KEY (workout_day_id)
        REFERENCES workout_days(id) ON DELETE CASCADE,
    CONSTRAINT chk_sessions_effort CHECK (effort_score IS NULL OR effort_score BETWEEN 1 AND 10)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE exercise_logs (
    id                      BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    session_id              BIGINT UNSIGNED   NOT NULL,
    exercise_id             BIGINT UNSIGNED   NOT NULL,
    set_number              TINYINT UNSIGNED  NOT NULL,
    reps_actual             SMALLINT UNSIGNED NULL,
    duration_actual_sec     SMALLINT UNSIGNED NULL,
    weight_kg               DECIMAL(5,2)      NULL,
    rest_actual_sec         SMALLINT UNSIGNED NULL,
    is_completed            BOOLEAN           NOT NULL DEFAULT FALSE,
    logged_at               TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_exercise_logs_session (session_id, exercise_id, set_number),
    CONSTRAINT fk_exercise_logs_session FOREIGN KEY (session_id)
        REFERENCES workout_sessions(id) ON DELETE CASCADE,
    CONSTRAINT fk_exercise_logs_exercise FOREIGN KEY (exercise_id)
        REFERENCES exercises(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE meal_logs (
    id                      BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    user_id                 BIGINT UNSIGNED   NOT NULL,
    meal_time_id            BIGINT UNSIGNED   NOT NULL,
    food_item_id            BIGINT UNSIGNED   NOT NULL,
    logged_at               TIMESTAMP         NOT NULL,
    actual_portion_gram     SMALLINT UNSIGNED NULL,
    notes                   VARCHAR(500)      NULL,
    created_at              TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uniq_meal_logs_user_time_food (user_id, meal_time_id, food_item_id),
    KEY idx_meal_logs_user_date (user_id, logged_at),
    CONSTRAINT fk_meal_logs_user FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_meal_logs_meal_time FOREIGN KEY (meal_time_id)
        REFERENCES meal_times(id) ON DELETE CASCADE,
    CONSTRAINT fk_meal_logs_food_item FOREIGN KEY (food_item_id)
        REFERENCES food_items(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE daily_logs (
    id                  BIGINT UNSIGNED       NOT NULL AUTO_INCREMENT,
    user_id             BIGINT UNSIGNED       NOT NULL,
    date                DATE                  NOT NULL,
    workout_completed   BOOLEAN               NOT NULL DEFAULT FALSE,
    workout_session_id  BIGINT UNSIGNED       NULL,
    meals_logged_count  TINYINT UNSIGNED      NOT NULL DEFAULT 0,
    meals_total         TINYINT UNSIGNED      NOT NULL DEFAULT 3,
    water_glasses       TINYINT UNSIGNED      NOT NULL DEFAULT 0,
    water_target        TINYINT UNSIGNED      NOT NULL DEFAULT 8,
    mood                ENUM('VERY_BAD','BAD','NEUTRAL','GOOD','VERY_GOOD') NULL,
    daily_score         TINYINT UNSIGNED      NULL,
    calories_consumed   SMALLINT UNSIGNED     NULL,
    calories_burned     SMALLINT UNSIGNED     NULL,
    created_at          TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP             NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uniq_daily_logs_user_date (user_id, date),
    CONSTRAINT fk_daily_logs_user FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_daily_logs_session FOREIGN KEY (workout_session_id)
        REFERENCES workout_sessions(id) ON DELETE SET NULL,
    CONSTRAINT chk_daily_logs_score CHECK (daily_score IS NULL OR daily_score BETWEEN 0 AND 100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- GAMIFICATION
-- =====================================================================

CREATE TABLE streaks (
    id                  BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    user_id             BIGINT UNSIGNED   NOT NULL,
    current_streak      SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    best_streak         SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    last_active_date    DATE              NULL,
    active_dates        JSON              NOT NULL,
    created_at          TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uniq_streaks_user_id (user_id),
    CONSTRAINT fk_streaks_user FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE badges (
    id                  BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    code                VARCHAR(50)       NOT NULL,
    title               VARCHAR(100)      NOT NULL,
    description         VARCHAR(500)      NOT NULL,
    icon_name           VARCHAR(50)       NOT NULL,
    icon_color          VARCHAR(7)        NULL,
    category            ENUM('STREAK','MILESTONE','GOAL','SPECIAL') NOT NULL,
    criterion_type      ENUM('STREAK','WORKOUTS_DONE','WEIGHT_LOST','MEALS_LOGGED','CUSTOM') NOT NULL,
    criterion_value     INT               NOT NULL,
    order_index         SMALLINT UNSIGNED NOT NULL,
    is_active           BOOLEAN           NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uniq_badges_code (code),
    KEY idx_badges_category (category, is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE user_badges (
    id              BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    user_id         BIGINT UNSIGNED   NOT NULL,
    badge_id        BIGINT UNSIGNED   NOT NULL,
    unlocked_at     TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uniq_user_badges_user_badge (user_id, badge_id),
    KEY idx_user_badges_badge (badge_id),
    CONSTRAINT fk_user_badges_user FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_badges_badge FOREIGN KEY (badge_id)
        REFERENCES badges(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE notifications (
    id          BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    user_id     BIGINT UNSIGNED   NOT NULL,
    type        ENUM('MOTIVATION','WORKOUT_REMINDER','MEAL_REMINDER','STREAK_MILESTONE','BADGE_UNLOCKED','REPLAN_DUE') NOT NULL,
    title       VARCHAR(150)      NOT NULL,
    body        VARCHAR(500)      NOT NULL,
    action_url  VARCHAR(255)      NULL,
    is_read     BOOLEAN           NOT NULL DEFAULT FALSE,
    read_at     TIMESTAMP         NULL,
    created_at  TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_notifications_user_unread (user_id, is_read, created_at),
    CONSTRAINT fk_notifications_user FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- SYNC / IDEMPOTENCY
-- =====================================================================

CREATE TABLE sync_ops_log (
    id                  BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
    user_id             BIGINT UNSIGNED   NOT NULL,
    op_id               VARCHAR(36)       NOT NULL,
    op_type             VARCHAR(50)       NOT NULL,
    status              ENUM('OK','DUPLICATE','CONFLICT','ERROR') NOT NULL,
    result_snapshot     JSON              NULL,
    created_at          TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uniq_sync_ops_user_op (user_id, op_id),
    KEY idx_sync_ops_created (created_at),
    CONSTRAINT fk_sync_ops_user FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- SEED: BADGES
-- =====================================================================

INSERT INTO badges (code, title, description, icon_name, icon_color, category, criterion_type, criterion_value, order_index) VALUES
('STREAK_3',          'Pemula Konsisten',     'Pertahankan streak 3 hari berturut-turut.',          'local_fire_department', '#FB3A01', 'STREAK',    'STREAK',         3,   10),
('STREAK_7',          'Seminggu Penuh',       'Pertahankan streak 7 hari berturut-turut.',          'local_fire_department', '#FB3A01', 'STREAK',    'STREAK',         7,   20),
('STREAK_30',         'Sebulan Tanpa Henti',  'Pertahankan streak 30 hari berturut-turut.',         'local_fire_department', '#FB3A01', 'STREAK',    'STREAK',         30,  30),
('STREAK_100',        'Centurion',            'Pertahankan streak 100 hari berturut-turut.',        'local_fire_department', '#8B5CF6', 'STREAK',    'STREAK',         100, 40),
('WORKOUTS_10',       'Mulai Bergerak',       'Selesaikan 10 sesi latihan.',                        'fitness_center',         '#1D6766', 'MILESTONE', 'WORKOUTS_DONE',  10,  50),
('WORKOUTS_50',       'Konsisten Bergerak',   'Selesaikan 50 sesi latihan.',                        'fitness_center',         '#1D6766', 'MILESTONE', 'WORKOUTS_DONE',  50,  60),
('WORKOUTS_100',      'Atlet Sejati',         'Selesaikan 100 sesi latihan.',                       'fitness_center',         '#FB3A01', 'MILESTONE', 'WORKOUTS_DONE',  100, 70),
('WEIGHT_LOST_1',     'Langkah Pertama',      'Turunkan berat 1 kg dari berat awal.',               'monitor_weight',         '#22C55E', 'GOAL',      'WEIGHT_LOST',    1,   80),
('WEIGHT_LOST_5',     'Lima Kilo Pergi',      'Turunkan berat 5 kg dari berat awal.',               'monitor_weight',         '#22C55E', 'GOAL',      'WEIGHT_LOST',    5,   90),
('WEIGHT_LOST_10',    'Transformasi',         'Turunkan berat 10 kg dari berat awal.',              'monitor_weight',         '#22C55E', 'GOAL',      'WEIGHT_LOST',    10,  100),
('MEALS_LOGGED_50',   'Pencatat Setia',       'Catat 50 kali makan.',                               'restaurant',             '#FB3A01', 'MILESTONE', 'MEALS_LOGGED',   50,  110),
('MEALS_LOGGED_200',  'Master Nutrisi',       'Catat 200 kali makan.',                              'restaurant',             '#8B5CF6', 'MILESTONE', 'MEALS_LOGGED',   200, 120),
('FIRST_PLAN',        'Punya Rencana',        'Plan pertamamu sudah jadi.',                         'flag',                   '#1D6766', 'SPECIAL',   'CUSTOM',         0,   200),
('COMPLETED_FIRST_WEEK','Minggu Pertama Aman','Selesaikan minggu pertama 100%.',                    'verified',               '#22C55E', 'SPECIAL',   'CUSTOM',         0,   210),
('EARLY_BIRD',        'Bangun Pagi',          'Selesaikan latihan sebelum jam 7 pagi 5 kali.',      'wb_sunny',               '#F59E0B', 'SPECIAL',   'CUSTOM',         5,   220);

-- =====================================================================
-- END
-- =====================================================================

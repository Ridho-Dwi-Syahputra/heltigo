-- ============================================================
-- HELTIGO — Database Schema
-- MySQL 8.0+  |  utf8mb4_unicode_ci
-- Generated from: backend/prisma/schema.prisma
-- Date: 2026-05-17
--
-- CARA IMPORT (phpMyAdmin):
--   1. Buka phpMyAdmin
--   2. Klik "New" di sidebar → buat database "heltigo"
--      Collation: utf8mb4_unicode_ci → klik Create
--   3. Klik database "heltigo" yang baru dibuat
--   4. Tab Import → pilih file ini → klik Go
--
-- CARA IMPORT (Terminal):
--   mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS heltigo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
--   mysql -u root -p heltigo < schema.sql
-- ============================================================

-- Matikan cek FK sementara agar urutan CREATE tidak masalah
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 1. USERS
-- ============================================================
CREATE TABLE IF NOT EXISTS `users` (
  `id`                BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
  `email`             VARCHAR(255)      NOT NULL,
  `password_hash`     VARCHAR(255)      NOT NULL,
  `name`              VARCHAR(100)      NOT NULL,
  `avatar_url`        VARCHAR(500)          NULL DEFAULT NULL,
  `email_verified_at` TIMESTAMP             NULL DEFAULT NULL,
  `last_login_at`     TIMESTAMP             NULL DEFAULT NULL,
  `created_at`        TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`        TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at`        TIMESTAMP             NULL DEFAULT NULL,

  PRIMARY KEY (`id`),
  UNIQUE  KEY `users_email_key`         (`email`),
  INDEX        `idx_users_deleted_at`   (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 2. HEALTH_PROFILES
-- ============================================================
CREATE TABLE IF NOT EXISTS `health_profiles` (
  `id`                    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`               BIGINT UNSIGNED NOT NULL,
  `age`                   TINYINT UNSIGNED NOT NULL,
  `gender`                ENUM('M','F','OTHER') NOT NULL,
  `date_of_birth`         DATE            NULL DEFAULT NULL,
  `height_cm`             DECIMAL(5,2)    NOT NULL,
  `weight_kg`             DECIMAL(5,2)    NOT NULL,
  `start_weight_kg`       DECIMAL(5,2)    NOT NULL,
  `target_weight_kg`      DECIMAL(5,2)    NULL DEFAULT NULL,
  `fitness_level`         ENUM('BEGINNER','INTERMEDIATE','ADVANCED') NOT NULL,
  `goal`                  ENUM('WEIGHT_LOSS','MUSCLE_GAIN','MAINTENANCE','PERFORMANCE') NOT NULL,
  `health_conditions`     JSON            NOT NULL,
  `allergies`             JSON            NOT NULL,
  `dietary_restrictions`  JSON            NOT NULL,
  `preferred_equipment`   JSON            NOT NULL,
  `available_days_per_week` TINYINT UNSIGNED NOT NULL DEFAULT 3,
  `session_duration_min`  TINYINT UNSIGNED NOT NULL DEFAULT 30,
  `workout_mode`          ENUM('HOME','GYM','HYBRID') NOT NULL DEFAULT 'HOME',
  `budget_per_day_idr`    DECIMAL(12,2)   NOT NULL DEFAULT 50000.00,
  `created_at`            TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`            TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),
  UNIQUE  KEY `health_profiles_user_id_key` (`user_id`),
  CONSTRAINT `fk_health_profiles_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 3. SETTINGS
-- ============================================================
CREATE TABLE IF NOT EXISTS `settings` (
  `id`                    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`               BIGINT UNSIGNED NOT NULL,
  `theme`                 ENUM('LIGHT','DARK','SYSTEM') NOT NULL DEFAULT 'DARK',
  `language`              ENUM('id','en')  NOT NULL DEFAULT 'id',
  `timezone`              VARCHAR(50)      NOT NULL DEFAULT 'Asia/Jakarta',
  `notifications_enabled` TINYINT(1)       NOT NULL DEFAULT 1,
  `daily_reminder_time`   TIME             NULL DEFAULT NULL,
  `workout_reminder_time` TIME             NULL DEFAULT NULL,
  `meal_reminder_time`    TIME             NULL DEFAULT NULL,
  `created_at`            TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`            TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),
  UNIQUE  KEY `settings_user_id_key` (`user_id`),
  CONSTRAINT `fk_settings_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 4. REFRESH_TOKENS
-- ============================================================
CREATE TABLE IF NOT EXISTS `refresh_tokens` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`     BIGINT UNSIGNED NOT NULL,
  `token_hash`  VARCHAR(64)     NOT NULL,   -- SHA256 hex
  `expires_at`  TIMESTAMP       NOT NULL,
  `revoked_at`  TIMESTAMP       NULL DEFAULT NULL,
  `user_agent`  VARCHAR(255)    NULL DEFAULT NULL,
  `created_at`  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),
  UNIQUE  KEY `refresh_tokens_token_hash_key`     (`token_hash`),
  INDEX        `idx_refresh_tokens_user_active`   (`user_id`, `revoked_at`),
  CONSTRAINT `fk_refresh_tokens_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 5. FCM_TOKENS
-- ============================================================
CREATE TABLE IF NOT EXISTS `fcm_tokens` (
  `id`          BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`     BIGINT UNSIGNED  NOT NULL,
  `token`       VARCHAR(255)     NOT NULL,
  `platform`    ENUM('ANDROID','IOS','WEB') NOT NULL,
  `created_at`  TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),
  UNIQUE  KEY `fcm_tokens_token_key`    (`token`),
  INDEX        `idx_fcm_tokens_user`    (`user_id`),
  CONSTRAINT `fk_fcm_tokens_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 6. EXERCISE_MASTER  (library latihan, tidak ada FK ke user)
-- ============================================================
CREATE TABLE IF NOT EXISTS `exercise_master` (
  `id`              BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `slug`            VARCHAR(80)      NOT NULL,
  `name`            VARCHAR(100)     NOT NULL,
  `description`     TEXT             NULL DEFAULT NULL,
  `instructions`    JSON             NULL DEFAULT NULL,
  `muscle_groups`   JSON             NULL DEFAULT NULL,
  `equipment`       JSON             NULL DEFAULT NULL,
  `difficulty`      ENUM('BEGINNER','INTERMEDIATE','ADVANCED') NOT NULL,
  `tips`            JSON             NULL DEFAULT NULL,
  `video_url`       VARCHAR(500)     NULL DEFAULT NULL,
  `image_url`       VARCHAR(500)     NULL DEFAULT NULL,
  `default_sets`    TINYINT UNSIGNED NULL DEFAULT NULL,
  `default_reps`    SMALLINT UNSIGNED NULL DEFAULT NULL,
  `default_rest_sec` SMALLINT UNSIGNED NULL DEFAULT NULL,
  `is_active`       TINYINT(1)       NOT NULL DEFAULT 1,
  `created_at`      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),
  UNIQUE  KEY `exercise_master_slug_key`         (`slug`),
  INDEX        `idx_exercise_master_difficulty`  (`difficulty`, `is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 7. FOOD_MASTER  (library makanan, tidak ada FK ke user)
-- ============================================================
CREATE TABLE IF NOT EXISTS `food_master` (
  `id`                   BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `slug`                 VARCHAR(120)     NOT NULL,
  `name`                 VARCHAR(150)     NOT NULL,
  `category`             ENUM('STAPLE','PROTEIN','VEGETABLE','FRUIT','BEVERAGE','DESSERT','SNACK') NOT NULL,
  `cuisine`              ENUM('INDONESIAN','ASIAN','WESTERN','OTHER') NOT NULL DEFAULT 'INDONESIAN',
  `base_portion`         VARCHAR(50)      NOT NULL,
  `base_portion_gram`    SMALLINT UNSIGNED NOT NULL DEFAULT 100,
  `calories_per_portion` SMALLINT UNSIGNED NOT NULL,
  `protein_g`            DECIMAL(6,2)     NOT NULL,
  `carbs_g`              DECIMAL(6,2)     NOT NULL,
  `fat_g`                DECIMAL(6,2)     NOT NULL,
  `fiber_g`              DECIMAL(6,2)     NOT NULL DEFAULT 0.00,
  `estimated_price_idr`  DECIMAL(12,2)    NOT NULL,
  `is_halal`             TINYINT(1)       NOT NULL DEFAULT 1,
  `is_vegetarian`        TINYINT(1)       NOT NULL DEFAULT 0,
  `is_vegan`             TINYINT(1)       NOT NULL DEFAULT 0,
  `is_gluten_free`       TINYINT(1)       NOT NULL DEFAULT 0,
  `image_url`            VARCHAR(500)     NULL DEFAULT NULL,
  `is_active`            TINYINT(1)       NOT NULL DEFAULT 1,
  `created_at`           TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),
  UNIQUE  KEY `food_master_slug_key`        (`slug`),
  INDEX        `idx_food_master_category`   (`category`, `is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 8. BADGES  (tidak ada FK ke user)
-- ============================================================
CREATE TABLE IF NOT EXISTS `badges` (
  `id`              BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `code`            VARCHAR(50)      NOT NULL,
  `title`           VARCHAR(100)     NOT NULL,
  `description`     VARCHAR(500)     NOT NULL,
  `icon_name`       VARCHAR(50)      NOT NULL,
  `icon_color`      VARCHAR(7)       NULL DEFAULT NULL,
  `category`        ENUM('STREAK','MILESTONE','GOAL','SPECIAL') NOT NULL,
  `criterion_type`  ENUM('STREAK','WORKOUTS_DONE','WEIGHT_LOST','MEALS_LOGGED','CUSTOM') NOT NULL,
  `criterion_value` INT              NOT NULL,
  `order_index`     SMALLINT UNSIGNED NOT NULL,
  `is_active`       TINYINT(1)       NOT NULL DEFAULT 1,
  `created_at`      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),
  UNIQUE  KEY `badges_code_key`          (`code`),
  INDEX        `idx_badges_category`     (`category`, `is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 9. WORKOUT_PLANS
-- ============================================================
CREATE TABLE IF NOT EXISTS `workout_plans` (
  `id`            BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`       BIGINT UNSIGNED  NOT NULL,
  `name`          VARCHAR(100)     NOT NULL,
  `start_date`    DATE             NOT NULL,
  `end_date`      DATE             NOT NULL,
  `status`        ENUM('ACTIVE','COMPLETED','ARCHIVED','SKIPPED') NOT NULL DEFAULT 'ACTIVE',
  `is_active`     TINYINT(1)       NOT NULL DEFAULT 1,
  `generated_by`  ENUM('ML','RULE','MANUAL') NOT NULL DEFAULT 'ML',
  `ml_metadata`   JSON             NULL DEFAULT NULL,
  `created_at`    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),
  INDEX `idx_workout_plans_user_active` (`user_id`, `is_active`),
  INDEX `idx_workout_plans_dates`       (`user_id`, `start_date`, `end_date`),
  CONSTRAINT `fk_workout_plans_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 10. MEAL_PLANS
-- ============================================================
CREATE TABLE IF NOT EXISTS `meal_plans` (
  `id`                      BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`                 BIGINT UNSIGNED  NOT NULL,
  `workout_plan_id`         BIGINT UNSIGNED  NULL DEFAULT NULL,
  `start_date`              DATE             NOT NULL,
  `end_date`                DATE             NOT NULL,
  `status`                  ENUM('ACTIVE','COMPLETED','ARCHIVED','SKIPPED') NOT NULL DEFAULT 'ACTIVE',
  `is_active`               TINYINT(1)       NOT NULL DEFAULT 1,
  `target_calories_per_day` SMALLINT UNSIGNED NOT NULL,
  `target_protein_g`        SMALLINT UNSIGNED NOT NULL,
  `target_carbs_g`          SMALLINT UNSIGNED NOT NULL,
  `target_fat_g`            SMALLINT UNSIGNED NOT NULL,
  `budget_per_day_idr`      DECIMAL(12,2)    NOT NULL,
  `created_at`              TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`              TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),
  INDEX `idx_meal_plans_user_active` (`user_id`, `is_active`),
  INDEX `idx_meal_plans_dates`       (`user_id`, `start_date`, `end_date`),
  CONSTRAINT `fk_meal_plans_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_meal_plans_workout_plan`
    FOREIGN KEY (`workout_plan_id`) REFERENCES `workout_plans` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 11. WORKOUT_DAYS
-- ============================================================
CREATE TABLE IF NOT EXISTS `workout_days` (
  `id`            BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `plan_id`       BIGINT UNSIGNED  NOT NULL,
  `day_number`    TINYINT UNSIGNED NOT NULL,
  `date`          DATE             NOT NULL,
  `workout_type`  ENUM('STRENGTH','CARDIO','HIIT','FLEXIBILITY','REST') NOT NULL,
  `intensity`     ENUM('LOW','MID','HIGH') NULL DEFAULT NULL,
  `name`          VARCHAR(100)     NULL DEFAULT NULL,
  `duration_min`  SMALLINT UNSIGNED NULL DEFAULT NULL,
  `total_sets`    SMALLINT UNSIGNED NULL DEFAULT NULL,
  `is_completed`  TINYINT(1)       NOT NULL DEFAULT 0,
  `completed_at`  TIMESTAMP        NULL DEFAULT NULL,
  `created_at`    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),
  UNIQUE  KEY `uniq_workout_days_plan_day` (`plan_id`, `day_number`),
  INDEX        `idx_workout_days_date`    (`date`),
  CONSTRAINT `fk_workout_days_plan`
    FOREIGN KEY (`plan_id`) REFERENCES `workout_plans` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 12. EXERCISES
-- ============================================================
CREATE TABLE IF NOT EXISTS `exercises` (
  `id`                 BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
  `workout_day_id`     BIGINT UNSIGNED   NOT NULL,
  `master_exercise_id` BIGINT UNSIGNED   NULL DEFAULT NULL,
  `name`               VARCHAR(100)      NOT NULL,
  `category`           ENUM('WARMUP','MAIN','COOLDOWN') NOT NULL,
  `sets`               TINYINT UNSIGNED  NOT NULL,
  `reps`               SMALLINT UNSIGNED NULL DEFAULT NULL,
  `duration_sec`       SMALLINT UNSIGNED NULL DEFAULT NULL,
  `rest_sec`           SMALLINT UNSIGNED NOT NULL DEFAULT 60,
  `tempo`              VARCHAR(20)       NULL DEFAULT NULL,
  `notes`              TEXT              NULL DEFAULT NULL,
  `order_index`        SMALLINT UNSIGNED NOT NULL,
  `created_at`         TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),
  INDEX `idx_exercises_workout_day` (`workout_day_id`, `order_index`),
  CONSTRAINT `fk_exercises_workout_day`
    FOREIGN KEY (`workout_day_id`) REFERENCES `workout_days` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_exercises_master`
    FOREIGN KEY (`master_exercise_id`) REFERENCES `exercise_master` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 13. MEAL_DAYS
-- ============================================================
CREATE TABLE IF NOT EXISTS `meal_days` (
  `id`              BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `plan_id`         BIGINT UNSIGNED  NOT NULL,
  `day_number`      TINYINT UNSIGNED NOT NULL,
  `date`            DATE             NOT NULL,
  `total_calories`  SMALLINT UNSIGNED NULL DEFAULT NULL,
  `total_protein_g` DECIMAL(6,2)     NULL DEFAULT NULL,
  `total_carbs_g`   DECIMAL(6,2)     NULL DEFAULT NULL,
  `total_fat_g`     DECIMAL(6,2)     NULL DEFAULT NULL,
  `total_cost_idr`  DECIMAL(12,2)    NULL DEFAULT NULL,
  `created_at`      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),
  UNIQUE  KEY `uniq_meal_days_plan_day` (`plan_id`, `day_number`),
  INDEX        `idx_meal_days_date`    (`date`),
  CONSTRAINT `fk_meal_days_plan`
    FOREIGN KEY (`plan_id`) REFERENCES `meal_plans` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 14. MEAL_TIMES
-- ============================================================
CREATE TABLE IF NOT EXISTS `meal_times` (
  `id`             BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `meal_day_id`    BIGINT UNSIGNED  NOT NULL,
  `meal_type`      ENUM('BREAKFAST','LUNCH','DINNER','SNACK') NOT NULL,
  `scheduled_time` TIME             NULL DEFAULT NULL,
  `is_logged`      TINYINT(1)       NOT NULL DEFAULT 0,
  `logged_at`      TIMESTAMP        NULL DEFAULT NULL,
  `order_index`    TINYINT UNSIGNED NOT NULL,
  `created_at`     TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),
  INDEX `idx_meal_times_day_type` (`meal_day_id`, `meal_type`),
  CONSTRAINT `fk_meal_times_day`
    FOREIGN KEY (`meal_day_id`) REFERENCES `meal_days` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 15. FOOD_ITEMS
-- ============================================================
CREATE TABLE IF NOT EXISTS `food_items` (
  `id`                  BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
  `meal_time_id`        BIGINT UNSIGNED   NOT NULL,
  `food_master_id`      BIGINT UNSIGNED   NULL DEFAULT NULL,
  `name`                VARCHAR(150)      NOT NULL,
  `portion`             VARCHAR(50)       NOT NULL,
  `portion_gram`        SMALLINT UNSIGNED NULL DEFAULT NULL,
  `calories`            SMALLINT UNSIGNED NOT NULL,
  `protein_g`           DECIMAL(6,2)      NOT NULL DEFAULT 0.00,
  `carbs_g`             DECIMAL(6,2)      NOT NULL DEFAULT 0.00,
  `fat_g`               DECIMAL(6,2)      NOT NULL DEFAULT 0.00,
  `fiber_g`             DECIMAL(6,2)      NOT NULL DEFAULT 0.00,
  `estimated_cost_idr`  DECIMAL(12,2)     NOT NULL DEFAULT 0.00,
  `order_index`         TINYINT UNSIGNED  NOT NULL,
  `created_at`          TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),
  INDEX `idx_food_items_meal_time` (`meal_time_id`, `order_index`),
  CONSTRAINT `fk_food_items_meal_time`
    FOREIGN KEY (`meal_time_id`) REFERENCES `meal_times` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_food_items_master`
    FOREIGN KEY (`food_master_id`) REFERENCES `food_master` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 16. WORKOUT_SESSIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS `workout_sessions` (
  `id`                   BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`              BIGINT UNSIGNED  NOT NULL,
  `workout_day_id`       BIGINT UNSIGNED  NOT NULL,
  `started_at`           TIMESTAMP        NOT NULL,
  `completed_at`         TIMESTAMP        NULL DEFAULT NULL,
  `duration_sec`         INT UNSIGNED     NULL DEFAULT NULL,
  `calories_burned`      SMALLINT UNSIGNED NULL DEFAULT NULL,
  `effort_score`         TINYINT UNSIGNED NULL DEFAULT NULL,
  `mood_before`          ENUM('VERY_BAD','BAD','NEUTRAL','GOOD','VERY_GOOD') NULL DEFAULT NULL,
  `energy_before`        TINYINT UNSIGNED NULL DEFAULT NULL,
  `sleep_band_before`    ENUM('LT5','B5_6','B6_7','B7_8','GT8') NULL DEFAULT NULL,
  `mood_after`           ENUM('VERY_BAD','BAD','NEUTRAL','GOOD','VERY_GOOD') NULL DEFAULT NULL,
  `intensity_multiplier` DECIMAL(4,2)     NULL DEFAULT NULL,
  `status`               ENUM('IN_PROGRESS','COMPLETED','ABANDONED') NOT NULL DEFAULT 'IN_PROGRESS',
  `notes`                TEXT             NULL DEFAULT NULL,
  `created_at`           TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`           TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),
  INDEX `idx_sessions_user_date`    (`user_id`, `started_at`),
  INDEX `idx_sessions_workout_day`  (`workout_day_id`),
  INDEX `idx_sessions_status`       (`status`),
  CONSTRAINT `fk_sessions_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_sessions_workout_day`
    FOREIGN KEY (`workout_day_id`) REFERENCES `workout_days` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 17. EXERCISE_LOGS
-- ============================================================
CREATE TABLE IF NOT EXISTS `exercise_logs` (
  `id`                  BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
  `session_id`          BIGINT UNSIGNED   NOT NULL,
  `exercise_id`         BIGINT UNSIGNED   NOT NULL,
  `set_number`          TINYINT UNSIGNED  NOT NULL,
  `reps_actual`         SMALLINT UNSIGNED NULL DEFAULT NULL,
  `duration_actual_sec` SMALLINT UNSIGNED NULL DEFAULT NULL,
  `weight_kg`           DECIMAL(5,2)      NULL DEFAULT NULL,
  `rest_actual_sec`     SMALLINT UNSIGNED NULL DEFAULT NULL,
  `is_completed`        TINYINT(1)        NOT NULL DEFAULT 0,
  `logged_at`           TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),
  INDEX `idx_exercise_logs_session` (`session_id`, `exercise_id`, `set_number`),
  CONSTRAINT `fk_exercise_logs_session`
    FOREIGN KEY (`session_id`) REFERENCES `workout_sessions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_exercise_logs_exercise`
    FOREIGN KEY (`exercise_id`) REFERENCES `exercises` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 18. MEAL_LOGS
-- ============================================================
CREATE TABLE IF NOT EXISTS `meal_logs` (
  `id`                  BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
  `user_id`             BIGINT UNSIGNED   NOT NULL,
  `meal_time_id`        BIGINT UNSIGNED   NOT NULL,
  `food_item_id`        BIGINT UNSIGNED   NOT NULL,
  `logged_at`           TIMESTAMP         NOT NULL,
  `actual_portion_gram` SMALLINT UNSIGNED NULL DEFAULT NULL,
  `notes`               VARCHAR(500)      NULL DEFAULT NULL,
  `created_at`          TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),
  UNIQUE  KEY `uniq_meal_logs_user_time_food` (`user_id`, `meal_time_id`, `food_item_id`),
  INDEX        `idx_meal_logs_user_date`      (`user_id`, `logged_at`),
  CONSTRAINT `fk_meal_logs_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_meal_logs_meal_time`
    FOREIGN KEY (`meal_time_id`) REFERENCES `meal_times` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_meal_logs_food_item`
    FOREIGN KEY (`food_item_id`) REFERENCES `food_items` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 19. DAILY_LOGS
-- ============================================================
CREATE TABLE IF NOT EXISTS `daily_logs` (
  `id`                  BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
  `user_id`             BIGINT UNSIGNED   NOT NULL,
  `date`                DATE              NOT NULL,
  `workout_completed`   TINYINT(1)        NOT NULL DEFAULT 0,
  `workout_session_id`  BIGINT UNSIGNED   NULL DEFAULT NULL,
  `meals_logged_count`  TINYINT UNSIGNED  NOT NULL DEFAULT 0,
  `meals_total`         TINYINT UNSIGNED  NOT NULL DEFAULT 3,
  `water_glasses`       TINYINT UNSIGNED  NOT NULL DEFAULT 0,
  `water_target`        TINYINT UNSIGNED  NOT NULL DEFAULT 8,
  `mood`                ENUM('VERY_BAD','BAD','NEUTRAL','GOOD','VERY_GOOD') NULL DEFAULT NULL,
  `daily_score`         TINYINT UNSIGNED  NULL DEFAULT NULL,
  `calories_consumed`   SMALLINT UNSIGNED NULL DEFAULT NULL,
  `calories_burned`     SMALLINT UNSIGNED NULL DEFAULT NULL,
  `created_at`          TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`          TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),
  UNIQUE  KEY `uniq_daily_logs_user_date` (`user_id`, `date`),
  CONSTRAINT `fk_daily_logs_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_daily_logs_session`
    FOREIGN KEY (`workout_session_id`) REFERENCES `workout_sessions` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 20. STREAKS
-- ============================================================
CREATE TABLE IF NOT EXISTS `streaks` (
  `id`               BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
  `user_id`          BIGINT UNSIGNED   NOT NULL,
  `current_streak`   SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `best_streak`      SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `last_active_date` DATE              NULL DEFAULT NULL,
  `active_dates`     JSON              NOT NULL,
  `created_at`       TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`       TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),
  UNIQUE  KEY `streaks_user_id_key` (`user_id`),
  CONSTRAINT `fk_streaks_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 21. USER_BADGES
-- ============================================================
CREATE TABLE IF NOT EXISTS `user_badges` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`     BIGINT UNSIGNED NOT NULL,
  `badge_id`    BIGINT UNSIGNED NOT NULL,
  `unlocked_at` TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),
  UNIQUE  KEY `uniq_user_badges_user_badge` (`user_id`, `badge_id`),
  INDEX        `idx_user_badges_badge`      (`badge_id`),
  CONSTRAINT `fk_user_badges_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user_badges_badge`
    FOREIGN KEY (`badge_id`) REFERENCES `badges` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 22. NOTIFICATIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS `notifications` (
  `id`          BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`     BIGINT UNSIGNED  NOT NULL,
  `type`        ENUM('MOTIVATION','WORKOUT_REMINDER','MEAL_REMINDER','STREAK_MILESTONE','BADGE_UNLOCKED','REPLAN_DUE') NOT NULL,
  `title`       VARCHAR(150)     NOT NULL,
  `body`        VARCHAR(500)     NOT NULL,
  `action_url`  VARCHAR(255)     NULL DEFAULT NULL,
  `is_read`     TINYINT(1)       NOT NULL DEFAULT 0,
  `read_at`     TIMESTAMP        NULL DEFAULT NULL,
  `created_at`  TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),
  INDEX `idx_notifications_user_unread` (`user_id`, `is_read`, `created_at`),
  CONSTRAINT `fk_notifications_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 23. SYNC_OPS_LOG
-- ============================================================
CREATE TABLE IF NOT EXISTS `sync_ops_log` (
  `id`               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`          BIGINT UNSIGNED NOT NULL,
  `op_id`            VARCHAR(36)     NOT NULL,   -- UUID v4
  `op_type`          VARCHAR(50)     NOT NULL,
  `status`           ENUM('OK','DUPLICATE','CONFLICT','ERROR') NOT NULL,
  `result_snapshot`  JSON            NULL DEFAULT NULL,
  `created_at`       TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),
  UNIQUE  KEY `uniq_sync_ops_user_op` (`user_id`, `op_id`),
  INDEX        `idx_sync_ops_created`  (`created_at`),
  CONSTRAINT `fk_sync_ops_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 24. WEIGHT_LOGS
--     Tracking berat badan berkala (dipakai oleh replan.py: weight_diff_kg)
-- ============================================================
CREATE TABLE IF NOT EXISTS `weight_logs` (
  `id`          BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`     BIGINT UNSIGNED  NOT NULL,
  `weight_kg`   DECIMAL(5,2)     NOT NULL,
  `bmi`         DECIMAL(5,2)     NULL DEFAULT NULL,
  `note`        VARCHAR(255)     NULL DEFAULT NULL,
  `logged_at`   DATE             NOT NULL,
  `created_at`  TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),
  UNIQUE  KEY `uniq_weight_logs_user_date` (`user_id`, `logged_at`),
  INDEX        `idx_weight_logs_user`      (`user_id`, `logged_at`),
  CONSTRAINT `fk_weight_logs_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 25. FOOD_SCAN_LOGS
--     Riwayat scan makanan via Gemini Vision + nutrition scorer
--     (food_scan_service.py → FoodScanResponse)
-- ============================================================
CREATE TABLE IF NOT EXISTS `food_scan_logs` (
  `id`                   BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`              BIGINT UNSIGNED  NOT NULL,
  `identified_by_gemini` JSON             NULL DEFAULT NULL,
  `matches`              JSON             NOT NULL,
  `calories_total`       DECIMAL(8,2)     NOT NULL DEFAULT 0.00,
  `protein_g_total`      DECIMAL(6,2)     NOT NULL DEFAULT 0.00,
  `fat_g_total`          DECIMAL(6,2)     NOT NULL DEFAULT 0.00,
  `carbs_g_total`        DECIMAL(6,2)     NOT NULL DEFAULT 0.00,
  `health_score`         DECIMAL(5,4)     NOT NULL DEFAULT 0.00,
  `assessment`           ENUM('HEALTHY','MODERATE','UNHEALTHY') NOT NULL DEFAULT 'MODERATE',
  `user_goal`            VARCHAR(30)      NOT NULL DEFAULT 'MAINTENANCE',
  `user_condition`       VARCHAR(50)      NOT NULL DEFAULT 'None',
  `scanned_at`           TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),
  INDEX `idx_food_scan_user` (`user_id`, `scanned_at`),
  CONSTRAINT `fk_food_scan_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 26. WEEKLY_PROGRESS
--     Ringkasan mingguan untuk replan input (replan.py: weekly_score,
--     workout_frequency) dan frontend ProgressModel
-- ============================================================
CREATE TABLE IF NOT EXISTS `weekly_progress` (
  `id`                       BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`                  BIGINT UNSIGNED  NOT NULL,
  `week_start_date`          DATE             NOT NULL,
  `week_end_date`            DATE             NOT NULL,
  `workouts_completed`       TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `workouts_total`           TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `meals_logged`             TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `meals_total`              TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `weekly_compliance_pct`    DECIMAL(5,2)     NOT NULL DEFAULT 0.00,
  `weekly_score`             DECIMAL(5,2)     NOT NULL DEFAULT 0.00,
  `avg_daily_calories`       SMALLINT UNSIGNED NULL DEFAULT NULL,
  `avg_daily_calories_burned` SMALLINT UNSIGNED NULL DEFAULT NULL,
  `weight_start_kg`          DECIMAL(5,2)     NULL DEFAULT NULL,
  `weight_end_kg`            DECIMAL(5,2)     NULL DEFAULT NULL,
  `replan_triggered`         TINYINT(1)       NOT NULL DEFAULT 0,
  `created_at`               TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`               TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),
  UNIQUE  KEY `uniq_weekly_progress_user_week` (`user_id`, `week_start_date`),
  INDEX        `idx_weekly_progress_user`       (`user_id`, `week_start_date`),
  CONSTRAINT `fk_weekly_progress_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- 27. ML_REQUEST_LOGS
--     Audit trail setiap panggilan ke ML service
--     (model_version dari WorkoutPlanResponse & ReplanResponse)
-- ============================================================
CREATE TABLE IF NOT EXISTS `ml_request_logs` (
  `id`              BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`         BIGINT UNSIGNED  NOT NULL,
  `endpoint`        ENUM('WORKOUT','MEAL','REPLAN','FOOD_SCAN','MEAL_ALTERNATIVE') NOT NULL,
  `model_version`   VARCHAR(50)      NULL DEFAULT NULL,
  `request_payload` JSON             NULL DEFAULT NULL,
  `response_summary` JSON            NULL DEFAULT NULL,
  `latency_ms`      INT UNSIGNED     NULL DEFAULT NULL,
  `status`          ENUM('SUCCESS','TIMEOUT','ERROR') NOT NULL DEFAULT 'SUCCESS',
  `error_message`   VARCHAR(500)     NULL DEFAULT NULL,
  `created_at`      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),
  INDEX `idx_ml_logs_user`     (`user_id`, `created_at`),
  INDEX `idx_ml_logs_endpoint` (`endpoint`, `status`),
  CONSTRAINT `fk_ml_logs_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================
-- Aktifkan kembali FK check
-- ============================================================
SET FOREIGN_KEY_CHECKS = 1;


-- ============================================================
-- SEED DATA: Badges default (15 badge)
-- ============================================================
INSERT IGNORE INTO `badges`
  (`code`, `title`, `description`, `icon_name`, `icon_color`, `category`, `criterion_type`, `criterion_value`, `order_index`, `is_active`)
VALUES
  -- Streak badges
  ('streak_3',      'Konsisten 3 Hari',      'Latihan 3 hari berturut-turut',       'local_fire_department', '#FF6B35', 'STREAK',    'STREAK',        3,   1, 1),
  ('streak_7',      'Seminggu Penuh',         'Latihan 7 hari berturut-turut',       'local_fire_department', '#FF4500', 'STREAK',    'STREAK',        7,   2, 1),
  ('streak_14',     'Dua Minggu Kuat',        'Latihan 14 hari berturut-turut',      'local_fire_department', '#DC143C', 'STREAK',    'STREAK',       14,   3, 1),
  ('streak_30',     'Sebulan Disiplin',       'Latihan 30 hari berturut-turut',      'emoji_events',          '#FFD700', 'STREAK',    'STREAK',       30,   4, 1),
  -- Workout milestone badges
  ('workouts_5',    'Pemula Aktif',           'Selesaikan 5 sesi latihan',           'fitness_center',        '#4CAF50', 'MILESTONE', 'WORKOUTS_DONE', 5,   5, 1),
  ('workouts_10',   'Rutin Berolahraga',      'Selesaikan 10 sesi latihan',          'fitness_center',        '#2196F3', 'MILESTONE', 'WORKOUTS_DONE',10,   6, 1),
  ('workouts_25',   'Atlet Sejati',           'Selesaikan 25 sesi latihan',          'military_tech',         '#9C27B0', 'MILESTONE', 'WORKOUTS_DONE',25,   7, 1),
  ('workouts_50',   'Setengah Abad Latihan',  'Selesaikan 50 sesi latihan',          'military_tech',         '#FF9800', 'MILESTONE', 'WORKOUTS_DONE',50,   8, 1),
  ('workouts_100',  'Legenda Kebugaran',      'Selesaikan 100 sesi latihan',         'workspace_premium',     '#FFD700', 'MILESTONE', 'WORKOUTS_DONE',100,  9, 1),
  -- Meal milestone badges
  ('meals_10',      'Makan Sehat Mulai',      'Catat 10 meal',                       'restaurant',            '#8BC34A', 'MILESTONE', 'MEALS_LOGGED',  10, 10, 1),
  ('meals_50',      'Nutrisi Terjaga',        'Catat 50 meal',                       'restaurant',            '#4CAF50', 'MILESTONE', 'MEALS_LOGGED',  50, 11, 1),
  ('meals_100',     'Master Nutrisi',         'Catat 100 meal',                      'local_dining',          '#FFD700', 'MILESTONE', 'MEALS_LOGGED', 100, 12, 1),
  -- Weight goal badges
  ('weight_1kg',    'Awal yang Baik',         'Turunkan berat badan 1 kg',           'trending_down',         '#00BCD4', 'GOAL',      'WEIGHT_LOST',   1,  13, 1),
  ('weight_5kg',    'Pejuang Berat Badan',    'Turunkan berat badan 5 kg',           'trending_down',         '#009688', 'GOAL',      'WEIGHT_LOST',   5,  14, 1),
  ('weight_10kg',   'Transformasi Nyata',     'Turunkan berat badan 10 kg',          'emoji_events',          '#FFD700', 'GOAL',      'WEIGHT_LOST',  10,  15, 1);


-- ============================================================
-- VERIFIKASI: Setelah import, jalankan ini secara terpisah di phpMyAdmin
--   SHOW TABLES;
-- ============================================================

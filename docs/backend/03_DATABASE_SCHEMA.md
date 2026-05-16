> ⚠️ **DEPRECATED — 2026-05-15**
>
> Schema di dokumen ini sudah **tidak akurat** dengan implementasi terkini. Konflik utama:
> - PK pakai UUID string (lama) vs `BIGINT UNSIGNED AUTO_INCREMENT` (baru).
> - `health_profiles.goal` enum: 3 values (LOSE_WEIGHT/MAINTAIN/GAIN_MUSCLE) → sekarang 4 values (WEIGHT_LOSS/MUSCLE_GAIN/MAINTENANCE/PERFORMANCE).
> - Missing tabel: `daily_logs`, `fcm_tokens`, `sync_ops_log`, `streaks`, `notifications`, `settings`.
> - `WorkoutLog` direname jadi `workout_sessions` dengan struktur berbeda.
> - 19+ tabel di skema baru vs 12 tabel di sini.
>
> **Source of truth saat ini:**
> - [`FE_requirement/01_DATABASE_DESIGN.md`](FE_requirement/01_DATABASE_DESIGN.md) — deskripsi lengkap 19 tabel
> - [`FE_requirement/schema.sql`](FE_requirement/schema.sql) — DDL siap-eksekusi MySQL 8.0+
>
> File ini di-keep sebagai sejarah desain awal. **Jangan dipakai untuk implementasi.**

---

# Backend — Database Schema (MySQL via Prisma)

## 1. Diagram ERD (Tekstual)

```
users (1) ──< (1) user_profiles
users (1) ──< (∞) weekly_plans
weekly_plans (1) ──< (∞) workout_days ──< (∞) plan_exercises
weekly_plans (1) ──< (∞) meal_days ──< (∞) plan_meals ──< (∞) plan_meal_foods
plan_meal_foods (∞) ──> (1) food_items
plan_exercises (∞) ──> (1) exercise_items

users (1) ──< (∞) workout_logs
users (1) ──< (∞) workout_checkins  [TTL 90 hari]
users (1) ──< (∞) checklist_entries
users (1) ──< (∞) weight_logs
users (1) ──< (∞) hydration_logs
users (1) ──< (∞) badge_unlocks ──> (1) badges
users (1) ──< (∞) weekly_reports
```

## 2. prisma/schema.prisma Lengkap

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "mysql"
  url      = env("DATABASE_URL")
}

// ============ USERS & AUTH ============

model User {
  id           String   @id @default(uuid())
  email        String   @unique
  passwordHash String   @map("password_hash")
  createdAt    DateTime @default(now()) @map("created_at")
  updatedAt    DateTime @updatedAt @map("updated_at")

  profile           UserProfile?
  plans             WeeklyPlan[]
  workoutLogs       WorkoutLog[]
  workoutCheckins   WorkoutCheckin[]
  checklistEntries  ChecklistEntry[]
  weightLogs        WeightLog[]
  hydrationLogs     HydrationLog[]
  badgeUnlocks      BadgeUnlock[]
  weeklyReports     WeeklyReport[]

  @@map("users")
}

model UserProfile {
  id                 String   @id @default(uuid())
  userId             String   @unique @map("user_id")
  name               String
  age                Int
  gender             Gender
  heightCm           Decimal  @map("height_cm") @db.Decimal(5, 2)
  weightKg           Decimal  @map("weight_kg") @db.Decimal(5, 2)
  waistCm            Decimal? @map("waist_cm") @db.Decimal(5, 2)

  // Computed (dipersist supaya cepat)
  bmi                Decimal  @db.Decimal(4, 2)
  bmr                Int      // kkal/hari
  tdee               Int      // kkal/hari
  bodyFatPct         Decimal? @map("body_fat_pct") @db.Decimal(4, 2)
  bmiCategory        BmiCategory @map("bmi_category")

  // Target & goal
  goal               Goal
  targetWeightKg     Decimal? @map("target_weight_kg") @db.Decimal(5, 2)
  timelineWeeks      Int?     @map("timeline_weeks")
  targetCalorieAdj   Int      @map("target_calorie_adj")  // +/- kkal/hari, signed

  // Workout preferences
  workoutMode        WorkoutMode @map("workout_mode")
  daysPerWeek        Int      @map("days_per_week")
  sessionMinutes     Int      @map("session_minutes")
  preferredTimes     Json     @map("preferred_times")     // ["pagi", "sore"]
  fitnessLevel       FitnessLevel @map("fitness_level")

  // Diet preferences
  budgetPerDay       Int      @map("budget_per_day")      // dalam IDR/MYR utuh
  currency           Currency @default(IDR)
  mealFrequency      Int      @map("meal_frequency")      // 2-4
  dietRestrictions   Json     @map("diet_restrictions")   // ["halal", "vegetarian"]
  conditions         Json                                  // ["injury", "pregnant", ...]

  // Notification preferences
  notifPrefs         Json?    @map("notif_prefs")

  createdAt          DateTime @default(now()) @map("created_at")
  updatedAt          DateTime @updatedAt @map("updated_at")

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@map("user_profiles")
}

enum Gender { MALE FEMALE }
enum BmiCategory { UNDERWEIGHT NORMAL OVERWEIGHT OBESE }
enum Goal { LOSE_WEIGHT MAINTAIN GAIN_MUSCLE }
enum WorkoutMode { HOME GYM }
enum FitnessLevel { BEGINNER INTERMEDIATE ADVANCED }
enum Currency { IDR MYR }

// ============ MASTER DATA ============

model FoodItem {
  id            String   @id @default(uuid())
  name          String
  category      FoodCategory
  caloriesKcal  Int      @map("calories_kcal")
  proteinG      Decimal  @map("protein_g") @db.Decimal(5, 2)
  carbG         Decimal  @map("carb_g") @db.Decimal(5, 2)
  fatG          Decimal  @map("fat_g") @db.Decimal(5, 2)
  fiberG        Decimal? @map("fiber_g") @db.Decimal(5, 2)
  servingGrams  Decimal? @map("serving_grams") @db.Decimal(6, 2)
  servingLabel  String?  @map("serving_label")           // "1 mangkuk", "1 piring"
  estimatedPriceIdr Int  @map("estimated_price_idr")     // estimasi rupiah
  imageUrl      String?  @map("image_url")
  isHalal       Boolean  @default(true) @map("is_halal")
  isVegetarian  Boolean  @default(false) @map("is_vegetarian")
  containsNuts  Boolean  @default(false) @map("contains_nuts")
  containsDairy Boolean  @default(false) @map("contains_dairy")
  source        String   @default("kaggle_indo")          // "kaggle_indo", "usda", "manual"

  planMealFoods PlanMealFood[]

  @@index([category])
  @@map("food_items")
}

enum FoodCategory { STAPLE PROTEIN VEGETABLE FRUIT BEVERAGE SNACK SOUP DESSERT }

model ExerciseItem {
  id              String   @id @default(uuid())
  name            String
  nameId          String?  @map("name_id")               // Bahasa Indonesia
  muscleGroup     MuscleGroup @map("muscle_group")
  equipment       Equipment
  difficulty      Difficulty
  defaultSets     Int      @map("default_sets")
  defaultReps     Int      @map("default_reps")
  restSeconds     Int      @map("rest_seconds")
  caloriesPerMin  Decimal? @map("calories_per_min") @db.Decimal(4, 2)
  instructions    Json                                  // array of strings
  videoUrl        String?  @map("video_url")
  imageUrl        String?  @map("image_url")
  exerciseType    ExerciseType @map("exercise_type")    // strength/cardio/flexibility/hiit

  planExercises   PlanExercise[]

  @@index([muscleGroup, equipment, difficulty])
  @@map("exercise_items")
}

enum MuscleGroup { CHEST BACK SHOULDER ARM LEG CORE FULL_BODY }
enum Equipment { BODYWEIGHT DUMBBELL BARBELL MACHINE BAND }
enum Difficulty { BEGINNER INTERMEDIATE ADVANCED }
enum ExerciseType { STRENGTH CARDIO FLEXIBILITY HIIT }

// ============ PLANS ============

model WeeklyPlan {
  id             String   @id @default(uuid())
  userId         String   @map("user_id")
  weekNumber     Int      @map("week_number")          // 1, 2, 3, ...
  startDate      DateTime @map("start_date")           // Senin minggu tsb
  archivedAt     DateTime? @map("archived_at")
  generatedBy    String   @map("generated_by")         // "initial", "weekly_replan", "manual"
  aiNotes        String?  @map("ai_notes") @db.Text
  scoreLastWeek  Decimal? @map("score_last_week") @db.Decimal(5, 2)
  createdAt      DateTime @default(now()) @map("created_at")

  user        User           @relation(fields: [userId], references: [id], onDelete: Cascade)
  workoutDays WorkoutDay[]
  mealDays    MealDay[]
  reports     WeeklyReport[]

  @@unique([userId, weekNumber])
  @@index([userId, archivedAt])
  @@map("weekly_plans")
}

model WorkoutDay {
  id             String   @id @default(uuid())
  planId         String   @map("plan_id")
  dayIndex       Int      @map("day_index")            // 0..6 (Sen..Min)
  isRestDay      Boolean  @default(false) @map("is_rest_day")
  estimatedMinutes Int    @map("estimated_minutes")
  estimatedCalories Int   @map("estimated_calories")
  notes          String?  @db.Text

  plan      WeeklyPlan      @relation(fields: [planId], references: [id], onDelete: Cascade)
  exercises PlanExercise[]

  @@unique([planId, dayIndex])
  @@map("workout_days")
}

model PlanExercise {
  id             String   @id @default(uuid())
  workoutDayId   String   @map("workout_day_id")
  exerciseItemId String   @map("exercise_item_id")
  orderInDay     Int      @map("order_in_day")
  phase          ExercisePhase                          // WARMUP, MAIN, COOLDOWN
  sets           Int
  reps           Int
  restSeconds    Int      @map("rest_seconds")
  aiTip          String?  @map("ai_tip") @db.Text

  workoutDay   WorkoutDay   @relation(fields: [workoutDayId], references: [id], onDelete: Cascade)
  exerciseItem ExerciseItem @relation(fields: [exerciseItemId], references: [id])

  @@map("plan_exercises")
}

enum ExercisePhase { WARMUP MAIN COOLDOWN }

model MealDay {
  id              String   @id @default(uuid())
  planId          String   @map("plan_id")
  dayIndex        Int      @map("day_index")
  totalCalories   Int      @map("total_calories")
  totalProteinG   Decimal  @map("total_protein_g") @db.Decimal(5, 2)
  totalCarbG      Decimal  @map("total_carb_g") @db.Decimal(5, 2)
  totalFatG       Decimal  @map("total_fat_g") @db.Decimal(5, 2)
  totalCostIdr    Int      @map("total_cost_idr")

  plan  WeeklyPlan @relation(fields: [planId], references: [id], onDelete: Cascade)
  meals PlanMeal[]

  @@unique([planId, dayIndex])
  @@map("meal_days")
}

model PlanMeal {
  id              String   @id @default(uuid())
  mealDayId       String   @map("meal_day_id")
  mealType        MealType @map("meal_type")             // BREAKFAST, LUNCH, DINNER, SNACK
  caloriesKcal    Int      @map("calories_kcal")
  costIdr         Int      @map("cost_idr")
  aiExplanation   String?  @map("ai_explanation") @db.Text

  mealDay MealDay         @relation(fields: [mealDayId], references: [id], onDelete: Cascade)
  foods   PlanMealFood[]

  @@map("plan_meals")
}

enum MealType { BREAKFAST LUNCH DINNER SNACK }

model PlanMealFood {
  id           String   @id @default(uuid())
  planMealId   String   @map("plan_meal_id")
  foodItemId   String   @map("food_item_id")
  servings     Decimal  @db.Decimal(4, 2)               // 1.0, 0.5
  caloriesKcal Int      @map("calories_kcal")           // hasil scale dari foodItem × servings

  planMeal PlanMeal @relation(fields: [planMealId], references: [id], onDelete: Cascade)
  foodItem FoodItem @relation(fields: [foodItemId], references: [id])

  @@map("plan_meal_foods")
}

// ============ LOGS & TRACKING ============

model WorkoutLog {
  id              String   @id @default(uuid())
  userId          String   @map("user_id")
  planId          String?  @map("plan_id")
  dayIndex        Int      @map("day_index")
  startedAt       DateTime @map("started_at")
  completedAt     DateTime @map("completed_at")
  durationSec     Int      @map("duration_sec")
  totalSets       Int      @map("total_sets")
  totalReps       Int      @map("total_reps")
  caloriesEstimate Int     @map("calories_estimate")
  moodAfter       Int?     @map("mood_after")            // 1-5
  syncId          String?  @unique @map("sync_id")       // UUID dari client
  createdAt       DateTime @default(now()) @map("created_at")

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([userId, completedAt])
  @@map("workout_logs")
}

model WorkoutCheckin {
  // Data mood/energy/sleep — TTL 90 hari (cron cleanup)
  id          String   @id @default(uuid())
  userId      String   @map("user_id")
  planId      String?  @map("plan_id")
  dayIndex    Int      @map("day_index")
  mood        Int                                       // 1-5
  energy      Int                                       // 1-5
  sleepBand   String   @map("sleep_band")               // '<5','5-6','6-7','7-8','>8'
  adjustment  Decimal  @db.Decimal(4, 2)               // -0.5..+0.2 (volume multiplier - 1)
  syncId      String?  @unique @map("sync_id")
  createdAt   DateTime @default(now()) @map("created_at")

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([userId, createdAt])
  @@map("workout_checkins")
}

model ChecklistEntry {
  // Per-hari, per-item (workout exercise atau meal)
  id           String   @id @default(uuid())
  userId       String   @map("user_id")
  date         DateTime @db.Date
  itemType     ChecklistItemType @map("item_type")
  itemId       String   @map("item_id")                 // exercise_item_id or plan_meal_id
  completed    Boolean  @default(false)
  syncId       String?  @unique @map("sync_id")
  updatedAt    DateTime @updatedAt @map("updated_at")

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([userId, date, itemType, itemId])
  @@index([userId, date])
  @@map("checklist_entries")
}

enum ChecklistItemType { EXERCISE MEAL }

model WeightLog {
  id        String   @id @default(uuid())
  userId    String   @map("user_id")
  date      DateTime @db.Date
  weightKg  Decimal  @map("weight_kg") @db.Decimal(5, 2)
  note      String?
  syncId    String?  @unique @map("sync_id")
  createdAt DateTime @default(now()) @map("created_at")

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([userId, date])
  @@index([userId, date])
  @@map("weight_logs")
}

model HydrationLog {
  id        String   @id @default(uuid())
  userId    String   @map("user_id")
  date      DateTime @db.Date
  glasses   Int                                       // running counter per day
  syncId    String?  @unique @map("sync_id")
  updatedAt DateTime @updatedAt @map("updated_at")

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([userId, date])
  @@map("hydration_logs")
}

// ============ ACHIEVEMENT ============

model Badge {
  id          String   @id @default(uuid())
  code        String   @unique                         // 'streak_7', 'first_workout', ...
  name        String
  description String   @db.Text
  category    BadgeCategory
  iconUrl     String?  @map("icon_url")
  threshold   Int                                       // value untuk unlock

  unlocks BadgeUnlock[]

  @@map("badges")
}

enum BadgeCategory { CONSISTENCY WORKOUT NUTRITION MILESTONE }

model BadgeUnlock {
  id        String   @id @default(uuid())
  userId    String   @map("user_id")
  badgeId   String   @map("badge_id")
  unlockedAt DateTime @default(now()) @map("unlocked_at")

  user  User  @relation(fields: [userId], references: [id], onDelete: Cascade)
  badge Badge @relation(fields: [badgeId], references: [id])

  @@unique([userId, badgeId])
  @@map("badge_unlocks")
}

// ============ WEEKLY REPORT ============

model WeeklyReport {
  id                      String   @id @default(uuid())
  userId                  String   @map("user_id")
  planId                  String   @map("plan_id")
  weekNumber              Int      @map("week_number")
  workoutDoneCount        Int      @map("workout_done_count")
  workoutTotalCount       Int      @map("workout_total_count")
  mealDoneCount           Int      @map("meal_done_count")
  mealTotalCount          Int      @map("meal_total_count")
  weightChangeKg          Decimal? @map("weight_change_kg") @db.Decimal(4, 2)
  averageCalorieAdherence Decimal? @map("avg_calorie_adherence") @db.Decimal(5, 2)
  averageBudgetPerDay     Int?     @map("avg_budget_per_day")
  mostSkippedExerciseId   String?  @map("most_skipped_exercise_id")
  scorePercent            Decimal  @map("score_percent") @db.Decimal(5, 2)
  aiRecommendation        String?  @map("ai_recommendation") @db.Text
  createdAt               DateTime @default(now()) @map("created_at")

  user User       @relation(fields: [userId], references: [id], onDelete: Cascade)
  plan WeeklyPlan @relation(fields: [planId], references: [id])

  @@unique([userId, weekNumber])
  @@map("weekly_reports")
}
```

## 3. Seed Data

File: `prisma/seed.ts`

Diisi dari:
- `notebook/dataset/Model_Perencana Makan_dan_Nutrisi/nutrition.csv` → tabel `food_items` (1.346 baris)
- `notebook/dataset/Model_rekomendasi_Pelatihan/600K+ Fitness Exercise & Workout Program Dataset/` → tabel `exercise_items` (sample, tidak perlu 600K, ambil ~200 yang relevan untuk home + gym)
- Hardcoded list 20-30 badge code di `seed-data/badges.ts`.

```ts
import { PrismaClient } from '@prisma/client';
import fs from 'fs';
import path from 'path';
import { parse } from 'csv-parse/sync';

const prisma = new PrismaClient();

async function seedFoods() {
  const csvPath = path.resolve(__dirname, '../seed-data/foods.csv');
  const records = parse(fs.readFileSync(csvPath), { columns: true, skip_empty_lines: true });

  for (const row of records) {
    await prisma.foodItem.upsert({
      where: { id: row.id },
      update: {},
      create: {
        id: row.id,
        name: row.name,
        category: mapCategory(row.category),
        caloriesKcal: parseInt(row.calories),
        proteinG: parseFloat(row.protein),
        carbG: parseFloat(row.carbohydrate),
        fatG: parseFloat(row.fat),
        servingLabel: row.serving_label || '1 porsi',
        estimatedPriceIdr: estimatePrice(row.category, row.calories),
        isHalal: true,
        // ... etc
      },
    });
  }
}

async function seedExercises() {/* similar */}
async function seedBadges() {/* hardcoded list */}

async function main() {
  await seedFoods();
  await seedExercises();
  await seedBadges();
  console.log('Seed selesai.');
}

main().finally(() => prisma.$disconnect());
```

Run: `pnpm prisma db seed`.

## 4. Migration Strategy

- **v1 (Day 1):** users + user_profiles (auth + profile minimum)
- **v2 (Day 4):** weekly_plans, workout_days, plan_exercises, meal_days, plan_meals, plan_meal_foods
- **v3 (Day 5):** food_items, exercise_items (master data)
- **v4 (Day 7):** workout_logs, workout_checkins, checklist_entries, weight_logs, hydration_logs
- **v5 (Day 11):** badges, badge_unlocks, weekly_reports

Tiap migration: `pnpm prisma migrate dev --name <description>`.

## 5. Index Strategy

Index sudah dideklarasikan di schema dengan `@@index`:
- `weekly_plans` indexed `[userId, archivedAt]` — query plan aktif user
- `workout_logs` indexed `[userId, completedAt]` — query log per minggu
- `checklist_entries` indexed `[userId, date]` — query checklist per hari
- `food_items` indexed `[category]` — filter saat knapsack
- `exercise_items` indexed `[muscleGroup, equipment, difficulty]` — filter saat ML

## 6. Estimasi Ukuran (Per User Aktif/Bulan)

- 4 plan × ~30 KB = 120 KB
- 30 hari × ~10 checklist entries × 200 byte = 60 KB
- 30 weight logs × 200 byte = 6 KB
- 30 workout logs × 500 byte = 15 KB
- 30 workout checkins × 300 byte = 9 KB

Total ~210 KB/user/bulan. 1000 user = 210 MB/bulan. MySQL single instance cukup hingga ribuan user.

## 7. Cleanup Cron (TTL)

`workout_checkins` dihapus setelah 90 hari. Job di `jobs/ttl-cleanup.job.ts`:

```ts
import cron from 'node-cron';
import { prisma } from '../config/db';

cron.schedule('0 3 * * *', async () => {  // Setiap hari 03:00
  const cutoff = new Date(Date.now() - 90 * 24 * 60 * 60 * 1000);
  await prisma.workoutCheckin.deleteMany({ where: { createdAt: { lt: cutoff } } });
});
```

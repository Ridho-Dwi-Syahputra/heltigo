# Backend — Business Logic

> 📌 **Sync 2026-05-16** — Logic tambahan yang **wajib** ada di backend (di luar list di bawah):
>
> ### Pre-Workout Intensity Adjuster (rule, bukan ML)
>
> Dipanggil saat `POST /workout/:dayId/check-in` (S-19). **Tidak** memanggil ML service — pure rule table di backend.
>
> ```ts
> // backend/services/intensity_adjuster.service.ts
>
> const BASE_TABLE: Record<string, number> = {
>   '1_LT5': -0.50, '1_B5_6': -0.40, '1_B6_7': -0.30, '1_B7_8': -0.25, '1_GT8': -0.20,
>   '2_LT5': -0.35, '2_B5_6': -0.25, '2_B6_7': -0.15, '2_B7_8': -0.10, '2_GT8': -0.05,
>   '3_LT5': -0.20, '3_B5_6': -0.10, '3_B6_7':  0.00, '3_B7_8':  0.00, '3_GT8': +0.05,
>   '4_LT5': -0.10, '4_B5_6':  0.00, '4_B6_7': +0.05, '4_B7_8': +0.10, '4_GT8': +0.15,
>   '5_LT5':  0.00, '5_B5_6': +0.05, '5_B6_7': +0.10, '5_B7_8': +0.15, '5_GT8': +0.20,
> };
>
> const moodModifier = (mood: number) => mood <= 2 ? -0.05 : mood >= 4 ? +0.03 : 0;
>
> export function calculateIntensityMultiplier(
>   mood: number, energy: number, sleepBand: string
> ): number {
>   const base = BASE_TABLE[`${energy}_${sleepBand}`] ?? 0;
>   return Math.max(-0.50, Math.min(0.20, base + moodModifier(mood)));
> }
>
> export function applyMultiplierToExercises(exercises, multiplier: number) {
>   return exercises.map(ex => ({
>     ...ex,
>     sets: Math.round(ex.sets * (1 + multiplier)),
>     reps: ex.reps ? Math.round(ex.reps * (1 + multiplier * 0.5)) : null,
>     restSec: Math.round(ex.restSec * (1 - multiplier)),
>   }));
> }
> ```
>
> Output tips per multiplier range:
> - `≤ -0.30` → "Tubuh butuh recovery, kurangi volume signifikan"
> - `≤ -0.10` → "Energi kurang, ringankan latihan hari ini"
> - `< +0.10` → "Kondisi normal, lanjut sesuai plan"
> - `≥ +0.10` → "Kondisi prima, waktunya push lebih keras"
>
> ### Increment-only Hydration
> - `PATCH /progress/daily/water` cuma terima `newGlassCount > current`.
> - Validasi: `IF newGlassCount <= currentWaterGlasses THEN return 400 INVALID_DECREMENT`.
> - Cron `cron/water_reset.cron.ts` jalan setiap 00:00 lokal user (per timezone) → `UPDATE daily_logs SET water_glasses = 0 WHERE date = CURDATE()`.
>
> ### Weekly Score Formula
> - **Score** = `0.6 * workout_compliance + 0.4 * nutrition_compliance`
>   - `workout_compliance = workouts_done / workouts_planned * 100`
>   - `nutrition_compliance = (meals_logged + water_glasses_avg/8) / total_target * 100`
> - Dihitung saat `GET /progress/weekly` atau di-aggregate via cron mingguan.
>
> ### Streak Calculation Algorithm
> - **Active day** = `daily_logs.workout_completed = TRUE` OR `daily_logs.meals_logged_count >= 2`.
> - Cron harian (`cron/streak_evaluator.cron.ts` jam 00:30):
>   1. Untuk tiap user, cek `last_active_date` dari `streaks` table.
>   2. Jika kemarin = active → `current_streak += 1`. Update `best_streak = max(best_streak, current_streak)`.
>   3. Jika kemarin = inactive → `current_streak = 0`.
>   4. Append today ke `active_dates` JSON (retain last 30 days).
>
> ### Badge Unlock Triggers
> Event-driven, dipanggil saat:
> - `workout_sessions.status` berubah ke `COMPLETED` → cek `WORKOUTS_DONE` badges.
> - `streaks.current_streak` di-update → cek `STREAK_3`, `STREAK_7`, `STREAK_30`, `STREAK_100`.
> - `health_metrics` weight log → cek `WEIGHT_LOST_*` badges.
> - `meal_logs` insert → cek `MEALS_LOGGED_*`.
> - Special: `FIRST_PLAN` saat plan_generate sukses pertama, `COMPLETED_FIRST_WEEK` saat 7/7 hari active.
> - Insert ke `user_badges` (idempotent via UNIQUE(user_id, badge_id)) + push notification.
>
> Source of truth: [`FE_requirement/01_DATABASE_DESIGN.md`](FE_requirement/01_DATABASE_DESIGN.md) §3.16-3.17 + [`schema.sql`](FE_requirement/schema.sql) seed badges.

---

Logic yang **harus jalan di backend** (bukan di ML service maupun mobile):
1. Kalkulasi BMI/BMR/TDEE/BFP saat profile create/update (validasi, simpan ke DB).
2. Penilaian skor kepatuhan mingguan.
3. Cron job replanning Sunday 20:00.
4. Idempotent sync resolver.
5. Badge unlock detection.

Yang **dipindahkan ke ML service** (Python FastAPI):
- Knapsack meal optimization
- Random Forest workout recommendation
- Adaptasi intensitas dari mood/energy

## 1. Health Calculator

File: `src/services/health.service.ts`

### 1.1 BMI

```ts
export function calculateBmi(weightKg: number, heightCm: number): number {
  const heightM = heightCm / 100;
  return Number((weightKg / (heightM * heightM)).toFixed(2));
}

export function bmiCategory(bmi: number): 'UNDERWEIGHT' | 'NORMAL' | 'OVERWEIGHT' | 'OBESE' {
  if (bmi < 18.5) return 'UNDERWEIGHT';
  if (bmi < 25) return 'NORMAL';
  if (bmi < 30) return 'OVERWEIGHT';
  return 'OBESE';
}
```

### 1.2 BMR (Harris-Benedict, revisi 1984)

```ts
export function calculateBmr(
  weightKg: number,
  heightCm: number,
  age: number,
  gender: 'MALE' | 'FEMALE',
): number {
  if (gender === 'MALE') {
    return Math.round(88.362 + 13.397 * weightKg + 4.799 * heightCm - 5.677 * age);
  }
  // FEMALE
  return Math.round(447.593 + 9.247 * weightKg + 3.098 * heightCm - 4.330 * age);
}
```

### 1.3 TDEE (Total Daily Energy Expenditure)

```ts
export function calculateTdee(
  bmr: number,
  daysPerWeek: number,
  fitnessLevel: 'BEGINNER' | 'INTERMEDIATE' | 'ADVANCED',
): number {
  // Activity factor formula
  let factor = 1.2; // sedentary baseline
  if (daysPerWeek <= 2) factor = 1.375;        // lightly active
  else if (daysPerWeek <= 4) factor = 1.55;    // moderately active
  else factor = 1.725;                         // very active

  // Adjust slight for fitness level
  if (fitnessLevel === 'ADVANCED') factor += 0.05;
  if (fitnessLevel === 'BEGINNER') factor -= 0.05;

  return Math.round(bmr * factor);
}
```

### 1.4 Body Fat Percentage (U.S. Navy formula)

```ts
export function calculateBodyFatPct(
  gender: 'MALE' | 'FEMALE',
  heightCm: number,
  waistCm: number,
  hipCm?: number,
  neckCm?: number,
): number | null {
  if (!waistCm) return null;

  // Simplified: kalau hip/neck tidak ada, pakai estimasi
  const neck = neckCm ?? estimateNeck(heightCm, gender);
  const hip = hipCm ?? estimateHip(waistCm, gender);

  if (gender === 'MALE') {
    return Number(
      (495 / (1.0324 - 0.19077 * Math.log10(waistCm - neck) + 0.15456 * Math.log10(heightCm)) - 450).toFixed(2),
    );
  }
  // FEMALE
  return Number(
    (495 / (1.29579 - 0.35004 * Math.log10(waistCm + hip - neck) + 0.22100 * Math.log10(heightCm)) - 450).toFixed(2),
  );
}

function estimateNeck(heightCm: number, gender: 'MALE' | 'FEMALE'): number {
  return gender === 'MALE' ? heightCm * 0.21 : heightCm * 0.20;
}

function estimateHip(waistCm: number, gender: 'MALE' | 'FEMALE'): number {
  return gender === 'MALE' ? waistCm * 1.05 : waistCm * 1.10;
}
```

### 1.5 Berat Ideal (Devine formula)

```ts
export function calculateIdealWeight(
  heightCm: number,
  gender: 'MALE' | 'FEMALE',
): number {
  const heightInches = heightCm / 2.54;
  const above5ft = Math.max(0, heightInches - 60);
  if (gender === 'MALE') {
    return Number((50 + 2.3 * above5ft).toFixed(1));
  }
  return Number((45.5 + 2.3 * above5ft).toFixed(1));
}
```

### 1.6 Target Calorie Adjustment

```ts
export function calculateTargetCalorieAdj(
  currentWeightKg: number,
  targetWeightKg: number | null,
  timelineWeeks: number | null,
  goal: 'LOSE_WEIGHT' | 'MAINTAIN' | 'GAIN_MUSCLE',
): number {
  if (goal === 'MAINTAIN' || !targetWeightKg || !timelineWeeks) return 0;

  // 1 kg = 7700 kkal (estimasi standar)
  const totalKcalDelta = (targetWeightKg - currentWeightKg) * 7700;
  const dailyAdjustment = Math.round(totalKcalDelta / (timelineWeeks * 7));

  // Clamp ke rentang aman -500..+500
  if (dailyAdjustment < -600) return -500;
  if (dailyAdjustment > 600) return 500;
  return dailyAdjustment;
}
```

### 1.7 Profile Compute Helper

```ts
export function computeProfileMetrics(input: {
  weightKg: number;
  heightCm: number;
  age: number;
  gender: 'MALE' | 'FEMALE';
  waistCm?: number;
  daysPerWeek: number;
  fitnessLevel: 'BEGINNER' | 'INTERMEDIATE' | 'ADVANCED';
  goal: 'LOSE_WEIGHT' | 'MAINTAIN' | 'GAIN_MUSCLE';
  targetWeightKg?: number;
  timelineWeeks?: number;
}) {
  const bmi = calculateBmi(input.weightKg, input.heightCm);
  const bmr = calculateBmr(input.weightKg, input.heightCm, input.age, input.gender);
  const tdee = calculateTdee(bmr, input.daysPerWeek, input.fitnessLevel);
  const bodyFatPct = calculateBodyFatPct(input.gender, input.heightCm, input.waistCm ?? 0);
  const idealWeight = calculateIdealWeight(input.heightCm, input.gender);
  const targetCalorieAdj = calculateTargetCalorieAdj(
    input.weightKg,
    input.targetWeightKg ?? null,
    input.timelineWeeks ?? null,
    input.goal,
  );

  return {
    bmi,
    bmiCategory: bmiCategory(bmi),
    bmr,
    tdee,
    bodyFatPct,
    idealWeightKg: idealWeight,
    targetCalorieAdj,
  };
}
```

## 2. Validasi Server-Side untuk Profile

File: `src/services/profile.service.ts`

```ts
export const profileService = {
  async create(userId: string, input: CreateProfileDto) {
    // 1. Validasi business rules
    if (input.age < 10 || input.age > 100) throw new ApiError(400, 'INVALID_AGE');
    if (input.heightCm < 100 || input.heightCm > 250) throw new ApiError(400, 'INVALID_HEIGHT');
    if (input.weightKg < 30 || input.weightKg > 200) throw new ApiError(400, 'INVALID_WEIGHT');
    if (input.targetWeightKg && Math.abs(input.targetWeightKg - input.weightKg) / input.weightKg > 0.3) {
      throw new ApiError(400, 'TARGET_WEIGHT_UNREALISTIC', 'Target berat di luar rentang aman');
    }
    if (input.timelineWeeks && (input.timelineWeeks < 4 || input.timelineWeeks > 52)) {
      throw new ApiError(400, 'INVALID_TIMELINE');
    }

    // 2. Hitung metrics
    const metrics = computeProfileMetrics(input);

    // 3. Persist
    return profileRepo.upsert(userId, {
      ...input,
      ...metrics,
    });
  },
};
```

## 3. Skor Kepatuhan Mingguan

File: `src/services/scoring.service.ts`

```ts
export interface WeeklyScoreInput {
  workoutDoneCount: number;
  workoutTotalCount: number;
  mealDoneCount: number;
  mealTotalCount: number;
}

export function calculateWeeklyScore(input: WeeklyScoreInput): {
  workoutScore: number;
  nutritionScore: number;
  overallScore: number;
} {
  const workoutScore = input.workoutTotalCount > 0
    ? Math.round((input.workoutDoneCount / input.workoutTotalCount) * 100)
    : 0;
  const nutritionScore = input.mealTotalCount > 0
    ? Math.round((input.mealDoneCount / input.mealTotalCount) * 100)
    : 0;
  // Bobot: workout 60%, nutrition 40% (kebugaran sedikit lebih penting)
  const overallScore = Math.round(workoutScore * 0.6 + nutritionScore * 0.4);
  return { workoutScore, nutritionScore, overallScore };
}

export function scoreCategory(overallScore: number): 'LOW' | 'MID' | 'HIGH' {
  if (overallScore < 50) return 'LOW';
  if (overallScore <= 80) return 'MID';
  return 'HIGH';
}
```

## 4. Replanning Service (Cron Sunday 20:00)

File: `src/services/replanning.service.ts`

```ts
import { logger } from '../utils/logger';
import { planRepo } from '../repositories/plan.repo';
import { checklistRepo } from '../repositories/checklist.repo';
import { weightLogRepo } from '../repositories/weight-log.repo';
import { profileRepo } from '../repositories/profile.repo';
import { reportRepo } from '../repositories/weekly-report.repo';
import { replanMl } from '../ml-client/replan.ml';
import { calculateWeeklyScore } from './scoring.service';

export const replanningService = {
  async runForUser(userId: string) {
    const profile = await profileRepo.findByUserId(userId);
    if (!profile) return;

    const activePlan = await planRepo.findActive(userId);
    if (!activePlan) return;

    // 1. Hitung skor minggu lalu
    const checklist = await checklistRepo.summarizeForPlan(activePlan.id);
    const score = calculateWeeklyScore({
      workoutDoneCount: checklist.workoutDone,
      workoutTotalCount: checklist.workoutTotal,
      mealDoneCount: checklist.mealDone,
      mealTotalCount: checklist.mealTotal,
    });

    // 2. Hitung tren berat
    const weightHistory = await weightLogRepo.getHistory(userId, 14); // 2 minggu
    const weightChangeKg = weightHistory.length >= 2
      ? Number(weightHistory[0].weightKg) - Number(weightHistory[weightHistory.length - 1].weightKg)
      : 0;

    // 3. Latihan paling sering diskip
    const mostSkipped = await checklistRepo.mostSkippedExercises(activePlan.id, 3);

    // 4. Panggil ML
    let mlResp;
    try {
      mlResp = await replanMl.infer({
        previous_plan: {
          week_number: activePlan.weekNumber,
          workout_days: activePlan.workoutDays,
          meal_days: activePlan.mealDays,
        },
        score_percent: score.overallScore,
        workout_done_count: checklist.workoutDone,
        workout_total_count: checklist.workoutTotal,
        meal_done_count: checklist.mealDone,
        meal_total_count: checklist.mealTotal,
        weight_change_kg: weightChangeKg,
        weight_target_change_kg: -0.5, // dari profile target
        most_skipped_exercise_ids: mostSkipped.map((s) => s.exerciseItemId),
        profile,
      });
    } catch (e) {
      logger.error({ userId, err: e }, 'Replan ML failed, skipping this user');
      return;
    }

    // 5. Archive plan lama, insert baru, dan WeeklyReport
    await planRepo.transaction(async (tx) => {
      await tx.weeklyPlan.update({
        where: { id: activePlan.id },
        data: { archivedAt: new Date(), scoreLastWeek: score.overallScore },
      });

      const newPlan = await planRepo.createInTx(tx, {
        userId,
        weekNumber: activePlan.weekNumber + 1,
        generatedBy: 'weekly_replan',
        aiNotes: mlResp.ai_notes,
        scoreLastWeek: score.overallScore,
        workoutDays: mlResp.workout_days,
        mealDays: mlResp.meal_days,
      });

      await reportRepo.upsertInTx(tx, {
        userId,
        planId: activePlan.id,
        weekNumber: activePlan.weekNumber,
        workoutDoneCount: checklist.workoutDone,
        workoutTotalCount: checklist.workoutTotal,
        mealDoneCount: checklist.mealDone,
        mealTotalCount: checklist.mealTotal,
        weightChangeKg,
        scorePercent: score.overallScore,
        mostSkippedExerciseId: mostSkipped[0]?.exerciseItemId ?? null,
        aiRecommendation: mlResp.ai_recommendation,
      });

      return newPlan;
    });

    logger.info({ userId, scoreLastWeek: score.overallScore }, 'Replanning completed');
  },

  async runForAllActiveUsers() {
    const users = await planRepo.findUsersWithActivePlan();
    logger.info({ count: users.length }, 'Starting weekly replanning');
    for (const user of users) {
      try {
        await this.runForUser(user.id);
      } catch (e) {
        logger.error({ userId: user.id, err: e }, 'Replanning failed for user');
      }
    }
    logger.info('Weekly replanning completed for all users');
  },
};
```

## 5. Cron Setup

File: `src/jobs/cron.ts`

```ts
import cron from 'node-cron';
import { replanningService } from '../services/replanning.service';
import { ttlCleanupJob } from './ttl-cleanup.job';
import { logger } from '../utils/logger';

export function startCronJobs() {
  // Weekly replanning: Setiap Minggu jam 20:00 WIB
  // node-cron format: 'minute hour day-of-month month day-of-week'
  // 0 = Sunday
  cron.schedule('0 20 * * 0', async () => {
    logger.info('🕐 Cron: Weekly replanning started');
    try {
      await replanningService.runForAllActiveUsers();
    } catch (e) {
      logger.error({ err: e }, 'Cron weekly replanning crashed');
    }
  }, { timezone: 'Asia/Jakarta' });

  // TTL cleanup: setiap hari jam 03:00
  cron.schedule('0 3 * * *', async () => {
    logger.info('🕐 Cron: TTL cleanup started');
    try {
      await ttlCleanupJob();
    } catch (e) {
      logger.error({ err: e }, 'Cron TTL cleanup crashed');
    }
  }, { timezone: 'Asia/Jakarta' });

  logger.info('✅ Cron jobs registered');
}
```

## 6. Sync Resolver (Idempotent Batch Upload)

File: `src/services/sync.service.ts`

```ts
import { logger } from '../utils/logger';
import { workoutService } from './workout.service';
import { nutritionService } from './nutrition.service';
import { progressService } from './progress.service';

type SyncItemType =
  | 'workout_checklist'
  | 'meal_checklist'
  | 'workout_log'
  | 'workout_mood_after'
  | 'weight_log'
  | 'hydration_log';

interface SyncItem {
  id: string;        // UUID v4 client-generated
  type: SyncItemType;
  payload: Record<string, any>;
  created_at: string;
}

interface SyncResult {
  id: string;
  status: 'ok' | 'duplicate' | 'invalid' | 'retry';
  error_code?: string;
}

export const syncService = {
  async batch(userId: string, items: SyncItem[]): Promise<SyncResult[]> {
    const results: SyncResult[] = [];
    for (const item of items) {
      try {
        const status = await this._processOne(userId, item);
        results.push({ id: item.id, status });
      } catch (e: any) {
        logger.warn({ userId, itemId: item.id, type: item.type, err: e }, 'Sync item failed');
        results.push({ id: item.id, status: 'retry', error_code: e.code });
      }
    }
    return results;
  },

  async _processOne(userId: string, item: SyncItem): Promise<'ok' | 'duplicate' | 'invalid'> {
    switch (item.type) {
      case 'workout_checklist':
        return workoutService.toggleChecklist(userId, { ...item.payload, sync_id: item.id });
      case 'meal_checklist':
        return nutritionService.toggleChecklist(userId, { ...item.payload, sync_id: item.id });
      case 'workout_log':
        return workoutService.recordLog(userId, { ...item.payload, sync_id: item.id });
      case 'workout_mood_after':
        return workoutService.setMoodAfter(userId, item.payload);
      case 'weight_log':
        return progressService.addWeight(userId, { ...item.payload, sync_id: item.id });
      case 'hydration_log':
        return nutritionService.upsertHydration(userId, { ...item.payload, sync_id: item.id });
      default:
        return 'invalid';
    }
  },
};
```

Setiap service yang menerima `sync_id`:
```ts
async addWeight(userId: string, input: { date: string; weight_kg: number; sync_id: string }) {
  // Cek duplikat
  const existing = await weightLogRepo.findBySyncId(input.sync_id);
  if (existing) return 'duplicate' as const;

  // Insert
  await weightLogRepo.create({ userId, ...input });
  return 'ok' as const;
}
```

## 7. Badge Unlock Detection

File: `src/services/badge.service.ts`

Dipanggil setelah workout log atau meal checklist.

```ts
export const badgeService = {
  async checkUnlocksAfterWorkoutLog(userId: string) {
    const newlyUnlocked: BadgeUnlock[] = [];
    const stats = await this._getUserStats(userId);

    // 1. First workout
    if (stats.totalWorkouts === 1) {
      newlyUnlocked.push(await this._unlockIfNotYet(userId, 'first_workout'));
    }
    // 2. 10 workouts
    if (stats.totalWorkouts === 10) {
      newlyUnlocked.push(await this._unlockIfNotYet(userId, 'ten_workouts'));
    }
    // 3. 50 workouts
    if (stats.totalWorkouts === 50) {
      newlyUnlocked.push(await this._unlockIfNotYet(userId, 'fifty_workouts'));
    }
    // 4. Streak 3, 7, 30
    for (const t of [3, 7, 30]) {
      if (stats.currentStreak === t) {
        newlyUnlocked.push(await this._unlockIfNotYet(userId, `streak_${t}`));
      }
    }
    // 5. Pagi person: 5 workouts in 05:00-08:00
    // ...

    return newlyUnlocked.filter(Boolean);
  },

  async _unlockIfNotYet(userId: string, badgeCode: string) {
    const existing = await badgeRepo.findUnlock(userId, badgeCode);
    if (existing) return null;
    return badgeRepo.unlock(userId, badgeCode);
  },

  async _getUserStats(userId: string) {
    // Aggregate query
    return {
      totalWorkouts: await workoutLogRepo.countByUser(userId),
      currentStreak: await this._calculateStreak(userId),
    };
  },

  async _calculateStreak(userId: string): Promise<number> {
    // Logic: count berapa hari berturut-turut user punya minimal 1 workout completed
    // SELECT date FROM workout_logs WHERE user_id = ? GROUP BY date ORDER BY date DESC
    // Iterate dan hitung consecutive days dari hari ini ke belakang.
    // ...
    return 0; // implement properly
  },
};
```

Daftar badge codes (di `prisma/seed-data/badges.ts`):
```ts
export const BADGES = [
  { code: 'first_workout', name: 'Latihan Pertama', category: 'WORKOUT', threshold: 1 },
  { code: 'ten_workouts', name: '10 Latihan', category: 'WORKOUT', threshold: 10 },
  { code: 'fifty_workouts', name: '50 Latihan', category: 'WORKOUT', threshold: 50 },
  { code: 'streak_3', name: 'Streak 3 Hari', category: 'CONSISTENCY', threshold: 3 },
  { code: 'streak_7', name: 'Streak 7 Hari', category: 'CONSISTENCY', threshold: 7 },
  { code: 'streak_30', name: 'Streak 30 Hari', category: 'CONSISTENCY', threshold: 30 },
  { code: 'meal_7d', name: 'Makan Sesuai 7 Hari', category: 'NUTRITION', threshold: 7 },
  { code: 'first_target', name: 'Target Pertama Tercapai', category: 'MILESTONE', threshold: 1 },
  { code: 'morning_5', name: 'Latihan Pagi 5x', category: 'CONSISTENCY', threshold: 5 },
  // ... bisa ditambah pasca-hackathon
];
```

## 8. Test Wajib

- `health.service.test.ts` — semua formula dengan 5+ profile berbeda. Hasil harus akurat ke 0.01.
- `scoring.service.test.ts` — edge case: 0/0, 100%, 50%, dll.
- `sync.service.test.ts` — duplicate detection.

## 9. Catatan: Apa yang BUKAN Business Logic Backend

- **Knapsack meal optimization** → ML service (perlu numpy, scipy)
- **Random Forest workout recommend** → ML service (joblib)
- **Adaptasi mood/energy/sleep ke volume workout** → ML service
- **Greeting Pagi/Siang/Sore/Malam** → mobile (locale device)
- **Animasi bounce di S-14 button** → mobile
- **Validasi format email** → mobile + backend (defense in depth)

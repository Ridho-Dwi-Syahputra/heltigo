/**
 * Plan Service
 * ────────────
 * Orchestrates plan generation:
 *  1. Read user's HealthProfile from DB
 *  2. Compute BMI/BMR/TDEE
 *  3. Build ML payloads → call workout-plan + meal-plan in parallel
 *  4. Persist WorkoutPlan + WorkoutDay + Exercise + MealPlan + MealDay + MealTime + FoodItem
 *  5. Mark previous active plans as ARCHIVED
 *  6. Return persisted plan with DB IDs
 */
import { Prisma } from '@prisma/client';
import { prisma } from '../config/db';
import { ApiError } from '../utils/api-error';
import { MlService } from './ml.service';
import { healthService } from './health.service';
import { logger } from '../utils/logger';

function toBig(id: string) {
  return BigInt(id);
}

function addDays(date: Date, days: number) {
  const d = new Date(date);
  d.setDate(d.getDate() + days);
  d.setHours(0, 0, 0, 0);
  return d;
}

function inferWorkoutType(t: string): string {
  const x = (t || '').toUpperCase();
  if (['STRENGTH', 'CARDIO', 'HIIT', 'FLEXIBILITY', 'REST'].includes(x)) return x;
  if (x.includes('REST')) return 'REST';
  if (x.includes('HIIT')) return 'HIIT';
  if (x.includes('CARDIO')) return 'CARDIO';
  if (x.includes('FLEX')) return 'FLEXIBILITY';
  return 'STRENGTH';
}

function inferIntensity(i?: string | null): 'LOW' | 'MID' | 'HIGH' | null {
  if (!i) return null;
  const x = i.toUpperCase();
  if (x.includes('HIGH')) return 'HIGH';
  if (x.includes('MID') || x.includes('MED')) return 'MID';
  if (x.includes('LOW')) return 'LOW';
  return null;
}

function inferExerciseCategory(phase?: string): 'WARMUP' | 'MAIN' | 'COOLDOWN' {
  const x = (phase || '').toUpperCase();
  if (x.includes('WARM')) return 'WARMUP';
  if (x.includes('COOL') || x.includes('STRETCH')) return 'COOLDOWN';
  return 'MAIN';
}

function inferMealType(mt: string): 'BREAKFAST' | 'LUNCH' | 'DINNER' | 'SNACK' {
  const x = (mt || '').toUpperCase();
  if (x.includes('BREAK')) return 'BREAKFAST';
  if (x.includes('LUNCH')) return 'LUNCH';
  if (x.includes('DIN')) return 'DINNER';
  return 'SNACK';
}

function inferFoodCategory(c?: string): 'STAPLE' | 'PROTEIN' | 'VEGETABLE' | 'FRUIT' | 'BEVERAGE' | 'DESSERT' | 'SNACK' {
  const x = (c || '').toUpperCase();
  const allowed = ['STAPLE', 'PROTEIN', 'VEGETABLE', 'FRUIT', 'BEVERAGE', 'DESSERT', 'SNACK'];
  return (allowed.find((a) => x.includes(a)) as any) || 'STAPLE';
}

function genderToMl(g: string): 'MALE' | 'FEMALE' {
  return g === 'F' ? 'FEMALE' : 'MALE';
}

function calorieAdjForGoal(goal: string): number {
  if (goal === 'WEIGHT_LOSS') return -500;
  if (goal === 'MUSCLE_GAIN') return 300;
  return 0;
}

export const planService = {
  async generate(userId: string, override?: { workoutOnly?: boolean; mealOnly?: boolean }) {
    const profile = await prisma.healthProfile.findUnique({ where: { userId: toBig(userId) } });
    if (!profile) {
      throw new ApiError(
        400,
        'PROFILE_REQUIRED',
        'Buat health profile dulu sebelum generate plan',
      );
    }

    const weightKg = Number(profile.weightKg);
    const heightCm = Number(profile.heightCm);
    const bmi = healthService.calculateBMI(weightKg, heightCm);
    const bmr = healthService.calculateBMR(weightKg, heightCm, profile.age, profile.gender as any);
    const tdee = Math.round(healthService.calculateTDEE(bmr, profile.fitnessLevel));

    const workoutPayload = {
      fitness_level: profile.fitnessLevel,
      goal: profile.goal,
      bmi: Number(bmi.toFixed(2)),
      age: profile.age,
      gender: genderToMl(profile.gender),
      workout_mode: profile.workoutMode,
      days_per_week: profile.availableDaysPerWeek,
      session_minutes: profile.sessionDurationMin,
      has_injury: (profile.healthConditions as any[])?.some((c: string) =>
        /injury|cidera/i.test(c),
      ) ?? false,
      has_chronic: (profile.healthConditions as any[])?.length > 0,
      conditions: (profile.healthConditions as string[]) ?? [],
    };

    const mealPayload = {
      tdee,
      target_calorie_adj: calorieAdjForGoal(profile.goal),
      budget_per_day_idr: Number(profile.budgetPerDayIdr),
      meal_frequency: 3,
      goal: profile.goal,
      dietary_restrictions: (profile.dietaryRestrictions as string[]) ?? [],
      excluded_food_ids: [],
      user_condition: ((profile.healthConditions as string[]) ?? []).join(',') || 'None',
    };

    const [workoutRes, mealRes] = await Promise.all([
      override?.mealOnly
        ? Promise.resolve(null)
        : MlService.predictWorkoutPlan(workoutPayload).catch((e) => {
            logger.error({ err: e?.message }, 'ML workout-plan failed');
            return null;
          }),
      override?.workoutOnly
        ? Promise.resolve(null)
        : MlService.predictMealPlan(mealPayload).catch((e) => {
            logger.error({ err: e?.message }, 'ML meal-plan failed');
            return null;
          }),
    ]);

    if (!workoutRes && !mealRes) {
      throw new ApiError(502, 'ML_UNAVAILABLE', 'ML service tidak dapat menghasilkan plan saat ini');
    }

    const startDate = new Date();
    startDate.setHours(0, 0, 0, 0);
    const planDays = Math.max(
      (workoutRes as any)?.days?.length ?? 0,
      (mealRes as any)?.days?.length ?? 0,
      7,
    );
    const endDate = addDays(startDate, planDays - 1);

    // Persist dalam 1 transaksi
    const result = await prisma.$transaction(
      async (tx) => {
        // Archive plan aktif sebelumnya
        await tx.workoutPlan.updateMany({
          where: { userId: toBig(userId), isActive: true },
          data: { isActive: false, status: 'ARCHIVED' },
        });
        await tx.mealPlan.updateMany({
          where: { userId: toBig(userId), isActive: true },
          data: { isActive: false, status: 'ARCHIVED' },
        });

        let workoutPlan: any = null;
        if (workoutRes) {
          workoutPlan = await tx.workoutPlan.create({
            data: {
              userId: toBig(userId),
              name: `Program ${profile.goal} ${planDays} hari`,
              startDate,
              endDate,
              status: 'ACTIVE',
              isActive: true,
              generatedBy: 'ML',
              mlMetadata: { model_version: (workoutRes as any).model_version },
            },
          });

          for (const day of (workoutRes as any).days ?? []) {
            const dayNum = (day.day_index ?? 0) + 1;
            const created = await tx.workoutDay.create({
              data: {
                planId: workoutPlan.id,
                dayNumber: dayNum,
                date: addDays(startDate, dayNum - 1),
                workoutType: inferWorkoutType(day.workout_type) as any,
                intensity: inferIntensity(day.intensity) as any,
                name: day.is_rest_day ? 'Rest Day' : `Day ${dayNum}`,
                durationMin: day.estimated_minutes ?? null,
                totalSets: (day.exercises ?? []).reduce(
                  (acc: number, e: any) => acc + (e.sets ?? 0),
                  0,
                ),
              },
            });

            for (let i = 0; i < (day.exercises ?? []).length; i++) {
              const ex = day.exercises[i];
              await tx.exercise.create({
                data: {
                  workoutDayId: created.id,
                  name: ex.name ?? `Exercise ${i + 1}`,
                  category: inferExerciseCategory(ex.phase) as any,
                  sets: ex.sets ?? 3,
                  reps: ex.reps ?? null,
                  restSec: ex.rest_seconds ?? 60,
                  orderIndex: i,
                },
              });
            }
          }
        }

        let mealPlan: any = null;
        if (mealRes) {
          const firstDay = (mealRes as any).days?.[0];
          mealPlan = await tx.mealPlan.create({
            data: {
              userId: toBig(userId),
              workoutPlanId: workoutPlan?.id ?? null,
              startDate,
              endDate,
              status: 'ACTIVE',
              isActive: true,
              targetCaloriesPerDay: Math.round(
                firstDay?.total_calories ?? tdee + calorieAdjForGoal(profile.goal),
              ),
              targetProteinG: Math.round(firstDay?.total_protein_g ?? 90),
              targetCarbsG: Math.round(firstDay?.total_carbs_g ?? 250),
              targetFatG: Math.round(firstDay?.total_fat_g ?? 60),
              budgetPerDayIdr: new Prisma.Decimal(Number(profile.budgetPerDayIdr)),
            },
          });

          for (const day of (mealRes as any).days ?? []) {
            const dayNum = (day.day_index ?? 0) + 1;
            const mealDay = await tx.mealDay.create({
              data: {
                planId: mealPlan.id,
                dayNumber: dayNum,
                date: addDays(startDate, dayNum - 1),
                totalCalories: Math.round(day.total_calories ?? 0),
                totalProteinG: new Prisma.Decimal(day.total_protein_g ?? 0),
                totalCarbsG: new Prisma.Decimal(day.total_carbs_g ?? 0),
                totalFatG: new Prisma.Decimal(day.total_fat_g ?? 0),
                totalCostIdr: new Prisma.Decimal(day.total_cost_idr ?? 0),
              },
            });

            for (let mIdx = 0; mIdx < (day.meals ?? []).length; mIdx++) {
              const meal = day.meals[mIdx];
              const mealTime = await tx.mealTime.create({
                data: {
                  mealDayId: mealDay.id,
                  mealType: inferMealType(meal.meal_type),
                  orderIndex: mIdx,
                },
              });

              for (let fIdx = 0; fIdx < (meal.foods ?? []).length; fIdx++) {
                const f = meal.foods[fIdx];
                await tx.foodItem.create({
                  data: {
                    mealTimeId: mealTime.id,
                    name: f.name ?? `Food ${fIdx + 1}`,
                    portion: '1 porsi',
                    calories: Math.round(f.calories ?? 0),
                    proteinG: new Prisma.Decimal(f.protein_g ?? 0),
                    carbsG: new Prisma.Decimal(f.carbs_g ?? 0),
                    fatG: new Prisma.Decimal(f.fat_g ?? 0),
                    estimatedCostIdr: new Prisma.Decimal(f.price_idr ?? 0),
                    orderIndex: fIdx,
                  },
                });
              }
            }
          }
        }

        return { workoutPlanId: workoutPlan?.id, mealPlanId: mealPlan?.id };
      },
      { timeout: 30_000 },
    );

    return this.getActiveById(userId, result.workoutPlanId, result.mealPlanId);
  },

  async getActive(userId: string) {
    const workoutPlan = await prisma.workoutPlan.findFirst({
      where: { userId: toBig(userId), isActive: true },
      include: { workoutDays: { include: { exercises: true }, orderBy: { dayNumber: 'asc' } } },
    });
    const mealPlan = await prisma.mealPlan.findFirst({
      where: { userId: toBig(userId), isActive: true },
      include: {
        mealDays: {
          include: { mealTimes: { include: { foodItems: true }, orderBy: { orderIndex: 'asc' } } },
          orderBy: { dayNumber: 'asc' },
        },
      },
    });
    return {
      workoutPlan: workoutPlan ? this._serializeWorkoutPlan(workoutPlan) : null,
      mealPlan: mealPlan ? this._serializeMealPlan(mealPlan) : null,
    };
  },

  async getActiveById(userId: string, workoutPlanId?: bigint, mealPlanId?: bigint) {
    const workoutPlan = workoutPlanId
      ? await prisma.workoutPlan.findUnique({
          where: { id: workoutPlanId },
          include: { workoutDays: { include: { exercises: true }, orderBy: { dayNumber: 'asc' } } },
        })
      : null;
    const mealPlan = mealPlanId
      ? await prisma.mealPlan.findUnique({
          where: { id: mealPlanId },
          include: {
            mealDays: {
              include: {
                mealTimes: { include: { foodItems: true }, orderBy: { orderIndex: 'asc' } },
              },
              orderBy: { dayNumber: 'asc' },
            },
          },
        })
      : await prisma.mealPlan.findFirst({
          where: { userId: toBig(userId), isActive: true },
          include: {
            mealDays: {
              include: {
                mealTimes: { include: { foodItems: true }, orderBy: { orderIndex: 'asc' } },
              },
              orderBy: { dayNumber: 'asc' },
            },
          },
        });
    return {
      workoutPlan: workoutPlan ? this._serializeWorkoutPlan(workoutPlan) : null,
      mealPlan: mealPlan ? this._serializeMealPlan(mealPlan) : null,
    };
  },

  async getHistory(userId: string) {
    const workoutPlans = await prisma.workoutPlan.findMany({
      where: { userId: toBig(userId) },
      orderBy: { startDate: 'desc' },
      take: 20,
    });
    return {
      plans: workoutPlans.map((p) => ({
        id: p.id.toString(),
        name: p.name,
        startDate: p.startDate,
        endDate: p.endDate,
        status: p.status,
        isActive: p.isActive,
      })),
    };
  },

  async getById(userId: string, planId: string) {
    const plan = await prisma.workoutPlan.findUnique({
      where: { id: toBig(planId) },
      include: {
        workoutDays: { include: { exercises: true }, orderBy: { dayNumber: 'asc' } },
        mealPlans: {
          include: {
            mealDays: {
              include: {
                mealTimes: { include: { foodItems: true }, orderBy: { orderIndex: 'asc' } },
              },
              orderBy: { dayNumber: 'asc' },
            },
          },
        },
      },
    });
    if (!plan || plan.userId !== toBig(userId)) {
      throw new ApiError(404, 'PLAN_NOT_FOUND', 'Plan tidak ditemukan');
    }
    return {
      workoutPlan: this._serializeWorkoutPlan(plan),
      mealPlan: plan.mealPlans[0] ? this._serializeMealPlan(plan.mealPlans[0]) : null,
    };
  },

  _serializeWorkoutPlan(p: any) {
    return {
      id: p.id.toString(),
      name: p.name,
      startDate: p.startDate,
      endDate: p.endDate,
      status: p.status,
      isActive: p.isActive,
      generatedBy: p.generatedBy,
      mlMetadata: p.mlMetadata,
      days: (p.workoutDays ?? []).map((d: any) => ({
        id: d.id.toString(),
        dayNumber: d.dayNumber,
        date: d.date,
        workoutType: d.workoutType,
        intensity: d.intensity,
        name: d.name,
        durationMin: d.durationMin,
        totalSets: d.totalSets,
        isCompleted: d.isCompleted,
        completedAt: d.completedAt,
        exercises: (d.exercises ?? []).map((e: any) => ({
          id: e.id.toString(),
          name: e.name,
          category: e.category,
          sets: e.sets,
          reps: e.reps,
          durationSec: e.durationSec,
          restSec: e.restSec,
          orderIndex: e.orderIndex,
        })),
      })),
    };
  },

  _serializeMealPlan(p: any) {
    return {
      id: p.id.toString(),
      startDate: p.startDate,
      endDate: p.endDate,
      status: p.status,
      isActive: p.isActive,
      targetCaloriesPerDay: p.targetCaloriesPerDay,
      targetProteinG: p.targetProteinG,
      targetCarbsG: p.targetCarbsG,
      targetFatG: p.targetFatG,
      budgetPerDayIdr: Number(p.budgetPerDayIdr),
      days: (p.mealDays ?? []).map((d: any) => ({
        id: d.id.toString(),
        dayNumber: d.dayNumber,
        date: d.date,
        totalCalories: d.totalCalories,
        totalProteinG: d.totalProteinG ? Number(d.totalProteinG) : 0,
        totalCarbsG: d.totalCarbsG ? Number(d.totalCarbsG) : 0,
        totalFatG: d.totalFatG ? Number(d.totalFatG) : 0,
        totalCostIdr: d.totalCostIdr ? Number(d.totalCostIdr) : 0,
        meals: (d.mealTimes ?? []).map((m: any) => ({
          id: m.id.toString(),
          mealType: m.mealType,
          scheduledTime: m.scheduledTime,
          isLogged: m.isLogged,
          loggedAt: m.loggedAt,
          orderIndex: m.orderIndex,
          foods: (m.foodItems ?? []).map((f: any) => ({
            id: f.id.toString(),
            name: f.name,
            portion: f.portion,
            calories: f.calories,
            proteinG: Number(f.proteinG),
            carbsG: Number(f.carbsG),
            fatG: Number(f.fatG),
            fiberG: Number(f.fiberG),
            estimatedCostIdr: Number(f.estimatedCostIdr),
            orderIndex: f.orderIndex,
          })),
        })),
      })),
    };
  },
};

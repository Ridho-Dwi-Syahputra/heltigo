/**
 * Meal Service
 * ────────────
 * Today's meals, detail, log consumption, swap (ML alternatives + Gemini), food-scan bridge.
 */
import { Prisma } from '@prisma/client';
import { prisma } from '../config/db';
import { ApiError } from '../utils/api-error';
import { MlService } from './ml.service';
import { geminiService } from './gemini.service';
import { badgeService } from './badge.service';

function toBig(id: string) {
  return BigInt(id);
}

function todayStart() {
  const d = new Date();
  d.setHours(0, 0, 0, 0);
  return d;
}

function serializeMealTime(m: any) {
  return {
    id: m.id.toString(),
    mealDayId: m.mealDayId.toString(),
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
  };
}

export const mealService = {
  async getToday(userId: string) {
    const date = todayStart();
    const day = await prisma.mealDay.findFirst({
      where: { date, mealPlan: { userId: toBig(userId), isActive: true } },
      include: {
        mealTimes: {
          include: { foodItems: { orderBy: { orderIndex: 'asc' } } },
          orderBy: { orderIndex: 'asc' },
        },
      },
    });
    if (!day) return { day: null };
    return {
      day: {
        id: day.id.toString(),
        date: day.date,
        totalCalories: day.totalCalories,
        totalProteinG: day.totalProteinG ? Number(day.totalProteinG) : 0,
        totalCarbsG: day.totalCarbsG ? Number(day.totalCarbsG) : 0,
        totalFatG: day.totalFatG ? Number(day.totalFatG) : 0,
        totalCostIdr: day.totalCostIdr ? Number(day.totalCostIdr) : 0,
        meals: day.mealTimes.map(serializeMealTime),
      },
    };
  },

  async getDayDetail(userId: string, dayId: string) {
    const day = await prisma.mealDay.findUnique({
      where: { id: toBig(dayId) },
      include: {
        mealPlan: true,
        mealTimes: {
          include: { foodItems: { orderBy: { orderIndex: 'asc' } } },
          orderBy: { orderIndex: 'asc' },
        },
      },
    });
    if (!day || day.mealPlan.userId !== toBig(userId)) {
      throw new ApiError(404, 'DAY_NOT_FOUND', 'Meal day tidak ditemukan');
    }
    return {
      day: {
        id: day.id.toString(),
        date: day.date,
        totalCalories: day.totalCalories,
        meals: day.mealTimes.map(serializeMealTime),
      },
    };
  },

  async getMealDetail(userId: string, mealId: string) {
    const meal = await prisma.mealTime.findUnique({
      where: { id: toBig(mealId) },
      include: {
        foodItems: { orderBy: { orderIndex: 'asc' } },
        mealDay: { include: { mealPlan: true } },
      },
    });
    if (!meal || meal.mealDay.mealPlan.userId !== toBig(userId)) {
      throw new ApiError(404, 'MEAL_NOT_FOUND', 'Meal tidak ditemukan');
    }
    return { meal: serializeMealTime(meal) };
  },

  async logMeal(
    userId: string,
    mealId: string,
    body: { foodItemId?: string; actualPortionGram?: number; notes?: string },
  ) {
    const meal = await prisma.mealTime.findUnique({
      where: { id: toBig(mealId) },
      include: { foodItems: true, mealDay: { include: { mealPlan: true } } },
    });
    if (!meal || meal.mealDay.mealPlan.userId !== toBig(userId)) {
      throw new ApiError(404, 'MEAL_NOT_FOUND', 'Meal tidak ditemukan');
    }
    const foodItem = body.foodItemId
      ? meal.foodItems.find((f) => f.id.toString() === body.foodItemId)
      : meal.foodItems[0];
    if (!foodItem) throw new ApiError(404, 'FOOD_NOT_FOUND', 'Food item tidak ditemukan');

    const log = await prisma.mealLog.upsert({
      where: {
        userId_mealTimeId_foodItemId: {
          userId: toBig(userId),
          mealTimeId: toBig(mealId),
          foodItemId: foodItem.id,
        },
      },
      create: {
        userId: toBig(userId),
        mealTimeId: toBig(mealId),
        foodItemId: foodItem.id,
        loggedAt: new Date(),
        actualPortionGram: body.actualPortionGram ?? null,
        notes: body.notes ?? null,
      },
      update: {
        loggedAt: new Date(),
        actualPortionGram: body.actualPortionGram ?? null,
        notes: body.notes ?? null,
      },
    });

    // Update meal_time.is_logged
    await prisma.mealTime.update({
      where: { id: toBig(mealId) },
      data: { isLogged: true, loggedAt: new Date() },
    });

    // Update daily_logs
    const dayDate = todayStart();
    await prisma.dailyLog.upsert({
      where: { userId_date: { userId: toBig(userId), date: dayDate } },
      create: {
        userId: toBig(userId),
        date: dayDate,
        mealsLoggedCount: 1,
        caloriesConsumed: foodItem.calories,
      },
      update: {
        mealsLoggedCount: { increment: 1 },
        caloriesConsumed: { increment: foodItem.calories },
      },
    });

    const newBadges = await badgeService.checkUnlocks(userId);

    return {
      log: { id: log.id.toString(), loggedAt: log.loggedAt },
      nutrition: {
        calories: foodItem.calories,
        proteinG: Number(foodItem.proteinG),
        carbsG: Number(foodItem.carbsG),
        fatG: Number(foodItem.fatG),
      },
      newBadges,
    };
  },

  async swapMeal(userId: string, mealId: string, body: { foodId?: string; budgetMaxIdr?: number }) {
    const meal = await prisma.mealTime.findUnique({
      where: { id: toBig(mealId) },
      include: { foodItems: true, mealDay: { include: { mealPlan: true } } },
    });
    if (!meal || meal.mealDay.mealPlan.userId !== toBig(userId)) {
      throw new ApiError(404, 'MEAL_NOT_FOUND', 'Meal tidak ditemukan');
    }
    const targetFood = meal.foodItems[0];
    if (!targetFood) throw new ApiError(404, 'FOOD_NOT_FOUND', 'Food item tidak ditemukan');

    const profile = await prisma.healthProfile.findUnique({ where: { userId: toBig(userId) } });

    const ml = await MlService.predictMealAlternatives({
      food_id: Number(targetFood.foodMasterId ?? 1),
      meal_type: meal.mealType,
      goal: profile?.goal ?? 'MAINTENANCE',
      dietary_restrictions: (profile?.dietaryRestrictions as string[]) ?? [],
      budget_max_idr: body.budgetMaxIdr ?? 25000,
    }).catch(() => ({ alternatives: [] as any[] }));

    const alts = (ml as any).alternatives ?? [];
    // Enrich top-3 dengan Gemini secara paralel
    const enriched = await Promise.all(
      alts.slice(0, 3).map(async (a: any) => ({
        foodId: a.food_id,
        name: a.name,
        category: a.category,
        calories: a.calories,
        proteinG: a.protein_g,
        carbsG: a.carbs_g,
        fatG: a.fat_g,
        priceIdr: a.price_idr,
        isHalal: a.is_halal,
        reason: await geminiService.enrichMealRecommendation({
          foodName: a.name,
          calories: a.calories,
          goal: profile?.goal,
          reason: `pengganti ${targetFood.name}`,
        }),
      })),
    );

    return { alternatives: enriched, restCount: Math.max(0, alts.length - 3) };
  },

  async replaceMeal(userId: string, mealId: string, body: { foodId: number; foodName: string; calories: number; proteinG?: number; carbsG?: number; fatG?: number; priceIdr?: number }) {
    const meal = await prisma.mealTime.findUnique({
      where: { id: toBig(mealId) },
      include: { mealDay: { include: { mealPlan: true } }, foodItems: true },
    });
    if (!meal || meal.mealDay.mealPlan.userId !== toBig(userId)) {
      throw new ApiError(404, 'MEAL_NOT_FOUND', 'Meal tidak ditemukan');
    }
    // Hapus food items lama, ganti dengan yang baru
    await prisma.foodItem.deleteMany({ where: { mealTimeId: toBig(mealId) } });
    const created = await prisma.foodItem.create({
      data: {
        mealTimeId: toBig(mealId),
        name: body.foodName,
        portion: '1 porsi',
        calories: Math.round(body.calories),
        proteinG: new Prisma.Decimal(body.proteinG ?? 0),
        carbsG: new Prisma.Decimal(body.carbsG ?? 0),
        fatG: new Prisma.Decimal(body.fatG ?? 0),
        estimatedCostIdr: new Prisma.Decimal(body.priceIdr ?? 0),
        orderIndex: 0,
      },
    });
    return { foodItem: { id: created.id.toString(), name: created.name, calories: created.calories } };
  },

  async getFoodDetail(userId: string, foodId: string) {
    const food = await prisma.foodItem.findUnique({
      where: { id: toBig(foodId) },
      include: {
        mealTime: { include: { mealDay: { include: { mealPlan: true } } } },
        foodMaster: true,
      },
    });
    if (!food || food.mealTime.mealDay.mealPlan.userId !== toBig(userId)) {
      throw new ApiError(404, 'FOOD_NOT_FOUND', 'Food tidak ditemukan');
    }
    return {
      food: {
        id: food.id.toString(),
        name: food.name,
        portion: food.portion,
        portionGram: food.portionGram,
        calories: food.calories,
        proteinG: Number(food.proteinG),
        carbsG: Number(food.carbsG),
        fatG: Number(food.fatG),
        fiberG: Number(food.fiberG),
        estimatedCostIdr: Number(food.estimatedCostIdr),
        master: food.foodMaster
          ? {
              category: food.foodMaster.category,
              cuisine: food.foodMaster.cuisine,
              isHalal: food.foodMaster.isHalal,
              isVegetarian: food.foodMaster.isVegetarian,
              imageUrl: food.foodMaster.imageUrl,
            }
          : null,
      },
    };
  },

  async getMealLog(userId: string, days = 7) {
    const since = new Date();
    since.setDate(since.getDate() - days);
    const logs = await prisma.mealLog.findMany({
      where: { userId: toBig(userId), loggedAt: { gte: since } },
      orderBy: { loggedAt: 'desc' },
      include: { foodItem: true, mealTime: true },
    });
    return {
      logs: logs.map((l) => ({
        id: l.id.toString(),
        loggedAt: l.loggedAt,
        actualPortionGram: l.actualPortionGram,
        food: {
          id: l.foodItem.id.toString(),
          name: l.foodItem.name,
          calories: l.foodItem.calories,
        },
        mealType: l.mealTime.mealType,
      })),
    };
  },

  async updateBudget(userId: string, body: { budgetPerDayIdr: number }) {
    if (!body.budgetPerDayIdr || body.budgetPerDayIdr < 10000) {
      throw new ApiError(400, 'BUDGET_TOO_LOW', 'Budget minimum Rp 10.000/hari');
    }
    const updated = await prisma.healthProfile.update({
      where: { userId: toBig(userId) },
      data: { budgetPerDayIdr: new Prisma.Decimal(body.budgetPerDayIdr) },
    });
    return {
      budgetPerDayIdr: Number(updated.budgetPerDayIdr),
      hint: 'Plan akan disesuaikan saat replan berikutnya. Trigger /plan/replan untuk apply sekarang.',
    };
  },

  /**
   * Food Scan: terima base64 image, forward ke ML /predict/food-scan,
   * simpan hasil ke meal_logs (optional), enrich dengan Gemini.
   */
  async foodScan(
    userId: string,
    body: { imageBase64?: string; identifiedFoods?: string[]; portions?: number[]; persist?: boolean },
  ) {
    const profile = await prisma.healthProfile.findUnique({ where: { userId: toBig(userId) } });
    const conditions = ((profile?.healthConditions as string[]) ?? []).join(',') || 'None';

    const ml: any = await MlService.predictFoodScan({
      image_base64: body.imageBase64,
      identified_foods: body.identifiedFoods,
      user_goal: profile?.goal ?? 'MAINTENANCE',
      user_condition: conditions,
      portions: body.portions,
    });

    const advice = await geminiService.enrichFoodScanAdvice({
      foods: (ml.matches ?? []).map((m: any) => m.matched ?? m.query).filter(Boolean),
      totalCalories: ml.nutrition_total?.calories ?? 0,
      assessment: ml.assessment ?? 'MODERATE',
      goal: profile?.goal,
      condition: conditions,
    });

    // Optional persist: catat ke daily_logs sebagai consumed calories
    if (body.persist && ml.nutrition_total?.calories) {
      const dayDate = todayStart();
      await prisma.dailyLog.upsert({
        where: { userId_date: { userId: toBig(userId), date: dayDate } },
        create: {
          userId: toBig(userId),
          date: dayDate,
          caloriesConsumed: Math.round(ml.nutrition_total.calories),
        },
        update: { caloriesConsumed: { increment: Math.round(ml.nutrition_total.calories) } },
      });
    }

    return {
      identifiedByGemini: ml.identified_by_gemini ?? null,
      matches: ml.matches ?? [],
      nutritionTotal: ml.nutrition_total ?? null,
      healthScore: ml.health_score ?? 0,
      assessment: ml.assessment ?? 'MODERATE',
      advice,
      persisted: body.persist === true,
    };
  },
};

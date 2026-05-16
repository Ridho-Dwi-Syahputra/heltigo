/**
 * Progress Service
 * ────────────────
 * Daily/weekly aggregates, streak, badges.
 */
import { prisma } from '../config/db';
import { ApiError } from '../utils/api-error';
import { scoringService } from './scoring.service';

function toBig(id: string) {
  return BigInt(id);
}
function todayStart() {
  const d = new Date();
  d.setHours(0, 0, 0, 0);
  return d;
}

export const progressService = {
  async getDaily(userId: string, dateStr?: string) {
    const date = dateStr ? new Date(dateStr) : todayStart();
    date.setHours(0, 0, 0, 0);
    const log = await prisma.dailyLog.findUnique({
      where: { userId_date: { userId: toBig(userId), date } },
    });
    if (!log) {
      return {
        date,
        workoutCompleted: false,
        mealsLoggedCount: 0,
        mealsTotal: 3,
        waterGlasses: 0,
        waterTarget: 8,
        caloriesConsumed: 0,
        caloriesBurned: 0,
        mood: null,
        dailyScore: null,
      };
    }
    return {
      date: log.date,
      workoutCompleted: log.workoutCompleted,
      workoutSessionId: log.workoutSessionId?.toString() ?? null,
      mealsLoggedCount: log.mealsLoggedCount,
      mealsTotal: log.mealsTotal,
      waterGlasses: log.waterGlasses,
      waterTarget: log.waterTarget,
      mood: log.mood,
      dailyScore: log.dailyScore,
      caloriesConsumed: log.caloriesConsumed ?? 0,
      caloriesBurned: log.caloriesBurned ?? 0,
    };
  },

  async updateWater(userId: string, body: { glasses?: number; delta?: number }) {
    const date = todayStart();
    const existing = await prisma.dailyLog.findUnique({
      where: { userId_date: { userId: toBig(userId), date } },
    });
    const current = existing?.waterGlasses ?? 0;
    const next =
      body.glasses != null
        ? Math.max(0, body.glasses)
        : Math.max(0, current + (body.delta ?? 1));
    const updated = await prisma.dailyLog.upsert({
      where: { userId_date: { userId: toBig(userId), date } },
      create: { userId: toBig(userId), date, waterGlasses: next },
      update: { waterGlasses: next },
    });
    return { waterGlasses: updated.waterGlasses, waterTarget: updated.waterTarget };
  },

  async logMood(userId: string, body: { mood: string }) {
    if (!body.mood) throw new ApiError(400, 'MOOD_REQUIRED', 'Mood wajib diisi');
    const date = todayStart();
    const updated = await prisma.dailyLog.upsert({
      where: { userId_date: { userId: toBig(userId), date } },
      create: { userId: toBig(userId), date, mood: body.mood as any },
      update: { mood: body.mood as any },
    });
    return { mood: updated.mood };
  },

  async getWeekly(userId: string) {
    const since = new Date();
    since.setDate(since.getDate() - 7);
    since.setHours(0, 0, 0, 0);
    const logs = await prisma.dailyLog.findMany({
      where: { userId: toBig(userId), date: { gte: since } },
      orderBy: { date: 'asc' },
    });
    const sessions = await prisma.workoutSession.findMany({
      where: { userId: toBig(userId), startedAt: { gte: since } },
    });
    const meals = await prisma.mealLog.findMany({
      where: { userId: toBig(userId), loggedAt: { gte: since } },
    });
    const totalCaloriesIn = logs.reduce((acc, l) => acc + (l.caloriesConsumed ?? 0), 0);
    const totalCaloriesOut = logs.reduce((acc, l) => acc + (l.caloriesBurned ?? 0), 0);
    return {
      since,
      workoutsCompleted: sessions.filter((s) => s.status === 'COMPLETED').length,
      mealsLogged: meals.length,
      activeDays: logs.filter((l) => l.workoutCompleted || l.mealsLoggedCount > 0).length,
      avgWaterGlasses:
        logs.length > 0 ? Math.round(logs.reduce((a, l) => a + l.waterGlasses, 0) / logs.length) : 0,
      totalCaloriesIn,
      totalCaloriesOut,
      weeklyScore: scoringService.calculateWeeklyScore(sessions as any, meals as any),
      dailyBreakdown: logs.map((l) => ({
        date: l.date,
        workoutCompleted: l.workoutCompleted,
        mealsLoggedCount: l.mealsLoggedCount,
        caloriesConsumed: l.caloriesConsumed ?? 0,
        caloriesBurned: l.caloriesBurned ?? 0,
        mood: l.mood,
      })),
    };
  },

  async getWeeklyReview(userId: string) {
    const weekly = await this.getWeekly(userId);
    const profile = await prisma.healthProfile.findUnique({ where: { userId: toBig(userId) } });
    const weightDiff = profile
      ? Number(profile.weightKg) - Number(profile.startWeightKg)
      : 0;
    return {
      ...weekly,
      weightDiffKg: Number(weightDiff.toFixed(2)),
      currentWeightKg: profile ? Number(profile.weightKg) : null,
      targetWeightKg: profile?.targetWeightKg ? Number(profile.targetWeightKg) : null,
      goal: profile?.goal,
    };
  },

  async getStreak(userId: string) {
    const streak = await prisma.streak.findUnique({ where: { userId: toBig(userId) } });
    return {
      currentStreak: streak?.currentStreak ?? 0,
      bestStreak: streak?.bestStreak ?? 0,
      lastActiveDate: streak?.lastActiveDate ?? null,
      activeDates: streak?.activeDates ?? [],
    };
  },

  async getBadges(userId: string) {
    const [badges, owned] = await Promise.all([
      prisma.badge.findMany({
        where: { isActive: true },
        orderBy: [{ category: 'asc' }, { orderIndex: 'asc' }],
      }),
      prisma.userBadge.findMany({
        where: { userId: toBig(userId) },
        include: { badge: true },
      }),
    ]);
    const ownedMap = new Map(owned.map((u) => [u.badgeId.toString(), u.unlockedAt]));
    return {
      badges: badges.map((b) => ({
        id: b.id.toString(),
        code: b.code,
        title: b.title,
        description: b.description,
        iconName: b.iconName,
        iconColor: b.iconColor,
        category: b.category,
        criterionType: b.criterionType,
        criterionValue: b.criterionValue,
        isUnlocked: ownedMap.has(b.id.toString()),
        unlockedAt: ownedMap.get(b.id.toString()) ?? null,
      })),
    };
  },

  async getBadgeDetail(userId: string, code: string) {
    const badge = await prisma.badge.findUnique({ where: { code } });
    if (!badge) throw new ApiError(404, 'BADGE_NOT_FOUND', 'Badge tidak ditemukan');
    const owned = await prisma.userBadge.findFirst({
      where: { userId: toBig(userId), badgeId: badge.id },
    });
    return {
      badge: {
        id: badge.id.toString(),
        code: badge.code,
        title: badge.title,
        description: badge.description,
        iconName: badge.iconName,
        iconColor: badge.iconColor,
        category: badge.category,
        criterionType: badge.criterionType,
        criterionValue: badge.criterionValue,
        isUnlocked: !!owned,
        unlockedAt: owned?.unlockedAt ?? null,
      },
    };
  },

  async getShareImage(userId: string) {
    const streak = await this.getStreak(userId);
    return {
      url: null,
      hint: 'Render image di FE menggunakan data ini',
      payload: { currentStreak: streak.currentStreak, bestStreak: streak.bestStreak },
    };
  },
};

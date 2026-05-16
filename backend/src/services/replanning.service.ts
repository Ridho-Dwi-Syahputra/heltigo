/**
 * Replanning Service
 * ──────────────────
 * Hitung weekly_score (kepatuhan 7 hari) + weight_diff → panggil ML replan →
 * enrich dengan Gemini → return rekomendasi.
 *
 * Belum auto-trigger regenerate plan baru. Itu di-handle FE saat user setuju.
 */
import { prisma } from '../config/db';
import { ApiError } from '../utils/api-error';
import { MlService } from './ml.service';
import { healthService } from './health.service';
import { scoringService } from './scoring.service';
import { geminiService } from './gemini.service';
import { logger } from '../utils/logger';
import { planService } from './plan.service';

function toBig(id: string) {
  return BigInt(id);
}

function levelToInt(l: string) {
  if (l === 'INTERMEDIATE') return 2;
  if (l === 'ADVANCED') return 3;
  return 1;
}

export const replanningService = {
  async runReplan(userId: string, override?: { applyImmediately?: boolean }) {
    const profile = await prisma.healthProfile.findUnique({ where: { userId: toBig(userId) } });
    if (!profile) throw new ApiError(400, 'PROFILE_REQUIRED', 'Health profile belum dibuat');

    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    sevenDaysAgo.setHours(0, 0, 0, 0);

    const sessions = await prisma.workoutSession.findMany({
      where: { userId: toBig(userId), startedAt: { gte: sevenDaysAgo } },
    });
    const meals = await prisma.mealLog.findMany({
      where: { userId: toBig(userId), loggedAt: { gte: sevenDaysAgo } },
    });
    const dailyLogs = await prisma.dailyLog.findMany({
      where: { userId: toBig(userId), date: { gte: sevenDaysAgo } },
      orderBy: { date: 'asc' },
    });

    const weeklyScore = scoringService.calculateWeeklyScore(sessions as any, meals as any);

    // weight diff: bandingkan weight_kg sekarang vs start_weight_kg
    const weightNow = Number(profile.weightKg);
    const weightDiff = weightNow - Number(profile.startWeightKg);

    const bmi = healthService.calculateBMI(weightNow, Number(profile.heightCm));

    const mlPayload = {
      weekly_score: weeklyScore,
      weight_diff_kg: Number(weightDiff.toFixed(2)),
      bmi: Number(bmi.toFixed(2)),
      experience_level: levelToInt(profile.fitnessLevel),
      age: profile.age,
      workout_frequency: profile.availableDaysPerWeek,
    };

    let mlResult: any;
    try {
      mlResult = await MlService.predictReplan(mlPayload);
    } catch (err) {
      logger.error({ err: (err as Error).message }, 'ML replan failed');
      throw new ApiError(502, 'ML_UNAVAILABLE', 'Tidak dapat menghitung replan saat ini');
    }

    const narrative = await geminiService.enrichReplanNarrative({
      weeklyScore,
      weightDiffKg: weightDiff,
      action: mlResult.action,
      volumeMultiplier: mlResult.volume_multiplier,
      goal: profile.goal,
    });

    let newPlan: any = null;
    if (override?.applyImmediately) {
      newPlan = await planService.generate(userId);
    }

    return {
      summary: {
        weeklyScore,
        weightDiffKg: Number(weightDiff.toFixed(2)),
        bmi: Number(bmi.toFixed(2)),
        sessionsCompleted: sessions.filter((s) => s.status === 'COMPLETED').length,
        mealsLogged: meals.length,
        activeDays: dailyLogs.filter((d) => d.workoutCompleted || d.mealsLoggedCount > 0).length,
      },
      ml: {
        volumeMultiplier: mlResult.volume_multiplier,
        action: mlResult.action,
        recommendation: mlResult.recommendation,
        modelVersion: mlResult.model_version,
      },
      narrative,
      regeneratedPlan: newPlan,
    };
  },
};

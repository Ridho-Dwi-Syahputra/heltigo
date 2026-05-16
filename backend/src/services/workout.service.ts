/**
 * Workout Service
 * ───────────────
 * Session lifecycle: check-in → update exercise set → pause → complete.
 * Gemini enrich di endpoint complete (congrats personal).
 */
import { Prisma } from '@prisma/client';
import { prisma } from '../config/db';
import { ApiError } from '../utils/api-error';
import { intensityAdjusterService } from './intensity_adjuster.service';
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

function serializeDay(d: any) {
  return {
    id: d.id.toString(),
    planId: d.planId.toString(),
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
      tempo: e.tempo,
      notes: e.notes,
      orderIndex: e.orderIndex,
    })),
  };
}

function serializeSession(s: any) {
  return {
    id: s.id.toString(),
    workoutDayId: s.workoutDayId.toString(),
    startedAt: s.startedAt,
    completedAt: s.completedAt,
    durationSec: s.durationSec,
    caloriesBurned: s.caloriesBurned,
    effortScore: s.effortScore,
    moodBefore: s.moodBefore,
    energyBefore: s.energyBefore,
    sleepBandBefore: s.sleepBandBefore,
    moodAfter: s.moodAfter,
    intensityMultiplier: s.intensityMultiplier ? Number(s.intensityMultiplier) : null,
    status: s.status,
    notes: s.notes,
    exerciseLogs: (s.exerciseLogs ?? []).map((l: any) => ({
      id: l.id.toString(),
      exerciseId: l.exerciseId.toString(),
      setNumber: l.setNumber,
      repsActual: l.repsActual,
      durationActualSec: l.durationActualSec,
      weightKg: l.weightKg ? Number(l.weightKg) : null,
      restActualSec: l.restActualSec,
      isCompleted: l.isCompleted,
      loggedAt: l.loggedAt,
    })),
  };
}

export const workoutService = {
  async getToday(userId: string) {
    const date = todayStart();
    const day = await prisma.workoutDay.findFirst({
      where: {
        date,
        workoutPlan: { userId: toBig(userId), isActive: true },
      },
      include: { exercises: { orderBy: { orderIndex: 'asc' } } },
    });
    if (!day) return { day: null };
    return { day: serializeDay(day) };
  },

  async getDayDetail(userId: string, dayId: string) {
    const day = await prisma.workoutDay.findUnique({
      where: { id: toBig(dayId) },
      include: { exercises: { orderBy: { orderIndex: 'asc' } }, workoutPlan: true },
    });
    if (!day || day.workoutPlan.userId !== toBig(userId)) {
      throw new ApiError(404, 'DAY_NOT_FOUND', 'Workout day tidak ditemukan');
    }
    return { day: serializeDay(day) };
  },

  async getExerciseDetail(userId: string, exerciseId: string) {
    const ex = await prisma.exercise.findUnique({
      where: { id: toBig(exerciseId) },
      include: {
        exerciseMaster: true,
        workoutDay: { include: { workoutPlan: true } },
      },
    });
    if (!ex || ex.workoutDay.workoutPlan.userId !== toBig(userId)) {
      throw new ApiError(404, 'EXERCISE_NOT_FOUND', 'Exercise tidak ditemukan');
    }
    return {
      exercise: {
        id: ex.id.toString(),
        name: ex.name,
        category: ex.category,
        sets: ex.sets,
        reps: ex.reps,
        durationSec: ex.durationSec,
        restSec: ex.restSec,
        master: ex.exerciseMaster
          ? {
              id: ex.exerciseMaster.id.toString(),
              slug: ex.exerciseMaster.slug,
              description: ex.exerciseMaster.description,
              instructions: ex.exerciseMaster.instructions,
              muscleGroups: ex.exerciseMaster.muscleGroups,
              equipment: ex.exerciseMaster.equipment,
              tips: ex.exerciseMaster.tips,
              videoUrl: ex.exerciseMaster.videoUrl,
              imageUrl: ex.exerciseMaster.imageUrl,
            }
          : null,
      },
    };
  },

  async checkIn(
    userId: string,
    dayId: string,
    body: { mood?: string; energy?: number; sleepBand?: string },
  ) {
    const day = await prisma.workoutDay.findUnique({
      where: { id: toBig(dayId) },
      include: { workoutPlan: true },
    });
    if (!day || day.workoutPlan.userId !== toBig(userId)) {
      throw new ApiError(404, 'DAY_NOT_FOUND', 'Workout day tidak ditemukan');
    }

    const intensityMultiplier = intensityAdjusterService.getMultiplier(
      body.mood ?? 'NEUTRAL',
      body.energy ?? 5,
      body.sleepBand ?? 'B6_7',
    );

    const session = await prisma.workoutSession.create({
      data: {
        userId: toBig(userId),
        workoutDayId: toBig(dayId),
        startedAt: new Date(),
        moodBefore: (body.mood as any) ?? null,
        energyBefore: body.energy ?? null,
        sleepBandBefore: (body.sleepBand as any) ?? null,
        intensityMultiplier: new Prisma.Decimal(intensityMultiplier),
        status: 'IN_PROGRESS',
      },
    });
    return {
      session: serializeSession(session),
      intensityMultiplier,
    };
  },

  async updateExerciseLog(
    userId: string,
    sessionId: string,
    body: {
      exerciseId: string;
      setNumber: number;
      repsActual?: number;
      durationActualSec?: number;
      weightKg?: number;
      restActualSec?: number;
      isCompleted?: boolean;
    },
  ) {
    const session = await prisma.workoutSession.findUnique({ where: { id: toBig(sessionId) } });
    if (!session || session.userId !== toBig(userId)) {
      throw new ApiError(404, 'SESSION_NOT_FOUND', 'Session tidak ditemukan');
    }
    const log = await prisma.exerciseLog.create({
      data: {
        sessionId: toBig(sessionId),
        exerciseId: toBig(body.exerciseId),
        setNumber: body.setNumber,
        repsActual: body.repsActual ?? null,
        durationActualSec: body.durationActualSec ?? null,
        weightKg: body.weightKg != null ? new Prisma.Decimal(body.weightKg) : null,
        restActualSec: body.restActualSec ?? null,
        isCompleted: body.isCompleted ?? true,
      },
    });
    return { log: { id: log.id.toString() } };
  },

  async pauseSession(userId: string, sessionId: string) {
    const session = await prisma.workoutSession.findUnique({ where: { id: toBig(sessionId) } });
    if (!session || session.userId !== toBig(userId)) {
      throw new ApiError(404, 'SESSION_NOT_FOUND', 'Session tidak ditemukan');
    }
    // Heltigo tidak punya status PAUSED; cukup catat di notes
    const updated = await prisma.workoutSession.update({
      where: { id: toBig(sessionId) },
      data: { notes: `${session.notes ?? ''}\n[Paused at ${new Date().toISOString()}]`.trim() },
    });
    return { session: serializeSession(updated) };
  },

  async completeSession(
    userId: string,
    sessionId: string,
    body: { effortScore?: number; moodAfter?: string; notes?: string },
  ) {
    const session = await prisma.workoutSession.findUnique({
      where: { id: toBig(sessionId) },
      include: {
        workoutDay: { include: { exercises: true } },
        exerciseLogs: true,
      },
    });
    if (!session || session.userId !== toBig(userId)) {
      throw new ApiError(404, 'SESSION_NOT_FOUND', 'Session tidak ditemukan');
    }
    if (session.status === 'COMPLETED') {
      return { session: serializeSession(session) };
    }

    const completedAt = new Date();
    const durationSec = Math.max(
      1,
      Math.floor((completedAt.getTime() - session.startedAt.getTime()) / 1000),
    );

    // Estimasi kalori: ~0.1 kkal/kg/menit * weight (default 65kg) * intensity
    const profile = await prisma.healthProfile.findUnique({ where: { userId: toBig(userId) } });
    const weight = profile ? Number(profile.weightKg) : 65;
    const intensity = session.intensityMultiplier ? Number(session.intensityMultiplier) : 1.0;
    const durationMin = durationSec / 60;
    const caloriesBurned = Math.round(weight * 0.1 * durationMin * intensity);

    const [updated] = await prisma.$transaction([
      prisma.workoutSession.update({
        where: { id: toBig(sessionId) },
        data: {
          completedAt,
          durationSec,
          caloriesBurned,
          effortScore: body.effortScore ?? null,
          moodAfter: (body.moodAfter as any) ?? null,
          notes: body.notes ?? session.notes,
          status: 'COMPLETED',
        },
      }),
      prisma.workoutDay.update({
        where: { id: session.workoutDayId },
        data: { isCompleted: true, completedAt },
      }),
    ]);

    // Update daily_logs
    const dayDate = todayStart();
    await prisma.dailyLog.upsert({
      where: { userId_date: { userId: toBig(userId), date: dayDate } },
      create: {
        userId: toBig(userId),
        date: dayDate,
        workoutCompleted: true,
        workoutSessionId: toBig(sessionId),
        caloriesBurned: caloriesBurned,
      },
      update: {
        workoutCompleted: true,
        workoutSessionId: toBig(sessionId),
        caloriesBurned: { increment: caloriesBurned },
      },
    });

    // Streak update
    await this._updateStreak(userId, dayDate);

    // Check badges
    const newBadges = await badgeService.checkUnlocks(userId);

    const enrichment = await geminiService.enrichWorkoutComplete({
      workoutName: session.workoutDay.name,
      durationMin: Math.round(durationMin),
      caloriesBurned,
      effortScore: body.effortScore ?? null,
      goal: profile?.goal,
    });

    return {
      session: serializeSession(updated),
      stats: {
        durationMin: Math.round(durationMin),
        caloriesBurned,
        intensityMultiplier: intensity,
        completedSets: session.exerciseLogs.filter((l) => l.isCompleted).length,
        totalSets: session.workoutDay.exercises.reduce((acc, e) => acc + e.sets, 0),
      },
      newBadges,
      message: enrichment,
    };
  },

  async getSessionDetail(userId: string, sessionId: string) {
    const session = await prisma.workoutSession.findUnique({
      where: { id: toBig(sessionId) },
      include: {
        exerciseLogs: { orderBy: { setNumber: 'asc' } },
        workoutDay: { include: { exercises: { orderBy: { orderIndex: 'asc' } } } },
      },
    });
    if (!session || session.userId !== toBig(userId)) {
      throw new ApiError(404, 'SESSION_NOT_FOUND', 'Session tidak ditemukan');
    }
    return {
      session: serializeSession(session),
      day: serializeDay(session.workoutDay),
    };
  },

  async getSessionsHistory(userId: string, limit = 20) {
    const sessions = await prisma.workoutSession.findMany({
      where: { userId: toBig(userId) },
      orderBy: { startedAt: 'desc' },
      take: Math.min(limit, 100),
      include: { workoutDay: true },
    });
    return {
      sessions: sessions.map((s) => ({
        id: s.id.toString(),
        workoutDayId: s.workoutDayId.toString(),
        workoutDayName: s.workoutDay.name,
        workoutType: s.workoutDay.workoutType,
        startedAt: s.startedAt,
        completedAt: s.completedAt,
        durationSec: s.durationSec,
        caloriesBurned: s.caloriesBurned,
        status: s.status,
      })),
    };
  },

  async swapExercise(userId: string, exerciseId: string, body: { masterExerciseId?: string }) {
    const ex = await prisma.exercise.findUnique({
      where: { id: toBig(exerciseId) },
      include: { workoutDay: { include: { workoutPlan: true } } },
    });
    if (!ex || ex.workoutDay.workoutPlan.userId !== toBig(userId)) {
      throw new ApiError(404, 'EXERCISE_NOT_FOUND', 'Exercise tidak ditemukan');
    }
    let target: any = null;
    if (body.masterExerciseId) {
      target = await prisma.exerciseMaster.findUnique({
        where: { id: toBig(body.masterExerciseId) },
      });
    } else {
      // pilih alternatif acak dengan difficulty sama dari master
      target = await prisma.exerciseMaster.findFirst({
        where: {
          isActive: true,
          id: { not: ex.masterExerciseId ?? undefined },
        },
        orderBy: { id: 'asc' },
      });
    }
    if (!target) {
      throw new ApiError(404, 'NO_ALTERNATIVE', 'Tidak ada exercise alternatif yang tersedia');
    }
    const updated = await prisma.exercise.update({
      where: { id: toBig(exerciseId) },
      data: {
        masterExerciseId: target.id,
        name: target.name,
        sets: target.defaultSets ?? ex.sets,
        reps: target.defaultReps ?? ex.reps,
        restSec: target.defaultRestSec ?? ex.restSec,
      },
    });
    return {
      exercise: {
        id: updated.id.toString(),
        name: updated.name,
        category: updated.category,
        sets: updated.sets,
        reps: updated.reps,
        restSec: updated.restSec,
      },
    };
  },

  async _updateStreak(userId: string, date: Date) {
    const streak = await prisma.streak.findUnique({ where: { userId: toBig(userId) } });
    const yesterday = new Date(date);
    yesterday.setDate(yesterday.getDate() - 1);

    if (!streak) {
      await prisma.streak.create({
        data: {
          userId: toBig(userId),
          currentStreak: 1,
          bestStreak: 1,
          lastActiveDate: date,
          activeDates: [date.toISOString().slice(0, 10)],
        },
      });
      return;
    }
    if (streak.lastActiveDate && streak.lastActiveDate.getTime() === date.getTime()) return;
    const isConsecutive =
      streak.lastActiveDate && streak.lastActiveDate.getTime() === yesterday.getTime();
    const current = isConsecutive ? streak.currentStreak + 1 : 1;
    const best = Math.max(current, streak.bestStreak);
    const datesArr = Array.isArray(streak.activeDates)
      ? [...(streak.activeDates as string[]), date.toISOString().slice(0, 10)]
      : [date.toISOString().slice(0, 10)];

    await prisma.streak.update({
      where: { userId: toBig(userId) },
      data: { currentStreak: current, bestStreak: best, lastActiveDate: date, activeDates: datesArr },
    });
  },
};

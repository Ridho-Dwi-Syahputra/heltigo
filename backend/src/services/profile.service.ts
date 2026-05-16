import { Prisma } from '@prisma/client';
import { prisma } from '../config/db';
import { ApiError } from '../utils/api-error';
import { healthService } from './health.service';

function toUserId(id: string) {
  return BigInt(id);
}

function serializeProfile(p: any) {
  if (!p) return null;
  return {
    id: p.id.toString(),
    userId: p.userId.toString(),
    age: p.age,
    gender: p.gender,
    dateOfBirth: p.dateOfBirth,
    heightCm: Number(p.heightCm),
    weightKg: Number(p.weightKg),
    startWeightKg: Number(p.startWeightKg),
    targetWeightKg: p.targetWeightKg != null ? Number(p.targetWeightKg) : null,
    fitnessLevel: p.fitnessLevel,
    goal: p.goal,
    healthConditions: p.healthConditions,
    allergies: p.allergies,
    dietaryRestrictions: p.dietaryRestrictions,
    preferredEquipment: p.preferredEquipment,
    availableDaysPerWeek: p.availableDaysPerWeek,
    sessionDurationMin: p.sessionDurationMin,
    workoutMode: p.workoutMode,
    budgetPerDayIdr: Number(p.budgetPerDayIdr),
    bmi: healthService.calculateBMI(Number(p.weightKg), Number(p.heightCm)),
    createdAt: p.createdAt,
    updatedAt: p.updatedAt,
  };
}

function serializeUser(u: any) {
  return {
    id: u.id.toString(),
    email: u.email,
    name: u.name,
    avatarUrl: u.avatarUrl,
    lastLoginAt: u.lastLoginAt,
    createdAt: u.createdAt,
  };
}

export const profileService = {
  async getProfile(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: toUserId(userId) },
      include: { healthProfile: true },
    });
    if (!user || user.deletedAt) throw new ApiError(404, 'USER_NOT_FOUND', 'User tidak ditemukan');
    return {
      user: serializeUser(user),
      healthProfile: serializeProfile(user.healthProfile),
    };
  },

  async updateProfile(userId: string, data: { name?: string; avatarUrl?: string | null }) {
    const updated = await prisma.user.update({
      where: { id: toUserId(userId) },
      data: {
        ...(data.name !== undefined ? { name: data.name } : {}),
        ...(data.avatarUrl !== undefined ? { avatarUrl: data.avatarUrl } : {}),
      },
    });
    return { user: serializeUser(updated) };
  },

  async updateAvatar(userId: string, avatarUrl: string) {
    const updated = await prisma.user.update({
      where: { id: toUserId(userId) },
      data: { avatarUrl },
    });
    return { user: serializeUser(updated) };
  },

  async createHealthProfile(userId: string, body: any) {
    const existing = await prisma.healthProfile.findUnique({ where: { userId: toUserId(userId) } });
    if (existing) {
      throw new ApiError(409, 'PROFILE_EXISTS', 'Health profile sudah ada, gunakan PUT untuk update');
    }
    const created = await prisma.healthProfile.create({
      data: {
        userId: toUserId(userId),
        age: body.age,
        gender: body.gender,
        dateOfBirth: body.dateOfBirth ? new Date(body.dateOfBirth) : null,
        heightCm: new Prisma.Decimal(body.heightCm),
        weightKg: new Prisma.Decimal(body.weightKg),
        startWeightKg: new Prisma.Decimal(body.startWeightKg ?? body.weightKg),
        targetWeightKg:
          body.targetWeightKg != null ? new Prisma.Decimal(body.targetWeightKg) : null,
        fitnessLevel: body.fitnessLevel,
        goal: body.goal,
        healthConditions: body.healthConditions ?? [],
        allergies: body.allergies ?? [],
        dietaryRestrictions: body.dietaryRestrictions ?? [],
        preferredEquipment: body.preferredEquipment ?? [],
        availableDaysPerWeek: body.availableDaysPerWeek ?? 3,
        sessionDurationMin: body.sessionDurationMin ?? 30,
        workoutMode: body.workoutMode ?? 'HOME',
        budgetPerDayIdr: new Prisma.Decimal(body.budgetPerDayIdr ?? 35000),
      },
    });
    return { healthProfile: serializeProfile(created) };
  },

  async updateHealthProfile(userId: string, body: any) {
    const existing = await prisma.healthProfile.findUnique({ where: { userId: toUserId(userId) } });
    if (!existing) throw new ApiError(404, 'PROFILE_NOT_FOUND', 'Health profile belum dibuat');
    const data: Prisma.HealthProfileUpdateInput = {};
    if (body.age !== undefined) data.age = body.age;
    if (body.gender !== undefined) data.gender = body.gender;
    if (body.dateOfBirth !== undefined) data.dateOfBirth = body.dateOfBirth ? new Date(body.dateOfBirth) : null;
    if (body.heightCm !== undefined) data.heightCm = new Prisma.Decimal(body.heightCm);
    if (body.weightKg !== undefined) data.weightKg = new Prisma.Decimal(body.weightKg);
    if (body.targetWeightKg !== undefined) {
      data.targetWeightKg = body.targetWeightKg != null ? new Prisma.Decimal(body.targetWeightKg) : null;
    }
    if (body.fitnessLevel !== undefined) data.fitnessLevel = body.fitnessLevel;
    if (body.goal !== undefined) data.goal = body.goal;
    if (body.healthConditions !== undefined) data.healthConditions = body.healthConditions;
    if (body.allergies !== undefined) data.allergies = body.allergies;
    if (body.dietaryRestrictions !== undefined) data.dietaryRestrictions = body.dietaryRestrictions;
    if (body.preferredEquipment !== undefined) data.preferredEquipment = body.preferredEquipment;
    if (body.availableDaysPerWeek !== undefined) data.availableDaysPerWeek = body.availableDaysPerWeek;
    if (body.sessionDurationMin !== undefined) data.sessionDurationMin = body.sessionDurationMin;
    if (body.workoutMode !== undefined) data.workoutMode = body.workoutMode;
    if (body.budgetPerDayIdr !== undefined) data.budgetPerDayIdr = new Prisma.Decimal(body.budgetPerDayIdr);

    const updated = await prisma.healthProfile.update({
      where: { userId: toUserId(userId) },
      data,
    });
    return { healthProfile: serializeProfile(updated) };
  },

  /**
   * Log berat badan baru → update health_profiles.weight_kg DAN simpan ke daily_logs.
   * (Heltigo tidak punya tabel weight_history terpisah, jadi history dibaca dari daily_logs.)
   */
  async logHealthMetric(userId: string, body: { weightKg?: number; date?: string }) {
    const profile = await prisma.healthProfile.findUnique({ where: { userId: toUserId(userId) } });
    if (!profile) throw new ApiError(404, 'PROFILE_NOT_FOUND', 'Health profile belum dibuat');

    if (body.weightKg !== undefined) {
      await prisma.healthProfile.update({
        where: { userId: toUserId(userId) },
        data: { weightKg: new Prisma.Decimal(body.weightKg) },
      });
    }

    const date = body.date ? new Date(body.date) : new Date();
    date.setHours(0, 0, 0, 0);

    const upserted = await prisma.dailyLog.upsert({
      where: { userId_date: { userId: toUserId(userId), date } },
      create: {
        userId: toUserId(userId),
        date,
      },
      update: {},
    });

    return {
      loggedAt: new Date(),
      currentWeightKg: body.weightKg ?? Number(profile.weightKg),
      bmi: body.weightKg
        ? healthService.calculateBMI(body.weightKg, Number(profile.heightCm))
        : healthService.calculateBMI(Number(profile.weightKg), Number(profile.heightCm)),
      dailyLogId: upserted.id.toString(),
    };
  },

  async getCurrentMetrics(userId: string) {
    const profile = await prisma.healthProfile.findUnique({ where: { userId: toUserId(userId) } });
    if (!profile) return { healthProfile: null };
    return {
      weightKg: Number(profile.weightKg),
      heightCm: Number(profile.heightCm),
      bmi: healthService.calculateBMI(Number(profile.weightKg), Number(profile.heightCm)),
      goal: profile.goal,
      targetWeightKg: profile.targetWeightKg != null ? Number(profile.targetWeightKg) : null,
      updatedAt: profile.updatedAt,
    };
  },

  /**
   * History 30 hari terakhir dari daily_logs (tanggal user aktif).
   */
  async getMetricsHistory(userId: string, days = 30) {
    const since = new Date();
    since.setDate(since.getDate() - days);
    since.setHours(0, 0, 0, 0);
    const logs = await prisma.dailyLog.findMany({
      where: { userId: toUserId(userId), date: { gte: since } },
      orderBy: { date: 'asc' },
    });
    return {
      history: logs.map((l) => ({
        date: l.date,
        workoutCompleted: l.workoutCompleted,
        caloriesConsumed: l.caloriesConsumed,
        caloriesBurned: l.caloriesBurned,
        waterGlasses: l.waterGlasses,
        mood: l.mood,
        dailyScore: l.dailyScore,
      })),
    };
  },
};

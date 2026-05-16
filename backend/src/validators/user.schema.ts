import { z } from 'zod';

export const updateProfileSchema = z.object({
  body: z.object({
    name: z.string().min(1).max(100).optional(),
    avatarUrl: z.string().url().max(500).nullable().optional(),
  }),
});

export const updateAvatarSchema = z.object({
  body: z.object({
    avatarUrl: z.string().url().max(500),
  }),
});

const Gender = z.enum(['M', 'F', 'OTHER']);
const FitnessLevel = z.enum(['BEGINNER', 'INTERMEDIATE', 'ADVANCED']);
const Goal = z.enum(['WEIGHT_LOSS', 'MUSCLE_GAIN', 'MAINTENANCE', 'PERFORMANCE']);
const WorkoutMode = z.enum(['HOME', 'GYM', 'HYBRID']);

export const healthProfileBody = z.object({
  age: z.number().int().min(10).max(100),
  gender: Gender,
  dateOfBirth: z.string().optional(),
  heightCm: z.number().min(80).max(250),
  weightKg: z.number().min(20).max(300),
  startWeightKg: z.number().min(20).max(300).optional(),
  targetWeightKg: z.number().min(20).max(300).optional().nullable(),
  fitnessLevel: FitnessLevel,
  goal: Goal,
  healthConditions: z.array(z.string()).default([]),
  allergies: z.array(z.string()).default([]),
  dietaryRestrictions: z.array(z.string()).default([]),
  preferredEquipment: z.array(z.string()).default([]),
  availableDaysPerWeek: z.number().int().min(1).max(7).default(3),
  sessionDurationMin: z.number().int().min(15).max(180).default(30),
  workoutMode: WorkoutMode.default('HOME'),
  budgetPerDayIdr: z.number().min(10000).max(500000).default(35000),
});

export const createHealthProfileSchema = z.object({ body: healthProfileBody });
export const updateHealthProfileSchema = z.object({ body: healthProfileBody.partial() });

export const logHealthMetricsSchema = z.object({
  body: z.object({
    weightKg: z.number().min(20).max(300).optional(),
    date: z.string().optional(),
  }),
});

import { Request, Response } from 'express';
import { asyncHandler } from '../middleware/async.middleware';
import { MlService } from '../services/ml.service';

export const planController = {
  generate: asyncHandler(async (req: Request, res: Response) => {
    // 1. Ambil data dari body atau profil user
    // Mock user profile payload for ML Service
    const mlPayload = {
      tdee: 2500,
      target_calorie_adj: -500,
      budget_per_day_idr: 50000,
      meal_frequency: 3,
      goal: "WEIGHT_LOSS",
      dietary_restrictions: ["halal"],
      fitness_level: "BEGINNER",
      bmi: 26.5,
      age: 28,
      gender: "MALE",
      workout_mode: "GYM",
      days_per_week: 4,
      session_minutes: 45
    };

    // 2. Orchestrate calls to ML Service (FastAPI) paralel
    const [workoutPlanRes, mealPlanRes] = await Promise.all([
      MlService.predictWorkoutPlan(mlPayload).catch(e => null),
      MlService.predictMealPlan(mlPayload).catch(e => null)
    ]);

    // 3. Simpan plan ke MySQL melalui Prisma (Belum diimplementasi penuh schema Prisma-nya)
    
    // 4. Return combined result ke frontend
    res.status(201).json({
      workoutPlan: workoutPlanRes,
      mealPlan: mealPlanRes,
      status: 'success',
      message: 'Plan generated successfully'
    });
  }),

  getActive: asyncHandler(async (req: Request, res: Response) => {
    res.json({ message: 'Active plan implementation pending' });
  }),

  getHistory: asyncHandler(async (req: Request, res: Response) => {
    res.json({ plans: [] });
  }),

  getById: asyncHandler(async (req: Request, res: Response) => {
    res.json({ message: 'Pending getById logic' });
  }),

  replan: asyncHandler(async (req: Request, res: Response) => {
    const replanRes = await MlService.predictReplan(req.body);
    res.status(201).json({ data: replanRes });
  }),

  replanSkip: asyncHandler(async (req: Request, res: Response) => {
    res.json({ message: 'Replan skipped' });
  }),
};

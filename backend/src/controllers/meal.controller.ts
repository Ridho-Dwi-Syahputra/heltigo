import { Request, Response } from 'express';
import { asyncHandler } from '../middleware/async.middleware';

export const mealController = {
  getToday: asyncHandler(async (req: Request, res: Response) => res.json({ message: 'pending' })),
  getDayDetail: asyncHandler(async (req: Request, res: Response) => res.json({ message: 'pending' })),
  getMealDetail: asyncHandler(async (req: Request, res: Response) => res.json({ message: 'pending' })),
  logMeal: asyncHandler(async (req: Request, res: Response) => res.json({ message: 'pending' })),
  swapMeal: asyncHandler(async (req: Request, res: Response) => res.json({ message: 'pending' })),
  replaceMeal: asyncHandler(async (req: Request, res: Response) => res.json({ message: 'pending' })),
  getFoodDetail: asyncHandler(async (req: Request, res: Response) => res.json({ message: 'pending' })),
  getMealLog: asyncHandler(async (req: Request, res: Response) => res.json({ message: 'pending' })),
  updateBudget: asyncHandler(async (req: Request, res: Response) => res.json({ message: 'pending' })),
};

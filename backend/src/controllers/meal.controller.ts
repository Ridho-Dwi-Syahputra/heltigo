import { Request, Response } from 'express';
import { asyncHandler } from '../middleware/async.middleware';
import { mealService } from '../services/meal.service';

export const mealController = {
  getToday: asyncHandler(async (req: Request, res: Response) => {
    const result = await mealService.getToday(req.user!.id);
    res.json(result);
  }),

  getDayDetail: asyncHandler(async (req: Request, res: Response) => {
    const result = await mealService.getDayDetail(req.user!.id, req.params.dayId);
    res.json(result);
  }),

  getMealDetail: asyncHandler(async (req: Request, res: Response) => {
    const result = await mealService.getMealDetail(req.user!.id, req.params.mealId);
    res.json(result);
  }),

  logMeal: asyncHandler(async (req: Request, res: Response) => {
    const result = await mealService.logMeal(req.user!.id, req.params.mealId, req.body ?? {});
    res.status(201).json(result);
  }),

  swapMeal: asyncHandler(async (req: Request, res: Response) => {
    const result = await mealService.swapMeal(req.user!.id, req.params.mealId, req.body ?? {});
    res.json(result);
  }),

  replaceMeal: asyncHandler(async (req: Request, res: Response) => {
    const result = await mealService.replaceMeal(req.user!.id, req.params.mealId, req.body);
    res.json(result);
  }),

  getFoodDetail: asyncHandler(async (req: Request, res: Response) => {
    const result = await mealService.getFoodDetail(req.user!.id, req.params.foodId);
    res.json(result);
  }),

  getMealLog: asyncHandler(async (req: Request, res: Response) => {
    const days = parseInt((req.query.days as string) ?? '7', 10);
    const result = await mealService.getMealLog(req.user!.id, days);
    res.json(result);
  }),

  updateBudget: asyncHandler(async (req: Request, res: Response) => {
    const result = await mealService.updateBudget(req.user!.id, req.body);
    res.json(result);
  }),

  foodScan: asyncHandler(async (req: Request, res: Response) => {
    const result = await mealService.foodScan(req.user!.id, req.body ?? {});
    res.json(result);
  }),
};

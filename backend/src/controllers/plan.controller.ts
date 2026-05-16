import { Request, Response } from 'express';
import { asyncHandler } from '../middleware/async.middleware';
import { planService } from '../services/plan.service';
import { replanningService } from '../services/replanning.service';

export const planController = {
  generate: asyncHandler(async (req: Request, res: Response) => {
    const result = await planService.generate(req.user!.id, {
      workoutOnly: req.body?.workoutOnly === true,
      mealOnly: req.body?.mealOnly === true,
    });
    res.status(201).json({ status: 'success', data: result });
  }),

  getActive: asyncHandler(async (req: Request, res: Response) => {
    const result = await planService.getActive(req.user!.id);
    res.json(result);
  }),

  getHistory: asyncHandler(async (req: Request, res: Response) => {
    const result = await planService.getHistory(req.user!.id);
    res.json(result);
  }),

  getById: asyncHandler(async (req: Request, res: Response) => {
    const result = await planService.getById(req.user!.id, req.params.planId);
    res.json(result);
  }),

  replan: asyncHandler(async (req: Request, res: Response) => {
    const result = await replanningService.runReplan(req.user!.id, {
      applyImmediately: req.body?.applyImmediately === true,
    });
    res.status(201).json({ status: 'success', data: result });
  }),

  replanSkip: asyncHandler(async (_req: Request, res: Response) => {
    res.json({ status: 'success', message: 'Replan dilewati' });
  }),
};

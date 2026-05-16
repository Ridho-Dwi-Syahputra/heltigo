import { Request, Response } from 'express';
import { asyncHandler } from '../middleware/async.middleware';
import { progressService } from '../services/progress.service';

export const progressController = {
  getDaily: asyncHandler(async (req: Request, res: Response) => {
    const result = await progressService.getDaily(req.user!.id, req.query.date as string | undefined);
    res.json(result);
  }),
  updateWater: asyncHandler(async (req: Request, res: Response) => {
    const result = await progressService.updateWater(req.user!.id, req.body ?? {});
    res.json(result);
  }),
  logMood: asyncHandler(async (req: Request, res: Response) => {
    const result = await progressService.logMood(req.user!.id, req.body);
    res.status(201).json(result);
  }),
  getWeekly: asyncHandler(async (req: Request, res: Response) => {
    const result = await progressService.getWeekly(req.user!.id);
    res.json(result);
  }),
  getWeeklyReview: asyncHandler(async (req: Request, res: Response) => {
    const result = await progressService.getWeeklyReview(req.user!.id);
    res.json(result);
  }),
  getStreak: asyncHandler(async (req: Request, res: Response) => {
    const result = await progressService.getStreak(req.user!.id);
    res.json(result);
  }),
  getBadges: asyncHandler(async (req: Request, res: Response) => {
    const result = await progressService.getBadges(req.user!.id);
    res.json(result);
  }),
  getBadgeDetail: asyncHandler(async (req: Request, res: Response) => {
    const result = await progressService.getBadgeDetail(req.user!.id, req.params.code);
    res.json(result);
  }),
  getShareImage: asyncHandler(async (req: Request, res: Response) => {
    const result = await progressService.getShareImage(req.user!.id);
    res.json(result);
  }),
};

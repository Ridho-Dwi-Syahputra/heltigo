import { Request, Response } from 'express';
import { asyncHandler } from '../middleware/async.middleware';
import { profileService } from '../services/profile.service';
import { userRepo } from '../repositories/user.repo';

export const userController = {
  getProfile: asyncHandler(async (req: Request, res: Response) => {
    const result = await profileService.getProfile(req.user!.id);
    res.json(result);
  }),

  updateProfile: asyncHandler(async (req: Request, res: Response) => {
    const result = await profileService.updateProfile(req.user!.id, req.body ?? {});
    res.json(result);
  }),

  updateAvatar: asyncHandler(async (req: Request, res: Response) => {
    const result = await profileService.updateAvatar(req.user!.id, req.body.avatarUrl);
    res.json(result);
  }),

  createHealthProfile: asyncHandler(async (req: Request, res: Response) => {
    const result = await profileService.createHealthProfile(req.user!.id, req.body);
    res.status(201).json(result);
  }),

  updateHealthProfile: asyncHandler(async (req: Request, res: Response) => {
    const result = await profileService.updateHealthProfile(req.user!.id, req.body);
    res.json(result);
  }),

  getHealthMetrics: asyncHandler(async (req: Request, res: Response) => {
    const result = await profileService.getCurrentMetrics(req.user!.id);
    res.json(result);
  }),

  logHealthMetrics: asyncHandler(async (req: Request, res: Response) => {
    const result = await profileService.logHealthMetric(req.user!.id, req.body ?? {});
    res.status(201).json(result);
  }),

  getHealthMetricsHistory: asyncHandler(async (req: Request, res: Response) => {
    const days = parseInt((req.query.days as string) ?? '30', 10);
    const result = await profileService.getMetricsHistory(req.user!.id, days);
    res.json(result);
  }),

  deleteAccount: asyncHandler(async (req: Request, res: Response) => {
    await userRepo.softDelete(req.user!.id);
    res.status(204).send();
  }),
};

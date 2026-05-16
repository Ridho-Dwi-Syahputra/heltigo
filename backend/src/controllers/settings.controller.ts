import { Request, Response } from 'express';
import { asyncHandler } from '../middleware/async.middleware';
import { settingsService } from '../services/settings.service';

export const settingsController = {
  getSettings: asyncHandler(async (req: Request, res: Response) => {
    const result = await settingsService.getSettings(req.user!.id);
    res.json(result);
  }),
  updateSettings: asyncHandler(async (req: Request, res: Response) => {
    const result = await settingsService.updateSettings(req.user!.id, req.body ?? {});
    res.json(result);
  }),
};

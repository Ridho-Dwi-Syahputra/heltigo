import { Request, Response } from 'express';
import { asyncHandler } from '../middleware/async.middleware';

export const settingsController = {
  getSettings: asyncHandler(async (req: Request, res: Response) => {
    res.json({ message: 'Pending get settings logic' });
  }),
  updateSettings: asyncHandler(async (req: Request, res: Response) => {
    res.json({ message: 'Pending update settings logic' });
  })
};

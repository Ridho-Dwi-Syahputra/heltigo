import { Request, Response } from 'express';
import { asyncHandler } from '../middleware/async.middleware';

export const progressController = {
  getDaily: asyncHandler(async (req: Request, res: Response) => res.json({ message: 'pending' })),
  updateWater: asyncHandler(async (req: Request, res: Response) => res.json({ message: 'pending' })),
  logMood: asyncHandler(async (req: Request, res: Response) => res.json({ message: 'pending' })),
  getWeekly: asyncHandler(async (req: Request, res: Response) => res.json({ message: 'pending' })),
  getWeeklyReview: asyncHandler(async (req: Request, res: Response) => res.json({ message: 'pending' })),
  getStreak: asyncHandler(async (req: Request, res: Response) => res.json({ message: 'pending' })),
  getBadges: asyncHandler(async (req: Request, res: Response) => res.json({ message: 'pending' })),
  getBadgeDetail: asyncHandler(async (req: Request, res: Response) => res.json({ message: 'pending' })),
  getShareImage: asyncHandler(async (req: Request, res: Response) => res.json({ message: 'pending' })),
};

import { Request, Response } from 'express';
import { asyncHandler } from '../middleware/async.middleware';

export const workoutController = {
  getToday: asyncHandler(async (req: Request, res: Response) => res.json({ message: 'pending' })),
  getDayDetail: asyncHandler(async (req: Request, res: Response) => res.json({ message: 'pending' })),
  getExerciseDetail: asyncHandler(async (req: Request, res: Response) => res.json({ message: 'pending' })),
  checkIn: asyncHandler(async (req: Request, res: Response) => res.status(201).json({ message: 'pending' })),
  updateExercise: asyncHandler(async (req: Request, res: Response) => res.json({ message: 'pending' })),
  pauseSession: asyncHandler(async (req: Request, res: Response) => res.json({ message: 'pending' })),
  completeSession: asyncHandler(async (req: Request, res: Response) => res.json({ message: 'pending' })),
  getSessionDetail: asyncHandler(async (req: Request, res: Response) => res.json({ message: 'pending' })),
  getSessionsHistory: asyncHandler(async (req: Request, res: Response) => res.json({ message: 'pending' })),
  swapExercise: asyncHandler(async (req: Request, res: Response) => res.json({ message: 'pending' })),
};

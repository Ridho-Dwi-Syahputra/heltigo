import { Request, Response } from 'express';
import { asyncHandler } from '../middleware/async.middleware';

export const userController = {
  getProfile: asyncHandler(async (req: Request, res: Response) => {
    res.json({ message: 'getProfile pending' });
  }),
  updateProfile: asyncHandler(async (req: Request, res: Response) => {
    res.json({ message: 'updateProfile pending' });
  }),
  updateAvatar: asyncHandler(async (req: Request, res: Response) => {
    res.json({ message: 'updateAvatar pending' });
  }),
  createHealthProfile: asyncHandler(async (req: Request, res: Response) => {
    res.status(201).json({ message: 'createHealthProfile pending' });
  }),
  updateHealthProfile: asyncHandler(async (req: Request, res: Response) => {
    res.json({ message: 'updateHealthProfile pending' });
  }),
  getHealthMetrics: asyncHandler(async (req: Request, res: Response) => {
    res.json({ message: 'getHealthMetrics pending' });
  }),
  logHealthMetrics: asyncHandler(async (req: Request, res: Response) => {
    res.status(201).json({ message: 'logHealthMetrics pending' });
  }),
  getHealthMetricsHistory: asyncHandler(async (req: Request, res: Response) => {
    res.json({ message: 'getHealthMetricsHistory pending' });
  }),
  deleteAccount: asyncHandler(async (req: Request, res: Response) => {
    res.status(204).send();
  }),
};

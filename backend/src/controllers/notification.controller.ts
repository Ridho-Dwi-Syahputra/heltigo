import { Request, Response } from 'express';
import { asyncHandler } from '../middleware/async.middleware';

export const notificationController = {
  getAll: asyncHandler(async (req: Request, res: Response) => {
    res.json({ message: 'Pending notifications logic', data: [] });
  }),
  markAsRead: asyncHandler(async (req: Request, res: Response) => {
    res.json({ message: 'Pending mark as read logic' });
  }),
  markAllAsRead: asyncHandler(async (req: Request, res: Response) => {
    res.json({ message: 'Pending mark all as read logic' });
  }),
  registerFcmToken: asyncHandler(async (req: Request, res: Response) => {
    res.json({ message: 'Pending register FCM token logic' });
  }),
  deleteFcmToken: asyncHandler(async (req: Request, res: Response) => {
    res.json({ message: 'Pending delete FCM token logic' });
  })
};

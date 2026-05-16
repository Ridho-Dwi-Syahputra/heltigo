import { Request, Response } from 'express';
import { asyncHandler } from '../middleware/async.middleware';
import { notificationService } from '../services/notification.service';

export const notificationController = {
  getAll: asyncHandler(async (req: Request, res: Response) => {
    const unreadOnly = req.query.unreadOnly === 'true';
    const limit = parseInt((req.query.limit as string) ?? '30', 10);
    const result = await notificationService.listForUser(req.user!.id, { unreadOnly, limit });
    res.json(result);
  }),
  markAsRead: asyncHandler(async (req: Request, res: Response) => {
    const result = await notificationService.markAsRead(req.user!.id, req.params.id);
    res.json(result);
  }),
  markAllAsRead: asyncHandler(async (req: Request, res: Response) => {
    const result = await notificationService.markAllAsRead(req.user!.id);
    res.json(result);
  }),
  registerFcmToken: asyncHandler(async (req: Request, res: Response) => {
    const result = await notificationService.registerFcmToken(req.user!.id, req.body);
    res.status(201).json(result);
  }),
  deleteFcmToken: asyncHandler(async (req: Request, res: Response) => {
    const result = await notificationService.deleteFcmToken(req.user!.id, req.body);
    res.json(result);
  }),
};

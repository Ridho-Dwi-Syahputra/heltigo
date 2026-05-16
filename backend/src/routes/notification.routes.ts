import { Router } from 'express';
import { notificationController } from '../controllers/notification.controller';
import { requireAuth } from '../middleware/auth.middleware';

export const notificationRouter = Router();
notificationRouter.use(requireAuth);

notificationRouter.get('/', notificationController.getAll);
notificationRouter.patch('/read-all', notificationController.markAllAsRead);
notificationRouter.patch('/:id/read', notificationController.markAsRead);
notificationRouter.post('/fcm-token', notificationController.registerFcmToken);
notificationRouter.delete('/fcm-token', notificationController.deleteFcmToken);

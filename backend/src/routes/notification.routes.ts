import { Router } from 'express';
import { notificationController } from '../controllers/notification.controller';

export const notificationRouter = Router();

notificationRouter.get('/', notificationController.getAll);
notificationRouter.patch('/:id/read', notificationController.markAsRead);
notificationRouter.patch('/read-all', notificationController.markAllAsRead);
notificationRouter.post('/fcm-token', notificationController.registerFcmToken);
notificationRouter.delete('/fcm-token', notificationController.deleteFcmToken);

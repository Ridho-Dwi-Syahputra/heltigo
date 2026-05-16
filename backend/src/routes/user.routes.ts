import { Router } from 'express';
import { userController } from '../controllers/user.controller';
import { requireAuth } from '../middleware/auth.middleware';

export const userRouter = Router();

userRouter.use(requireAuth);

userRouter.get('/profile', userController.getProfile);
userRouter.put('/profile', userController.updateProfile);
userRouter.patch('/profile/avatar', userController.updateAvatar);
userRouter.post('/health-profile', userController.createHealthProfile);
userRouter.put('/health-profile', userController.updateHealthProfile);
userRouter.get('/health-metrics', userController.getHealthMetrics);
userRouter.post('/health-metrics', userController.logHealthMetrics);
userRouter.get('/health-metrics/history', userController.getHealthMetricsHistory);
userRouter.delete('/account', userController.deleteAccount);

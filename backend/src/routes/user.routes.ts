import { Router } from 'express';
import { userController } from '../controllers/user.controller';
import { requireAuth } from '../middleware/auth.middleware';
import { validate } from '../middleware/validate.middleware';
import {
  updateProfileSchema,
  updateAvatarSchema,
  createHealthProfileSchema,
  updateHealthProfileSchema,
  logHealthMetricsSchema,
} from '../validators/user.schema';

export const userRouter = Router();

userRouter.use(requireAuth);

userRouter.get('/profile', userController.getProfile);
userRouter.put('/profile', validate(updateProfileSchema), userController.updateProfile);
userRouter.patch('/profile/avatar', validate(updateAvatarSchema), userController.updateAvatar);
userRouter.post('/health-profile', validate(createHealthProfileSchema), userController.createHealthProfile);
userRouter.put('/health-profile', validate(updateHealthProfileSchema), userController.updateHealthProfile);
userRouter.get('/health-metrics', userController.getHealthMetrics);
userRouter.post('/health-metrics', validate(logHealthMetricsSchema), userController.logHealthMetrics);
userRouter.get('/health-metrics/history', userController.getHealthMetricsHistory);
userRouter.delete('/account', userController.deleteAccount);

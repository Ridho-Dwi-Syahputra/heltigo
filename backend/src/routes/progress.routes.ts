import { Router } from 'express';
import { progressController } from '../controllers/progress.controller';
import { requireAuth } from '../middleware/auth.middleware';

export const progressRouter = Router();
progressRouter.use(requireAuth);

progressRouter.get('/daily', progressController.getDaily);
progressRouter.patch('/daily/water', progressController.updateWater);
progressRouter.post('/daily/mood', progressController.logMood);
progressRouter.get('/weekly', progressController.getWeekly);
progressRouter.get('/weekly-review', progressController.getWeeklyReview);
progressRouter.get('/streak', progressController.getStreak);
progressRouter.get('/badges', progressController.getBadges);
progressRouter.get('/badge/:code', progressController.getBadgeDetail);
progressRouter.get('/share-image', progressController.getShareImage);

import { Router } from 'express';
import { settingsController } from '../controllers/settings.controller';
import { requireAuth } from '../middleware/auth.middleware';

export const settingsRouter = Router();
settingsRouter.use(requireAuth);

settingsRouter.get('/', settingsController.getSettings);
settingsRouter.put('/', settingsController.updateSettings);

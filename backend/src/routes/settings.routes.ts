import { Router } from 'express';
import { settingsController } from '../controllers/settings.controller';

export const settingsRouter = Router();

settingsRouter.get('/', settingsController.getSettings);
settingsRouter.put('/', settingsController.updateSettings);

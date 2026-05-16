import { Router } from 'express';
import { planController } from '../controllers/plan.controller';
import { requireAuth } from '../middleware/auth.middleware';

export const planRouter = Router();

planRouter.use(requireAuth);

planRouter.post('/generate', planController.generate);
planRouter.get('/active', planController.getActive);
planRouter.get('/history', planController.getHistory);
planRouter.get('/:planId', planController.getById);
planRouter.post('/replan', planController.replan);
planRouter.post('/replan/skip', planController.replanSkip);

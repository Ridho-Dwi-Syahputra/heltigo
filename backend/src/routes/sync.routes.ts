import { Router } from 'express';
import { syncController } from '../controllers/sync.controller';
import { requireAuth } from '../middleware/auth.middleware';

export const syncRouter = Router();
syncRouter.use(requireAuth);

syncRouter.post('/batch', syncController.batchSync);

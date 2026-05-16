import { Router } from 'express';
import { syncController } from '../controllers/sync.controller';

export const syncRouter = Router();

syncRouter.post('/batch', syncController.batchSync);

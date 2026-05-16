import { Request, Response } from 'express';
import { asyncHandler } from '../middleware/async.middleware';
import { syncService } from '../services/sync.service';

export const syncController = {
  batchSync: asyncHandler(async (req: Request, res: Response) => {
    const result = await syncService.processBatch(req.user!.id, req.body?.operations ?? []);
    res.json(result);
  }),
};

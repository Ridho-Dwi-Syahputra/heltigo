import { Request, Response } from 'express';
import { asyncHandler } from '../middleware/async.middleware';

export const syncController = {
  batchSync: asyncHandler(async (req: Request, res: Response) => {
    res.json({ message: 'Pending batch sync logic', status: 'success' });
  })
};

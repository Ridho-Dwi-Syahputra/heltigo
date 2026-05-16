import { Request, Response } from 'express';
import { asyncHandler } from '../middleware/async.middleware';
import { workoutService } from '../services/workout.service';

export const workoutController = {
  getToday: asyncHandler(async (req: Request, res: Response) => {
    const result = await workoutService.getToday(req.user!.id);
    res.json(result);
  }),

  getDayDetail: asyncHandler(async (req: Request, res: Response) => {
    const result = await workoutService.getDayDetail(req.user!.id, req.params.dayId);
    res.json(result);
  }),

  getExerciseDetail: asyncHandler(async (req: Request, res: Response) => {
    const result = await workoutService.getExerciseDetail(req.user!.id, req.params.exerciseId);
    res.json(result);
  }),

  checkIn: asyncHandler(async (req: Request, res: Response) => {
    const result = await workoutService.checkIn(req.user!.id, req.params.dayId, req.body ?? {});
    res.status(201).json(result);
  }),

  updateExercise: asyncHandler(async (req: Request, res: Response) => {
    const result = await workoutService.updateExerciseLog(
      req.user!.id,
      req.params.sessionId,
      req.body ?? {},
    );
    res.json(result);
  }),

  pauseSession: asyncHandler(async (req: Request, res: Response) => {
    const result = await workoutService.pauseSession(req.user!.id, req.params.sessionId);
    res.json(result);
  }),

  completeSession: asyncHandler(async (req: Request, res: Response) => {
    const result = await workoutService.completeSession(
      req.user!.id,
      req.params.sessionId,
      req.body ?? {},
    );
    res.json(result);
  }),

  getSessionDetail: asyncHandler(async (req: Request, res: Response) => {
    const result = await workoutService.getSessionDetail(req.user!.id, req.params.sessionId);
    res.json(result);
  }),

  getSessionsHistory: asyncHandler(async (req: Request, res: Response) => {
    const limit = parseInt((req.query.limit as string) ?? '20', 10);
    const result = await workoutService.getSessionsHistory(req.user!.id, limit);
    res.json(result);
  }),

  swapExercise: asyncHandler(async (req: Request, res: Response) => {
    const result = await workoutService.swapExercise(
      req.user!.id,
      req.params.exerciseId,
      req.body ?? {},
    );
    res.json(result);
  }),
};

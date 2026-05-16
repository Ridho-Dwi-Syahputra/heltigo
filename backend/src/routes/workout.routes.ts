import { Router } from 'express';
import { workoutController } from '../controllers/workout.controller';
import { requireAuth } from '../middleware/auth.middleware';

export const workoutRouter = Router();
workoutRouter.use(requireAuth);

workoutRouter.get('/today', workoutController.getToday);
workoutRouter.get('/day/:dayId', workoutController.getDayDetail);
workoutRouter.get('/exercise/:exerciseId', workoutController.getExerciseDetail);
workoutRouter.post('/:dayId/check-in', workoutController.checkIn);
workoutRouter.patch('/session/:sessionId/exercise', workoutController.updateExercise);
workoutRouter.post('/session/:sessionId/pause', workoutController.pauseSession);
workoutRouter.post('/session/:sessionId/complete', workoutController.completeSession);
workoutRouter.get('/session/:sessionId', workoutController.getSessionDetail);
workoutRouter.get('/sessions', workoutController.getSessionsHistory);
workoutRouter.post('/exercise/:exerciseId/swap', workoutController.swapExercise);

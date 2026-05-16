import { Router } from 'express';
import { requireAuth } from '../middleware/auth.middleware';
import * as mlController from '../controllers/ml.controller';

export const mlRouter = Router();

// Assuming requireAuth middleware exists and we want ML endpoints protected
mlRouter.use(requireAuth);

mlRouter.post('/food-scan', mlController.predictFoodScan);
mlRouter.post('/meal-plan', mlController.predictMealPlan);
mlRouter.post('/meal-alternatives', mlController.predictMealAlternatives);
mlRouter.post('/replan', mlController.predictReplan);
mlRouter.post('/workout-plan', mlController.predictWorkoutPlan);

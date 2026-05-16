import { Router } from 'express';
import { mealController } from '../controllers/meal.controller';
import { requireAuth } from '../middleware/auth.middleware';

export const mealRouter = Router();
mealRouter.use(requireAuth);

mealRouter.get('/today', mealController.getToday);
mealRouter.get('/log', mealController.getMealLog);
mealRouter.put('/budget', mealController.updateBudget);
mealRouter.post('/food-scan', mealController.foodScan);
mealRouter.get('/day/:dayId', mealController.getDayDetail);
mealRouter.get('/food/:foodId', mealController.getFoodDetail);
mealRouter.get('/:mealId', mealController.getMealDetail);
mealRouter.post('/:mealId/log', mealController.logMeal);
mealRouter.post('/:mealId/swap', mealController.swapMeal);
mealRouter.post('/:mealId/replace', mealController.replaceMeal);

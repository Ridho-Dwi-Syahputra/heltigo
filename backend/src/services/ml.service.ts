import { mlClient } from '../ml-client/ml.client';

export class MlService {
  static async predictFoodScan(payload: any) {
    return mlClient.post('/predict/food-scan', payload);
  }

  static async predictMealPlan(payload: any) {
    return mlClient.post('/predict/meal-plan', payload);
  }

  static async predictMealAlternatives(payload: any) {
    return mlClient.post('/predict/meal-alternatives', payload);
  }

  static async predictReplan(payload: any) {
    return mlClient.post('/predict/replan', payload);
  }

  static async predictWorkoutPlan(payload: any) {
    return mlClient.post('/predict/workout-plan', payload);
  }
}

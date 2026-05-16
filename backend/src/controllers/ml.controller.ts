import { Request, Response, NextFunction } from 'express';
import { MlService } from '../services/ml.service';

export const predictFoodScan = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const result = await MlService.predictFoodScan(req.body);
    res.status(200).json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
};

export const predictMealPlan = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const result = await MlService.predictMealPlan(req.body);
    res.status(200).json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
};

export const predictMealAlternatives = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const result = await MlService.predictMealAlternatives(req.body);
    res.status(200).json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
};

export const predictReplan = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const result = await MlService.predictReplan(req.body);
    res.status(200).json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
};

export const predictWorkoutPlan = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const result = await MlService.predictWorkoutPlan(req.body);
    res.status(200).json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
};

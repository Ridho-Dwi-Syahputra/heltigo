import { Router } from 'express';
import { authRouter } from './auth.routes';
import { userRouter } from './user.routes';
import { planRouter } from './plan.routes';
import { workoutRouter } from './workout.routes';
import { mealRouter } from './meal.routes';
import { progressRouter } from './progress.routes';
import { notificationRouter } from './notification.routes';
import { settingsRouter } from './settings.routes';
import { syncRouter } from './sync.routes';

export const v1Router = Router();

v1Router.use('/auth', authRouter);
v1Router.use('/user', userRouter);
v1Router.use('/plan', planRouter);
v1Router.use('/workout', workoutRouter);
v1Router.use('/meal', mealRouter);
v1Router.use('/progress', progressRouter);
v1Router.use('/notifications', notificationRouter);
v1Router.use('/settings', settingsRouter);
v1Router.use('/sync', syncRouter);
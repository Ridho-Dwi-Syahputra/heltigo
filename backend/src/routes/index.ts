import { Router } from 'express';
import { authRouter } from './auth.routes';
import { mlRouter } from './ml.routes';

export const v1Router = Router();

v1Router.use('/auth', authRouter);
v1Router.use('/ml', mlRouter);
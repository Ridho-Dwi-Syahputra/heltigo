import { Router } from 'express';
import { authController } from '../controllers/auth.controller';
import { validate } from '../middleware/validate.middleware';
import { requireAuth } from '../middleware/auth.middleware';
import { signupSchema, loginSchema } from '../validators/auth.schema';

export const authRouter = Router();

authRouter.post('/register', validate(signupSchema), authController.register);
authRouter.post('/login', validate(loginSchema), authController.login);
authRouter.get('/me', requireAuth, authController.me);
authRouter.post('/logout', requireAuth, authController.logout);
authRouter.post('/refresh-token', authController.refreshToken);

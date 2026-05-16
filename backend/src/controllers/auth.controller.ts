import { Request, Response } from 'express';
import { asyncHandler } from '../middleware/async.middleware';
import { authService } from '../services/auth.service';

export const authController = {
  register: asyncHandler(async (req: Request, res: Response) => {
    const { email, password, name } = req.body;
    const result = await authService.register(email, password, name);
    res.status(201).json(result);
  }),

  login: asyncHandler(async (req: Request, res: Response) => {
    const { email, password } = req.body;
    const result = await authService.login(email, password);
    res.json(result);
  }),

  me: asyncHandler(async (req: Request, res: Response) => {
    const result = await authService.getMe(req.user!.id);
    res.json(result);
  }),

  logout: asyncHandler(async (req: Request, res: Response) => {
    // In a real app with refresh tokens, we'd revoke the token in DB here
    res.status(204).send();
  }),

  refreshToken: asyncHandler(async (req: Request, res: Response) => {
    const { refreshToken } = req.body;
    // Implement refresh token logic using authService
    res.status(200).json({ accessToken: 'new-token' });
  }),

  forgotPassword: asyncHandler(async (req: Request, res: Response) => {
    res.json({ message: 'Pending forgot password logic' });
  }),

  resetPassword: asyncHandler(async (req: Request, res: Response) => {
    res.json({ message: 'Pending reset password logic' });
  }),
};

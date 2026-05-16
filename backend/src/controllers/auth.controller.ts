import { Request, Response } from 'express';
import { asyncHandler } from '../middleware/async.middleware';
import { authService } from '../services/auth.service';
import { ApiError } from '../utils/api-error';

export const authController = {
  register: asyncHandler(async (req: Request, res: Response) => {
    const { email, password, name } = req.body;
    const ua = req.headers['user-agent'];
    const result = await authService.register(email, password, name, ua);
    res.status(201).json(result);
  }),

  login: asyncHandler(async (req: Request, res: Response) => {
    const { email, password } = req.body;
    const ua = req.headers['user-agent'];
    const result = await authService.login(email, password, ua);
    res.json(result);
  }),

  me: asyncHandler(async (req: Request, res: Response) => {
    const result = await authService.getMe(req.user!.id);
    res.json(result);
  }),

  logout: asyncHandler(async (req: Request, res: Response) => {
    const { refreshToken } = req.body ?? {};
    await authService.logout(refreshToken);
    res.status(204).send();
  }),

  refreshToken: asyncHandler(async (req: Request, res: Response) => {
    const { refreshToken } = req.body ?? {};
    const ua = req.headers['user-agent'];
    const result = await authService.refresh(refreshToken, ua);
    res.json(result);
  }),

  forgotPassword: asyncHandler(async (req: Request, res: Response) => {
    const { email } = req.body ?? {};
    if (!email) throw new ApiError(400, 'EMAIL_REQUIRED', 'Email wajib diisi');
    const result = await authService.forgotPassword(email);
    res.json(result);
  }),

  resetPassword: asyncHandler(async (req: Request, res: Response) => {
    const { token, newPassword } = req.body ?? {};
    if (!token || !newPassword) {
      throw new ApiError(400, 'INVALID_INPUT', 'Token dan password baru wajib diisi');
    }
    const result = await authService.resetPassword(token, newPassword);
    res.json(result);
  }),
};

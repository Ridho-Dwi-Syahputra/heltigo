import { Request, Response, NextFunction } from 'express';
import { verifyJwt } from '../utils/jwt.util';
import { ApiError } from '../utils/api-error';

export function requireAuth(req: Request, _res: Response, next: NextFunction) {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) {
    return next(new ApiError(401, 'UNAUTHORIZED', 'Token tidak ditemukan'));
  }
  const token = header.slice(7);
  try {
    const payload = verifyJwt(token);
    req.user = { id: payload.userId, email: payload.email };
    next();
  } catch (e: any) {
    if (e.name === 'TokenExpiredError') {
      return next(new ApiError(401, 'TOKEN_EXPIRED', 'Token sudah kedaluwarsa, silakan login ulang'));
    }
    return next(new ApiError(401, 'TOKEN_INVALID', 'Token tidak valid'));
  }
}

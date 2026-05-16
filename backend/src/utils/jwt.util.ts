import jwt from 'jsonwebtoken';
import { env } from '../config/env';

export interface JwtPayload {
  userId: string;
  email: string;
}

export function signJwt(payload: JwtPayload): string {
  return jwt.sign(payload, env.JWT_SECRET, {
    expiresIn: parseInt(env.JWT_ACCESS_EXPIRES, 10),
    issuer: 'heltigo-api',
    audience: 'heltigo-mobile',
  });
}

export function verifyJwt(token: string): JwtPayload {
  const decoded = jwt.verify(token, env.JWT_SECRET, {
    issuer: 'heltigo-api',
    audience: 'heltigo-mobile',
  });
  if (typeof decoded === 'string') {
    throw new Error('Invalid token payload');
  }
  return { userId: decoded.sub as string || decoded.userId, email: decoded.email };
}

# Backend — Auth & JWT

> 📌 **Update 2026-05-15** — Spec auth final:
> - **Access token TTL:** 15 menit (`JWT_ACCESS_EXPIRES=900s`)
> - **Refresh token TTL:** 7 hari (`JWT_REFRESH_EXPIRES=604800s`), **wajib** di-rotate setiap pakai (revoke yang lama, issue baru). Hash SHA-256 disimpan di tabel `refresh_tokens`.
> - **Bcrypt cost:** 12 (lebih kuat dari draft 10). Latency signup/login +200ms (acceptable).
> - **Endpoint refresh wajib:** `POST /auth/refresh-token` dengan body `{refreshToken}` → response `{accessToken}` (refresh juga di-rotate).
> - **Endpoint logout:** revoke refresh token di DB (`UPDATE refresh_tokens SET revoked_at = NOW()`).
> - **Path final:** `/auth/register` (bukan `/v1/auth/signup`), `/auth/login`, `/auth/logout`, `/auth/refresh-token`, `/auth/forgot-password` (Phase 4), `/auth/reset-password` (Phase 4).
>
> Source of truth: [`FE_requirement/00_API_REQUIREMENTS.md`](FE_requirement/00_API_REQUIREMENTS.md) §2.

## 1. Strategi

- **Mandatory auth** dengan email + password (sesuai keputusan D-05 di `00_ARCHITECTURE.md`).
- **JWT stateless**: token berisi `userId`, `email`, `iat`, `exp`. Server tidak simpan session.
- **Single token** sederhana untuk hackathon. Refresh token *opsional* — diadd jika waktu cukup.
- **Bcrypt** untuk hash password (cost factor 10).
- **Secure storage** di mobile (`flutter_secure_storage`) — Keychain iOS, EncryptedSharedPreferences Android.

## 2. Library

```json
"jsonwebtoken": "^9.0.2",
"bcrypt": "^5.1.1",
"@types/jsonwebtoken": "^9.0.6",
"@types/bcrypt": "^5.0.2"
```

## 3. JWT Configuration

File: `src/utils/jwt.util.ts`

```ts
import jwt from 'jsonwebtoken';
import { env } from '../config/env';

export interface JwtPayload {
  userId: string;
  email: string;
}

export function signJwt(payload: JwtPayload): string {
  return jwt.sign(payload, env.JWT_SECRET, {
    expiresIn: env.JWT_EXPIRES_IN, // '7d'
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
  return { userId: decoded.userId, email: decoded.email };
}
```

**Catatan keamanan:**
- `JWT_SECRET` minimum 32 karakter random. Generate: `openssl rand -base64 48`.
- Jangan commit `.env` ke git. Tambahkan `.env` di `.gitignore`.
- Untuk production: rotate secret saat ada compromise (semua user paksa logout).

## 4. Password Hashing

File: `src/utils/password.util.ts`

```ts
import bcrypt from 'bcrypt';
import { env } from '../config/env';

const ROUNDS = parseInt(env.BCRYPT_ROUNDS, 10);

export async function hashPassword(plain: string): Promise<string> {
  return bcrypt.hash(plain, ROUNDS);
}

export async function comparePassword(plain: string, hash: string): Promise<boolean> {
  return bcrypt.compare(plain, hash);
}
```

`BCRYPT_ROUNDS=10` aman & cepat. `12` lebih aman tapi 4x lebih lambat — tidak perlu untuk hackathon.

## 5. Auth Service

File: `src/services/auth.service.ts`

```ts
import { ApiError } from '../utils/api-error';
import { hashPassword, comparePassword } from '../utils/password.util';
import { signJwt } from '../utils/jwt.util';
import { userRepo } from '../repositories/user.repo';

export const authService = {
  async signup(email: string, password: string) {
    const existing = await userRepo.findByEmail(email);
    if (existing) throw new ApiError(409, 'EMAIL_TAKEN', 'Email sudah terdaftar');

    const passwordHash = await hashPassword(password);
    const user = await userRepo.create({ email, passwordHash });

    const token = signJwt({ userId: user.id, email: user.email });
    return { user: this._toPublicUser(user), token };
  },

  async login(email: string, password: string) {
    const user = await userRepo.findByEmail(email);
    if (!user) throw new ApiError(401, 'INVALID_CREDENTIALS', 'Email atau password salah');

    const valid = await comparePassword(password, user.passwordHash);
    if (!valid) throw new ApiError(401, 'INVALID_CREDENTIALS', 'Email atau password salah');

    const token = signJwt({ userId: user.id, email: user.email });
    return { user: this._toPublicUser(user), token };
  },

  async getMe(userId: string) {
    const user = await userRepo.findByIdWithProfile(userId);
    if (!user) throw new ApiError(404, 'USER_NOT_FOUND', 'User tidak ditemukan');
    return { user: this._toPublicUser(user) };
  },

  _toPublicUser(user: any) {
    return {
      id: user.id,
      email: user.email,
      has_profile: user.profile != null,
      created_at: user.createdAt,
    };
  },
};
```

## 6. Auth Middleware

File: `src/middleware/auth.middleware.ts`

```ts
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
```

Augmentasi `Request` di `src/types/express.d.ts`:
```ts
declare global {
  namespace Express {
    interface Request {
      user?: { id: string; email: string };
    }
  }
}
export {};
```

## 7. Routes Setup

File: `src/routes/auth.routes.ts`

```ts
import { Router } from 'express';
import { authController } from '../controllers/auth.controller';
import { validate } from '../middleware/validate.middleware';
import { requireAuth } from '../middleware/auth.middleware';
import { signupSchema, loginSchema } from '../validators/auth.schema';

export const authRouter = Router();

authRouter.post('/signup', validate(signupSchema), authController.signup);
authRouter.post('/login', validate(loginSchema), authController.login);
authRouter.get('/me', requireAuth, authController.me);
authRouter.post('/logout', requireAuth, authController.logout);
```

File: `src/validators/auth.schema.ts`

```ts
import { z } from 'zod';

export const signupSchema = z.object({
  body: z.object({
    email: z.string().email('Format email tidak valid'),
    password: z.string().min(8, 'Password minimum 8 karakter').max(128),
  }),
});

export const loginSchema = z.object({
  body: z.object({
    email: z.string().email(),
    password: z.string().min(1),
  }),
});
```

## 8. Controller

File: `src/controllers/auth.controller.ts`

```ts
import { Request, Response } from 'express';
import { asyncHandler } from '../middleware/async.middleware';
import { authService } from '../services/auth.service';

export const authController = {
  signup: asyncHandler(async (req: Request, res: Response) => {
    const { email, password } = req.body;
    const result = await authService.signup(email, password);
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

  logout: asyncHandler(async (_req: Request, res: Response) => {
    // Stateless JWT, hapus client-side. Tidak ada server state.
    res.status(204).send();
  }),
};
```

## 9. Flow End-to-End

### 9.1 Signup
```
Mobile (S-05 → Signup) ── POST /v1/auth/signup ──▶ Express
                                                    │
                                                    ├─ validate input
                                                    ├─ check email taken
                                                    ├─ bcrypt hash password
                                                    ├─ INSERT INTO users
                                                    └─ sign JWT
Mobile ◀── 201 { user, token } ────────────────────┘
   │
   ├─ flutter_secure_storage.write('token', token)
   └─ navigate to /setup/step1
```

### 9.2 Login
```
Mobile ── POST /v1/auth/login ─▶ Express
                                  ├─ find user by email
                                  ├─ bcrypt compare
                                  └─ sign JWT
Mobile ◀── 200 { user, token } ──┘
   │
   ├─ store token
   └─ if user.has_profile → /home, else → /setup/step1
```

### 9.3 Request dengan Token
```
Mobile ── GET /v1/profile + Authorization: Bearer xxx ─▶ Express
                                                          ├─ requireAuth verify token
                                                          ├─ attach req.user
                                                          ├─ profile.controller
                                                          └─ profileService.get(req.user.id)
Mobile ◀── 200 { profile } ──────────────────────────────┘
```

### 9.4 Token Expired
```
Mobile ── GET /v1/profile + expired token ─▶ Express
                                              └─ TokenExpiredError
Mobile ◀── 401 TOKEN_EXPIRED ─────────────────┘
   │
   ├─ AuthInterceptor catch 401 → logout (clear secureStorage)
   └─ redirect ke /welcome
```

## 10. Refresh Token (Opsional, Pasca-Hackathon)

Jika waktu cukup atau pasca-hackathon, tambahkan refresh token flow:

- Tabel `refresh_tokens` (id, userId, tokenHash, expiresAt, revoked)
- POST `/v1/auth/refresh` body `{ refresh_token }` → return access token baru
- Access token TTL pendek (15 menit), refresh token TTL panjang (30 hari)
- Mobile pakai access token; saat 401 expired → coba refresh, baru retry request

Untuk hackathon, **TTL access token = 7 hari** sudah cukup. User akan rejected sekali setelah 7 hari, harus login ulang.

## 11. Rate Limiting (Opsional)

Untuk endpoint auth, tambah `express-rate-limit`:

```ts
import rateLimit from 'express-rate-limit';

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 menit
  max: 10, // 10 request per IP
  message: { error: { code: 'TOO_MANY_REQUESTS', message: 'Terlalu banyak percobaan, coba lagi nanti.' } },
});

authRouter.post('/signup', authLimiter, ...);
authRouter.post('/login', authLimiter, ...);
```

Mencegah brute force. Tidak prioritas hackathon tapi mudah ditambah.

## 12. Testing Auth

```ts
// tests/auth.test.ts
import { test, expect } from 'vitest';
import request from 'supertest';
import { createApp } from '../src/app';

const app = createApp();

test('signup → login → me end-to-end', async () => {
  const email = `test-${Date.now()}@example.com`;

  // signup
  const r1 = await request(app).post('/v1/auth/signup').send({ email, password: 'password123' });
  expect(r1.status).toBe(201);
  const token1 = r1.body.token;

  // login
  const r2 = await request(app).post('/v1/auth/login').send({ email, password: 'password123' });
  expect(r2.status).toBe(200);
  const token2 = r2.body.token;
  // Note: token1 !== token2 karena iat berbeda

  // me
  const r3 = await request(app).get('/v1/auth/me').set('Authorization', `Bearer ${token2}`);
  expect(r3.status).toBe(200);
  expect(r3.body.user.email).toBe(email);
  expect(r3.body.user.has_profile).toBe(false);
});

test('login wrong password returns 401', async () => {
  const r = await request(app).post('/v1/auth/login').send({ email: 'x@x.com', password: 'wrong' });
  expect(r.status).toBe(401);
  expect(r.body.error.code).toBe('INVALID_CREDENTIALS');
});
```

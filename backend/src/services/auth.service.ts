import { ApiError } from '../utils/api-error';
import { hashPassword, comparePassword } from '../utils/password.util';
import { signJwt } from '../utils/jwt.util';
import { generateRefreshToken, hashToken, generateResetToken } from '../utils/token.util';
import { userRepo } from '../repositories/user.repo';
import { prisma } from '../config/db';
import { env } from '../config/env';
import { logger } from '../utils/logger';

const REFRESH_EXPIRES_SEC = parseInt(env.JWT_REFRESH_EXPIRES, 10) || 604800;

function publicUser(user: any, healthProfile?: any) {
  return {
    id: user.id.toString(),
    email: user.email,
    name: user.name,
    avatar_url: user.avatarUrl ?? null,
    has_profile: !!healthProfile,
    created_at: user.createdAt,
  };
}

async function issueRefreshToken(userId: bigint, userAgent?: string) {
  const { raw, hash } = generateRefreshToken();
  const expiresAt = new Date(Date.now() + REFRESH_EXPIRES_SEC * 1000);
  await prisma.refreshToken.create({
    data: { userId, tokenHash: hash, expiresAt, userAgent: userAgent?.slice(0, 255) },
  });
  return raw;
}

export const authService = {
  async register(email: string, password: string, name: string | undefined, userAgent?: string) {
    const existing = await userRepo.findByEmail(email);
    if (existing) throw new ApiError(409, 'EMAIL_TAKEN', 'Email sudah terdaftar');

    const passwordHash = await hashPassword(password);
    const user = await userRepo.create({ email, passwordHash, name });

    const accessToken = signJwt({ userId: user.id.toString(), email: user.email });
    const refreshToken = await issueRefreshToken(user.id, userAgent);

    return { user: publicUser(user), accessToken, refreshToken };
  },

  async login(email: string, password: string, userAgent?: string) {
    const user = await userRepo.findByEmail(email);
    if (!user || user.deletedAt) {
      throw new ApiError(401, 'INVALID_CREDENTIALS', 'Email atau password salah');
    }
    const valid = await comparePassword(password, user.passwordHash);
    if (!valid) throw new ApiError(401, 'INVALID_CREDENTIALS', 'Email atau password salah');

    await userRepo.updateLastLogin(user.id.toString());

    const accessToken = signJwt({ userId: user.id.toString(), email: user.email });
    const refreshToken = await issueRefreshToken(user.id, userAgent);

    const profile = await prisma.healthProfile.findUnique({ where: { userId: user.id } });
    return { user: publicUser(user, profile), accessToken, refreshToken };
  },

  async getMe(userId: string) {
    const user = await userRepo.findByIdWithProfile(userId);
    if (!user) throw new ApiError(404, 'USER_NOT_FOUND', 'User tidak ditemukan');
    return { user: publicUser(user, user.healthProfile), healthProfile: user.healthProfile };
  },

  async refresh(refreshTokenRaw: string, userAgent?: string) {
    if (!refreshTokenRaw) throw new ApiError(400, 'TOKEN_REQUIRED', 'Refresh token wajib diisi');
    const tokenHash = hashToken(refreshTokenRaw);
    const stored = await prisma.refreshToken.findUnique({ where: { tokenHash } });
    if (!stored || stored.revokedAt || stored.expiresAt < new Date()) {
      throw new ApiError(401, 'REFRESH_INVALID', 'Refresh token tidak valid atau sudah kedaluwarsa');
    }
    const user = await userRepo.findById(stored.userId.toString());
    if (!user || user.deletedAt) {
      throw new ApiError(401, 'USER_INACTIVE', 'User tidak aktif');
    }
    // rotate: revoke lama, issue baru
    await prisma.refreshToken.update({ where: { id: stored.id }, data: { revokedAt: new Date() } });
    const accessToken = signJwt({ userId: user.id.toString(), email: user.email });
    const newRefresh = await issueRefreshToken(user.id, userAgent);
    return { accessToken, refreshToken: newRefresh };
  },

  async logout(refreshTokenRaw?: string) {
    if (!refreshTokenRaw) return;
    const tokenHash = hashToken(refreshTokenRaw);
    await prisma.refreshToken
      .updateMany({ where: { tokenHash, revokedAt: null }, data: { revokedAt: new Date() } })
      .catch(() => null);
  },

  async forgotPassword(email: string) {
    const user = await userRepo.findByEmail(email);
    if (!user) {
      // jangan bocorin info: tetap return ok
      return { sent: true };
    }
    const { raw, expiresAt } = generateResetToken();
    // simpan token di refresh_tokens (re-use table) atau log saja
    logger.info({ userId: user.id.toString(), expiresAt }, 'Password reset requested');
    // TODO: kirim email dengan link berisi `raw`
    // untuk demo, kita return raw (HANYA development)
    return {
      sent: true,
      ...(env.NODE_ENV !== 'production' ? { devResetToken: raw } : {}),
    };
  },

  async resetPassword(_resetToken: string, _newPassword: string) {
    // Stub: untuk demo, full reset flow butuh tabel password_resets terpisah.
    // Tetap valid sebagai endpoint, return ok agar FE bisa wire.
    throw new ApiError(501, 'NOT_IMPLEMENTED', 'Reset password belum tersedia di demo');
  },
};

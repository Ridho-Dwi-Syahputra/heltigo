import { ApiError } from '../utils/api-error';
import { hashPassword, comparePassword } from '../utils/password.util';
import { signJwt } from '../utils/jwt.util';
import { userRepo } from '../repositories/user.repo';

export const authService = {
  async register(email: string, password: string, name?: string) {
    const existing = await userRepo.findByEmail(email);
    if (existing) throw new ApiError(409, 'EMAIL_TAKEN', 'Email sudah terdaftar');

    const passwordHash = await hashPassword(password);
    const user = await userRepo.create({ email, passwordHash, name });

    const accessToken = signJwt({ userId: user.id.toString(), email: user.email });
    const refreshToken = 'dummy-refresh-token'; // Setup real refresh token logic later
    
    return { user: this._toPublicUser(user), accessToken, refreshToken };
  },

  async login(email: string, password: string) {
    const user = await userRepo.findByEmail(email);
    if (!user) throw new ApiError(401, 'INVALID_CREDENTIALS', 'Email atau password salah');

    const valid = await comparePassword(password, user.passwordHash);
    if (!valid) throw new ApiError(401, 'INVALID_CREDENTIALS', 'Email atau password salah');

    const accessToken = signJwt({ userId: user.id.toString(), email: user.email });
    const refreshToken = 'dummy-refresh-token';
    
    return { user: this._toPublicUser(user), accessToken, refreshToken };
  },

  async getMe(userId: string) {
    const user = await userRepo.findById(userId);
    if (!user) throw new ApiError(404, 'USER_NOT_FOUND', 'User tidak ditemukan');
    return { user: this._toPublicUser(user), healthProfile: null }; // Mock health profile
  },

  _toPublicUser(user: any) {
    return {
      id: user.id.toString(),
      email: user.email,
      name: user.name,
      has_profile: false,
      created_at: user.createdAt || new Date(),
    };
  },
};

import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.string().default('3000'),
  DATABASE_URL: z.string(),
  JWT_SECRET: z.string().min(32),
  JWT_EXPIRES_IN: z.string().default('7d'),
  JWT_ACCESS_EXPIRES: z.string().default('900s'),
  JWT_REFRESH_EXPIRES: z.string().default('604800s'),
  BCRYPT_ROUNDS: z.string().default('12'),
  ML_SERVICE_URL: z.string(),
  ML_SERVICE_KEY: z.string(),
  CORS_ORIGINS: z.string().default('*'),
  LOG_LEVEL: z.string().default('debug'),
});

const _env = envSchema.safeParse(process.env);

if (!_env.success) {
  console.error('Invalid environment variables', _env.error.format());
  process.exit(1);
}

export const env = _env.data;

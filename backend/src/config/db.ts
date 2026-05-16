import { PrismaClient } from '@prisma/client';
import { env } from './env';
import { logger } from '../utils/logger';

export const prisma = new PrismaClient({
  datasources: {
    db: {
      url: env.DATABASE_URL,
    },
  },
  log: env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
});

prisma.$connect()
  .then(() => logger.info('Database connected successfully'))
  .catch((err) => {
    logger.error({ err }, 'Failed to connect to database');
    process.exit(1);
  });

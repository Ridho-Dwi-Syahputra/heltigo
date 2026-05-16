import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import pinoHttp from 'pino-http';
import { errorMiddleware } from './middleware/error.middleware';
import { env } from './config/env';
import { logger } from './utils/logger';
import { v1Router } from './routes';

export function createApp() {
  const app = express();

  app.use(helmet());
  app.use(cors({ origin: env.CORS_ORIGINS.split(',') }));
  app.use(express.json({ limit: '1mb' }));
  app.use(express.urlencoded({ extended: true }));
  app.use(pinoHttp({ logger }));

  app.get('/health', (_, res) => res.json({ status: 'ok', timestamp: new Date().toISOString() }));

  app.use('/api/v1', v1Router); // Sesuai FE req: /api/v1

  app.use(errorMiddleware);
  return app;
}

import axios, { AxiosError, AxiosInstance } from 'axios';
import { env } from '../config/env';
import { logger } from '../utils/logger';
import { ApiError } from '../utils/api-error';

class MlClient {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: env.ML_SERVICE_URL,
      timeout: 10_000,
      headers: {
        'Content-Type': 'application/json',
        'X-ML-KEY': env.ML_SERVICE_KEY,
      },
    });

    this.client.interceptors.response.use(
      (r) => r,
      (err) => this._handleError(err),
    );
  }

  async post<T>(path: string, body: unknown, options?: { timeout?: number; retries?: number }): Promise<T> {
    const { timeout = 10_000, retries = 2 } = options ?? {};
    let attempt = 0;
    while (true) {
      try {
        const res = await this.client.post<T>(path, body, { timeout });
        return res.data;
      } catch (err) {
        attempt++;
        const ax = err as AxiosError;
        const isRetriable = !ax.response || ax.response.status >= 500;
        if (!isRetriable || attempt > retries) {
          throw err;
        }
        const backoff = 300 * 2 ** (attempt - 1);
        logger.warn({ path, attempt, backoff }, 'ML call failed, retrying...');
        await new Promise((r) => setTimeout(r, backoff));
      }
    }
  }

  async get<T>(path: string): Promise<T> {
    const res = await this.client.get<T>(path);
    return res.data;
  }

  private _handleError(err: AxiosError) {
    if (err.code === 'ECONNABORTED' || err.code === 'ETIMEDOUT') {
      logger.error({ url: err.config?.url }, 'ML service timeout');
      throw new ApiError(502, 'ML_TIMEOUT', 'ML service timeout');
    }
    if (!err.response) {
      logger.error({ url: err.config?.url }, 'ML service unreachable');
      throw new ApiError(502, 'ML_UNREACHABLE', 'ML service tidak dapat dihubungi');
    }
    logger.error({ status: err.response.status, data: err.response.data }, 'ML error response');
    throw new ApiError(502, 'ML_ERROR', `ML service error: ${err.response.status}`);
  }
}

export const mlClient = new MlClient();

/**
 * Idempotent batch sync untuk offline queue dari FE.
 * Body shape:
 * {
 *   operations: [
 *     { opId: 'uuid', opType: 'log_meal', payload: {...} },
 *     ...
 *   ]
 * }
 *
 * Setiap op dicatat di sync_ops_log (unique by userId+opId).
 * Jika opId duplikat → status: DUPLICATE, hasil sebelumnya dipakai ulang.
 */
import { Prisma } from '@prisma/client';
import { prisma } from '../config/db';
import { mealService } from './meal.service';
import { progressService } from './progress.service';
import { workoutService } from './workout.service';
import { logger } from '../utils/logger';

type Op = { opId: string; opType: string; payload: any };

function toBig(id: string) {
  return BigInt(id);
}

async function dispatch(userId: string, opType: string, payload: any): Promise<any> {
  switch (opType) {
    case 'log_meal':
      return mealService.logMeal(userId, payload.mealId, payload);
    case 'update_water':
      return progressService.updateWater(userId, payload);
    case 'log_mood':
      return progressService.logMood(userId, payload);
    case 'complete_session':
      return workoutService.completeSession(userId, payload.sessionId, payload);
    case 'update_exercise_log':
      return workoutService.updateExerciseLog(userId, payload.sessionId, payload);
    default:
      throw new Error(`Unknown opType: ${opType}`);
  }
}

export const syncService = {
  async processBatch(userId: string, operations: Op[]) {
    if (!Array.isArray(operations) || operations.length === 0) {
      return { results: [], summary: { total: 0, ok: 0, duplicate: 0, error: 0 } };
    }
    const results: Array<{ opId: string; status: string; data?: any; error?: string }> = [];
    let ok = 0, duplicate = 0, error = 0;

    for (const op of operations) {
      try {
        // Cek duplicate
        const existing = await prisma.syncOpsLog.findUnique({
          where: { userId_opId: { userId: toBig(userId), opId: op.opId } },
        });
        if (existing) {
          duplicate++;
          results.push({ opId: op.opId, status: 'DUPLICATE', data: existing.resultSnapshot });
          continue;
        }
        const data = await dispatch(userId, op.opType, op.payload);
        await prisma.syncOpsLog.create({
          data: {
            userId: toBig(userId),
            opId: op.opId,
            opType: op.opType,
            status: 'OK',
            resultSnapshot: data as Prisma.InputJsonValue,
          },
        });
        ok++;
        results.push({ opId: op.opId, status: 'OK', data });
      } catch (err) {
        error++;
        logger.warn({ opId: op.opId, err: (err as Error).message }, 'Sync op failed');
        await prisma.syncOpsLog
          .create({
            data: {
              userId: toBig(userId),
              opId: op.opId,
              opType: op.opType,
              status: 'ERROR',
              resultSnapshot: { error: (err as Error).message } as Prisma.InputJsonValue,
            },
          })
          .catch(() => null);
        results.push({ opId: op.opId, status: 'ERROR', error: (err as Error).message });
      }
    }
    return { results, summary: { total: operations.length, ok, duplicate, error } };
  },
};

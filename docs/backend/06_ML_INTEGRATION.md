# Backend — ML Integration

> 📌 **Update 2026-05-16** — ML service menyediakan **4 endpoint** (3 model + 1 utility), **bukan 5**:
>
> | Endpoint | Tujuan | Timeout | Ada di ML? |
> |---|---|---|---|
> | `POST /predict/workout-plan` | Generate 7-day workout (RF multi-output) | < 800 ms | ✅ ML |
> | `POST /predict/meal-plan` | Generate 7-day meal (Knapsack) | < 500 ms | ✅ ML |
> | `POST /predict/meal-alternatives` | Get food alternatives (knapsack subset) | < 200 ms | ✅ ML |
> | `POST /predict/replan` | Re-generate plan mingguan (rule 3-cabang) | < 600 ms | ✅ ML |
> | ~~`POST /predict/intensity`~~ | ~~Adjust intensity dari mood/energy/sleep~~ | < 10 ms | ❌ **Backend rule, bukan ML** |
>
> Intensity adjuster (mood/energy/sleep → multiplier volume) adalah **rule table di backend Express** (`services/intensity_adjuster.service.ts`), tidak memanggil FastAPI. Logika ada di `07_BUSINESS_LOGIC.md` §Intensity Adjuster.
>
> Source of truth: [`../machine-learning/FE-model-requirement/00_OVERVIEW.md`](../machine-learning/FE-model-requirement/00_OVERVIEW.md).

---

## 1. Pola Komunikasi

```
┌────────────┐  HTTP POST   ┌────────────────┐
│  Express   ├─────────────▶│  Python FastAPI │
│  Service   │              │  ML Microservice│
│            │◀─────────────┤                 │
└────────────┘  JSON resp   └────────────────┘
        ↑                            ↑
        │                            │
   shared secret               models loaded
   X-ML-KEY header             di startup (joblib)
```

- **Sync HTTP** (bukan message queue) untuk simplisitas hackathon.
- **Shared secret** `X-ML-KEY` di header — jangan expose FastAPI ke public internet.
- Express **stateless** terhadap ML — semua context dikirim di body request.
- Timeout default 10 detik, retry 2x untuk endpoint inference.

## 2. ML Endpoint Contract

Detail di `docs/machine-learning/06_SERVING_FASTAPI.md`. Ringkasan:

| Endpoint | Tujuan | Dipanggil dari |
|---|---|---|
| `POST /infer/workout` | Generate 7-day workout plan | `/v1/plan/generate`, `/v1/plan/replan` |
| `POST /infer/workout/adjust` | Adjust intensity berdasarkan mood/energy/sleep | `/v1/workout/checkin` |
| `POST /infer/meal` | Generate 7-day meal plan (knapsack) | `/v1/plan/generate`, `/v1/plan/replan` |
| `POST /infer/meal/alternative` | Cari meal alternatif | `/v1/nutrition/alternative` |
| `POST /infer/replan` | Score-based weekly replanning logic | `/v1/plan/replan` (cron Sunday 20:00) |
| `GET /healthz` | Health check | Monitoring |

## 3. ML Client Wrapper

File: `src/ml-client/ml.client.ts`

```ts
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
```

## 4. Per-Service Wrapper

### 4.1 Workout

File: `src/ml-client/workout.ml.ts`

```ts
import { mlClient } from './ml.client';

export interface WorkoutInferRequest {
  profile: {
    bmi: number;
    bmi_category: string;
    gender: 'MALE' | 'FEMALE';
    age: number;
    fitness_level: 'BEGINNER' | 'INTERMEDIATE' | 'ADVANCED';
    workout_mode: 'HOME' | 'GYM';
    days_per_week: number;
    session_minutes: number;
    conditions: string[];
  };
}

export interface WorkoutInferResponse {
  days: Array<{
    day_index: number;
    is_rest_day: boolean;
    estimated_minutes: number;
    estimated_calories: number;
    exercises: Array<{
      exercise_item_id: string;
      order_in_day: number;
      phase: 'WARMUP' | 'MAIN' | 'COOLDOWN';
      sets: number;
      reps: number;
      rest_seconds: number;
      ai_tip: string | null;
    }>;
  }>;
}

export const workoutMl = {
  infer(req: WorkoutInferRequest) {
    return mlClient.post<WorkoutInferResponse>('/infer/workout', req);
  },

  adjust(req: {
    original_workout: WorkoutInferResponse['days'][0];
    mood: number;
    energy: number;
    sleep_band: '<5' | '5-6' | '6-7' | '7-8' | '>8';
  }) {
    return mlClient.post<{ adjustment: number; adjusted_workout: WorkoutInferResponse['days'][0] }>(
      '/infer/workout/adjust',
      req,
    );
  },
};
```

### 4.2 Meal

File: `src/ml-client/meal.ml.ts`

```ts
import { mlClient } from './ml.client';

export interface MealInferRequest {
  profile: {
    tdee: number;
    target_calorie_adj: number;  // signed: -350 untuk lose, +200 untuk gain
    budget_per_day_idr: number;
    meal_frequency: number;       // 2-4
    diet_restrictions: string[];  // ['halal', 'vegetarian', 'no-nuts', 'no-dairy']
  };
  excluded_food_ids?: string[];
}

export interface MealInferResponse {
  days: Array<{
    day_index: number;
    total_calories: number;
    total_protein_g: number;
    total_carb_g: number;
    total_fat_g: number;
    total_cost_idr: number;
    meals: Array<{
      meal_type: 'BREAKFAST' | 'LUNCH' | 'DINNER' | 'SNACK';
      calories_kcal: number;
      cost_idr: number;
      ai_explanation: string | null;
      foods: Array<{
        food_item_id: string;
        servings: number;
        calories_kcal: number;
      }>;
    }>;
  }>;
}

export const mealMl = {
  infer(req: MealInferRequest) {
    return mlClient.post<MealInferResponse>('/infer/meal', req);
  },

  alternative(req: {
    plan_meal_id: string;
    target_calories: number;
    budget_idr: number;
    diet_restrictions: string[];
    exclude_food_ids: string[];
  }) {
    return mlClient.post<{ meal: MealInferResponse['days'][0]['meals'][0] }>(
      '/infer/meal/alternative',
      req,
    );
  },
};
```

### 4.3 Replan

File: `src/ml-client/replan.ml.ts`

```ts
import { mlClient } from './ml.client';

export interface ReplanRequest {
  previous_plan: {
    week_number: number;
    workout_days: any[];
    meal_days: any[];
  };
  score_percent: number;          // 0-100
  workout_done_count: number;
  workout_total_count: number;
  meal_done_count: number;
  meal_total_count: number;
  weight_change_kg: number;        // signed
  weight_target_change_kg: number; // expected based on plan
  most_skipped_exercise_ids: string[];
  profile: any;                    // sama format dengan WorkoutInferRequest.profile
}

export interface ReplanResponse {
  ai_notes: string;
  ai_recommendation: string;
  workout_days: any[];   // format sama dengan WorkoutInferResponse.days
  meal_days: any[];      // format sama dengan MealInferResponse.days
}

export const replanMl = {
  infer(req: ReplanRequest) {
    return mlClient.post<ReplanResponse>('/infer/replan', req, { timeout: 15_000 });
  },
};
```

## 5. Orchestration di Service Layer

### 5.1 Plan Generate

File: `src/services/plan.service.ts`

```ts
import { ApiError } from '../utils/api-error';
import { profileRepo } from '../repositories/profile.repo';
import { planRepo } from '../repositories/plan.repo';
import { workoutMl } from '../ml-client/workout.ml';
import { mealMl } from '../ml-client/meal.ml';
import { logger } from '../utils/logger';

export const planService = {
  async generate(userId: string) {
    const profile = await profileRepo.findByUserId(userId);
    if (!profile) throw new ApiError(404, 'PROFILE_NOT_FOUND', 'Profil belum dibuat');

    const existing = await planRepo.findActive(userId);
    if (existing) throw new ApiError(409, 'PLAN_ALREADY_EXISTS', 'Sudah ada rencana aktif');

    logger.info({ userId }, 'Generating plan: calling ML services in parallel');

    const [workoutRes, mealRes] = await Promise.all([
      workoutMl.infer({
        profile: {
          bmi: profile.bmi.toNumber(),
          bmi_category: profile.bmiCategory,
          gender: profile.gender,
          age: profile.age,
          fitness_level: profile.fitnessLevel,
          workout_mode: profile.workoutMode,
          days_per_week: profile.daysPerWeek,
          session_minutes: profile.sessionMinutes,
          conditions: profile.conditions as string[],
        },
      }),
      mealMl.infer({
        profile: {
          tdee: profile.tdee,
          target_calorie_adj: profile.targetCalorieAdj,
          budget_per_day_idr: profile.budgetPerDay,
          meal_frequency: profile.mealFrequency,
          diet_restrictions: profile.dietRestrictions as string[],
        },
      }),
    ]);

    const plan = await planRepo.create({
      userId,
      weekNumber: 1,
      generatedBy: 'initial',
      workoutDays: workoutRes.days,
      mealDays: mealRes.days,
    });

    return plan;
  },
};
```

## 6. Fallback Strategy (Saat ML Down)

Jika ML service down/timeout:

### Opsi A — Hard Fail (Sederhana)
Throw `502 ML_UNAVAILABLE`. Mobile tampilkan dialog retry. Recommended untuk hackathon.

### Opsi B — Rule-Based Fallback (Pasca-Hackathon)
Service punya generator rule-based sebagai backup:

```ts
async function generateWorkoutFallback(profile: UserProfile) {
  // Hardcoded template berdasarkan bmi_category & fitness_level
  // Misal Pemula+Overweight → 3 hari/minggu, mostly cardio
  return ruleBased.workout(profile);
}

async function generateMealFallback(profile: UserProfile) {
  // Pakai knapsack di Express langsung (kurang akurat tapi jalan)
  // Pilih top-N foods dengan rasio kalori/harga terbaik
  return ruleBased.meal(profile);
}
```

Untuk hackathon: skip ini. Tampilkan error jelas ke user.

## 7. Health Check

Saat startup Express, check ML health:

```ts
// src/server.ts
import { mlClient } from './ml-client/ml.client';

async function bootstrap() {
  // ... db check ...
  try {
    await mlClient.get('/healthz');
    logger.info('✅ ML service reachable');
  } catch (e) {
    logger.warn('⚠️  ML service tidak reachable saat startup. Plan generation akan gagal.');
  }
}
```

Endpoint Express `/health` bisa juga return status ML:
```json
{
  "status": "ok",
  "services": {
    "db": "up",
    "ml": "up"
  }
}
```

## 8. Logging ML Calls

Setiap call dicatat:
```ts
logger.info({ path, durationMs, status: 'ok' }, 'ML call');
```

Saat error:
```ts
logger.error({ path, error: err.message, attempt }, 'ML call failed');
```

Useful untuk debugging saat demo.

## 9. Testing ML Integration

### 9.1 Mock ML di Unit Test
```ts
// tests/plan.service.test.ts
import { vi, test, expect } from 'vitest';
import { planService } from '../src/services/plan.service';

vi.mock('../src/ml-client/workout.ml', () => ({
  workoutMl: { infer: vi.fn().mockResolvedValue({ days: [/* mock 7 days */] }) },
}));

vi.mock('../src/ml-client/meal.ml', () => ({
  mealMl: { infer: vi.fn().mockResolvedValue({ days: [/* mock */] }) },
}));

test('generate plan calls both ML services and persists', async () => {
  const plan = await planService.generate('user-id-test');
  expect(plan.workoutDays).toHaveLength(7);
  expect(plan.mealDays).toHaveLength(7);
});
```

### 9.2 Smoke Test Live
```bash
# Start FastAPI di port 8001
cd ml-service && uvicorn main:app --port 8001 &

# Start Express di port 3000
cd backend && pnpm dev &

# Trigger generate
curl -X POST http://localhost:3000/v1/plan/generate \
  -H "Authorization: Bearer $JWT" \
  -H "Content-Type: application/json"
```

## 10. Versioning ML API

Saat ML team ubah skema response (mis. tambah field), gunakan **additive changes**:
- Tambah field opsional → tidak breaking
- Hapus/rename field → breaking, koordinasi dengan BE
- Ubah enum value → breaking

Untuk hackathon, schema sederhana di awal & tidak ubah-ubah. Pasca-hackathon, pikirkan `X-ML-VERSION` header atau prefix `/v1/infer/...`.

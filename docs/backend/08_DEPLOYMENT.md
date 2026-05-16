# Backend — Deployment

> 📌 **Env vars update 2026-05-15** — Final env config:
> ```bash
> NODE_ENV=production
> PORT=3000
> DATABASE_URL=mysql://user:pass@host:3306/heltigo
> ML_SERVICE_URL=http://ml:8000
> ML_TIMEOUT_MS=5000
>
> JWT_SECRET=<256-bit>
> JWT_ACCESS_EXPIRES=900            # 15 menit (DETIK)
> JWT_REFRESH_EXPIRES=604800        # 7 hari (DETIK)
> BCRYPT_ROUNDS=12
> IDEMPOTENCY_TTL_SECONDS=86400     # 24 jam Redis TTL
>
> REDIS_URL=redis://redis:6379
> CORS_ORIGINS=https://app.heltigo.app,http://localhost:5000
>
> FCM_SERVER_KEY=<firebase-key>     # Phase 4 push notif
> S3_BUCKET=heltigo-avatars         # Phase 4 avatar upload
> AWS_REGION=ap-southeast-1
> ```
>
> Cron yang harus terdaftar (node-cron atau pakai SQL events):
> - `0 0 * * *` — `cron/water_reset.cron.ts` (reset hydration 00:00 lokal)
> - `30 0 * * *` — `cron/streak_evaluator.cron.ts` (eval streak)
> - `0 20 * * 0` — `cron/replan_due.cron.ts` (Minggu 20:00 → push notif "Saatnya replan!")
> - `0 3 * * *` — `cron/cleanup_sync_ops.cron.ts` (prune sync_ops_log > 24 jam)

---

## 1. Strategi untuk Hackathon

3 environment:
1. **Local dev** — Docker compose (MySQL, Express, opsional FastAPI bareng-bareng)
2. **Staging** — Cloud hosting gratis/murah (Railway atau Render)
3. **Production demo** — Sama dengan staging untuk hackathon (tidak terpisah)

## 2. Local Dev: Docker Compose

File: `backend/docker-compose.yml`

```yaml
version: '3.9'

services:
  db:
    image: mysql:8.0
    container_name: heltigo-db
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: heltigo
      MYSQL_USER: heltigo
      MYSQL_PASSWORD: secret
    ports:
      - '3306:3306'
    volumes:
      - heltigo_db_data:/var/lib/mysql
    healthcheck:
      test: ['CMD', 'mysqladmin', 'ping', '-h', 'localhost']
      interval: 5s
      timeout: 3s
      retries: 10

  api:
    build: .
    container_name: heltigo-api
    depends_on:
      db:
        condition: service_healthy
    environment:
      NODE_ENV: development
      PORT: 3000
      DATABASE_URL: mysql://heltigo:secret@db:3306/heltigo
      JWT_SECRET: dev-secret-32-chars-replace-in-prod
      JWT_EXPIRES_IN: 7d
      BCRYPT_ROUNDS: 10
      ML_SERVICE_URL: http://ml:8001
      ML_SERVICE_KEY: dev-shared-secret
      LOG_LEVEL: debug
    ports:
      - '3000:3000'
    volumes:
      - ./src:/app/src
      - ./prisma:/app/prisma
    command: pnpm dev

  ml:
    # Komen out jika ML service belum ready, bisa berdiri sendiri
    image: heltigo-ml:dev
    build:
      context: ../ml-service
    container_name: heltigo-ml
    environment:
      ML_SERVICE_KEY: dev-shared-secret
    ports:
      - '8001:8001'

volumes:
  heltigo_db_data:
```

Mulai stack:
```bash
docker compose up -d
docker compose logs -f api
```

Run migration & seed:
```bash
docker compose exec api pnpm prisma migrate deploy
docker compose exec api pnpm prisma db seed
```

## 3. Dockerfile Production

File: `backend/Dockerfile`

```dockerfile
# Multi-stage build
FROM node:20-alpine AS builder
WORKDIR /app
RUN corepack enable && corepack prepare pnpm@9.5.0 --activate

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

COPY tsconfig.json ./
COPY prisma ./prisma
COPY src ./src
RUN pnpm prisma generate
RUN pnpm build  # output ke dist/

# Runtime stage
FROM node:20-alpine
WORKDIR /app
RUN corepack enable && corepack prepare pnpm@9.5.0 --activate

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --prod --frozen-lockfile

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma

EXPOSE 3000
CMD ["node", "dist/server.js"]
```

`.dockerignore`:
```
node_modules
dist
.git
.env
.env.local
tests
docker-compose.yml
```

## 4. Hosting Pilihan

### 4.1 Railway (Recommended untuk hackathon)

**Pros:**
- Free tier dengan $5 credit/bulan
- Built-in MySQL, Redis, Postgres
- Auto deploy dari GitHub
- Environment variables UI
- Custom domain support

**Setup:**
1. Buat akun di railway.app
2. New Project → Deploy from GitHub repo
3. Add service: MySQL → otomatis isi `DATABASE_URL` ke env
4. Add env vars: `JWT_SECRET`, `ML_SERVICE_URL`, `ML_SERVICE_KEY`
5. Settings → Set start command: `node dist/server.js`
6. Settings → Set build command: `pnpm install && pnpm prisma generate && pnpm build && pnpm prisma migrate deploy && pnpm prisma db seed`
7. Generate domain → `https://heltigo-api.up.railway.app`

**Catatan:**
- Free tier sleep setelah idle. Untuk demo, ping endpoint /health setiap 5 menit (UptimeRobot gratis).
- Atau upgrade ke $5/bulan paid plan, no sleep.

### 4.2 Render (Alternatif Gratis)

**Pros:**
- Free tier untuk Web Service (sleep setelah 15 menit idle, wake up 30-60 detik)
- MySQL via add-on (PlanetScale free atau Aiven free trial)

**Setup:**
1. New → Web Service → Connect GitHub repo
2. Build command: `pnpm install && pnpm prisma generate && pnpm build`
3. Start command: `pnpm prisma migrate deploy && node dist/server.js`
4. Add env vars
5. Untuk MySQL: tambah add-on PlanetScale atau eksternal

### 4.3 VPS (Hetzner / Contabo) — Pasca-Hackathon

**Pros:**
- Lebih murah long-term ($4/bulan Hetzner CX11)
- Full control

**Cons:**
- Manual setup (Docker, NGINX, SSL via Let's Encrypt, monitoring)
- Lebih lama setup

Setup script:
```bash
# Di VPS Ubuntu 22.04
apt update && apt install -y docker.io docker-compose git nginx certbot
git clone <repo>
cd heltigo/backend
docker compose -f docker-compose.prod.yml up -d
# NGINX reverse proxy + Certbot untuk HTTPS
```

Tidak prioritas hackathon.

## 5. Environment Variables Production

Wajib di-set di Railway/Render dashboard:

```
NODE_ENV=production
PORT=3000
DATABASE_URL=mysql://...                           # auto-fill dari Railway MySQL service
JWT_SECRET=<generate dengan openssl rand -base64 48>
JWT_EXPIRES_IN=7d
BCRYPT_ROUNDS=10
ML_SERVICE_URL=https://heltigo-ml.onrender.com
ML_SERVICE_KEY=<random string match dengan FastAPI>
CORS_ORIGINS=https://heltigo-app.com,*             # mobile pakai *.app domain
LOG_LEVEL=info
TZ=Asia/Jakarta                                    # untuk cron timezone
```

## 6. Migration di Production

**Jangan pernah:**
- `prisma migrate dev` (interactive, dev-only)
- `prisma db push` (skip migration history, tidak safe)

**Selalu:**
- `prisma migrate deploy` (apply pending migrations)
- Jalankan saat deploy / startup

Di start script:
```bash
pnpm prisma migrate deploy && pnpm prisma db seed && node dist/server.js
```

Catatan: `db seed` idempotent (pakai `upsert`) supaya aman dipanggil tiap restart.

## 7. CORS

File: `src/config/cors.ts`

```ts
import { CorsOptions } from 'cors';
import { env } from './env';

export const corsOptions: CorsOptions = {
  origin: (origin, callback) => {
    if (!origin) return callback(null, true); // mobile native (no origin)

    const allowed = env.CORS_ORIGINS.split(',').map((s) => s.trim());
    if (allowed.includes('*') || allowed.some((p) => matchOrigin(origin, p))) {
      return callback(null, true);
    }
    return callback(new Error('CORS not allowed'));
  },
  credentials: true,
};

function matchOrigin(origin: string, pattern: string) {
  if (pattern === origin) return true;
  if (pattern.includes('*')) {
    const regex = new RegExp('^' + pattern.replace(/\./g, '\\.').replace(/\*/g, '.*') + '$');
    return regex.test(origin);
  }
  return false;
}
```

Mobile native tidak kirim Origin header → diizinkan langsung.

## 8. Monitoring & Logging

### Minimum (Hackathon)
- **Pino logs** ke stdout → Railway/Render auto kumpulkan, cari di dashboard.
- **/health endpoint** untuk uptime monitoring (UptimeRobot gratis).

### Pasca-Hackathon (Opsional)
- **Sentry** untuk error tracking: `@sentry/node` integrate di error middleware
- **Better Stack / Logtail** untuk centralized logging
- **Grafana Cloud** untuk metrics

## 9. Backup Strategy

Hackathon: **tidak prioritas**. Demo dengan akun fresh setiap presentasi jika perlu.

Pasca-hackathon:
- Railway MySQL auto-backup harian (paid plan)
- Atau cron job `mysqldump` ke S3 setiap hari

## 10. Smoke Test Production

Setelah deploy, run sequence ini:

```bash
# 1. Health
curl https://heltigo-api.up.railway.app/health
# Expect: {"status":"ok","timestamp":"..."}

# 2. Signup
curl -X POST https://heltigo-api.up.railway.app/v1/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"smoketest@heltigo.app","password":"smoke12345"}'
# Expect: 201 + {user, token}

# 3. Login
curl -X POST https://heltigo-api.up.railway.app/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"smoketest@heltigo.app","password":"smoke12345"}'
# Expect: 200 + token

# 4. Auth-required (substitute TOKEN)
curl https://heltigo-api.up.railway.app/v1/auth/me \
  -H "Authorization: Bearer TOKEN"
# Expect: 200 + user
```

## 11. Rollback Strategy

Jika deploy production crash:
- Railway: revert ke previous deployment via dashboard (1 click)
- Render: sama, revert ke previous build
- Migration revert: prisma `migrate resolve --rolled-back <name>` lalu apply migration sebelumnya

**Hackathon:** lebih sering daripada complete rollback, fix forward dengan hotfix commit dan redeploy.

## 12. Checklist Deploy Day 14

- [ ] Pastikan semua env vars terisi di Railway/Render
- [ ] `JWT_SECRET` minimum 32 char random
- [ ] `ML_SERVICE_KEY` match antara Express dan FastAPI
- [ ] `CORS_ORIGINS` sudah include domain mobile (jika ada) atau `*` untuk testing
- [ ] Migration applied: `prisma migrate deploy` sukses
- [ ] Seed sukses: cek tabel `food_items` punya 1300+ rows, `exercise_items` punya 100+ rows
- [ ] Health endpoint return ok
- [ ] Signup → login → me end-to-end via curl
- [ ] Plan generate via curl (post-setup) berhasil
- [ ] Cron job terjadwal (cek log)
- [ ] APK Flutter build dengan `API_BASE_URL` ke domain production
- [ ] Demo akun ter-seed (1 akun dengan 3 minggu plan history untuk progress chart)

## 13. Disaster Recovery Saat Demo Hari-H

Backup plan jika hal-hal aneh terjadi:

| Situasi | Mitigasi |
|---|---|
| Railway down saat demo | Switch APK ke endpoint local (laptop sebagai server, hotspot HP) |
| ML service down | Gunakan video recording demo flow (sudah disiapkan Day 14) |
| MySQL data lost | Restore dari seed dump lokal yang sudah di-backup |
| Internet venue lambat | Demo via screen recording yang sudah pre-recorded |

Selalu punya **video demo recording 3-5 menit** di laptop sebagai ultimate backup. Recorded di Day 14.

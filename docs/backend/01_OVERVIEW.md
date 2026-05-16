# Backend — Overview

> 📌 **Source of Truth Update (2026-05-15)**
> Sejak 2026-05-15, daftar lengkap endpoint dan schema database **terbaru** ada di:
> - [`FE_requirement/00_API_REQUIREMENTS.md`](FE_requirement/00_API_REQUIREMENTS.md) — endpoint API
> - [`FE_requirement/01_DATABASE_DESIGN.md`](FE_requirement/01_DATABASE_DESIGN.md) — schema 19 tabel
> - [`FE_requirement/schema.sql`](FE_requirement/schema.sql) — DDL siap-eksekusi
>
> Dokumen `03_DATABASE_SCHEMA.md` dan `04_API_ENDPOINTS.md` di folder ini sudah **deprecated**.
> File overview ini (di bawah) tetap valid untuk konteks high-level — patch ditandai dengan ▶ di section relevan.

## 1. Tujuan

Backend Heltigo bertanggung jawab atas:
1. **Authentication & user management** (signup, login, JWT)
2. **CRUD profile, plan, log** ke MySQL
3. **Orchestration** panggilan ke ML microservice (FastAPI Python)
4. **Business logic** validasi BMI/TDEE, knapsack helper jika perlu, perhitungan skor mingguan
5. **Cron job** replanning setiap Sunday 20:00
6. **Sync endpoint** untuk batch upload offline-cached items dari mobile

## 2. Tech Stack

| Layer | Pilihan | Alasan |
|---|---|---|
| Runtime | **Node.js 20 LTS** | Stable, performant, ekosistem matang |
| Framework | **Express.js 4.19+** | Sesuai pilihan user, minimal, mature |
| Bahasa | **JavaScript (CommonJS)** atau **TypeScript** | TS recommended untuk type safety, JS ok jika tim familiar |
| ORM | **Prisma 5+** | Type-safe, migration auto, schema-first. Atau Sequelize jika tim lebih familiar. |
| DB | **MySQL 8.0+** | Sesuai pilihan user |
| Auth | **JWT** via `jsonwebtoken` + **bcrypt** untuk hash | Standard, stateless |
| Validation | **Zod** atau **express-validator** | Schema-first input validation |
| Logging | **Pino** + `pino-pretty` (dev) | Performant, JSON structured |
| Scheduler | **node-cron** | Untuk replanning Sunday 20:00 |
| HTTP client (ke FastAPI) | **axios** atau native `fetch` (Node 18+) | Retry, timeout, interceptor |
| Testing | **Vitest** atau **Jest** + **supertest** | Smoke test endpoint |

## 3. Struktur Folder

Detail di `02_PROJECT_STRUCTURE.md`. Singkat:

```
backend/
├── src/
│   ├── routes/          # Express router per resource
│   ├── controllers/     # Request handlers
│   ├── services/        # Business logic
│   ├── repositories/    # DB access via Prisma
│   ├── middleware/      # Auth, error handler, request logger
│   ├── validators/      # Zod schemas
│   ├── utils/
│   ├── jobs/            # Cron jobs
│   ├── ml-client/       # HTTP client ke FastAPI
│   ├── config/          # env loader, db setup
│   └── server.ts        # Entry point
├── prisma/
│   ├── schema.prisma
│   ├── migrations/
│   └── seed.ts          # Seed food + exercise master data
├── tests/
├── .env.example
├── package.json
├── tsconfig.json (jika TS)
├── docker-compose.yml   # MySQL container untuk dev
└── Dockerfile
```

## 4. Variabel Environment (.env.example)

```ini
# Server
NODE_ENV=development
PORT=3000

# Database (MySQL)
DATABASE_URL=mysql://heltigo:secret@localhost:3306/heltigo

# Auth
JWT_SECRET=replace-with-32+-char-random-string
JWT_EXPIRES_IN=7d
BCRYPT_ROUNDS=10

# ML Service
ML_SERVICE_URL=http://localhost:8001
ML_SERVICE_KEY=shared-secret-with-fastapi

# CORS
CORS_ORIGINS=http://localhost:*,https://heltigo-app.example.com

# Logging
LOG_LEVEL=debug
```

## 5. Quick Start (Local Dev)

```bash
cd backend
cp .env.example .env
# edit .env

# Start MySQL via Docker
docker compose up -d db

# Install deps
pnpm install   # atau npm install

# Run migration
pnpm prisma migrate dev --name init

# Seed master data
pnpm prisma db seed

# Run dev server
pnpm dev
# Server di http://localhost:3000
```

Smoke test:
```bash
curl http://localhost:3000/health
# {"status":"ok","timestamp":"..."}
```

## 6. Conventions

### URL & Versioning
- Prefix `/v1` untuk semua endpoint API
- RESTful resource naming (`/users`, `/plans`, `/workouts`)
- Plural nouns
- HTTP methods sesuai semantik (GET read, POST create, PUT/PATCH update, DELETE delete)

### Request / Response
- JSON only (`Content-Type: application/json`)
- snake_case di JSON keys (konsisten dengan Python ML service di sisi lain)
- Timestamp ISO 8601 UTC (`2026-05-07T10:30:00Z`)
- Money: integer dalam unit terkecil (rupiah utuh, bukan float)

### Error Response Format
```json
{
  "error": {
    "code": "INVALID_BMI",
    "message": "BMI di luar rentang valid (10-60)",
    "details": {
      "field": "weight_kg",
      "value": -5
    }
  }
}
```

HTTP status codes standard:
- `200 OK`, `201 Created`, `204 No Content`
- `400 Bad Request` (validation), `401 Unauthorized`, `403 Forbidden`, `404 Not Found`, `409 Conflict`, `422 Unprocessable Entity`
- `500 Internal Server Error`, `502 Bad Gateway` (ML down), `503 Service Unavailable`

### Pagination
Untuk list endpoint:
```
GET /v1/foods?limit=20&offset=0&search=ayam
```
Response:
```json
{
  "items": [...],
  "total": 1346,
  "limit": 20,
  "offset": 0
}
```

## 7. Hubungan dengan Tim Lain

- **Frontend (Flutter)** mengonsumsi REST API di `04_API_ENDPOINTS.md`. Setiap perubahan endpoint **wajib** koordinasi.
- **ML (Python FastAPI)** menyediakan endpoint inference di `docs/machine-learning/06_SERVING_FASTAPI.md`. Backend memanggil via `axios` dengan header `X-ML-KEY`.

## 8. Definition of Done — Endpoint

Endpoint dianggap selesai jika:
1. Validasi input dengan Zod, error 400 untuk input invalid.
2. Auth middleware terpasang (kecuali signup/login/health).
3. Response format konsisten dengan `04_API_ENDPOINTS.md`.
4. Error handling: tidak ada raw stack trace di response, hanya `error.code` + `message`.
5. Smoke test dengan curl atau Postman berhasil.
6. Logging terdokumentasi (info untuk path bisnis, error untuk failure).

## 9. Catatan Performa

- **Connection pooling Prisma**: default 10. Cukup untuk hackathon.
- **N+1 query**: gunakan `include` Prisma atau JOIN explicit. Awasi response time `/plan/current` (banyak relasi).
- **Caching**: tidak prioritas hackathon. Untuk production tambah Redis untuk cache plan/profile.
- **Rate limiting**: `express-rate-limit` minimum di endpoint auth (mencegah brute force) — opsional jika waktu cukup.

### ▶ 9.1 Konstrain Khusus (added 2026-05-15)

Sumber: [`FE_requirement/00_API_REQUIREMENTS.md`](FE_requirement/00_API_REQUIREMENTS.md) §12.

- **Increment-only hydration:** `PATCH /progress/daily/water` HANYA accept `glassCount > current`. Jika sebaliknya → return `400 INVALID_DECREMENT`. Auto-reset 00:00 lokal (cron).
- **7-day plan window:** Setiap `workout_plan` dan `meal_plan` tepat 7 hari (Sen-Min). Hanya 1 plan aktif per user. Saat user buka app di hari ke-8 → `GET /plan/active` return `{ shouldReplan: true }`.
- **Rate limit:** 60 req/min per IP global; 5 req/min untuk auth endpoint (`/auth/login`, `/auth/register`, `/auth/forgot-password`).
- **Idempotency-Key header:** Wajib untuk POST endpoint dengan side-effect (log meal, complete workout, sync batch). TTL 24 jam di Redis.
- **JWT TTL:** Access token 15 min (`JWT_ACCESS_EXPIRES=900s`), refresh token 7 day (`JWT_REFRESH_EXPIRES=604800s`). Refresh token di-rotate setiap pakai.
- **Bcrypt cost:** 12 (lebih kuat dari draft awal yang 10).

## 10. Catatan Privasi

Sesuai `docs/00_ARCHITECTURE.md` §4:
- Password user hash bcrypt sebelum simpan.
- JWT tidak berisi data sensitif (hanya `userId`, `email`, `iat`, `exp`).
- Komunikasi ke FastAPI hanya di network internal (Docker network atau VPC).
- Log mood/energi/sleep di tabel `workout_checkins` dengan **TTL 90 hari** (cron cleanup).
- HTTPS wajib untuk production (Railway/Render auto handle).

# Heltigo Backend — Documentation Index

> Folder ini berisi dokumentasi backend (Express.js + MySQL + JWT) untuk Heltigo, plus integrasi ke ML microservice.
> **Source of truth terbaru:** [`FE_requirement/`](FE_requirement/) (2026-05-15).

---

## 📂 File di folder ini

### ✅ Source of Truth (latest, 2026-05-15)
| File | Topik | Status |
|---|---|---|
| [`FE_requirement/00_API_REQUIREMENTS.md`](FE_requirement/00_API_REQUIREMENTS.md) | Daftar lengkap 60+ endpoint, screen→endpoint matrix, constraints khusus | ✅ **AUTHORITATIVE** |
| [`FE_requirement/01_DATABASE_DESIGN.md`](FE_requirement/01_DATABASE_DESIGN.md) | Skema 19 tabel + ER diagram + indexes | ✅ **AUTHORITATIVE** |
| [`FE_requirement/schema.sql`](FE_requirement/schema.sql) | DDL siap-eksekusi MySQL 8.0+ + seed badges | ✅ **AUTHORITATIVE** |

### ✅ Aktif (di-patch dengan sync notes)
| File | Topik | Catatan |
|---|---|---|
| [`01_OVERVIEW.md`](01_OVERVIEW.md) | Tujuan backend, tech stack, prinsip arsitektur | Patch §9.1 (konstrain khusus, JWT TTL, bcrypt 12) |
| [`02_PROJECT_STRUCTURE.md`](02_PROJECT_STRUCTURE.md) | Layered architecture, folder layout | Patch: tambah sync.service, daily_logs.repo, cron files |
| [`05_AUTH_JWT.md`](05_AUTH_JWT.md) | Strategi auth, JWT flow | Patch: refresh token rotation, bcrypt 12 |
| [`06_ML_INTEGRATION.md`](06_ML_INTEGRATION.md) | Komunikasi ke FastAPI ML service | Patch: 5 endpoint ML + per-endpoint timeout |
| [`07_BUSINESS_LOGIC.md`](07_BUSINESS_LOGIC.md) | BMR/TDEE, score mingguan, streak | Patch: increment-only hydration, weekly score formula, streak algo, badge triggers |
| [`08_DEPLOYMENT.md`](08_DEPLOYMENT.md) | Deploy strategy, env vars, cron jobs | Patch: env vars final + cron schedule |

### ⚠️ Deprecated (jangan dipakai)
| File | Alasan |
|---|---|
| [`03_DATABASE_SCHEMA.md`](03_DATABASE_SCHEMA.md) | UUID vs BIGINT PK mismatch, missing 7 tabel — gunakan `FE_requirement/01_DATABASE_DESIGN.md` |
| [`04_API_ENDPOINTS.md`](04_API_ENDPOINTS.md) | 30+ endpoint path/method beda — gunakan `FE_requirement/00_API_REQUIREMENTS.md` |

---

## 📖 Reading Order untuk Engineer Baru

1. **Konteks high-level:**
   - `../README.md` (top-level)
   - `../00_ARCHITECTURE.md` (sistem keseluruhan)
2. **Overview backend:**
   - `01_OVERVIEW.md`
3. **API contract (untuk integrasi dengan mobile):**
   - `FE_requirement/00_API_REQUIREMENTS.md`
4. **Database schema (untuk Prisma/SQL setup):**
   - `FE_requirement/01_DATABASE_DESIGN.md`
   - `FE_requirement/schema.sql`
5. **Implementation details:**
   - `02_PROJECT_STRUCTURE.md`
   - `05_AUTH_JWT.md`
   - `06_ML_INTEGRATION.md`
   - `07_BUSINESS_LOGIC.md`
6. **Deploy:**
   - `08_DEPLOYMENT.md`

---

## 🔄 Update History

| Tanggal | Update | Files |
|---|---|---|
| 2026-05-15 | Add `FE_requirement/*` sebagai source of truth; deprecate `03`, `04`; patch `01,02,05,06,07,08` | All |

---

## 🤝 Cross-References

- **Frontend docs:** [`../frontend/`](../frontend/) (screen specs, navigation, design system)
- **ML docs:** [`../machine-learning/`](../machine-learning/) (model specs, FastAPI service)
- **Top-level:** [`../00_ARCHITECTURE.md`](../00_ARCHITECTURE.md), [`../00_MASTER_PLAN.md`](../00_MASTER_PLAN.md)

# Heltigo — Documentation Index

> Heltigo adalah aplikasi mobile **AI-Powered Personal Health & Fitness** untuk MSU iREX 2026.
> Stack: Flutter (mobile) + Express.js/MySQL (backend) + Python FastAPI scikit-learn (ML).
> **Demo target:** 2026-05-21.

---

## 📂 Struktur Dokumentasi

```
docs/
├── README.md                    ← (file ini) — top-level index
├── 00_ARCHITECTURE.md           ← arsitektur sistem keseluruhan
├── 00_MASTER_PLAN.md            ← roadmap 2-minggu
├── 00_TIMELINE_2_WEEKS.md       ← timeline detail
│
├── frontend/                    ← Flutter mobile app
│   ├── README.md                ← index frontend
│   ├── 01..09_*.md              ← spec per topik
│   └── progress/                ← sprint progress notes
│
├── backend/                     ← Express.js + MySQL backend
│   ├── README.md                ← index backend
│   ├── FE_requirement/          ⭐ SOURCE OF TRUTH API + DB (latest 2026-05-15)
│   │   ├── 00_API_REQUIREMENTS.md
│   │   ├── 01_DATABASE_DESIGN.md
│   │   └── schema.sql
│   └── 01..08_*.md              ← draft awal (patched/deprecated)
│
└── machine-learning/            ← Python ML microservice
    ├── README.md                ← index ML
    ├── FE-model-requirement/    ⭐ SOURCE OF TRUTH MODEL SPEC (latest 2026-05-15)
    │   ├── 00_OVERVIEW.md
    │   ├── 01_MODELS_SPEC.md
    │   └── 02_DATASETS_INVENTORY.md
    └── 01..07_*.md              ← draft awal (patched)
```

---

## ⭐ Source of Truth per Area

| Area | Source of Truth | Status |
|---|---|---|
| **API endpoints** | [`backend/FE_requirement/00_API_REQUIREMENTS.md`](backend/FE_requirement/00_API_REQUIREMENTS.md) | ✅ Authoritative |
| **Database schema** | [`backend/FE_requirement/01_DATABASE_DESIGN.md`](backend/FE_requirement/01_DATABASE_DESIGN.md) + [`schema.sql`](backend/FE_requirement/schema.sql) | ✅ Authoritative |
| **ML model spec** | [`machine-learning/FE-model-requirement/01_MODELS_SPEC.md`](machine-learning/FE-model-requirement/01_MODELS_SPEC.md) | ✅ Authoritative |
| **ML dataset inventory** | [`machine-learning/FE-model-requirement/02_DATASETS_INVENTORY.md`](machine-learning/FE-model-requirement/02_DATASETS_INVENTORY.md) | ✅ Authoritative |
| **Frontend screen spec** | [`frontend/05_SCREENS_SPEC.md`](frontend/05_SCREENS_SPEC.md) + kode aktual `frontend/heltigo/lib/screens/` | ✅ Authoritative (sync 2026-05-15) |
| **Design system** | [`frontend/03_DESIGN_SYSTEM.md`](frontend/03_DESIGN_SYSTEM.md) + `frontend/heltigo/lib/styles/` | ✅ Authoritative |
| **Sistem arsitektur** | [`00_ARCHITECTURE.md`](00_ARCHITECTURE.md) | ✅ Aktif |

---

## ⚠️ Deprecated Files (jangan pakai)

| File | Pengganti |
|---|---|
| [`backend/03_DATABASE_SCHEMA.md`](backend/03_DATABASE_SCHEMA.md) | [`backend/FE_requirement/01_DATABASE_DESIGN.md`](backend/FE_requirement/01_DATABASE_DESIGN.md) |
| [`backend/04_API_ENDPOINTS.md`](backend/04_API_ENDPOINTS.md) | [`backend/FE_requirement/00_API_REQUIREMENTS.md`](backend/FE_requirement/00_API_REQUIREMENTS.md) |
| [`machine-learning/02_DATASETS.md`](machine-learning/02_DATASETS.md) | [`machine-learning/FE-model-requirement/02_DATASETS_INVENTORY.md`](machine-learning/FE-model-requirement/02_DATASETS_INVENTORY.md) |
| [`machine-learning/03_MODELS.md`](machine-learning/03_MODELS.md) | [`machine-learning/FE-model-requirement/01_MODELS_SPEC.md`](machine-learning/FE-model-requirement/01_MODELS_SPEC.md) |

(File-file di atas tetap di-keep sebagai sejarah desain. Jangan dipakai untuk implementasi.)

---

## 📖 Reading Order (Engineer Baru)

1. **Mulai dari sini:** `README.md` (file ini) → `00_ARCHITECTURE.md` → `00_MASTER_PLAN.md`
2. **Domain spesifik:**
   - **Mobile dev:** `frontend/README.md` → `frontend/01_OVERVIEW.md` → `frontend/05_SCREENS_SPEC.md`
   - **Backend dev:** `backend/README.md` → `backend/FE_requirement/00_API_REQUIREMENTS.md` → `backend/FE_requirement/01_DATABASE_DESIGN.md`
   - **ML engineer:** `machine-learning/README.md` → `machine-learning/FE-model-requirement/00_OVERVIEW.md` → `machine-learning/FE-model-requirement/01_MODELS_SPEC.md`
3. **Cross-area integration:** `backend/06_ML_INTEGRATION.md` + `frontend/08_API_INTEGRATION.md`

---

## 🎯 47 Screens Frontend → 60+ API Endpoints → 4 ML Models → 19 DB Tables

Lihat **screen→endpoint matrix** di [`backend/FE_requirement/00_API_REQUIREMENTS.md`](backend/FE_requirement/00_API_REQUIREMENTS.md) §11.

---

## 🔄 Last Sync Date

**2026-05-15** — Backend & ML docs di-sinkronkan dengan kode frontend aktual. Source of truth untuk API, DB, ML spec pindah ke folder `FE_requirement/` & `FE-model-requirement/`.

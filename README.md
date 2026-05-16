# Heltigo — AI-Powered Personal Health & Fitness

> Aplikasi mobile yang menyediakan rekomendasi workout & meal personal berbasis AI, serta adaptive weekly replanning. Dibangun untuk **MSU iREX 2026** hackathon.

**Demo target:** 2026-05-21
**Tech:** Flutter (mobile) + Express.js/MySQL (backend) + Python FastAPI ML (microservice)

---

## 📂 Struktur Proyek

```
heltigo/
├── frontend/heltigo/      ← Flutter mobile app (47 screens, dark mode)
├── notebook/              ← Python ML training notebooks
│   ├── .venv/             ← (gitignored) virtualenv
│   ├── dataset/           ← Training datasets (CSV)
│   ├── training_model/    ← Notebooks per model
│   ├── requirements.txt
│   └── README.md
├── docs/                  ← Comprehensive documentation
│   ├── frontend/          ← Screen specs, design system
│   ├── backend/           ← API + DB design
│   └── machine-learning/  ← ML model specs + research refs
├── Heltigo_Deskripsi_Aplikasi_Updated.docx
└── Heltigo_UI_Screens.docx
```

---

## 🚀 Quick Start

### 1. Frontend (Flutter)

```bash
cd frontend/heltigo
flutter pub get
flutter run
```

### 2. ML Notebooks (Python)

```powershell
cd notebook
python -m venv .venv
.\.venv\Scripts\Activate.ps1   # Windows
# atau: source .venv/bin/activate   # macOS/Linux
pip install -r requirements.txt
python -m ipykernel install --user --name=heltigo-ml --display-name "Heltigo ML"
jupyter notebook
```

### 3. Dataset Besar (download manual)

File `programs_detailed_boostcamp_kaggle.csv` (282MB) di-exclude dari git karena melebihi limit GitHub 100MB. Download dari:
- [Kaggle: 600K+ Fitness Exercise & Workout Program](https://www.kaggle.com/datasets/) (cari "boostcamp")
- Letakkan di: `notebook/dataset/Model_rekomendasi_Pelatihan/600K+ Fitness Exercise & Workout Program Dataset/`

---

## 🎯 3 Model ML

| # | Model | Tipe | Folder |
|---|---|---|---|
| 1 | Rekomendasi Latihan | XGBoost Classifier (multi-output) | `notebook/training_model/Model_Rekomendasi_Latihan/` |
| 2 | Perencana Makan | Knapsack + Genetic Algorithm (deap) | `notebook/training_model/Model_Perencana_Makan/` |
| 3 | Adaptif Perencanaan Ulang | Rule 3-cabang + XGBoost Regressor + Thompson Sampling | `notebook/training_model/Model_Adaptif_Perencanaan_Ulang/` |

Detail spec: [`docs/machine-learning/FE-model-requirement/`](docs/machine-learning/FE-model-requirement/).

---

## 📖 Dokumentasi

- [Master plan](docs/00_MASTER_PLAN.md)
- [Architecture](docs/00_ARCHITECTURE.md)
- [Frontend specs](docs/frontend/README.md) — 47 screens
- [Backend API & DB](docs/backend/README.md) — 60+ endpoints, 19 tables
- [ML models](docs/machine-learning/README.md) — research-driven (2024-2025 papers)

---

## 🎨 Design

- **Mode:** Dark only
- **Brand colors:** Teal `#1D6766` + Orange `#FB3A01`
- **Background:** `#0D0D0D` (pure dark)
- **Font:** Inter (Google Fonts)

---

## 👥 Team

MSU iREX 2026 Team — Heltigo

---

## 📄 License

Proprietary — hackathon submission MSU iREX 2026.

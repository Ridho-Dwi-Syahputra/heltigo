# Heltigo ML — Notebook Environment

> Folder ini berisi semua notebook EDA, preprocessing, training, dan evaluation untuk 3 model ML Heltigo.

**Stack:** Python 3.11 + XGBoost 2.0 + Optuna 3.5 + scikit-learn 1.4 + imbalanced-learn 0.12 + deap 1.4 + transformers 4.36 (IndoBERT).

---

## 🚀 Setup Pertama Kali

### 1. Pastikan Python 3.11 terinstall

```powershell
python --version
# Output: Python 3.11.x
```

Kalau belum: download dari [python.org](https://www.python.org/downloads/release/python-3119/) atau via winget:
```powershell
winget install Python.Python.3.11
```

### 2. Buat & aktifkan virtual environment

```powershell
cd "d:\Local Disk D\Tugas\hackathon core3d\notebook"
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

Kalau ada error PowerShell execution policy:
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### 3. Install dependencies

```powershell
pip install --upgrade pip
pip install -r requirements.txt
```

⚠️ **Catatan:** Total deps ~2 GB (termasuk torch untuk IndoBERT). Tunggu 5-10 menit tergantung koneksi.

### 4. Register Jupyter kernel

```powershell
python -m ipykernel install --user --name=heltigo-ml --display-name "Heltigo ML"
```

### 5. Start Jupyter

```powershell
jupyter notebook
# atau
jupyter lab
```

Pilih kernel **"Heltigo ML"** saat buka notebook.

---

## 📂 Struktur Folder

```
notebook/
├── .venv/                          ← Python virtualenv (jangan commit)
├── requirements.txt                ← Pin dependencies
├── README.md                       ← File ini
├── .gitignore                      ← Exclude .venv + artifacts
│
├── dataset/                        ← Raw datasets (read-only)
│   ├── Model_Adaptif_Perencanaan_Ulang/
│   ├── Model_Perencana Makan_dan_Nutrisi/
│   └── Model_rekomendasi_Pelatihan/
│
└── training_model/
    ├── Model_Rekomendasi_Latihan/
    │   ├── 01_eda.ipynb
    │   ├── 02_preprocessing.ipynb
    │   ├── 03_training.ipynb
    │   ├── 04_evaluation.ipynb
    │   └── output/
    │       ├── eda/        ← plot + summary.json
    │       ├── preprocessed/ ← .parquet + scaler.pkl
    │       ├── models/     ← workout_xgb_*.pkl
    │       └── evaluation/ ← metrics + confusion matrix
    │
    ├── Model_Perencana_Makan/
    │   ├── 01_eda.ipynb
    │   ├── 02_preprocessing.ipynb
    │   ├── 03_knapsack_engine.ipynb
    │   ├── 04_validation.ipynb
    │   └── output/
    │       ├── eda/
    │       ├── preprocessed/  ← food_master.parquet (1,346 row + 18 kolom)
    │       └── validation/
    │
    └── Model_Adaptif_Perencanaan_Ulang/
        ├── 01_eda.ipynb
        ├── 02_rule_engine.ipynb
        ├── 03_training_evaluation.ipynb
        └── output/
            ├── eda/
            ├── preprocessed/
            ├── models/     ← replanner_xgb.pkl
            └── evaluation/
```

---

## 🎯 Urutan Eksekusi

### Model 1 — Rekomendasi Latihan
```
01_eda.ipynb        → load + combine 973+1800 = 2,773 baris
02_preprocessing.ipynb → RobustScaler + SMOTEENN + augment 7-day = ~19k baris
03_training.ipynb   → XGBoost + Optuna 50 trial → workout_xgb_*.pkl
04_evaluation.ipynb → metrics + confusion matrix + ROC
```

### Model 2 — Perencana Makan
```
01_eda.ipynb        → EDA nutrition.csv + diet_recommendations
02_preprocessing.ipynb → augment kategori/price/halal/veg → food_master.parquet
03_knapsack_engine.ipynb → Knapsack daily + GA weekly diversity
04_validation.ipynb → cross-check medis (diabetes/hipertensi)
```

### Model 3 — Adaptif Perencanaan Ulang
```
01_eda.ipynb        → simulate weekly_score dari combined dataset
02_rule_engine.ipynb → Rule 3-cabang (Phase 1) + Thompson Sampling path (Phase 2)
03_training_evaluation.ipynb → XGBoost Regressor untuk fine-tune multiplier
```

---

## 📊 Target Metrics

| Model | Metric | Target | Sumber |
|---|---|---|---|
| Workout (XGBoost) | F1-macro workout_type | ≥ 0.85 | Jurnal EightGym Indonesia 2024 |
| Workout (XGBoost) | F1-macro intensity | ≥ 0.80 | Jurnal Nature Sci Reports 2025 |
| Meal (Knapsack + GA) | Calorie deviation | ≤ 15% | Diet planning paper Soft Computing 2024 |
| Meal (Knapsack + GA) | Food diversity score | ≥ 0.85 | GA improvement over greedy |
| Replanner (XGBoost) | MAE multiplier | < 0.04 | Internal target |
| Replanner (XGBoost) | R² | > 0.90 | Internal target |

---

## 📚 Referensi

- **Research references**: [`../docs/machine-learning/FE-model-requirement/03_RESEARCH_REFERENCES.md`](../docs/machine-learning/FE-model-requirement/03_RESEARCH_REFERENCES.md)
- **Model spec**: [`../docs/machine-learning/FE-model-requirement/01_MODELS_SPEC.md`](../docs/machine-learning/FE-model-requirement/01_MODELS_SPEC.md)
- **Dataset inventory**: [`../docs/machine-learning/FE-model-requirement/02_DATASETS_INVENTORY.md`](../docs/machine-learning/FE-model-requirement/02_DATASETS_INVENTORY.md)

---

## 🐛 Troubleshooting

### "ModuleNotFoundError: No module named 'xgboost'"
```powershell
.\.venv\Scripts\Activate.ps1  # Pastikan venv aktif
pip install -r requirements.txt
```

### Jupyter pakai Python global, bukan .venv
```powershell
python -m ipykernel install --user --name=heltigo-ml --display-name "Heltigo ML"
# Lalu pilih kernel "Heltigo ML" di Jupyter
```

### Torch install gagal (out of memory / disk)
Edit `requirements.txt`, comment out:
```
# transformers>=4.36
# torch>=2.1
# sentencepiece>=0.1.99
```
Lalu re-run `pip install -r requirements.txt`. IndoBERT jadi tidak available (skip Phase 2 NLP features).

### Optuna study sangat lambat
Reduce trial:
```python
study.optimize(objective, n_trials=20)  # dari 50 → 20
```

---

## 🔄 Reproducibility

Semua notebook pakai:
- `random_state=42`
- `np.random.seed(42)`
- Optuna `sampler=TPESampler(seed=42)`

Hasil training harus deterministic (selama Python + library versions sama).

# Machine Learning — Notebooks

> 📌 **Notebook sequence final 2026-05-15** — Lihat [`FE-model-requirement/02_DATASETS_INVENTORY.md`](FE-model-requirement/02_DATASETS_INVENTORY.md) §7:
>
> ```
> notebook/
> ├── 01_eda_gym_members.ipynb         (EDA workout dataset)
> ├── 02_eda_nutrition.ipynb           (EDA nutrition + diet rec)
> ├── 03_clean_nutrition.ipynb         (Augment nutrition.csv → food_master.parquet)
> ├── 04_train_workout_rf.ipynb        (Augment 973→6800 + train RF)
> ├── 05_test_meal_planner.ipynb       (Test knapsack)
> ├── 06_test_intensity_adjuster.ipynb (Test rule table 5×5)
> ├── 07_train_replanner_dt.ipynb      (Optional DT untuk replanner)
> └── 08_eval_endtoend.ipynb           (Smoke test all 4 models)
> ```
>
> **Artifact naming standard** (output ke `notebook/artifacts/`):
> - `workout_rf.pkl` (singular, `.pkl` extension)
> - `food_master.parquet` (singular)
> - `exercise_master_seed.json`
> - `intensity_table.json`
> - `replanner_dt.pkl` (optional)
>
> Konvensi: random seed = 42, output cells included di commit, data version tag di markdown header.

---

Inventaris notebook yang harus dibuat selama 2 minggu, di folder `notebook/` (top-level proyek) atau `ml-service/notebooks/` (mirror).

## 1. Status Saat Ini (per 2026-05-07)

```
notebook/
├── dataset/
│   ├── Model_Perencana Makan_dan_Nutrisi/
│   │   └── nutrition.csv                    ✅ Tersedia (1.346 baris)
│   ├── Model_Perencana_latihan/
│   │   └── (kosong)                         ❌ Open question
│   └── Model_rekomendasi_Pelatihan/
│       ├── 600K+ Fitness Exercise & Workout Program Dataset/    ✅ Tersedia
│       ├── exercide and fitness matrix dataset/                  ✅ Tersedia
│       ├── fitness exercises using BFP & BMI/                    ✅ Tersedia
│       └── gym_member_exercise_dataset/                          ✅ Tersedia
└── (no notebooks yet)
```

Notebooks belum dibuat — akan dibuat sesuai timeline.

## 2. Rencana Notebook (Day-by-Day)

### Day 1: EDA

#### `01_eda_workout.ipynb`
**Tujuan:** Pahami struktur dataset gym_member.

**Cell sequence:**
1. Import pandas, matplotlib, seaborn
2. Load `dataset/Model_rekomendasi_Pelatihan/gym_member_exercise_dataset/gym_members_exercise_tracking.csv`
3. `df.shape`, `df.dtypes`, `df.head()`, `df.describe()`
4. `df.isnull().sum()` — cek missing
5. Distribusi: histogram BMI, gender countplot, workout_type countplot, experience_level countplot
6. Korelasi heatmap antar fitur numerik
7. Boxplot BMI per workout_type
8. **Markdown summary**: list quality issues, distribusi imbalanced, plan cleaning

**Output:**
- Notebook dengan plot
- Catatan di akhir: "Dataset relatif balanced. Tidak ada missing besar. Outlier minor di BMI >40."

---

#### `02_eda_nutrition.ipynb`
**Tujuan:** Pahami struktur Indonesian Food.

**Cell sequence:**
1. Load `nutrition.csv`
2. Cek format: `df.dtypes` (sering kolom numerik tersimpan sebagai string)
3. Sample `df.head(20)` untuk melihat nama makanan
4. Cek apakah ada `image_url` field
5. Distribusi kalori (histogram dengan log-scale jika perlu)
6. Try infer kategori dari nama menggunakan keyword matching
7. **Markdown summary**: confirm field-field, plan augmentasi

**Output:**
- Catatan: "Field calories/protein/fat/carbohydrate ada. Field price tidak ada — perlu heuristic. Image URL: cek availability."

---

### Day 2: Cleaning

#### `03_clean_workout.ipynb`
**Tujuan:** Produce `workout_clean.parquet` siap training.

**Cell sequence:**
1. Load raw csv
2. Drop rows missing target (`Workout_Type`)
3. Encode kategorikal: `gender_enc`, `experience_enc`, `bmi_cat`
4. Drop outlier (BMI <12 or >50, session >4h)
5. `df.to_parquet('../dataset/clean/workout_clean.parquet')`
6. Print stats final

**Output:**
- `dataset/clean/workout_clean.parquet`

---

#### `04_clean_nutrition.ipynb`
**Tujuan:** Produce `foods_master.parquet` + `foods.csv` untuk seeder.

**Cell sequence:**
1. Load `nutrition.csv`
2. Parse numeric (`pd.to_numeric(errors='coerce')`)
3. Drop rows tanpa kalori
4. Augmentasi: `category` (keyword), `estimated_price_idr` (heuristic), `is_halal`, `is_vegetarian`, `contains_nuts`, `contains_dairy`
5. Generate UUID id per food
6. Save: `dataset/clean/foods_master.parquet` + `backend/prisma/seed-data/foods.csv`
7. Validasi: distribusi kategori (jangan dominan 1 kategori)

**Output:**
- `dataset/clean/foods_master.parquet`
- `backend/prisma/seed-data/foods.csv`

---

#### `04b_filter_exercises.ipynb` (opsional)
**Tujuan:** Filter 600K+ exercises ke ~200 yang relevan.

**Cell sequence:**
1. Load 600K dataset (mungkin perlu pakai `chunksize` jika file besar)
2. Filter BODYWEIGHT (target 100), DUMBBELL (target 50), BARBELL/MACHINE (target 50)
3. Filter difficulty: balanced BEGINNER/INTERMEDIATE/ADVANCED
4. Hapus duplikat (similarity check by name)
5. Augmentasi: `nameId` translasi ke Bahasa Indonesia (manual atau dictionary)
6. Save: `backend/prisma/seed-data/exercises.csv`

**Output:**
- `backend/prisma/seed-data/exercises.csv`
- `ml-service/app/data/exercise_master.parquet` (subset yang dipakai composer)

---

### Day 3-4: Workout Model Training

#### `05_train_workout_rf.ipynb`
**Tujuan:** Train + tune Random Forest workout classifier. Simpan joblib.

**Cell sequence (Day 3 — baseline):**
1. Load `workout_clean.parquet`
2. Synthesize 7-day per-user (lihat `04_PIPELINE.md` §2)
3. Train/test split 80/20 stratified
4. Baseline `RandomForestClassifier(n_estimators=100, max_depth=10)` wrapped in `MultiOutputClassifier`
5. Fit + predict
6. `classification_report` per output
7. Confusion matrix per output
8. Feature importance plot

**Cell sequence (Day 4 — tune):**
1. `GridSearchCV` over `n_estimators`, `max_depth`, `min_samples_split`
2. Best params + score
3. Re-fit dengan best params
4. Final eval
5. Save bundle: `joblib.dump({model, le_type, le_intensity, features}, '../app/data/workout_rf.joblib')`

**Output:**
- `ml-service/app/data/workout_rf.joblib`
- Markdown summary akhir: accuracy >70% target ✅

---

### Day 5: Meal Optimizer Dev

#### `06_meal_optimizer_dev.ipynb`
**Tujuan:** Validasi knapsack works dengan profile berbagai variasi.

**Cell sequence:**
1. Load `foods_master.parquet`
2. Import `from app.services.meal_planner import knapsack_meal, compose_meal_day`
3. Define 5 test profile (lose, maintain, gain × budget low/mid/high)
4. Run `compose_meal_day` untuk masing-masing
5. Validate:
   - Budget compliance (`total_cost ≤ budget_per_day`)
   - Calorie within ±20%
   - Protein ≥ 15% target
   - Tidak ada duplikat food dalam 1 hari
6. Iterate scoring weights jika hasil aneh
7. **Markdown**: ringkasan hasil + tweaking yang dilakukan

**Output:**
- Tidak ada model file (knapsack rule-based)
- Validasi service `meal_planner.py` siap dipakai

---

### Day 7: Replanner Logic

#### `07_replanner_logic.ipynb`
**Tujuan:** Validasi 3 strategi replanner dengan dummy plan + score.

**Cell sequence:**
1. Construct dummy plan minggu 1 (minimal: 5 workout days, 7 meal days)
2. Test scenario A: `score_percent=35, weight=tetap` → expect strategi REDUCE
3. Test scenario B: `score_percent=70, weight=on track` → expect strategi MAINTAIN_SWAP
4. Test scenario C: `score_percent=92, weight=on track` → expect strategi INTENSIFY
5. Edge case: skipped_exercises kosong
6. Edge case: weight_change kontradiksi target
7. **Markdown**: validasi semua scenario produce output yang masuk akal

**Output:**
- Service `replanner.py` siap dipakai

---

### Optional Day 10: Replanner DT Tweaking

#### `08_replanner_dt_finetune.ipynb` (opsional)
**Tujuan:** Train Decision Tree kecil untuk fine-tune intensity multiplier.

**Cell sequence:**
1. Generate synthetic data: 500 rows `(score, weight_diff, fitness_level, age) → multiplier`
2. Train DT max_depth=5
3. Eval (RMSE pada multiplier)
4. Save: `app/data/replanner_dt.joblib` (opsional)

Jika hasil tidak jauh berbeda dari rule-based hardcoded, **skip** dan tetap pakai rules. Tidak prioritas.

---

## 3. Standard Notebook Practices

1. **Setiap notebook** mulai dengan cell metadata:
   ```python
   """
   Notebook: 05_train_workout_rf.ipynb
   Author: ML Team
   Date: 2026-05-09
   Purpose: Train Random Forest untuk workout type & intensity classification.
   Dependencies: workout_clean.parquet (dari notebook 03)
   Output: app/data/workout_rf.joblib
   """
   ```

2. **Path relative**, bukan absolute. Pakai `Path(__file__).parent` style.

3. **Random seed** = 42 di mana pun ada randomness.

4. **Markdown narrative** di setiap section. Notebook bukan hanya kode — orang lain harus bisa baca dan paham.

5. **Run-all sebelum commit.** Jangan commit notebook dengan output stale.

6. **Output file** diluar git (gitignore parquet/joblib/csv besar) jika repo private. Untuk hackathon kecil, bisa di-commit semua untuk simplisitas — pastikan size < 50MB total.

## 4. Mapping ke Folder Existing

User sudah punya struktur:
```
notebook/
└── dataset/
    ├── Model_Perencana Makan_dan_Nutrisi/      ← nutrition.csv di sini
    ├── Model_Perencana_latihan/                  ← KOSONG (unclear purpose)
    └── Model_rekomendasi_Pelatihan/              ← 4 dataset workout di sini
```

Notebooks akan ditaruh di `notebook/` (top-level), output di `notebook/dataset/clean/` dan `ml-service/app/data/`.

**Open question:** Folder `Model_Perencana_latihan/` — confirm dengan user di Day 1:
- Opsi A: hapus folder, tidak dipakai (semua workout di `Model_rekomendasi_Pelatihan/`)
- Opsi B: dataset terpisah yang belum diunduh — tunggu upload
- Opsi C: dipakai untuk dataset training plan (yang berbeda dari rekomendasi awal) — perlu clarify

Default action: assume opsi A jika tidak ada konfirmasi user di Day 1.

## 5. Notebook Output Promotion ke ml-service

Hasil training di-copy ke `ml-service/app/data/`:

```bash
# Manual untuk hackathon (atau bash script)
cp ml-service/notebooks/output/workout_rf.joblib ml-service/app/data/workout_rf.joblib
cp notebook/dataset/clean/foods_master.parquet ml-service/app/data/food_master.parquet
cp notebook/dataset/clean/exercise_master.parquet ml-service/app/data/exercise_master.parquet
```

Pastikan file ini ter-include di Docker image (jangan masuk ke `.dockerignore`).

## 6. Reproducibility Checklist

Untuk setiap model, checklist agar reproducible:

- [ ] Notebook menyebut versi Python + library di cell awal (`pip freeze | grep -E '^(pandas|numpy|scikit-learn)'`)
- [ ] Random seed 42 set di semua randomness
- [ ] Path relative
- [ ] Output bundle (`joblib`) berisi: model, encoders, feature list, metadata (tanggal, accuracy)
- [ ] Markdown summary di akhir: accuracy, F1, top features, edge cases observed
- [ ] Sanity check: minimal 3 sample inference manual di cell terakhir

## 7. Konsumsi Notebook Output di FastAPI

Lihat `06_SERVING_FASTAPI.md` §8. Service load joblib + parquet di startup (singleton pattern).

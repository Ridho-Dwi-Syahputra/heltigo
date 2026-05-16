# Heltigo — Datasets Inventory & Quality Assessment

> Inventaris lengkap semua dataset di [`notebook/dataset/`](../../../notebook/dataset/) plus quality score, augmentation needed, dan mapping ke model ML.

**Versi:** 1.1 (2026-05-16 — added combined dataset strategy for Model 1)
**Total file dataset:** ~14 (CSV + XLSX)
**Total ukuran:** ~310 MB

## 🔄 Update 2026-05-16: Dataset Combination Strategy

**Model 1 (Rekomendasi Latihan) — Combined Approach:**
- `gym_members_exercise_tracking.csv` (973 baris, real) **+**
- `gym_members_exercise_tracking_synthetic_data.csv` (1,800 baris, synthetic) — schema **identik**
- → **Combined: 2,773 baris**
- → Augmentasi 7-day expansion → **~19,400 baris training**
- Drift check: KS-test pakai p-value ≥ 0.05 untuk verifikasi synthetic representative

**Model 3 (Adaptive Replanner) — Same Combined Dataset:**
- Pakai combined dataset Model 1 untuk simulasi `weekly_score` per user
- → **2,773 → 2,773 records** dengan simulated targets untuk XGBoost Regressor

**Optional weak label:** `final_dataset_BFP.csv` (5,000 baris) bisa dipakai untuk validation rules (BMI→exercise plan mapping), TIDAK di-concat ke training karena schema beda.

---

## 1. Struktur Folder

```
notebook/dataset/
├── Model_Adaptif_Perencanaan_Ulang/        ← Untuk Replanner
│   └── Fitness Tracker Dataset/
│       └── gym_members_exercise_tracking_synthetic_data.csv
├── Model_rekomendasi_Pelatihan/            ← Untuk Workout Recommender
│   ├── 600K+ Fitness Exercise & Workout Program Dataset/
│   │   ├── program_summary.csv
│   │   └── programs_detailed_boostcamp_kaggle.csv  (~294 MB)
│   ├── exercide and fitness matrix dataset/
│   │   └── exercise_dataset.csv
│   ├── fitness exercises using BFP & BMI/
│   │   └── final_dataset_BFP.csv
│   └── gym_member_exercise_dataset/
│       └── gym_members_exercise_tracking.csv  ← PRIMARY
└── Model_Perencana Makan_dan_Nutrisi/      ← Untuk Meal Planner
    ├── Diet Recommendations Dataset/
    │   └── diet_recommendations_dataset.csv
    ├── Indonesian Food & Drink Nutrition Dataset/
    │   └── nutrition.csv                     ← PRIMARY (must augment)
    ├── Malaysian Food Barometer 2 (MFB2)/
    │   └── *.xlsx + *.docx  (reference only)
    └── USDA FoodData Central/
        └── *.xlsx  (reference only)
```

---

## 2. Inventory Table

| # | Dataset | Path (relatif `notebook/dataset/`) | Format | Rows | Size | Domain | Quality | Status |
|---|---|---|---|---|---|---|---|---|
| 1 | Gym Members Tracking (Synthetic) | `Model_Adaptif_Perencanaan_Ulang/Fitness Tracker Dataset/gym_members_exercise_tracking_synthetic_data.csv` | CSV | 1,800 | 138 KB | Replanning | 9/10 | ✅ Ready |
| 2 | Gym Members Tracking (Real) | `Model_rekomendasi_Pelatihan/gym_member_exercise_dataset/gym_members_exercise_tracking.csv` | CSV | 973 | 65 KB | Workout (Primary) | 8/10 | ✅ Ready (augment 7×) |
| 3 | 600K+ Programs (summary) | `Model_rekomendasi_Pelatihan/600K+ Fitness Exercise & Workout Program Dataset/program_summary.csv` | CSV | 7,799 | ~ | Workout (Library) | 9/10 | ✅ Ready (parse level field) |
| 4 | 600K+ Programs (detailed) | `Model_rekomendasi_Pelatihan/600K+ Fitness Exercise & Workout Program Dataset/programs_detailed_boostcamp_kaggle.csv` | CSV | ~M | 294 MB | Workout (Library) | 9/10 | ⚠️ Use chunked, filter ~200 |
| 5 | Exercise Matrix | `Model_rekomendasi_Pelatihan/exercide and fitness matrix dataset/exercise_dataset.csv` | CSV | 3,864 | 343 KB | Workout (Aux) | 7.5/10 | ✅ Ready (HR sanity check) |
| 6 | BFP & BMI Plan | `Model_rekomendasi_Pelatihan/fitness exercises using BFP & BMI/final_dataset_BFP.csv` | CSV | 5,000 | 518 KB | Workout (Validation) | 9/10 | ✅ Ready |
| 7 | Indonesian Food Nutrition | `Model_Perencana Makan_dan_Nutrisi/Indonesian Food & Drink Nutrition Dataset/nutrition.csv` | CSV | 1,346 | 195 KB | Meal (Primary) | 7/10 → 9/10 setelah augment | ⚠️ Augment wajib |
| 8 | Diet Recommendations | `Model_Perencana Makan_dan_Nutrisi/Diet Recommendations Dataset/diet_recommendations_dataset.csv` | CSV | 1,000 | 121 KB | Meal (Validation) | 8.5/10 | ✅ Ready (as validator) |
| 9 | Malaysian Food Barometer 2 | `Model_Perencana Makan_dan_Nutrisi/Malaysian Food Barometer 2 (MFB2)/*.xlsx` | XLSX × 3 | ~2,000 | 3.6 MB | Meal (Reference) | 9/10 (untuk reference) | ℹ️ Optional Phase 4 |
| 10 | USDA FoodData Central | `Model_Perencana Makan_dan_Nutrisi/USDA FoodData Central/*.xlsx` | XLSX × 4 | ~5,000 | 8.7 MB | Meal (Reference) | 10/10 | ℹ️ Optional Phase 4 |

---

## 3. Detail per Dataset

### 3.1 `gym_members_exercise_tracking_synthetic_data.csv` (1,800 rows)

**Path:** `Model_Adaptif_Perencanaan_Ulang/Fitness Tracker Dataset/`

**Kolom:**
| Kolom | Tipe | Range |
|---|---|---|
| Age | int | 18-54 |
| Gender | str | Male, Female |
| Weight (kg) | float | 46.5-121.7 |
| Height (m) | float | 1.54-1.94 |
| Max_BPM | int | 160-200 |
| Avg_BPM | int | 120-180 |
| Resting_BPM | int | 50-90 |
| Session_Duration (hours) | float | 0.59-1.69 |
| Calories_Burned | float | 532-1678 |
| Workout_Type | str | Strength, Cardio, HIIT, Yoga (4 categories) |
| Fat_Percentage | float | 11.6-33.9 |
| Water_Intake (liters) | float | 1.8-3.7 |
| Workout_Frequency (days/week) | int | 2-5 |
| Experience_Level | int | 1, 2, 3 |
| BMI | float | 12.73-49.84 |

**Sample 3 rows:**
```
34, Female, 86.7, 1.86, 174, 152, 74, 1.12, 712,  Strength, 12.8, 2.4, 5, 2, 14.31
26, Female, 84.7, 1.83, 166, 156, 73, 1.0,  833,  Strength, 27.9, 2.8, 5, 2, 33.49
22, Male,   64.8, 1.85, 187, 166, 64, 1.24, 1678, Cardio,   28.7, 1.9, 3, 2, 12.73
```

**Quality:** 9/10
- ✅ Complete (no missing values)
- ✅ Synthetic but realistic ranges
- ⚠️ Hanya 4 workout type (Yoga, bukan FLEXIBILITY/REST)
- ⚠️ Some BMI outliers (12.73 = severely underweight)

**Used for:** Adaptive Replanner training (optional DT)

**Augmentation:** None required for replanner. For workout RF, expand 1 row → 7 day rows (lihat 3.2).

---

### 3.2 `gym_members_exercise_tracking.csv` (973 rows) — PRIMARY

**Path:** `Model_rekomendasi_Pelatihan/gym_member_exercise_dataset/`

Kolom identik dengan 3.1 (synthetic version). Real gym data.

**Quality:** 8/10
- ✅ Real gym member data → lebih representative
- ✅ Diverse demographics
- ⚠️ Hanya 973 rows untuk 13-feature RF → augmentation wajib

**Used for:** Workout Recommender (PRIMARY training data)

**Augmentation strategy (notebook `02_train_workout.ipynb`):**

```python
# 1 user → 7 day rows
def expand_user_to_week(user_row):
    rows = []
    days_per_week = user_row['Workout_Frequency (days/week)']
    workout_indices = sample_days(days_per_week)  # e.g., [0, 2, 4]
    
    for day_idx in range(7):
        new_row = user_row.copy()
        new_row['day_index'] = day_idx
        new_row['is_first_day'] = int(day_idx == 0)
        
        if day_idx in workout_indices:
            # Active day: use original workout_type
            pass
        else:
            # Rest day
            new_row['workout_type_label'] = 'REST'
            new_row['intensity_label'] = 'LOW'
        
        # Add small noise
        new_row['BMI'] += np.random.normal(0, 0.5)
        new_row['Age'] += np.random.randint(-1, 2)
        
        rows.append(new_row)
    return rows

# Apply
expanded = []
for _, user in df.iterrows():
    expanded.extend(expand_user_to_week(user))
# Result: 973 × 7 ≈ 6,811 rows
```

---

### 3.3 `program_summary.csv` (7,799 rows)

**Path:** `Model_rekomendasi_Pelatihan/600K+ Fitness Exercise & Workout Program Dataset/`

**Kolom utama:**
| Kolom | Tipe | Notes |
|---|---|---|
| `title` | str | E.g., "5x5 Strength Program" |
| `description` | str | Free text |
| `level` | str (list-like) | `"['Beginner', 'Intermediate']"` — perlu parsing |
| `goal` | str | `muscle building`, `weight loss`, `strength`, `conditioning`, ... |
| `equipment` | str | `dumbbell`, `barbell`, `bodyweight`, `gym` |
| `program_length` | str | E.g., "6 weeks" |
| `time_per_workout` | str | E.g., "60 minutes" |
| `total_exercises` | int | |

**Quality:** 9/10 untuk structure, ⚠️ untuk parsing complexity

**Used for:** Seed `exercise_master` table (~200 entries kurasi).

**Parsing tip:**
```python
import ast
df['level_list'] = df['level'].apply(lambda x: ast.literal_eval(x) if isinstance(x, str) else x)
df['is_beginner'] = df['level_list'].apply(lambda x: 'Beginner' in x)
```

---

### 3.4 `programs_detailed_boostcamp_kaggle.csv` (~294 MB)

**Path:** `Model_rekomendasi_Pelatihan/600K+ Fitness Exercise & Workout Program Dataset/`

Detailed exercise-level data. Too large untuk loaded full.

**Strategy:** Chunked loading (`pd.read_csv(..., chunksize=10000)`) + filter ke ~200 exercise paling umum (bodyweight, dumbbell, beginner-intermediate). Save filtered ke Parquet (`exercise_master.parquet`).

---

### 3.5 `exercise_dataset.csv` (3,864 rows)

**Path:** `Model_rekomendasi_Pelatihan/exercide and fitness matrix dataset/`

**Kolom utama:**
| Kolom | Tipe |
|---|---|
| Exercise | str (10 unique: "Exercise 1"-"Exercise 10") |
| Calories Burn | float |
| Heart Rate | int (100-180) |
| Duration | int (20-53 min) |
| Weather Conditions | str |
| Exercise Intensity | int (1-10) |

**Quality:** 7.5/10
- ✅ Multi-variate dengan HR
- ⚠️ Exercise names generic, bukan real

**Used for:** Sanity check intensity adjuster (HR vs intensity correlation).

---

### 3.6 `final_dataset_BFP.csv` (5,000 rows)

**Path:** `Model_rekomendasi_Pelatihan/fitness exercises using BFP & BMI/`

**Kolom:**
| Kolom | Tipe |
|---|---|
| Weight | float (52-105) |
| Height | float (1.4-1.94) |
| BMI | float (15-34) |
| Body Fat Percentage | float (9-50) |
| BFPcase | str (4 categories: Acceptable, Fitness, Obese, Athletes) |
| Gender | str |
| Age | int (19-63) |
| BMIcase | str (7 categories) |
| Exercise Recommendation Plan | int (1-7) |

**Quality:** 9/10

**Used for:** Validation Workout RF — pastikan recommendations match BFPcase rules. Bisa juga di-merge sebagai augmentation training data.

---

### 3.7 `nutrition.csv` (1,346 rows) — PRIMARY but needs augmentation

**Path:** `Model_Perencana Makan_dan_Nutrisi/Indonesian Food & Drink Nutrition Dataset/`

**Kolom existing:**
| Kolom | Tipe | Sample |
|---|---|---|
| id | int | 1, 2, 3 |
| calories | int | 0-940 |
| proteins | float (g) | 0-23.7 |
| fat | float (g) | 0-37 |
| carbohydrate | float (g) | 0-77 |
| name | str | "Abon", "Agar-agar", "Alpukat" |
| image | str (URL) | https://... |

**Sample 5 rows:**
```
1, 280, 9.2,  28.4, 0,    Abon,          https://...
2, 513, 23.7, 37,   21.3, Abon haruwan,  https://...
3, 0,   0,    0.2,  0,    Agar-agar,     https://...
4, 85,  1.0,  6.5,  9.6,  Alpukat,       https://...
5, 70,  0.3,  0.4,  17.9, Apel,          https://...
```

**Quality:** 7/10 (sebelum augmentation) → 9/10 setelahnya

**Issues:**
- ❌ No `category` (STAPLE/PROTEIN/dll)
- ❌ No `price_idr` (CRITICAL untuk Meal Planner)
- ❌ No `is_halal`, `is_vegetarian`
- ⚠️ 0-calorie entries (Agar-agar, beberapa minuman)
- ⚠️ Image URL mungkin broken (perlu fallback)
- ⚠️ Beberapa nama makanan typo / kapitalisasi inkonsisten

**MANDATORY AUGMENTATION:** Lihat `01_MODELS_SPEC.md` §Model 2 untuk detail script. Output: `food_master.parquet` siap seed ke MySQL.

---

### 3.8 `diet_recommendations_dataset.csv` (1,000 rows)

**Path:** `Model_Perencana Makan_dan_Nutrisi/Diet Recommendations Dataset/`

**Kolom:**
| Kolom | Tipe | Range |
|---|---|---|
| Patient_ID | str | P0001-P1000 |
| Age | int | |
| Gender | str | M/F |
| Weight_kg | float | |
| Height_cm | float | |
| BMI | float | |
| Disease_Type | str | Obesity / Diabetes / Hypertension / None |
| Severity | str | Mild / Moderate / Severe |
| Physical_Activity_Level | str | Sedentary / Moderate / Active |
| Daily_Caloric_Intake | int | 1737-3496 |
| Cholesterol_mg/dL | float | 163-200 |
| Glucose_mg/dL | float | 85-182 |
| Blood_Pressure_mmHg | str | "120/80" |
| Dietary_Restrictions | str | None / Low_Sugar / Low_Sodium |
| Allergies | str | None / Peanuts / Gluten |
| Preferred_Cuisine | str | Mexican / Chinese / Indian / Italian |
| Adherence_to_Diet_Plan | float (%) | 54-96 |
| Diet_Recommendation | str | Balanced / Low_Carb / Low_Sodium |

**Quality:** 8.5/10

**Used for:** Validation Meal Planner — pastikan output ML untuk user dengan disease_type=Diabetes → diet output low_carb / low_sugar.

---

### 3.9 Malaysian Food Barometer 2 (MFB2)

**Path:** `Model_Perencana Makan_dan_Nutrisi/Malaysian Food Barometer 2 (MFB2)/`

3 XLSX files + DOCX. SE Asia dietary patterns.

**Use case:** Optional Phase 4 — regional tuning untuk meal recommender. Skip untuk hackathon.

---

### 3.10 USDA FoodData Central

**Path:** `Model_Perencana Makan_dan_Nutrisi/USDA FoodData Central/`

4 XLSX files. Gold-standard nutrient data internasional.

**Use case:** Cross-validation nutrient values (kalau `nutrition.csv` ada outlier mencurigakan). Skip untuk hackathon utama; lakukan kalau ada waktu.

---

## 4. Dataset → Model Mapping

```
gym_members_exercise_tracking.csv ──────────► Workout RF (PRIMARY)
gym_members_synthetic.csv ──────────────────► Workout RF (validation) + Replanner DT (optional)
program_summary.csv ────────────────────────► exercise_master seed
programs_detailed_boostcamp_kaggle.csv ─────► exercise_master seed (chunked)
exercise_dataset.csv ───────────────────────► Intensity Adjuster sanity check
final_dataset_BFP.csv ──────────────────────► Workout RF validation

nutrition.csv (augmented) ──────────────────► food_master seed + Meal Planner knapsack
diet_recommendations_dataset.csv ───────────► Meal Planner validation rules
MFB2 / USDA ────────────────────────────────► (Phase 4) reference validation
```

---

## 5. Critical Data Gaps & Mitigations

| Gap | Severity | Mitigasi |
|---|---|---|
| Food pricing (IDR) tidak ada | 🔴 HIGH | Heuristic: `category × calories × base_price`. Phase 4: scrape Tokopedia/Lazada |
| Pre-workout intensity calibration tidak punya labeled data | 🟡 MEDIUM | Hardcode 5×5 table, validate via exercise_dataset HR |
| Longitudinal user adherence data | 🟡 MEDIUM | Synthetic generation di replanner training |
| Exercise contraindications per kondisi medis | 🟡 MEDIUM | Hardcode rules (low_back_pain → no squat) |
| Detailed program 294 MB file size | 🟢 LOW | Chunked read + filter ke 200 entries |
| 0-calorie nutrition entries | 🟢 LOW | Filter atau impute min 1 kcal |
| Disease overlap (Diabetes + Hypertension) | 🟢 LOW | Priority mapping di code |

---

## 6. Data Cleaning Priority

### P0 — CRITICAL (Days 1-2)
1. **Clean & augment `nutrition.csv`:**
   - Add columns: `category`, `estimated_price_idr`, `is_halal`, `is_vegetarian`, `is_vegan`, `is_gluten_free`
   - Filter 0-calorie atau impute
   - Standardize name capitalization
   - Save as `food_master.parquet` di `notebook/artifacts/`

2. **Validate `gym_members_exercise_tracking.csv`:**
   - Check & remove BMI outliers (< 14 atau > 45 mungkin error)
   - Verify Workout_Type distribution (avoid heavy class imbalance)

### P1 — IMPORTANT (Days 3-4)
3. **Parse `program_summary.csv`:**
   - Convert `level` list field
   - Filter beginner-intermediate
   - Curate top ~200 by total_exercises + popular muscle_groups
   - Save as `exercise_master_seed.json`

4. **Chunked load `programs_detailed_boostcamp_kaggle.csv`:**
   - Filter exercises that match `exercise_master_seed`
   - Extract instructions, tips, video_urls
   - Merge ke seed JSON

### P2 — NICE TO HAVE (Days 5+)
5. Cross-validate `nutrition.csv` macro values vs USDA reference (random sample).
6. Add Malaysian dishes dari MFB2 ke `food_master` extra entries.

---

## 7. EDA Notebook Convention

Saran struktur notebook:
```
notebook/
├── 01_eda_gym_members.ipynb         (EDA workout dataset)
├── 02_eda_nutrition.ipynb           (EDA nutrition + diet rec)
├── 03_clean_nutrition.ipynb         (Augment nutrition.csv → food_master.parquet)
├── 04_train_workout_rf.ipynb        (Augment + train RandomForest)
├── 05_test_meal_planner.ipynb       (Test knapsack)
├── 06_test_intensity_adjuster.ipynb (Test rule table)
├── 07_train_replanner_dt.ipynb      (Optional DT)
├── 08_eval_endtoend.ipynb           (Smoke test all models)
└── requirements.txt
```

Per notebook commit:
- ✅ Output cells included
- ✅ Markdown intro + summary per section
- ✅ Random seed = 42
- ✅ Data version tag (e.g., "nutrition.csv MD5: ...")

---

## 8. Storage & Artifacts

Setelah cleaning + training:

```
notebook/artifacts/
├── workout_rf.pkl                  ← Model 1
├── food_master.parquet              ← Augmented nutrition (1,346 rows)
├── exercise_master_seed.json        ← Curated ~200 exercises
├── intensity_table.json             ← Hardcoded 5×5
└── replanner_dt.pkl (optional)      ← Model 4
```

Total size: < 50 MB. Bisa di-commit ke repo (atau di-host di S3 untuk loading saat FastAPI startup).

---

## 9. Refresh Strategy

- **Pre-demo refresh (sekali):** Run all P0 notebooks → artifacts.
- **Post-demo (future):** Retrain quarterly jika ada data baru atau model drift detected.

---

**Lihat juga:**
- [`00_OVERVIEW.md`](00_OVERVIEW.md) — overall arsitektur ML
- [`01_MODELS_SPEC.md`](01_MODELS_SPEC.md) — spec detail per model
- [`../02_DATASETS.md`](../02_DATASETS.md) — versi spec lainnya (jika ada)

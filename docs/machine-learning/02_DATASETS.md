# Machine Learning — Datasets

> 📌 **Inventaris dataset terbaru 2026-05-15** ada di:
> **[`FE-model-requirement/02_DATASETS_INVENTORY.md`](FE-model-requirement/02_DATASETS_INVENTORY.md)**
>
> Inventaris lengkap dengan: tabel dataset (10 sumber), quality score per dataset (7-10), sample 3 rows per CSV, augmentation strategy per dataset, dataset→model mapping, critical data gaps + mitigations.
>
> Dokumen ini ([`02_DATASETS.md`](02_DATASETS.md)) tetap di-keep sebagai draft awal — gunakan **`02_DATASETS_INVENTORY.md`** untuk reference terbaru.

---

## 1. Inventaris Dataset (Existing di `notebook/dataset/`)

Status per 2026-05-07. Path relatif terhadap root proyek `d:\Local Disk D\Tugas\hackathon core3d\`.

### 1.1 Workout / Latihan

#### `notebook/dataset/Model_rekomendasi_Pelatihan/`

| Folder/File | Sumber | Status | Catatan |
|---|---|---|---|
| `gym_member_exercise_dataset/` | Kaggle: valakhorasani/gym-members-exercise-dataset | ✅ Tersedia | 973 baris. **Dataset PRIMER** untuk train Workout RF |
| `600K+ Fitness Exercise & Workout Program Dataset/` | Kaggle: adnanelouardi/600k-fitness-exercise-and-workout-program-dataset | ✅ Tersedia | Library latihan untuk seed exercise_items table. Filter ~200 untuk home + gym. |
| `fitness exercises using BFP & BMI/` | Kaggle: mustafa20635/fitness-exercises-using-bfp-and-bmi | ✅ Tersedia | Mapping BMI/BFP → tipe latihan. Untuk validasi rules. |
| `exercide and fitness matrix dataset/` | Kaggle: aakashjoshi123/exercise-and-fitness-metrics-dataset | ✅ Tersedia | Multi-feature (BMI, lemak, BPM, durasi, tipe latihan, level, kalori). Untuk feature engineering tambahan. |

#### `notebook/dataset/Model_Perencana_latihan/`

| Folder/File | Status | Catatan |
|---|---|---|
| *(kosong)* | ❌ KOSONG | **Open question**: dataset ini apakah dimerge dengan `Model_rekomendasi_Pelatihan/` atau dataset terpisah yang belum diunduh? Klarifikasi user diperlukan saat Day 1 ML. |

### 1.2 Nutrition / Makanan

#### `notebook/dataset/Model_Perencana Makan_dan_Nutrisi/`

| File | Sumber | Status | Catatan |
|---|---|---|---|
| `nutrition.csv` | Kaggle: anasfikrihanif/indonesian-food-and-drink-nutrition-dataset | ✅ Tersedia | 1.346 item makanan/minuman Indonesia. **Database PRIMER** meal planner. Contains: name, calories, protein, fat, carb, dan field tambahan. |

### 1.3 Adaptive / Replanning (Belum Diunduh)

Dataset ini **belum di-folder local**, perlu didownload jika mau dipakai untuk training adaptive model:

| Dataset | Sumber | Use case |
|---|---|---|
| Fitness Tracker Dataset | Kaggle: nadeemajeedch/fitness-tracker-dataset | Time-series longitudinal untuk train adaptive replanner. **Opsional** — bisa pakai rule-based untuk hackathon |
| NHANES | CDC: cdc.gov/nchs/nhanes | National survey untuk validasi. **Opsional** |

**Keputusan default hackathon:** Skip download dataset adaptive. Replanner pakai rule-based dengan small Decision Tree opsional. Lihat `03_MODELS.md` §3.

## 2. Schema Dataset Detail

### 2.1 `gym_member_exercise_dataset/gym_members_exercise_tracking.csv`

Field utama (perlu dicek saat EDA Day 1):
- `Age`, `Gender`, `Weight (kg)`, `Height (m)`, `BMI`
- `Max_BPM`, `Avg_BPM`, `Resting_BPM`
- `Session_Duration (hours)`
- `Calories_Burned`
- `Workout_Type` (Cardio, Strength, Yoga, HIIT) ← **target classification**
- `Fat_Percentage`, `Water_Intake (liters)`
- `Workout_Frequency (days/week)`, `Experience_Level`

Use case: **target = Workout_Type**. Train classifier dari fitur fisiologis + preferensi.

### 2.2 `nutrition.csv`

Field utama (perlu validasi saat EDA Day 1):
- `name` (string, ID nama makanan)
- `calories` (kkal per porsi)
- `protein` (g)
- `fat` (g)
- `carbohydrate` (g)
- Field tambahan: image, source URL

Tidak ada `price` atau `category` di dataset asli. Perlu **augmentasi**:
1. Klasifikasi `category` manual atau heuristic dari nama (e.g. nama mengandung "nasi" → STAPLE).
2. Estimasi `price_idr` heuristic berdasarkan kalori + kategori (e.g. STAPLE 2000-5000/porsi, PROTEIN 8000-25000/porsi).
3. Flag `is_halal=true` default (asumsi semua halal kecuali keyword "babi/pork/wine"), `is_vegetarian=false` default kecuali tidak ada keyword daging/ikan.

### 2.3 `600K+ Fitness Exercise & Workout Program Dataset`

Format: kemungkinan multiple CSV. Field umum:
- exercise_name, target_muscle, equipment, difficulty
- sets, reps, rest, instructions
- video_url (opsional)

Use case: **seed master `exercise_items`**. Filter ke ~200 yang relevan:
- 100 BODYWEIGHT (untuk Home mode)
- 100 mixed equipment (DUMBBELL, BARBELL, MACHINE) untuk Gym mode

## 3. Cleaning Plan (Day 2 ML)

### 3.1 Workout Cleaning Notebook

`notebook/03_clean_workout.ipynb`:

```python
import pandas as pd
df = pd.read_csv('../dataset/Model_rekomendasi_Pelatihan/gym_member_exercise_dataset/gym_members_exercise_tracking.csv')

# Drop rows dengan missing target
df = df.dropna(subset=['Workout_Type'])

# Encode kategorikal
df['gender_enc'] = df['Gender'].map({'Male': 0, 'Female': 1})
df['experience_enc'] = df['Experience_Level'].map({'Beginner': 0, 'Intermediate': 1, 'Advanced': 2})

# Bins age
df['age_band'] = pd.cut(df['Age'], bins=[0, 25, 35, 50, 100], labels=['young', 'adult', 'mid', 'senior'])

# BMI kategori
df['bmi_cat'] = pd.cut(df['BMI'], bins=[0, 18.5, 25, 30, 100], labels=['UNDER', 'NORMAL', 'OVER', 'OBESE'])

# Drop outliers
df = df[(df['BMI'] >= 12) & (df['BMI'] <= 50)]
df = df[df['Session_Duration (hours)'] <= 4]

df.to_parquet('../dataset/clean/workout_clean.parquet')
```

### 3.2 Nutrition Cleaning Notebook

`notebook/04_clean_nutrition.ipynb`:

```python
import pandas as pd
import re

df = pd.read_csv('../dataset/Model_Perencana Makan_dan_Nutrisi/nutrition.csv')

# Parse numerik (sering string dengan satuan)
for col in ['calories', 'protein', 'fat', 'carbohydrate']:
    df[col] = pd.to_numeric(df[col], errors='coerce')

df = df.dropna(subset=['calories'])

# Augmentasi category
def categorize(name: str) -> str:
    name = name.lower()
    if any(k in name for k in ['nasi', 'mie', 'roti', 'kentang']):
        return 'STAPLE'
    if any(k in name for k in ['ayam', 'ikan', 'sapi', 'tempe', 'tahu', 'telur']):
        return 'PROTEIN'
    if any(k in name for k in ['sayur', 'sup', 'soto']):
        return 'VEGETABLE'
    if any(k in name for k in ['buah', 'pisang', 'apel', 'jeruk']):
        return 'FRUIT'
    if any(k in name for k in ['teh', 'kopi', 'jus', 'susu', 'air']):
        return 'BEVERAGE'
    if any(k in name for k in ['cake', 'kue', 'es krim', 'permen']):
        return 'DESSERT'
    return 'SNACK'

df['category'] = df['name'].apply(categorize)

# Augmentasi price (heuristic kasar)
def estimate_price_idr(row):
    base = {'STAPLE': 3000, 'PROTEIN': 12000, 'VEGETABLE': 4000, 'FRUIT': 5000,
            'BEVERAGE': 5000, 'SNACK': 6000, 'SOUP': 10000, 'DESSERT': 8000}[row['category']]
    # Skala dengan kalori (300 kkal = base, 100 kkal = base × 0.5, 600 kkal = base × 1.4)
    factor = max(0.4, min(1.5, row['calories'] / 300))
    return int(base * factor)

df['estimated_price_idr'] = df.apply(estimate_price_idr, axis=1)

# Halal & vegetarian flags
non_halal_keywords = ['babi', 'pork', 'wine', 'rum', 'beer']
df['is_halal'] = df['name'].str.lower().apply(lambda n: not any(k in n for k in non_halal_keywords))

veg_keywords = ['sayur', 'tahu', 'tempe', 'sup sayur', 'gado-gado', 'kacang']
nonveg_keywords = ['ayam', 'sapi', 'ikan', 'udang', 'kerang', 'cumi', 'daging']
df['is_vegetarian'] = df['name'].str.lower().apply(
    lambda n: any(k in n for k in veg_keywords) and not any(k in n for k in nonveg_keywords)
)

# Save final
df.to_parquet('../dataset/clean/foods_master.parquet', index=False)
print(f"Total foods: {len(df)}")
```

Catatan: heuristic price akurasi ~60-70%, cukup untuk demo. Pasca-hackathon, scrape harga real dari marketplace.

## 4. Master Data untuk Backend Seeder

Output cleaning notebook akan di-export ke `backend/prisma/seed-data/`:
- `foods.csv` (1.346 baris hasil cleaning)
- `exercises.csv` (~200 baris hasil filter dari 600K)

Backend `prisma db seed` akan baca CSV ini dan insert ke MySQL.

## 5. Sumber Eksternal (Untuk Validasi)

| Sumber | Kegunaan |
|---|---|
| USDA FoodData Central | Validasi nilai gizi (jika dataset Indonesia tampak invalid) |
| Malaysian Food Barometer 2 (MFB2) | Referensi akademis pola makan SE Asia |
| NHANES | Validasi BMI/TDEE kalkulasi |

Tidak diintegrasikan langsung ke pipeline, hanya untuk sanity check saat EDA.

## 6. Etika & Lisensi

Semua dataset Kaggle dipakai bersifat **publik** dan terlisensi untuk educational use.
- Sertakan attribution di **App Settings (S-33)** dan README:
  - "Indonesian Food & Drink Nutrition Dataset by Anas Fikri Hanif (Kaggle)"
  - "Gym Members Exercise Dataset by Valakhorasani (Kaggle)"
  - "USDA FoodData Central (Public Domain)"

## 7. Open Questions (Day 1 ML)

1. **`Model_Perencana_latihan/` kosong** — apakah dataset terpisah (belum diunduh) atau supposed merge dengan `Model_rekomendasi_Pelatihan/`?
   - **Default action:** assume merge. Train satu Workout RF dari `gym_member_exercise_dataset` saja. Notify user di Day 1.

2. **Price data tidak ada di nutrition.csv** — pakai heuristic atau cari dataset price terpisah?
   - **Default action:** heuristic (lihat §3.2). Jika ada waktu, scrape Tokopedia API atau dataset harga pasar.

3. **Image food** — dataset ada `image_url`? Jika ya, pakai untuk Food Item Detail (S-24). Jika tidak, pakai placeholder icon.
   - **Default action:** Day 1 EDA cek field, putuskan sesuai hasil.

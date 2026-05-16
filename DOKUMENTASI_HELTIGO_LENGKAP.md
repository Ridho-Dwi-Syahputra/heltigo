# DOKUMENTASI LENGKAP APLIKASI HELTIGO
## AI-Powered Personal Health & Fitness App

**Versi:** 1.0.0  
**Tanggal:** 15 Mei 2026  
**Target Kompetisi:** MSU iREX 2026  
**Tim:** Hackathon Core3D

---

## DAFTAR ISI

1. [Latar Belakang](#1-latar-belakang)
2. [Permasalahan yang Diselesaikan](#2-permasalahan-yang-diselesaikan)
3. [Relevansi Aplikasi](#3-relevansi-aplikasi)
4. [Fitur-Fitur Utama](#4-fitur-fitur-utama)
5. [Arsitektur Sistem](#5-arsitektur-sistem)
6. [4 Model AI yang Digunakan](#6-4-model-ai-yang-digunakan)
7. [Cara Kerja Microservice](#7-cara-kerja-microservice)
8. [Tech Stack Detail](#8-tech-stack-detail)
9. [Database Schema](#9-database-schema)
10. [API Endpoints](#10-api-endpoints)
11. [Frontend Mobile (Flutter)](#11-frontend-mobile-flutter)
12. [Offline-First Strategy](#12-offline-first-strategy)
13. [Gamifikasi & Motivasi](#13-gamifikasi--motivasi)
14. [Timeline Implementasi](#14-timeline-implementasi)

---

## 1. LATAR BELAKANG

### 1.1 Konteks Masalah Kesehatan Global

Obesitas dan penyakit tidak menular (PTM) seperti diabetes tipe 2, hipertensi, dan penyakit jantung terus meningkat secara global. Menurut WHO, lebih dari 1,9 miliar orang dewasa mengalami kelebihan berat badan, dan 650 juta di antaranya mengalami obesitas. Di Indonesia, prevalensi obesitas meningkat dari 14,8% (2013) menjadi 21,8% (2018) berdasarkan Riskesdas.

### 1.2 Tantangan Program Kesehatan Konvensional

Program latihan dan diet konvensional memiliki tingkat kegagalan yang tinggi:
- **90% program latihan gagal** dalam 6 bulan pertama karena tidak personal dan tidak adaptif
- **Biaya personal trainer** mencapai Rp 500.000 - Rp 2.000.000 per bulan, tidak terjangkau untuk mayoritas masyarakat
- **Aplikasi fitness existing** fokus pada pengguna gym dengan wearable device, mengabaikan segmen home workout
- **Database makanan** didominasi makanan Western, tidak relevan untuk pola makan Indonesia
- **Faktor psikologis** (mood, energi, kualitas tidur) diabaikan dalam perencanaan latihan

### 1.3 Solusi: Heltigo

Heltigo adalah aplikasi mobile berbasis AI yang menyediakan program latihan dan nutrisi personal yang:
- **Adaptif real-time** berdasarkan kondisi fisik dan psikologis pengguna
- **Budget-aware** dengan database 1.346+ makanan lokal Indonesia
- **Hybrid offline-first** sehingga fitur kritis tetap berfungsi tanpa internet
- **Tanpa wearable device** - hanya butuh smartphone
- **Gamified** dengan streak, badge, dan motivasi AI untuk meningkatkan konsistensi


---

## 2. PERMASALAHAN YANG DISELESAIKAN

### 2.1 Gap Penelitian yang Diisi Heltigo

| Gap | Masalah Existing | Solusi Heltigo |
|-----|------------------|----------------|
| **G1: Integrasi Holistik** | Aplikasi fitness dan nutrisi terpisah, tidak terintegrasi | Single platform yang mengintegrasikan latihan, nutrisi, dan budget dalam satu pipeline AI |
| **G2: Ketergantungan Wearable** | Butuh smartwatch/fitness tracker yang mahal (Rp 2-10 juta) | Hanya butuh smartphone, AI bekerja dengan input manual sederhana |
| **G3: Database Makanan** | Fokus makanan Western (burger, pizza, salad) | 1.346 item makanan lokal Indonesia dengan estimasi harga |
| **G4: Faktor Psikologis** | Hanya fokus data fisiologis (berat, tinggi, BMI) | Integrasi mood, energi, dan kualitas tidur untuk adaptasi real-time |
| **G5: Privasi Data** | Data kesehatan dikirim ke cloud pihak ketiga | Hybrid offline-first, data sensitif terenkripsi, server isolated |

### 2.2 Masalah Spesifik yang Diselesaikan

#### A. Personalisasi yang Tidak Memadai
**Masalah:** Program latihan "one-size-fits-all" tidak mempertimbangkan:
- Kondisi kesehatan khusus (cedera, diabetes, hipertensi)
- Tingkat kebugaran saat ini
- Ketersediaan alat (home vs gym)
- Waktu yang tersedia (15-60 menit per sesi)

**Solusi Heltigo:** AI menghasilkan program 7 hari yang disesuaikan dengan 13 parameter profil pengguna, termasuk kondisi kesehatan, fitness level, dan preferensi equipment.

#### B. Ketidaksesuaian Budget Nutrisi
**Masalah:** Rekomendasi makanan sehat sering mahal dan tidak realistis untuk budget harian Rp 15.000 - Rp 50.000.

**Solusi Heltigo:** Meal planner AI menggunakan algoritma knapsack untuk mengoptimalkan nilai gizi dalam batasan budget, dengan database makanan lokal yang terjangkau.

#### C. Kurangnya Adaptasi Real-Time
**Masalah:** Program latihan statis tidak menyesuaikan intensitas saat pengguna merasa lelah, sakit, atau kurang tidur.

**Solusi Heltigo:** Pre-workout check-in (mood, energi, kualitas tidur) memicu AI intensity adjuster yang mengurangi atau menambah volume latihan secara otomatis.

#### D. Rendahnya Konsistensi Jangka Panjang
**Masalah:** 70% pengguna berhenti dalam 3 bulan pertama karena kurangnya motivasi dan feedback.

**Solusi Heltigo:** Sistem gamifikasi dengan streak tracking, 15 badge pencapaian, weekly review dengan AI insights, dan notifikasi motivasi personal.


---

## 3. RELEVANSI APLIKASI

### 3.1 Relevansi untuk Kompetisi MSU iREX 2026

Heltigo memenuhi kriteria kompetisi innovation & research excellence:

1. **Innovation in AI Application**
   - Hybrid ML approach: Random Forest + Knapsack optimization + Rule-based adjuster
   - Real-time intensity adaptation berdasarkan faktor psikologis
   - Budget-aware meal planning dengan constraint optimization

2. **Social Impact**
   - Target: 100 juta+ orang Indonesia dengan smartphone yang tidak mampu personal trainer
   - Mengatasi obesitas dan PTM dengan solusi terjangkau (gratis)
   - Mendukung ekonomi lokal dengan database makanan Indonesia

3. **Technical Excellence**
   - Microservice architecture (Flutter + Express.js + FastAPI)
   - Offline-first dengan sync queue untuk area dengan koneksi terbatas
   - Property-based testing untuk reliability

### 3.2 Relevansi untuk Masyarakat Indonesia

#### A. Aksesibilitas Ekonomi
- **Gratis** vs personal trainer Rp 500K-2jt/bulan
- **Budget meal planning** mulai Rp 15.000/hari
- **Tidak butuh gym membership** - home workout dengan bodyweight

#### B. Relevansi Budaya
- **Database makanan lokal**: nasi goreng, gado-gado, soto, tempe, tahu
- **Bahasa Indonesia** sebagai bahasa utama
- **Halal-aware** meal planning

#### C. Infrastruktur
- **Hybrid offline-first** untuk area dengan koneksi internet tidak stabil
- **Ringan** - hanya butuh smartphone Android 5.0+ atau iOS 12+
- **Tidak butuh wearable** - input manual sederhana

### 3.3 Potensi Dampak Jangka Panjang

#### Kesehatan Publik
- Menurunkan prevalensi obesitas melalui program personal yang sustainable
- Mencegah PTM (diabetes, hipertensi) dengan intervensi dini
- Meningkatkan literasi kesehatan masyarakat

#### Ekonomi
- Mengurangi biaya kesehatan nasional dari PTM (estimasi Rp 100 triliun/tahun)
- Memberdayakan UMKM makanan sehat lokal
- Menciptakan ekosistem data kesehatan untuk penelitian

#### Teknologi
- Benchmark untuk aplikasi AI kesehatan di Indonesia
- Dataset longitudinal untuk penelitian adaptive health intervention
- Open-source potential untuk komunitas developer


---

## 4. FITUR-FITUR UTAMA

### 4.1 Setup Profil Cerdas (7 Langkah)

**Wizard interaktif** yang mengumpulkan data untuk personalisasi AI:

1. **Data Dasar** - Nama, usia, gender
2. **Data Fisik** - Tinggi, berat, lingkar pinggang
3. **Hasil BMI** - Kalkulasi otomatis BMI, BMR, TDEE, % lemak tubuh
4. **Target Kesehatan** - Turun berat / Jaga berat / Naikkan massa otot
5. **Kondisi Khusus** - Cedera, diabetes, hipertensi, kehamilan
6. **Preferensi Latihan** - Home/Gym, 3-5 hari/minggu, 15-60 menit/sesi
7. **Budget & Diet** - Budget harian Rp 15K-100K, frekuensi makan, pantangan (halal, vegetarian, dll)

**Output:** AI menghasilkan program 7 hari pertama dalam ~6 detik.

### 4.2 Program Latihan Personal

#### A. Workout Recommender (AI Model 1)
- **Input:** 13 fitur (BMI, age, fitness level, workout mode, kondisi kesehatan, dll)
- **Output:** 7-day workout plan dengan 4-6 exercise per hari
- **Adaptasi:** Warmup → Main → Cooldown, disesuaikan dengan equipment yang tersedia

#### B. Pre-Workout Check-in (AI Model 3)
- **Input:** Mood (1-5), Energi (1-5), Kualitas tidur (<5 jam, 5-6, 6-7, 7-8, >8 jam)
- **Output:** Adjustment factor -50% hingga +20% untuk volume latihan
- **Contoh:** Mood 2, Energi 1, Tidur <5 jam → Volume dikurangi 40%, fokus teknik

#### C. Active Workout Tracking
- **Timer real-time** dengan countdown per set
- **Rest timer** otomatis antar set
- **Haptic feedback** saat selesai rep
- **Wakelock** agar layar tidak mati
- **Log per-exercise:** sets, reps, rest actual

#### D. Workout Complete & Insights
- **Summary:** Durasi, total sets, total reps, kalori terbakar (estimasi)
- **Perbandingan:** vs latihan sebelumnya (+X reps, +X menit)
- **Badge unlock:** Jika mencapai milestone
- **Streak update:** +1 hari jika konsisten

### 4.3 Meal Planning Budget-Aware

#### A. Meal Planner (AI Model 2)
- **Algoritma:** 0/1 Knapsack optimization per meal
- **Constraint:** Budget harian, target kalori ±15%, macro balance
- **Scoring:** Protein > Kalori > Serat, penalti lemak
- **Output:** 2-4 meals per hari × 7 hari

#### B. Meal Swap & Alternatives
- **Trigger:** User tap "Minta Alternatif" di meal detail
- **Logic:** Re-run knapsack dengan exclude current foods
- **Diversifikasi:** Tidak ulang menu utama 2 hari berturut

#### C. Meal Logging
- **Checklist:** Tandai sudah makan per meal
- **Idempotent:** Tidak bisa double-log
- **Aggregation:** Total kalori, protein, karbo, lemak per hari

#### D. Food Item Detail
- **Nutrisi lengkap:** Kalori, protein, karbo, lemak, serat per porsi
- **Harga estimasi:** Berdasarkan kategori dan kalori
- **Similar foods:** Rekomendasi alternatif dengan nutrisi serupa

### 4.4 Progress Tracking & Gamifikasi

#### A. Daily Dashboard
- **Kalori sisa:** Target - consumed + burned
- **Hidrasi:** X/8 gelas (increment-only, reset tiap hari)
- **Streak:** 🔥 X hari berturut-turut
- **Workout hari ini:** Status + tombol "Mulai Latihan"
- **Meal checklist:** ✅/⭕ per waktu makan

#### B. Weekly Review
- **Skor mingguan:** 0-100% (workout done + meal logged + weight progress)
- **Insights AI:** "Latihan paling sering diskip: Squat. Akan diganti otomatis."
- **Charts:** Bar chart workout compliance, line chart weight progress
- **Rekomendasi:** Strategi minggu depan (REDUCE / MAINTAIN / INTENSIFY)

#### C. Streak & Badges
- **Current streak:** Hari berturut-turut aktif
- **Best streak:** Record tertinggi
- **15 badges:** Streak 3/7/30, Workouts 10/50/100, Weight lost 1/5/10 kg, dll
- **Progress bar:** Menuju unlock badge berikutnya

#### D. Weight History
- **Line chart:** 4 minggu terakhir
- **Zona target:** Shaded area untuk target weight
- **Delta:** +/- kg dari minggu lalu
- **Estimasi:** "X minggu lagi mencapai target"


### 4.5 Adaptive Replanning (AI Model 4)

**Trigger:** Setiap Sunday 20:00 atau manual dari Weekly Review

#### A. Evaluasi Mingguan
- **Skor:** Workout done / total × 50% + Meal logged / total × 30% + Weight progress × 20%
- **Analisis:** Latihan yang sering diskip, meal yang sering dilewati
- **Weight diff:** Actual vs target change

#### B. Strategi Replanning
| Skor | Strategi | Aksi |
|------|----------|------|
| <50% | **REDUCE** | Volume -30%, difficulty turun 1 level, fokus konsistensi |
| 50-80% | **MAINTAIN_SWAP** | Volume sama, swap exercise yang sering diskip |
| >80% | **INTENSIFY** | Volume +15%, difficulty naik, tambah variasi |

#### C. User Choice Override
- **KEEP:** Pertahankan program saat ini
- **MODERATE:** Ubah sedikit (default AI)
- **AGGRESSIVE:** Ubah signifikan (untuk yang bosan)

#### D. New Plan Ready
- **Preview:** 7 hari baru dengan highlight perubahan
- **AI Notes:** "Skor minggu ini 85%. Performamu luar biasa! Saya naikkan intensitas."
- **Motivasi:** Disesuaikan dengan performa (encouragement vs challenge)

### 4.6 Smart Notifications

#### A. Workout Reminder
- **Waktu:** User-defined (default 18:00)
- **Pesan:** "Waktunya latihan! Hari ini: Push & Core (30 menit)"
- **Pre-reminder:** 15 menit sebelum

#### B. Meal Reminder
- **Waktu:** Per meal type (breakfast 07:00, lunch 12:00, dinner 19:00)
- **Pesan:** "Jangan lupa sarapan! Menu hari ini: Nasi goreng + telur (Rp 12.000)"

#### C. Hydration Reminder
- **Frekuensi:** Setiap 1-3 jam (user-defined)
- **Pesan:** "Minum air! Target: X/8 gelas"

#### D. Streak Milestone
- **Trigger:** Saat mencapai streak 3, 7, 30, 100 hari
- **Pesan:** "🔥 Streak 7 hari! Kamu luar biasa konsisten!"

#### E. Badge Unlocked
- **Trigger:** Saat unlock badge baru
- **Pesan:** "🏆 Badge baru: Workouts 10! Lihat koleksimu."

#### F. Replan Due
- **Trigger:** Hari ke-8 plan aktif
- **Pesan:** "Minggu ini selesai! Yuk evaluasi dan buat rencana minggu depan."

### 4.7 Offline-First Features

#### A. Fitur yang Berfungsi Offline
- ✅ Lihat plan workout & meal (dari cache)
- ✅ Centang exercise/meal selesai (enqueue untuk sync)
- ✅ Active workout tracking (timer lokal)
- ✅ Add weight log (enqueue)
- ✅ Kalkulasi BMI/BMR/TDEE (pure Dart)
- ✅ Notifikasi pengingat (flutter_local_notifications)

#### B. Fitur yang Butuh Online
- ❌ Signup / Login
- ❌ Generate plan pertama (butuh ML)
- ❌ Pre-workout check-in dengan ML adjust (fallback: pakai original)
- ❌ Meal swap alternatives (fallback: tampilkan pesan)
- ❌ Weekly report agregasi (fallback: tampilkan cached)

#### C. Sync Queue
- **Enqueue:** Saat offline, aksi disimpan ke Hive box `sync_queue`
- **Drain:** Saat online kembali, batch-upload ke `/sync/batch`
- **Idempotent:** Setiap aksi punya UUID, server deduplikasi
- **Indicator:** Banner "📡 Mode Offline - X aksi belum disinkronkan"


---

## 5. ARSITEKTUR SISTEM

### 5.1 Arsitektur 3-Tier

```
┌─────────────────────────────────────────────────────────────────┐
│                     TIER 1: MOBILE CLIENT                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Flutter 3.x (Dart 3.x)                                   │  │
│  │  - 47 screens (onboarding, setup, workout, meal, progress)│  │
│  │  - Provider + GetIt (state management)                    │  │
│  │  - Shared Preferences (cache)                             │  │
│  │  - Local notifications                                     │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────────────┘
                         │ HTTPS REST + JWT
                         │ (online/offline hybrid)
┌────────────────────────┴────────────────────────────────────────┐
│                   TIER 2: BACKEND API                            │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Express.js (Node 20 + TypeScript)                        │  │
│  │  - Auth (JWT + refresh token)                             │  │
│  │  - Business logic (scoring, streak, badge)                │  │
│  │  - Orchestration (call ML service)                        │  │
│  │  - MySQL 8.0 (19 tables)                                  │  │
│  │  - Redis (cache + rate limit)                             │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────┬────────────────────────────────────────┘
                         │ HTTP Internal
                         │ (backend ↔ ML service)
┌────────────────────────┴────────────────────────────────────────┐
│                   TIER 3: ML SERVICE                             │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  FastAPI (Python 3.11)                                    │  │
│  │  - Model 1: Workout Recommender (Random Forest)           │  │
│  │  - Model 2: Meal Planner (Knapsack optimization)          │  │
│  │  - Model 3: Intensity Adjuster (Rule-based table)         │  │
│  │  - Model 4: Adaptive Replanner (Rule + optional DT)       │  │
│  │  - scikit-learn, pandas, numpy, scipy                     │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### 5.2 Data Flow: Plan Generation

```
1. User selesai setup wizard (S-12)
   ↓
2. Frontend POST /user/health-profile (save profil)
   ↓
3. Frontend POST /plan/generate
   ↓
4. Backend collect health_profile + user data
   ↓
5. Backend POST http://ml:8000/predict/workout-plan
   ├─ ML Model 1 (Workout RF) generate 7-day workout
   └─ Return: { days: [...] }
   ↓
6. Backend POST http://ml:8000/predict/meal-plan
   ├─ ML Model 2 (Meal Knapsack) generate 7-day meal
   └─ Return: { days: [...] }
   ↓
7. Backend save ke MySQL:
   ├─ workout_plans → workout_days → exercises
   └─ meal_plans → meal_days → meal_times → food_items
   ↓
8. Backend return { workoutPlan, mealPlan } ke frontend
   ↓
9. Frontend cache ke Shared Preferences
   ↓
10. Frontend navigate ke Plan Ready screen (S-14)
```

### 5.3 Data Flow: Pre-Workout Check-in

```
1. User tap "Mulai Latihan" di Workout Day screen (S-17)
   ↓
2. Frontend navigate ke Pre-Workout Check-in (S-19)
   ↓
3. User input: mood (1-5), energy (1-5), sleep_band
   ↓
4. Frontend POST /workout/:dayId/check-in
   ↓
5. Backend lookup workout_day exercises
   ↓
6. Backend call intensity adjuster (Model 3):
   ├─ Lookup adjustment table: (energy, sleep_band) → multiplier
   ├─ Apply mood modifier: ±5%
   └─ Clamp to [-0.5, +0.2]
   ↓
7. Backend apply adjustment ke exercises:
   ├─ sets × (1 + adjustment)
   ├─ reps × (1 + adjustment)
   └─ rest_sec × (1 - adjustment) jika volume turun
   ↓
8. Backend create workout_session (status: IN_PROGRESS)
   ↓
9. Backend return { sessionId, adjustedExercises }
   ↓
10. Frontend navigate ke Active Workout (S-20) dengan adjusted plan
```

### 5.4 Data Flow: Weekly Replanning

```
1. Trigger: Sunday 20:00 notification ATAU user tap "Lihat Rencana" di Weekly Review (S-29)
   ↓
2. Frontend GET /progress/weekly-review
   ├─ Backend aggregate: workout_done, meal_logged, weight_change
   └─ Return: { score, highlights, insights }
   ↓
3. Frontend tampilkan Weekly Review Modal (S-34)
   ↓
4. User pilih strategi: KEEP / MODERATE / AGGRESSIVE
   ↓
5. Frontend POST /plan/replan { choice, previousPlanId, score, skippedExerciseIds }
   ↓
6. Backend determine strategy:
   ├─ score <50% → REDUCE
   ├─ score 50-80% → MAINTAIN_SWAP
   └─ score >80% → INTENSIFY
   ↓
7. Backend POST http://ml:8000/predict/replan
   ├─ ML Model 4 apply strategy ke previous plan
   └─ Return: { workoutDays, mealDays, aiNotes }
   ↓
8. Backend save new plan (mark old plan status='COMPLETED')
   ↓
9. Backend return { workoutPlan, mealPlan, aiNotes }
   ↓
10. Frontend navigate ke New Plan Ready (S-35)
```


---

## 6. 4 MODEL AI YANG DIGUNAKAN

### 6.1 Model 1: Workout Recommender (Random Forest)

#### Tujuan
Generate 7-day workout plan yang personal berdasarkan profil fisiologis dan preferensi user.

#### Algoritma
**Random Forest Classifier (Multi-Output)**
- Library: scikit-learn 1.4+
- Hyperparameter: n_estimators=100, max_depth=10, min_samples_split=5
- Training data: 973 rows → augmented ke ~6,800 rows (expand 7 hari per user)

#### Input Features (13 fitur)
| Fitur | Tipe | Range | Contoh |
|-------|------|-------|--------|
| `bmi` | float | 12-50 | 26.5 |
| `bmi_cat_enc` | int | 0-3 | 2 (OVERWEIGHT) |
| `gender_enc` | int | 0/1 | 0 (MALE) |
| `age` | int | 10-100 | 28 |
| `age_band_enc` | int | 0-3 | 1 (25-35) |
| `fitness_level_enc` | int | 0-2 | 0 (BEGINNER) |
| `mode_enc` | int | 0/1 | 1 (GYM) |
| `days_per_week` | int | 3-5 | 4 |
| `session_minutes` | int | 15-60 | 45 |
| `day_index` | int | 0-6 | 0 (Senin) |
| `is_first_day_of_week` | bool | 0/1 | 1 |
| `has_injury` | bool | 0/1 | 0 |
| `has_chronic_condition` | bool | 0/1 | 0 |

#### Output
- **workout_type** ∈ {STRENGTH, CARDIO, HIIT, FLEXIBILITY, REST}
- **intensity_band** ∈ {LOW, MID, HIGH}

#### Post-Processing (Rule-Based Composer)
1. Filter exercise_master berdasarkan:
   - workout_type & muscle_group
   - equipment (HOME: bodyweight only, GYM: all)
   - difficulty (sesuai fitness_level + intensity)
2. Hindari kontraindikasi (e.g., JOINT_PAIN → exclude squat/lunge)
3. Random sample untuk diversifikasi
4. Set sets/reps/rest dari template per intensity
5. Generate phase order: WARMUP → MAIN → COOLDOWN

#### Evaluation Metrics
- **Accuracy:** >70% per output (workout_type & intensity)
- **F1-macro:** >0.65
- **Inference latency:** <800ms per request

#### Dataset
- **Primary:** `gym_member_exercise_dataset` (973 rows)
- **Augmentation:** Expand 1 user → 7 hari dengan synthetic label rules
- **Validation:** 80/20 split, stratified by workout_type

---

### 6.2 Model 2: Meal Planner (Knapsack Optimization)

#### Tujuan
Generate 7-day meal plan yang mengoptimalkan nilai gizi dalam batasan budget harian.

#### Algoritma
**0/1 Knapsack (Greedy Approximation)**
- Constraint: Budget per meal, target kalori ±15%, macro balance
- Scoring: Protein > Kalori > Serat, penalti lemak
- Diversifikasi: Tidak ulang menu utama 2 hari berturut

#### Input
| Parameter | Tipe | Range | Contoh |
|-----------|------|-------|--------|
| `tdee` | int | 800-5000 | 2200 kkal |
| `target_calorie_adj` | int | -500 to +500 | -350 (deficit) |
| `budget_per_day_idr` | int | 5000-300000 | 35000 |
| `meal_frequency` | int | 2-4 | 3 |
| `diet_restrictions` | array | - | ["halal"] |

#### Scoring Function
```python
score = (
    w_protein × protein_g / price × 1000 +
    w_calories × calories / price × 1000 +
    w_fiber × fiber_g / price × 1000 +
    w_fat_penalty × fat_g / price × 1000
)
```

**Weights per goal:**
| Goal | Protein | Calories | Fiber | Fat Penalty |
|------|---------|----------|-------|-------------|
| WEIGHT_LOSS | 0.5 | 0.2 | 0.3 | -0.2 |
| MAINTENANCE | 0.4 | 0.3 | 0.2 | -0.1 |
| MUSCLE_GAIN | 0.6 | 0.3 | 0.1 | 0.0 |

#### Output
- **7 meal_days**, each with 2-4 meals
- **Per meal:** list of food_items dengan servings, calories, cost
- **Aggregation:** total_calories, total_protein_g, total_carbs_g, total_fat_g, total_cost_idr

#### Constraint Validation
- ✅ `total_cost_idr ≤ budget_per_day`
- ✅ `abs(total_calories - target) / target < 0.20`
- ✅ `protein_g ≥ 15% of total_calories`
- ✅ `fat_g ≤ 35% of total_calories`

#### Dataset
- **Primary:** `nutrition.csv` (1,346 Indonesian food items)
- **Augmentation:** category, estimated_price_idr, is_halal, is_vegetarian, is_vegan, is_gluten_free
- **Heuristic price:** `base_price[category] × (1 + calories/500)`

#### Performance
- **Latency:** <500ms per 7-day plan
- **Budget compliance:** 100% (hard constraint)
- **Calorie accuracy:** ±15% target

---

### 6.3 Model 3: Pre-Workout Intensity Adjuster (Rule-Based)

#### Tujuan
Adjust volume latihan real-time berdasarkan kondisi psikologis user (mood, energi, kualitas tidur).

#### Algoritma
**Rule-Based Lookup Table (5×5 matrix)**
- Input: energy (1-5), sleep_band (5 levels)
- Output: adjustment multiplier [-0.5, +0.2]
- Mood modifier: ±5% additional

#### Adjustment Table
| Energy | <5 jam | 5-6 jam | 6-7 jam | 7-8 jam | >8 jam |
|--------|--------|---------|---------|---------|--------|
| 1 (Sangat Lelah) | -0.40 | -0.35 | -0.30 | -0.25 | -0.20 |
| 2 (Lelah) | -0.30 | -0.25 | -0.20 | -0.15 | -0.10 |
| 3 (Normal) | -0.20 | -0.10 | 0.00 | +0.05 | +0.10 |
| 4 (Energik) | -0.10 | 0.00 | +0.05 | +0.10 | +0.15 |
| 5 (Sangat Energik) | -0.05 | +0.05 | +0.10 | +0.15 | +0.20 |

#### Application
```python
factor = 1 + adjustment
adjusted_sets = max(1, round(original_sets × factor))
adjusted_reps = max(4, round(original_reps × factor))
adjusted_rest = round(original_rest × (1 - adjustment)) if adjustment < 0 else original_rest
```

#### Contoh
**Input:** mood=2, energy=1, sleep_band="<5"
- Base adjustment: -0.40
- Mood modifier: -0.05 (mood < 3)
- Final adjustment: -0.45
- Factor: 0.55 (volume dikurangi 45%)

**Original plan:** 4 sets × 12 reps, rest 60s
**Adjusted plan:** 2 sets × 7 reps, rest 87s

#### Rationale
- **Tidak butuh ML training** - logika deterministik, user trust tinggi
- **Fast inference** - O(1) lookup, <10ms
- **Explainable** - user bisa lihat "Volume dikurangi 40% karena energi rendah"

---

### 6.4 Model 4: Adaptive Replanner (Rule-Based + Optional DT)

#### Tujuan
Re-generate plan minggu depan berdasarkan performa minggu sebelumnya.

#### Algoritma
**Rule-Based 3-Branch Strategy**
1. **REDUCE** (score <50%): Volume -30%, difficulty turun 1 level
2. **MAINTAIN_SWAP** (score 50-80%): Volume sama, swap exercise yang sering diskip
3. **INTENSIFY** (score >80%): Volume +15%, difficulty naik

**Optional:** Decision Tree kecil untuk fine-tune intensity multiplier (jika ada waktu training)

#### Input
| Parameter | Tipe | Contoh |
|-----------|------|--------|
| `score_percent` | float | 75.0 |
| `workout_done_count` | int | 3 |
| `workout_total_count` | int | 4 |
| `meal_done_count` | int | 18 |
| `meal_total_count` | int | 21 |
| `weight_change_kg` | float | -0.6 |
| `weight_target_change_kg` | float | -0.5 |
| `most_skipped_exercise_ids` | array | [12, 15] |
| `user_choice` | enum | "MODERATE" |

#### Strategy Logic
```python
if score < 50:
    strategy = "REDUCE"
    notes = "Skor minggu ini rendah. Saya kurangi volume agar lebih mudah konsisten."
elif score <= 80:
    strategy = "MAINTAIN_SWAP"
    notes = "Performa stabil. Saya pertahankan struktur, ganti latihan yang sering diskip."
else:
    strategy = "INTENSIFY"
    notes = "Performa luar biasa! Saya naikkan intensitas dan tambah volume."
```

#### Output
- **ai_notes:** Penjelasan strategi
- **ai_recommendation:** Motivasi personal
- **workout_days:** 7-day adjusted workout
- **meal_days:** 7-day adjusted meal (jika weight_diff signifikan)

#### Performance
- **Latency:** <600ms
- **User satisfaction:** Measured via feedback (Phase 4)


---

## 7. CARA KERJA MICROSERVICE

### 7.1 Komunikasi Antar Service

#### A. Frontend ↔ Backend
**Protocol:** HTTPS REST
**Auth:** JWT Bearer token (access_token 15 min, refresh_token 7 hari)
**Format:** JSON

**Request Example:**
```http
POST /api/v1/plan/generate HTTP/1.1
Host: api.heltigo.app
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{}
```

**Response Example:**
```json
{
  "workoutPlan": {
    "id": 42,
    "startDate": "2026-05-19",
    "endDate": "2026-05-25",
    "days": [...]
  },
  "mealPlan": {
    "id": 43,
    "startDate": "2026-05-19",
    "endDate": "2026-05-25",
    "days": [...]
  }
}
```

#### B. Backend ↔ ML Service
**Protocol:** HTTP Internal (tidak exposed public)
**Auth:** Shared secret header `X-ML-KEY`
**Format:** JSON

**Request Example:**
```http
POST /predict/workout-plan HTTP/1.1
Host: ml-service:8000
X-ML-KEY: dev-shared-secret
Content-Type: application/json

{
  "profile": {
    "bmi": 26.5,
    "bmi_category": "OVERWEIGHT",
    "gender": "MALE",
    "age": 28,
    "fitness_level": "INTERMEDIATE",
    "workout_mode": "GYM",
    "days_per_week": 4,
    "session_minutes": 45,
    "conditions": []
  }
}
```

**Response Example:**
```json
{
  "days": [
    {
      "day_index": 0,
      "is_rest_day": false,
      "estimated_minutes": 45,
      "estimated_calories": 320,
      "exercises": [
        {
          "exercise_item_id": "ex-001",
          "order_in_day": 1,
          "phase": "WARMUP",
          "sets": 1,
          "reps": 10,
          "rest_seconds": 30,
          "ai_tip": "Lakukan pelan, fokus pada teknik."
        },
        ...
      ]
    },
    ...
  ]
}
```

### 7.2 Service Isolation & Deployment

#### A. Containerization (Docker)

**Backend Dockerfile:**
```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["node", "dist/server.js"]
```

**ML Service Dockerfile:**
```dockerfile
FROM python:3.11-slim
WORKDIR /app
RUN apt-get update && apt-get install -y build-essential
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app ./app
COPY main.py .
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]
```

#### B. Docker Compose (Development)

```yaml
version: '3.8'
services:
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: heltigo
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  backend:
    build: ./backend
    ports:
      - "3000:3000"
    environment:
      DATABASE_URL: mysql://root:root@mysql:3306/heltigo
      REDIS_URL: redis://redis:6379
      ML_SERVICE_URL: http://ml-service:8000
      JWT_SECRET: dev-secret-key
    depends_on:
      - mysql
      - redis
      - ml-service

  ml-service:
    build: ./ml-service
    ports:
      - "8000:8000"
    environment:
      ML_SERVICE_KEY: dev-shared-secret
    volumes:
      - ./ml-service/app/data:/app/app/data

volumes:
  mysql_data:
```

#### C. Production Deployment (Render / Railway)

**Backend:**
- Platform: Render Web Service
- Build: `npm install && npm run build`
- Start: `node dist/server.js`
- Env vars: `DATABASE_URL`, `REDIS_URL`, `ML_SERVICE_URL`, `JWT_SECRET`
- Health check: `GET /health`

**ML Service:**
- Platform: Render Web Service (Docker)
- Build: Docker
- Env vars: `ML_SERVICE_KEY`
- Health check: `GET /health`

**MySQL:**
- Platform: PlanetScale / Railway MySQL
- Connection: SSL required

**Redis:**
- Platform: Upstash / Railway Redis
- Connection: TLS required

### 7.3 Error Handling & Resilience

#### A. Backend → ML Service Timeout
```typescript
async function callMLService(endpoint: string, payload: any): Promise<any> {
  try {
    const response = await axios.post(`${ML_SERVICE_URL}${endpoint}`, payload, {
      headers: { 'X-ML-KEY': ML_SERVICE_KEY },
      timeout: 5000, // 5 detik
    });
    return response.data;
  } catch (error) {
    if (error.code === 'ECONNABORTED') {
      logger.error('ML service timeout', { endpoint });
      // Fallback: rule-based default plan
      return generateFallbackPlan(payload);
    }
    throw new ApiError(500, 'ML_SERVICE_ERROR', 'Gagal generate plan');
  }
}
```

#### B. Frontend → Backend Retry
```dart
Future<T> withRetry<T>(Future<T> Function() task, {int maxAttempts = 3}) async {
  var attempt = 0;
  while (true) {
    try {
      return await task();
    } on DioException catch (e) {
      attempt++;
      final shouldRetry = (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.connectionError ||
              (e.response?.statusCode != null && e.response!.statusCode! >= 500)) &&
          attempt < maxAttempts;
      if (!shouldRetry) rethrow;
      await Future.delayed(Duration(milliseconds: 500 * attempt));
    }
  }
}
```

#### C. Circuit Breaker (Optional Phase 4)
```typescript
import CircuitBreaker from 'opossum';

const mlServiceBreaker = new CircuitBreaker(callMLService, {
  timeout: 5000,
  errorThresholdPercentage: 50,
  resetTimeout: 30000,
});

mlServiceBreaker.fallback(() => generateFallbackPlan());
```

### 7.4 Monitoring & Logging

#### A. Structured Logging (Pino)
```typescript
import pino from 'pino';

const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  transport: {
    target: 'pino-pretty',
    options: { colorize: true },
  },
});

logger.info({ userId: 42, planId: 123 }, 'Plan generated successfully');
logger.error({ error: err.message, stack: err.stack }, 'ML service call failed');
```

#### B. Health Check Endpoints
**Backend:**
```typescript
app.get('/health', async (req, res) => {
  const dbOk = await checkDatabaseConnection();
  const redisOk = await checkRedisConnection();
  const mlOk = await checkMLServiceHealth();

  res.status(dbOk && redisOk && mlOk ? 200 : 503).json({
    status: dbOk && redisOk && mlOk ? 'healthy' : 'degraded',
    database: dbOk ? 'ok' : 'down',
    redis: redisOk ? 'ok' : 'down',
    mlService: mlOk ? 'ok' : 'down',
    timestamp: new Date().toISOString(),
  });
});
```

**ML Service:**
```python
@app.get("/health")
async def health():
    return {
        "status": "ok",
        "models_loaded": [
            f"workout_rf={workout_recommender.is_loaded}",
            f"meal_master={meal_planner.is_ready}",
        ],
        "timestamp": datetime.utcnow().isoformat(),
    }
```

#### C. Performance Metrics (Optional)
- **Prometheus + Grafana** untuk metrics collection
- **Sentry** untuk error tracking
- **Uptime Robot** untuk uptime monitoring


---

## 8. TECH STACK DETAIL

### 8.1 Frontend Mobile (Flutter)

| Layer | Technology | Version | Alasan Pemilihan |
|-------|------------|---------|------------------|
| **Framework** | Flutter | 3.22.x | Cross-platform (Android + iOS), performa native, hot reload |
| **Language** | Dart | 3.4.x | Type-safe, null-safety, async/await native |
| **State Management** | Provider + GetIt | 6.x + 7.x | Lightweight, mudah dipelajari, cukup untuk scope hackathon |
| **Routing** | GoRouter | 14.x | Declarative routing, deep linking support |
| **HTTP Client** | Dio | 5.x | Interceptor mature, retry, timeout, auth header injection |
| **Local Storage** | Shared Preferences | 2.x | Key-value storage untuk cache plan & settings |
| **Notifications** | flutter_local_notifications | 17.x | Reminder offline, scheduled, cross-platform |
| **Charts** | fl_chart | 0.68.x | Native Flutter, performant, customizable |
| **Fonts** | google_fonts | 6.x | Inter font sesuai design system |
| **Connectivity** | connectivity_plus | 6.x | Detect online/offline untuk sync queue |
| **Image Picker** | image_picker | 1.1.x | Kamera + galeri untuk avatar upload |
| **Permissions** | permission_handler | 11.x | Request camera/storage permissions |

**Struktur Folder:**
```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── theme/ (colors, text_styles, sizes)
│   ├── router/ (app_router.dart)
│   └── utils/ (date_utils, currency_formatter)
├── providers/ (state management)
├── screens/ (47 screens)
│   ├── splash/
│   ├── onboarding/
│   ├── auth/
│   ├── setup/
│   ├── home/
│   ├── workout/
│   ├── meal/
│   ├── progress/
│   └── profile/
├── widgets/ (reusable components)
└── services/ (API client, notification service)
```

---

### 8.2 Backend API (Express.js)

| Layer | Technology | Version | Alasan Pemilihan |
|-------|------------|---------|------------------|
| **Runtime** | Node.js | 20 LTS | Mature, large ecosystem, async I/O |
| **Framework** | Express.js | 4.x | Minimalist, flexible, middleware-based |
| **Language** | TypeScript | 5.x | Type safety, better DX, compile-time error detection |
| **ORM** | Prisma | 5.x | Type-safe query builder, migration tool, schema-first |
| **Database** | MySQL | 8.0 | ACID compliance, mature, wide hosting support |
| **Cache** | Redis | 7.x | In-memory cache, rate limiting, session store |
| **Auth** | jsonwebtoken | 9.x | JWT generation & verification |
| **Password** | bcrypt | 5.x | Secure password hashing (cost 12) |
| **Validation** | Zod | 3.x | Schema validation, type inference |
| **Logging** | Pino | 8.x | Fast structured logging, JSON output |
| **HTTP Client** | Axios | 1.x | Call ML service, retry logic |
| **Testing** | Jest + Supertest | 29.x | Unit & integration testing |

**Struktur Folder:**
```
backend/
├── src/
│   ├── server.ts
│   ├── app.ts
│   ├── config/ (env, db)
│   ├── middleware/ (auth, error, validate)
│   ├── routes/ (auth, user, plan, workout, meal, progress)
│   ├── controllers/ (request handlers)
│   ├── services/ (business logic)
│   ├── repositories/ (data access)
│   ├── utils/ (logger, jwt, password)
│   └── types/ (TypeScript types)
├── prisma/
│   ├── schema.prisma
│   ├── migrations/
│   └── seed.ts
└── tests/
```

---

### 8.3 ML Service (FastAPI)

| Layer | Technology | Version | Alasan Pemilihan |
|-------|------------|---------|------------------|
| **Framework** | FastAPI | 0.110.x | Async, Pydantic auto-validation, OpenAPI docs |
| **Language** | Python | 3.11 | Native ML ecosystem |
| **ML Library** | scikit-learn | 1.4.x | Random Forest, Decision Tree, Pipeline |
| **Numerik** | numpy | 1.26.x | Array operations |
| **Data** | pandas | 2.2.x | DataFrame manipulation |
| **Optimization** | scipy | 1.12.x | Knapsack optimization |
| **Serialization** | joblib | 1.3.x | Save/load trained models |
| **Validation** | pydantic | 2.6.x | Request/response schemas |
| **Server** | uvicorn | 0.27.x | ASGI server |
| **Testing** | pytest + httpx | 8.x + 0.27.x | Async testing |

**Struktur Folder:**
```
ml-service/
├── main.py
├── app/
│   ├── config.py
│   ├── deps.py (auth middleware)
│   ├── api/ (routers: workout, meal, replan, health)
│   ├── schemas/ (Pydantic models)
│   ├── services/ (ML logic)
│   │   ├── workout_recommender.py
│   │   ├── meal_planner.py
│   │   ├── intensity_adjuster.py
│   │   └── replanner.py
│   └── data/ (trained models & master data)
│       ├── workout_rf.joblib
│       ├── food_master.parquet
│       └── exercise_master.parquet
├── notebooks/ (training notebooks)
└── tests/
```

---

### 8.4 Database (MySQL 8.0)

**19 Tabel:**
1. `users` - Akun user
2. `health_profiles` - Data kesehatan & preferensi
3. `settings` - Pengaturan app
4. `refresh_tokens` - JWT refresh tokens
5. `fcm_tokens` - Push notification tokens
6. `exercise_master` - Library 200 exercise
7. `food_master` - Library 1,346 makanan Indonesia
8. `workout_plans` - Plan workout 7 hari
9. `workout_days` - 1 hari workout
10. `exercises` - Exercise dalam workout_day
11. `workout_sessions` - Actual session yang dijalankan
12. `exercise_logs` - Log per-set per-exercise
13. `meal_plans` - Plan meal 7 hari
14. `meal_days` - 1 hari meal
15. `meal_times` - Sarapan/makan siang/makan malam
16. `food_items` - Item makanan dalam meal_time
17. `meal_logs` - Riwayat user log makan
18. `daily_logs` - Agregat aktivitas per hari
19. `streaks` - Current & best streak
20. `badges` - Master badge
21. `user_badges` - Junction user-badge
22. `notifications` - In-app notifications
23. `sync_ops_log` - Idempotency tracking

**Indexes Kritis:**
- `users.email` (UNIQUE)
- `workout_plans(user_id, is_active)` (composite)
- `workout_days.date` (single)
- `meal_logs(user_id, meal_time_id, food_item_id)` (UNIQUE, idempotent)
- `daily_logs(user_id, date)` (UNIQUE)

---

### 8.5 Infrastructure & DevOps

| Component | Technology | Alasan |
|-----------|------------|--------|
| **Hosting (Backend)** | Render / Railway | Free tier, auto-deploy from GitHub, managed DB |
| **Hosting (ML)** | Render (Docker) | Support Python + model files |
| **Database** | PlanetScale / Railway MySQL | Managed, auto-backup, scaling |
| **Cache** | Upstash Redis | Serverless Redis, free tier |
| **Storage (Avatar)** | AWS S3 / Cloudinary | CDN, image optimization |
| **CI/CD** | GitHub Actions | Auto-test + deploy on push |
| **Monitoring** | Sentry (error) + Uptime Robot | Free tier |
| **Version Control** | Git + GitHub | Standard |

**Deployment Flow:**
```
1. Developer push ke GitHub
   ↓
2. GitHub Actions trigger:
   ├─ Run tests (Jest + pytest)
   ├─ Build Docker images
   └─ Deploy ke Render/Railway
   ↓
3. Render auto-deploy:
   ├─ Backend: npm install → npm run build → node dist/server.js
   └─ ML Service: Docker build → uvicorn main:app
   ↓
4. Health check pass → traffic routed
```



---

## 9. DATABASE SCHEMA

### 9.1 Tabel Users & Auth

#### users
```sql
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(100) NOT NULL,
  avatar_url VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_email (email)
);
```

#### refresh_tokens
```sql
CREATE TABLE refresh_tokens (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  token VARCHAR(500) UNIQUE NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_token (token),
  INDEX idx_user_expires (user_id, expires_at)
);
```

#### fcm_tokens
```sql
CREATE TABLE fcm_tokens (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  token VARCHAR(500) NOT NULL,
  device_type ENUM('ANDROID', 'IOS') NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_user_token (user_id, token)
);
```

### 9.2 Tabel Health Profile & Settings

#### health_profiles
```sql
CREATE TABLE health_profiles (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT UNIQUE NOT NULL,
  gender ENUM('MALE', 'FEMALE') NOT NULL,
  age INT NOT NULL,
  height_cm DECIMAL(5,2) NOT NULL,
  weight_kg DECIMAL(5,2) NOT NULL,
  waist_cm DECIMAL(5,2),
  bmi DECIMAL(4,2) NOT NULL,
  bmi_category ENUM('UNDERWEIGHT', 'NORMAL', 'OVERWEIGHT', 'OBESE') NOT NULL,
  bmr INT NOT NULL,
  tdee INT NOT NULL,
  body_fat_percent DECIMAL(4,2),
  goal ENUM('WEIGHT_LOSS', 'MAINTENANCE', 'MUSCLE_GAIN') NOT NULL,
  target_weight_kg DECIMAL(5,2),
  fitness_level ENUM('BEGINNER', 'INTERMEDIATE', 'ADVANCED') NOT NULL,
  workout_mode ENUM('HOME', 'GYM') NOT NULL,
  days_per_week INT NOT NULL,
  session_minutes INT NOT NULL,
  conditions JSON, -- ["JOINT_PAIN", "DIABETES", "HYPERTENSION"]
  budget_per_day_idr INT NOT NULL,
  meal_frequency INT NOT NULL,
  diet_restrictions JSON, -- ["halal", "vegetarian"]
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

#### settings
```sql
CREATE TABLE settings (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT UNIQUE NOT NULL,
  workout_reminder_enabled BOOLEAN DEFAULT TRUE,
  workout_reminder_time TIME DEFAULT '18:00:00',
  meal_reminder_enabled BOOLEAN DEFAULT TRUE,
  hydration_reminder_enabled BOOLEAN DEFAULT TRUE,
  hydration_interval_hours INT DEFAULT 2,
  theme_mode ENUM('LIGHT', 'DARK', 'SYSTEM') DEFAULT 'SYSTEM',
  language VARCHAR(10) DEFAULT 'id',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

### 9.3 Tabel Master Data

#### exercise_master
```sql
CREATE TABLE exercise_master (
  id VARCHAR(50) PRIMARY KEY, -- 'ex-001'
  name VARCHAR(200) NOT NULL,
  muscle_group ENUM('CHEST', 'BACK', 'LEGS', 'SHOULDERS', 'ARMS', 'CORE', 'CARDIO', 'FULL_BODY') NOT NULL,
  equipment ENUM('BODYWEIGHT', 'DUMBBELL', 'BARBELL', 'MACHINE', 'CABLE', 'RESISTANCE_BAND') NOT NULL,
  difficulty ENUM('BEGINNER', 'INTERMEDIATE', 'ADVANCED') NOT NULL,
  contraindications JSON, -- ["JOINT_PAIN", "BACK_INJURY"]
  video_url VARCHAR(500),
  thumbnail_url VARCHAR(500),
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_muscle_equipment (muscle_group, equipment),
  INDEX idx_difficulty (difficulty)
);
```

#### food_master
```sql
CREATE TABLE food_master (
  id VARCHAR(50) PRIMARY KEY, -- 'food-001'
  name VARCHAR(200) NOT NULL,
  category ENUM('CARBS', 'PROTEIN', 'VEGETABLES', 'FRUITS', 'SNACKS', 'BEVERAGES') NOT NULL,
  calories_per_100g INT NOT NULL,
  protein_g_per_100g DECIMAL(5,2) NOT NULL,
  carbs_g_per_100g DECIMAL(5,2) NOT NULL,
  fat_g_per_100g DECIMAL(5,2) NOT NULL,
  fiber_g_per_100g DECIMAL(5,2),
  estimated_price_idr INT NOT NULL,
  serving_size_g INT NOT NULL,
  is_halal BOOLEAN DEFAULT TRUE,
  is_vegetarian BOOLEAN DEFAULT FALSE,
  is_vegan BOOLEAN DEFAULT FALSE,
  is_gluten_free BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_category (category),
  INDEX idx_price (estimated_price_idr)
);
```

### 9.4 Tabel Workout Plans

#### workout_plans
```sql
CREATE TABLE workout_plans (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  status ENUM('ACTIVE', 'COMPLETED', 'CANCELLED') DEFAULT 'ACTIVE',
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_active (user_id, is_active),
  INDEX idx_status (status)
);
```

#### workout_days
```sql
CREATE TABLE workout_days (
  id INT PRIMARY KEY AUTO_INCREMENT,
  workout_plan_id INT NOT NULL,
  day_index INT NOT NULL, -- 0-6
  date DATE NOT NULL,
  is_rest_day BOOLEAN DEFAULT FALSE,
  estimated_minutes INT,
  estimated_calories INT,
  is_completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMP NULL,
  FOREIGN KEY (workout_plan_id) REFERENCES workout_plans(id) ON DELETE CASCADE,
  INDEX idx_plan_day (workout_plan_id, day_index),
  INDEX idx_date (date)
);
```

#### exercises
```sql
CREATE TABLE exercises (
  id INT PRIMARY KEY AUTO_INCREMENT,
  workout_day_id INT NOT NULL,
  exercise_item_id VARCHAR(50) NOT NULL,
  order_in_day INT NOT NULL,
  phase ENUM('WARMUP', 'MAIN', 'COOLDOWN') NOT NULL,
  sets INT NOT NULL,
  reps INT NOT NULL,
  rest_seconds INT NOT NULL,
  ai_tip TEXT,
  FOREIGN KEY (workout_day_id) REFERENCES workout_days(id) ON DELETE CASCADE,
  FOREIGN KEY (exercise_item_id) REFERENCES exercise_master(id),
  INDEX idx_workout_day (workout_day_id),
  INDEX idx_order (workout_day_id, order_in_day)
);
```

#### workout_sessions
```sql
CREATE TABLE workout_sessions (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  workout_day_id INT NOT NULL,
  status ENUM('IN_PROGRESS', 'COMPLETED', 'CANCELLED') DEFAULT 'IN_PROGRESS',
  mood INT, -- 1-5
  energy INT, -- 1-5
  sleep_band ENUM('<5', '5-6', '6-7', '7-8', '>8'),
  adjustment_factor DECIMAL(4,2), -- -0.5 to +0.2
  started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP NULL,
  duration_minutes INT,
  total_sets INT,
  total_reps INT,
  calories_burned INT,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (workout_day_id) REFERENCES workout_days(id) ON DELETE CASCADE,
  INDEX idx_user_status (user_id, status),
  INDEX idx_completed_at (completed_at)
);
```

#### exercise_logs
```sql
CREATE TABLE exercise_logs (
  id INT PRIMARY KEY AUTO_INCREMENT,
  workout_session_id INT NOT NULL,
  exercise_id INT NOT NULL,
  set_number INT NOT NULL,
  reps_done INT NOT NULL,
  rest_seconds_actual INT,
  logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (workout_session_id) REFERENCES workout_sessions(id) ON DELETE CASCADE,
  FOREIGN KEY (exercise_id) REFERENCES exercises(id) ON DELETE CASCADE,
  INDEX idx_session (workout_session_id),
  INDEX idx_exercise (exercise_id)
);
```

### 9.5 Tabel Meal Plans

#### meal_plans
```sql
CREATE TABLE meal_plans (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  status ENUM('ACTIVE', 'COMPLETED', 'CANCELLED') DEFAULT 'ACTIVE',
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_active (user_id, is_active)
);
```

#### meal_days
```sql
CREATE TABLE meal_days (
  id INT PRIMARY KEY AUTO_INCREMENT,
  meal_plan_id INT NOT NULL,
  day_index INT NOT NULL, -- 0-6
  date DATE NOT NULL,
  total_calories INT,
  total_protein_g DECIMAL(6,2),
  total_carbs_g DECIMAL(6,2),
  total_fat_g DECIMAL(6,2),
  total_cost_idr INT,
  FOREIGN KEY (meal_plan_id) REFERENCES meal_plans(id) ON DELETE CASCADE,
  INDEX idx_plan_day (meal_plan_id, day_index),
  INDEX idx_date (date)
);
```

#### meal_times
```sql
CREATE TABLE meal_times (
  id INT PRIMARY KEY AUTO_INCREMENT,
  meal_day_id INT NOT NULL,
  meal_type ENUM('BREAKFAST', 'LUNCH', 'DINNER', 'SNACK') NOT NULL,
  order_in_day INT NOT NULL,
  calories INT,
  protein_g DECIMAL(6,2),
  carbs_g DECIMAL(6,2),
  fat_g DECIMAL(6,2),
  cost_idr INT,
  is_logged BOOLEAN DEFAULT FALSE,
  logged_at TIMESTAMP NULL,
  FOREIGN KEY (meal_day_id) REFERENCES meal_days(id) ON DELETE CASCADE,
  INDEX idx_meal_day (meal_day_id),
  INDEX idx_type (meal_type)
);
```

#### food_items
```sql
CREATE TABLE food_items (
  id INT PRIMARY KEY AUTO_INCREMENT,
  meal_time_id INT NOT NULL,
  food_master_id VARCHAR(50) NOT NULL,
  servings DECIMAL(4,2) NOT NULL,
  calories INT NOT NULL,
  protein_g DECIMAL(6,2) NOT NULL,
  carbs_g DECIMAL(6,2) NOT NULL,
  fat_g DECIMAL(6,2) NOT NULL,
  cost_idr INT NOT NULL,
  FOREIGN KEY (meal_time_id) REFERENCES meal_times(id) ON DELETE CASCADE,
  FOREIGN KEY (food_master_id) REFERENCES food_master(id),
  INDEX idx_meal_time (meal_time_id)
);
```

#### meal_logs
```sql
CREATE TABLE meal_logs (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  meal_time_id INT NOT NULL,
  food_item_id INT NOT NULL,
  logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (meal_time_id) REFERENCES meal_times(id) ON DELETE CASCADE,
  FOREIGN KEY (food_item_id) REFERENCES food_items(id) ON DELETE CASCADE,
  UNIQUE KEY unique_meal_log (user_id, meal_time_id, food_item_id),
  INDEX idx_user_date (user_id, logged_at)
);
```

### 9.6 Tabel Progress & Gamifikasi

#### daily_logs
```sql
CREATE TABLE daily_logs (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  date DATE NOT NULL,
  weight_kg DECIMAL(5,2),
  calories_consumed INT DEFAULT 0,
  calories_burned INT DEFAULT 0,
  water_glasses INT DEFAULT 0,
  workout_done BOOLEAN DEFAULT FALSE,
  meals_logged INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_user_date (user_id, date),
  INDEX idx_user_date (user_id, date)
);
```

#### streaks
```sql
CREATE TABLE streaks (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT UNIQUE NOT NULL,
  current_streak INT DEFAULT 0,
  best_streak INT DEFAULT 0,
  last_activity_date DATE,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

#### badges
```sql
CREATE TABLE badges (
  id VARCHAR(50) PRIMARY KEY, -- 'badge-streak-3'
  name VARCHAR(100) NOT NULL,
  description TEXT NOT NULL,
  icon_url VARCHAR(500),
  category ENUM('STREAK', 'WORKOUT', 'WEIGHT', 'CONSISTENCY', 'SPECIAL') NOT NULL,
  requirement_type ENUM('STREAK_DAYS', 'WORKOUTS_DONE', 'WEIGHT_LOST_KG', 'WEEKS_ACTIVE') NOT NULL,
  requirement_value INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### user_badges
```sql
CREATE TABLE user_badges (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  badge_id VARCHAR(50) NOT NULL,
  unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (badge_id) REFERENCES badges(id),
  UNIQUE KEY unique_user_badge (user_id, badge_id),
  INDEX idx_user (user_id),
  INDEX idx_unlocked_at (unlocked_at)
);
```

#### notifications
```sql
CREATE TABLE notifications (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  type ENUM('WORKOUT_REMINDER', 'MEAL_REMINDER', 'HYDRATION', 'STREAK_MILESTONE', 'BADGE_UNLOCKED', 'REPLAN_DUE') NOT NULL,
  title VARCHAR(200) NOT NULL,
  body TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_read (user_id, is_read),
  INDEX idx_created_at (created_at)
);
```

### 9.7 Tabel Sync & Idempotency

#### sync_ops_log
```sql
CREATE TABLE sync_ops_log (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  operation_uuid VARCHAR(36) UNIQUE NOT NULL,
  operation_type ENUM('WORKOUT_COMPLETE', 'MEAL_LOG', 'WEIGHT_LOG', 'WATER_LOG') NOT NULL,
  payload JSON NOT NULL,
  processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_uuid (operation_uuid),
  INDEX idx_user_type (user_id, operation_type)
);
```

### 9.8 Relasi Antar Tabel

```
users (1) ─── (1) health_profiles
  │
  ├─── (1) settings
  ├─── (1) streaks
  ├─── (N) refresh_tokens
  ├─── (N) fcm_tokens
  ├─── (N) workout_plans ─── (N) workout_days ─── (N) exercises ─── (1) exercise_master
  │                              │
  │                              └─── (N) workout_sessions ─── (N) exercise_logs
  │
  ├─── (N) meal_plans ─── (N) meal_days ─── (N) meal_times ─── (N) food_items ─── (1) food_master
  │                                              │
  │                                              └─── (N) meal_logs
  │
  ├─── (N) daily_logs
  ├─── (N) user_badges ─── (1) badges
  ├─── (N) notifications
  └─── (N) sync_ops_log
```


---

## 10. API ENDPOINTS

### 10.1 Authentication

#### POST /api/v1/auth/signup
**Deskripsi:** Registrasi user baru

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "name": "John Doe"
}
```

**Response 201:**
```json
{
  "user": {
    "id": 42,
    "email": "user@example.com",
    "name": "John Doe",
    "avatarUrl": null
  },
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Error 400:**
```json
{
  "error": "VALIDATION_ERROR",
  "message": "Email sudah terdaftar"
}
```

---

#### POST /api/v1/auth/login
**Deskripsi:** Login user

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```

**Response 200:**
```json
{
  "user": {
    "id": 42,
    "email": "user@example.com",
    "name": "John Doe",
    "avatarUrl": "https://cdn.heltigo.app/avatars/42.jpg"
  },
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Error 401:**
```json
{
  "error": "INVALID_CREDENTIALS",
  "message": "Email atau password salah"
}
```

---

#### POST /api/v1/auth/refresh
**Deskripsi:** Refresh access token

**Request Body:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response 200:**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

#### POST /api/v1/auth/logout
**Deskripsi:** Logout user (invalidate refresh token)

**Headers:** `Authorization: Bearer <accessToken>`

**Response 200:**
```json
{
  "message": "Logout berhasil"
}
```


### 10.2 User & Health Profile

#### GET /api/v1/user/profile
**Deskripsi:** Get user profile

**Headers:** `Authorization: Bearer <accessToken>`

**Response 200:**
```json
{
  "id": 42,
  "email": "user@example.com",
  "name": "John Doe",
  "avatarUrl": "https://cdn.heltigo.app/avatars/42.jpg",
  "createdAt": "2026-05-01T10:00:00Z"
}
```

---

#### PUT /api/v1/user/profile
**Deskripsi:** Update user profile

**Headers:** `Authorization: Bearer <accessToken>`

**Request Body:**
```json
{
  "name": "John Updated",
  "avatarUrl": "https://cdn.heltigo.app/avatars/42-new.jpg"
}
```

**Response 200:**
```json
{
  "id": 42,
  "email": "user@example.com",
  "name": "John Updated",
  "avatarUrl": "https://cdn.heltigo.app/avatars/42-new.jpg"
}
```

---

#### POST /api/v1/user/health-profile
**Deskripsi:** Create/update health profile

**Headers:** `Authorization: Bearer <accessToken>`

**Request Body:**
```json
{
  "gender": "MALE",
  "age": 28,
  "heightCm": 175,
  "weightKg": 82,
  "waistCm": 92,
  "goal": "WEIGHT_LOSS",
  "targetWeightKg": 75,
  "fitnessLevel": "INTERMEDIATE",
  "workoutMode": "GYM",
  "daysPerWeek": 4,
  "sessionMinutes": 45,
  "conditions": ["JOINT_PAIN"],
  "budgetPerDayIdr": 35000,
  "mealFrequency": 3,
  "dietRestrictions": ["halal"]
}
```

**Response 200:**
```json
{
  "id": 1,
  "userId": 42,
  "gender": "MALE",
  "age": 28,
  "heightCm": 175,
  "weightKg": 82,
  "waistCm": 92,
  "bmi": 26.78,
  "bmiCategory": "OVERWEIGHT",
  "bmr": 1850,
  "tdee": 2590,
  "bodyFatPercent": 24.5,
  "goal": "WEIGHT_LOSS",
  "targetWeightKg": 75,
  "fitnessLevel": "INTERMEDIATE",
  "workoutMode": "GYM",
  "daysPerWeek": 4,
  "sessionMinutes": 45,
  "conditions": ["JOINT_PAIN"],
  "budgetPerDayIdr": 35000,
  "mealFrequency": 3,
  "dietRestrictions": ["halal"]
}
```


### 10.3 Plan Generation

#### POST /api/v1/plan/generate
**Deskripsi:** Generate 7-day workout & meal plan

**Headers:** `Authorization: Bearer <accessToken>`

**Request Body:** `{}` (empty, data diambil dari health_profile)

**Response 200:**
```json
{
  "workoutPlan": {
    "id": 42,
    "userId": 42,
    "startDate": "2026-05-19",
    "endDate": "2026-05-25",
    "status": "ACTIVE",
    "days": [
      {
        "id": 101,
        "dayIndex": 0,
        "date": "2026-05-19",
        "isRestDay": false,
        "estimatedMinutes": 45,
        "estimatedCalories": 320,
        "exercises": [
          {
            "id": 501,
            "exerciseItemId": "ex-001",
            "name": "Jumping Jacks",
            "orderInDay": 1,
            "phase": "WARMUP",
            "sets": 1,
            "reps": 20,
            "restSeconds": 30,
            "aiTip": "Lakukan pelan, fokus pada teknik."
          }
        ]
      }
    ]
  },
  "mealPlan": {
    "id": 43,
    "userId": 42,
    "startDate": "2026-05-19",
    "endDate": "2026-05-25",
    "status": "ACTIVE",
    "days": [
      {
        "id": 201,
        "dayIndex": 0,
        "date": "2026-05-19",
        "totalCalories": 1850,
        "totalProteinG": 120,
        "totalCarbsG": 200,
        "totalFatG": 55,
        "totalCostIdr": 34500,
        "meals": [
          {
            "id": 301,
            "mealType": "BREAKFAST",
            "orderInDay": 1,
            "calories": 450,
            "proteinG": 25,
            "carbsG": 60,
            "fatG": 12,
            "costIdr": 12000,
            "foods": [
              {
                "id": 401,
                "foodMasterId": "food-001",
                "name": "Nasi Goreng",
                "servings": 1.5,
                "calories": 350,
                "proteinG": 18,
                "carbsG": 50,
                "fatG": 10,
                "costIdr": 10000
              }
            ]
          }
        ]
      }
    ]
  }
}
```

**Error 400:**
```json
{
  "error": "HEALTH_PROFILE_NOT_FOUND",
  "message": "Lengkapi profil kesehatan terlebih dahulu"
}
```


### 10.4 Workout Execution

#### POST /api/v1/workout/:dayId/check-in
**Deskripsi:** Pre-workout check-in dengan intensity adjustment

**Headers:** `Authorization: Bearer <accessToken>`

**Request Body:**
```json
{
  "mood": 3,
  "energy": 4,
  "sleepBand": "7-8"
}
```

**Response 200:**
```json
{
  "sessionId": 1001,
  "adjustmentFactor": 0.10,
  "adjustedExercises": [
    {
      "id": 501,
      "name": "Jumping Jacks",
      "originalSets": 1,
      "originalReps": 20,
      "adjustedSets": 1,
      "adjustedReps": 22,
      "restSeconds": 30
    }
  ],
  "aiNote": "Energi bagus! Volume dinaikkan 10%."
}
```

---

#### POST /api/v1/workout/session/:sessionId/complete
**Deskripsi:** Mark workout session complete

**Headers:** `Authorization: Bearer <accessToken>`

**Request Body:**
```json
{
  "exerciseLogs": [
    {
      "exerciseId": 501,
      "setNumber": 1,
      "repsDone": 22,
      "restSecondsActual": 35
    }
  ],
  "durationMinutes": 47,
  "caloriesBurned": 340
}
```

**Response 200:**
```json
{
  "sessionId": 1001,
  "status": "COMPLETED",
  "totalSets": 12,
  "totalReps": 180,
  "durationMinutes": 47,
  "caloriesBurned": 340,
  "streakUpdated": true,
  "newStreak": 5,
  "badgesUnlocked": ["badge-workout-10"]
}
```

---

#### GET /api/v1/workout/active-plan
**Deskripsi:** Get active workout plan

**Headers:** `Authorization: Bearer <accessToken>`

**Response 200:**
```json
{
  "id": 42,
  "startDate": "2026-05-19",
  "endDate": "2026-05-25",
  "days": [...]
}
```


### 10.5 Meal Logging

#### POST /api/v1/meal/:mealTimeId/log
**Deskripsi:** Log meal sebagai sudah dimakan (idempotent)

**Headers:** `Authorization: Bearer <accessToken>`

**Request Body:**
```json
{
  "foodItemIds": [401, 402]
}
```

**Response 200:**
```json
{
  "mealTimeId": 301,
  "isLogged": true,
  "loggedAt": "2026-05-19T07:30:00Z",
  "caloriesConsumed": 450
}
```

---

#### POST /api/v1/meal/:mealTimeId/swap
**Deskripsi:** Minta alternatif meal

**Headers:** `Authorization: Bearer <accessToken>`

**Request Body:** `{}`

**Response 200:**
```json
{
  "mealTimeId": 301,
  "newFoods": [
    {
      "id": 403,
      "foodMasterId": "food-005",
      "name": "Bubur Ayam",
      "servings": 1.0,
      "calories": 380,
      "proteinG": 22,
      "carbsG": 55,
      "fatG": 8,
      "costIdr": 11000
    }
  ]
}
```

---

#### GET /api/v1/meal/active-plan
**Deskripsi:** Get active meal plan

**Headers:** `Authorization: Bearer <accessToken>`

**Response 200:**
```json
{
  "id": 43,
  "startDate": "2026-05-19",
  "endDate": "2026-05-25",
  "days": [...]
}
```

### 10.6 Progress Tracking

#### POST /api/v1/progress/weight
**Deskripsi:** Log berat badan

**Headers:** `Authorization: Bearer <accessToken>`

**Request Body:**
```json
{
  "weightKg": 81.5,
  "date": "2026-05-19"
}
```

**Response 200:**
```json
{
  "date": "2026-05-19",
  "weightKg": 81.5,
  "diffFromLastWeek": -0.5,
  "diffFromTarget": 6.5
}
```

---

#### POST /api/v1/progress/water
**Deskripsi:** Increment water intake (idempotent per request)

**Headers:** `Authorization: Bearer <accessToken>`

**Request Body:**
```json
{
  "glasses": 1
}
```

**Response 200:**
```json
{
  "date": "2026-05-19",
  "totalGlasses": 5,
  "targetGlasses": 8
}
```


#### GET /api/v1/progress/daily/:date
**Deskripsi:** Get daily summary

**Headers:** `Authorization: Bearer <accessToken>`

**Response 200:**
```json
{
  "date": "2026-05-19",
  "weightKg": 81.5,
  "caloriesConsumed": 1200,
  "caloriesBurned": 340,
  "caloriesRemaining": 310,
  "waterGlasses": 5,
  "workoutDone": true,
  "mealsLogged": 2
}
```

---

#### GET /api/v1/progress/weekly-review
**Deskripsi:** Get weekly review data

**Headers:** `Authorization: Bearer <accessToken>`

**Response 200:**
```json
{
  "weekStartDate": "2026-05-12",
  "weekEndDate": "2026-05-18",
  "score": 75.0,
  "workoutDoneCount": 3,
  "workoutTotalCount": 4,
  "mealLoggedCount": 18,
  "mealTotalCount": 21,
  "weightChangeKg": -0.6,
  "weightTargetChangeKg": -0.5,
  "mostSkippedExercises": [
    {
      "exerciseId": 12,
      "name": "Squat",
      "skipCount": 2
    }
  ],
  "insights": [
    "Latihan paling sering diskip: Squat. Akan diganti otomatis.",
    "Konsistensi meal logging bagus (85%)."
  ],
  "aiRecommendation": "MAINTAIN_SWAP"
}
```

---

#### GET /api/v1/progress/streak
**Deskripsi:** Get streak data

**Headers:** `Authorization: Bearer <accessToken>`

**Response 200:**
```json
{
  "currentStreak": 5,
  "bestStreak": 12,
  "lastActivityDate": "2026-05-19"
}
```

---

#### GET /api/v1/progress/badges
**Deskripsi:** Get user badges

**Headers:** `Authorization: Bearer <accessToken>`

**Response 200:**
```json
{
  "unlockedBadges": [
    {
      "id": "badge-streak-3",
      "name": "Streak 3 Hari",
      "description": "Aktif 3 hari berturut-turut",
      "iconUrl": "https://cdn.heltigo.app/badges/streak-3.png",
      "unlockedAt": "2026-05-17T20:00:00Z"
    }
  ],
  "lockedBadges": [
    {
      "id": "badge-streak-7",
      "name": "Streak 7 Hari",
      "description": "Aktif 7 hari berturut-turut",
      "progress": 5,
      "requirement": 7
    }
  ]
}
```


### 10.7 Replanning

#### POST /api/v1/plan/replan
**Deskripsi:** Generate new 7-day plan berdasarkan performa minggu lalu

**Headers:** `Authorization: Bearer <accessToken>`

**Request Body:**
```json
{
  "choice": "MODERATE",
  "previousPlanId": 42,
  "score": 75.0,
  "skippedExerciseIds": [12, 15]
}
```

**Response 200:**
```json
{
  "workoutPlan": {
    "id": 44,
    "startDate": "2026-05-26",
    "endDate": "2026-06-01",
    "days": [...]
  },
  "mealPlan": {
    "id": 45,
    "startDate": "2026-05-26",
    "endDate": "2026-06-01",
    "days": [...]
  },
  "aiNotes": "Skor minggu ini 75%. Performa stabil. Saya pertahankan struktur, ganti latihan yang sering diskip.",
  "aiRecommendation": "Fokus pada konsistensi minggu ini!"
}
```

### 10.8 Settings

#### GET /api/v1/settings
**Deskripsi:** Get user settings

**Headers:** `Authorization: Bearer <accessToken>`

**Response 200:**
```json
{
  "workoutReminderEnabled": true,
  "workoutReminderTime": "18:00",
  "mealReminderEnabled": true,
  "hydrationReminderEnabled": true,
  "hydrationIntervalHours": 2,
  "themeMode": "SYSTEM",
  "language": "id"
}
```

---

#### PUT /api/v1/settings
**Deskripsi:** Update settings

**Headers:** `Authorization: Bearer <accessToken>`

**Request Body:**
```json
{
  "workoutReminderEnabled": false,
  "themeMode": "DARK"
}
```

**Response 200:**
```json
{
  "workoutReminderEnabled": false,
  "workoutReminderTime": "18:00",
  "mealReminderEnabled": true,
  "hydrationReminderEnabled": true,
  "hydrationIntervalHours": 2,
  "themeMode": "DARK",
  "language": "id"
}
```

### 10.9 Sync (Offline-First)

#### POST /api/v1/sync/batch
**Deskripsi:** Batch upload offline operations

**Headers:** `Authorization: Bearer <accessToken>`

**Request Body:**
```json
{
  "operations": [
    {
      "uuid": "550e8400-e29b-41d4-a716-446655440000",
      "type": "WORKOUT_COMPLETE",
      "payload": {
        "sessionId": 1001,
        "exerciseLogs": [...],
        "durationMinutes": 47
      }
    },
    {
      "uuid": "550e8400-e29b-41d4-a716-446655440001",
      "type": "MEAL_LOG",
      "payload": {
        "mealTimeId": 301,
        "foodItemIds": [401, 402]
      }
    }
  ]
}
```

**Response 200:**
```json
{
  "processed": 2,
  "failed": 0,
  "results": [
    {
      "uuid": "550e8400-e29b-41d4-a716-446655440000",
      "status": "SUCCESS"
    },
    {
      "uuid": "550e8400-e29b-41d4-a716-446655440001",
      "status": "SUCCESS"
    }
  ]
}
```


---

## 11. FRONTEND MOBILE (FLUTTER)

### 11.1 Struktur 47 Screens

#### A. Splash & Onboarding (3 screens)
| Screen ID | Nama | Deskripsi |
|-----------|------|-----------|
| S-01 | Splash Screen | Logo + loading animation |
| S-02 | Onboarding 1 | "AI Personal Trainer" |
| S-03 | Onboarding 2 | "Budget-Aware Meal Planning" |

#### B. Authentication (2 screens)
| Screen ID | Nama | Deskripsi |
|-----------|------|-----------|
| S-04 | Login | Email + password |
| S-05 | Signup | Email + password + name |

#### C. Setup Wizard (7 screens)
| Screen ID | Nama | Deskripsi |
|-----------|------|-----------|
| S-06 | Setup Welcome | "Mari kita kenali kamu" |
| S-07 | Basic Info | Nama, usia, gender |
| S-08 | Physical Data | Tinggi, berat, lingkar pinggang |
| S-09 | BMI Result | Kalkulasi BMI, BMR, TDEE |
| S-10 | Health Goal | Turun/jaga/naikkan berat |
| S-11 | Workout Preferences | Home/gym, frekuensi, durasi |
| S-12 | Budget & Diet | Budget harian, meal frequency, pantangan |

#### D. Plan Generation (2 screens)
| Screen ID | Nama | Deskripsi |
|-----------|------|-----------|
| S-13 | Generating Plan | Loading animation + progress |
| S-14 | Plan Ready | Preview 7-day plan + "Mulai Sekarang" |

#### E. Home & Dashboard (3 screens)
| Screen ID | Nama | Deskripsi |
|-----------|------|-----------|
| S-15 | Home Dashboard | Kalori, hidrasi, streak, workout hari ini |
| S-16 | Notifications | List notifikasi in-app |
| S-17 | Profile | Avatar, nama, email, settings |

#### F. Workout (8 screens)
| Screen ID | Nama | Deskripsi |
|-----------|------|-----------|
| S-18 | Workout Week View | 7-day calendar dengan status |
| S-19 | Workout Day Detail | List exercise + estimasi waktu |
| S-20 | Pre-Workout Check-in | Mood, energi, kualitas tidur |
| S-21 | Active Workout | Timer, set counter, rest timer |
| S-22 | Exercise Detail | Video, deskripsi, tips |
| S-23 | Rest Timer | Countdown + skip button |
| S-24 | Workout Complete | Summary + badge unlock |
| S-25 | Workout History | List session sebelumnya |

#### G. Meal (7 screens)
| Screen ID | Nama | Deskripsi |
|-----------|------|-----------|
| S-26 | Meal Week View | 7-day calendar dengan status |
| S-27 | Meal Day Detail | List meal per waktu makan |
| S-28 | Meal Time Detail | List food items + nutrisi |
| S-29 | Food Item Detail | Nutrisi lengkap + similar foods |
| S-30 | Meal Swap | Alternatif meal |
| S-31 | Meal Logging | Checklist sudah makan |
| S-32 | Meal History | Riwayat meal logged |

#### H. Progress (8 screens)
| Screen ID | Nama | Deskripsi |
|-----------|------|-----------|
| S-33 | Progress Dashboard | Charts weight, workout compliance |
| S-34 | Weekly Review Modal | Skor, insights, strategi replan |
| S-35 | New Plan Ready | Preview plan baru setelah replan |
| S-36 | Weight History | Line chart 4 minggu |
| S-37 | Weight Log Form | Input berat badan |
| S-38 | Streak Detail | Current, best, calendar heatmap |
| S-39 | Badges Collection | Grid unlocked + locked badges |
| S-40 | Badge Detail | Deskripsi + progress bar |

#### I. Settings (7 screens)
| Screen ID | Nama | Deskripsi |
|-----------|------|-----------|
| S-41 | Settings Main | List menu settings |
| S-42 | Notification Settings | Toggle reminder + waktu |
| S-43 | Theme Settings | Light / Dark / System |
| S-44 | Language Settings | Bahasa Indonesia / English |
| S-45 | Edit Profile | Nama, avatar |
| S-46 | Edit Health Profile | Update tinggi, berat, goal |
| S-47 | About | Versi app, credits, privacy policy |

### 11.2 Navigation Flow

```
Splash (S-01)
  ↓
Onboarding (S-02, S-03) [first time only]
  ↓
Login/Signup (S-04, S-05)
  ↓
Setup Wizard (S-06 → S-12) [first time only]
  ↓
Generating Plan (S-13)
  ↓
Plan Ready (S-14)
  ↓
Home Dashboard (S-15) ← Main entry point
  ├─ Workout Week (S-18)
  │   ├─ Workout Day (S-19)
  │   │   ├─ Pre-Workout Check-in (S-20)
  │   │   │   └─ Active Workout (S-21)
  │   │   │       ├─ Exercise Detail (S-22)
  │   │   │       ├─ Rest Timer (S-23)
  │   │   │       └─ Workout Complete (S-24)
  │   │   └─ Workout History (S-25)
  │   └─ ...
  ├─ Meal Week (S-26)
  │   ├─ Meal Day (S-27)
  │   │   ├─ Meal Time (S-28)
  │   │   │   ├─ Food Item (S-29)
  │   │   │   ├─ Meal Swap (S-30)
  │   │   │   └─ Meal Logging (S-31)
  │   │   └─ Meal History (S-32)
  │   └─ ...
  ├─ Progress (S-33)
  │   ├─ Weekly Review (S-34) → New Plan Ready (S-35)
  │   ├─ Weight History (S-36) → Weight Log (S-37)
  │   ├─ Streak Detail (S-38)
  │   └─ Badges (S-39) → Badge Detail (S-40)
  ├─ Profile (S-17)
  │   └─ Settings (S-41)
  │       ├─ Notification Settings (S-42)
  │       ├─ Theme Settings (S-43)
  │       ├─ Language Settings (S-44)
  │       ├─ Edit Profile (S-45)
  │       ├─ Edit Health Profile (S-46)
  │       └─ About (S-47)
  └─ Notifications (S-16)
```

### 11.3 State Management Pattern

**Provider + GetIt:**
```dart
// Service locator (GetIt)
final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  getIt.registerLazySingleton<AuthService>(() => AuthService(getIt<ApiClient>()));
  getIt.registerLazySingleton<PlanService>(() => PlanService(getIt<ApiClient>()));
  // ...
}

// Provider (state management)
class WorkoutProvider extends ChangeNotifier {
  final PlanService _planService = getIt<PlanService>();
  WorkoutPlan? _activePlan;
  bool _isLoading = false;

  WorkoutPlan? get activePlan => _activePlan;
  bool get isLoading => _isLoading;

  Future<void> fetchActivePlan() async {
    _isLoading = true;
    notifyListeners();
    
    _activePlan = await _planService.getActiveWorkoutPlan();
    
    _isLoading = false;
    notifyListeners();
  }
}

// Usage in widget
class WorkoutWeekScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return LoadingIndicator();
        return WorkoutWeekView(plan: provider.activePlan);
      },
    );
  }
}
```


### 11.4 Offline-First Implementation

**Connectivity Detection:**
```dart
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();

  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  bool _isOnline = true;

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen((result) {
      _isOnline = result != ConnectivityResult.none;
      _connectionStatusController.add(_isOnline);
    });
  }

  bool get isOnline => _isOnline;
}
```

**Sync Queue:**
```dart
class SyncQueue {
  final Hive _hive;
  final ApiClient _apiClient;
  final ConnectivityService _connectivity;

  Future<void> enqueue(SyncOperation operation) async {
    final box = await _hive.openBox<SyncOperation>('sync_queue');
    await box.add(operation);
    
    if (_connectivity.isOnline) {
      await drain();
    }
  }

  Future<void> drain() async {
    final box = await _hive.openBox<SyncOperation>('sync_queue');
    final operations = box.values.toList();
    
    if (operations.isEmpty) return;

    try {
      final response = await _apiClient.post('/sync/batch', {
        'operations': operations.map((op) => op.toJson()).toList(),
      });
      
      // Clear processed operations
      await box.clear();
    } catch (e) {
      // Retry later
    }
  }
}
```

**Cache Strategy:**
```dart
class CacheService {
  final SharedPreferences _prefs;

  Future<void> cacheWorkoutPlan(WorkoutPlan plan) async {
    await _prefs.setString('active_workout_plan', jsonEncode(plan.toJson()));
  }

  WorkoutPlan? getCachedWorkoutPlan() {
    final json = _prefs.getString('active_workout_plan');
    if (json == null) return null;
    return WorkoutPlan.fromJson(jsonDecode(json));
  }
}
```

---

## 12. OFFLINE-FIRST STRATEGY

### 12.1 Fitur Offline vs Online

| Fitur | Offline | Online | Fallback Strategy |
|-------|---------|--------|-------------------|
| **Lihat workout plan** | ✅ Cache | ✅ Fresh | Cache jika API gagal |
| **Lihat meal plan** | ✅ Cache | ✅ Fresh | Cache jika API gagal |
| **Centang exercise selesai** | ✅ Enqueue | ✅ Langsung | Enqueue untuk sync |
| **Centang meal selesai** | ✅ Enqueue | ✅ Langsung | Enqueue untuk sync |
| **Active workout tracking** | ✅ Lokal | ✅ Lokal | Timer lokal, sync setelah selesai |
| **Log berat badan** | ✅ Enqueue | ✅ Langsung | Enqueue untuk sync |
| **Log air minum** | ✅ Lokal | ✅ Langsung | Increment lokal, sync batch |
| **Pre-workout check-in** | ❌ | ✅ ML adjust | Gunakan original plan tanpa adjust |
| **Meal swap** | ❌ | ✅ ML replan | Tampilkan pesan "Butuh koneksi" |
| **Generate plan pertama** | ❌ | ✅ ML | Tidak bisa offline |
| **Weekly review** | ⚠️ Cache | ✅ Fresh | Tampilkan cached data + warning |
| **Replan** | ❌ | ✅ ML | Tidak bisa offline |
| **Signup/Login** | ❌ | ✅ Auth | Tidak bisa offline |


### 12.2 Sync Queue Architecture

**Operation Types:**
```dart
enum SyncOperationType {
  WORKOUT_COMPLETE,
  MEAL_LOG,
  WEIGHT_LOG,
  WATER_LOG,
}

class SyncOperation {
  final String uuid; // UUID v4
  final SyncOperationType type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  SyncOperation({
    required this.uuid,
    required this.type,
    required this.payload,
    required this.createdAt,
  });
}
```

**Enqueue Example:**
```dart
// User centang workout selesai saat offline
await syncQueue.enqueue(SyncOperation(
  uuid: Uuid().v4(),
  type: SyncOperationType.WORKOUT_COMPLETE,
  payload: {
    'sessionId': 1001,
    'exerciseLogs': [...],
    'durationMinutes': 47,
  },
  createdAt: DateTime.now(),
));
```

**Drain on Reconnect:**
```dart
// Listener connectivity
_connectivity.connectionStatus.listen((isOnline) {
  if (isOnline) {
    syncQueue.drain(); // Batch upload semua pending operations
  }
});
```

### 12.3 Conflict Resolution

**Idempotency Key:**
- Setiap operation punya UUID unik
- Backend track di `sync_ops_log` table
- Jika UUID sudah ada, skip (tidak error)

**Last-Write-Wins:**
- Weight log: timestamp terbaru menang
- Meal log: idempotent per (user_id, meal_time_id, food_item_id)
- Workout session: tidak bisa conflict (sessionId unik)

**No Conflict:**
- Workout complete: sessionId unik, tidak bisa conflict
- Water log: increment-only, tidak bisa conflict

### 12.4 Cache Invalidation

**TTL Strategy:**
- Workout plan: Cache 7 hari (sampai plan expired)
- Meal plan: Cache 7 hari
- Daily log: Cache 1 hari (reset tiap midnight)
- Weekly review: Cache 1 minggu

**Manual Invalidation:**
- Saat replan: Clear old plan cache
- Saat logout: Clear semua cache
- Saat sync success: Update cache dengan server response

---

## 13. GAMIFIKASI & MOTIVASI

### 13.1 Streak System

**Definisi Streak:**
- User dianggap "aktif" jika:
  - Menyelesaikan minimal 1 workout ATAU
  - Log minimal 2 meals
- Streak bertambah jika aktif hari ini DAN kemarin
- Streak reset jika tidak aktif 2 hari berturut-turut

**Streak Calculation:**
```typescript
function updateStreak(userId: number, today: Date): Promise<void> {
  const yesterday = subDays(today, 1);
  const todayLog = await getDailyLog(userId, today);
  const yesterdayLog = await getDailyLog(userId, yesterday);

  const isActiveToday = todayLog.workoutDone || todayLog.mealsLogged >= 2;
  const wasActiveYesterday = yesterdayLog?.workoutDone || yesterdayLog?.mealsLogged >= 2;

  if (isActiveToday && wasActiveYesterday) {
    await incrementStreak(userId);
  } else if (isActiveToday && !wasActiveYesterday) {
    await resetStreak(userId, 1); // Start new streak
  }
}
```

**Streak Milestones:**
- 🔥 3 hari → Badge "Streak 3"
- 🔥 7 hari → Badge "Streak 7" + notifikasi motivasi
- 🔥 30 hari → Badge "Streak 30" + special reward
- 🔥 100 hari → Badge "Streak 100" + hall of fame


### 13.2 Badge System (15 Badges)

#### A. Streak Badges (4)
| Badge ID | Nama | Requirement | Icon |
|----------|------|-------------|------|
| badge-streak-3 | Streak 3 Hari | Current streak ≥ 3 | 🔥 |
| badge-streak-7 | Streak 7 Hari | Current streak ≥ 7 | 🔥🔥 |
| badge-streak-30 | Streak 30 Hari | Current streak ≥ 30 | 🔥🔥🔥 |
| badge-streak-100 | Streak 100 Hari | Current streak ≥ 100 | 🏆 |

#### B. Workout Badges (4)
| Badge ID | Nama | Requirement | Icon |
|----------|------|-------------|------|
| badge-workout-10 | 10 Workouts | Total workouts ≥ 10 | 💪 |
| badge-workout-50 | 50 Workouts | Total workouts ≥ 50 | 💪💪 |
| badge-workout-100 | 100 Workouts | Total workouts ≥ 100 | 💪💪💪 |
| badge-workout-perfect-week | Perfect Week | 7/7 workouts dalam 1 minggu | ⭐ |

#### C. Weight Loss Badges (3)
| Badge ID | Nama | Requirement | Icon |
|----------|------|-------------|------|
| badge-weight-1kg | Turun 1 kg | Weight lost ≥ 1 kg | 📉 |
| badge-weight-5kg | Turun 5 kg | Weight lost ≥ 5 kg | 📉📉 |
| badge-weight-10kg | Turun 10 kg | Weight lost ≥ 10 kg | 🎯 |

#### D. Consistency Badges (3)
| Badge ID | Nama | Requirement | Icon |
|----------|------|-------------|------|
| badge-meal-logger | Meal Logger | Log meals 21/21 dalam 1 minggu | 🍽️ |
| badge-early-bird | Early Bird | Workout sebelum 08:00 sebanyak 5× | 🌅 |
| badge-night-owl | Night Owl | Workout setelah 20:00 sebanyak 5× | 🌙 |

#### E. Special Badge (1)
| Badge ID | Nama | Requirement | Icon |
|----------|------|-------------|------|
| badge-first-plan | First Plan | Selesaikan setup & generate plan pertama | 🎉 |

### 13.3 Weekly Review Insights

**AI-Generated Insights:**
```typescript
function generateInsights(weeklyData: WeeklyData): string[] {
  const insights: string[] = [];

  // Workout compliance
  const workoutRate = weeklyData.workoutDoneCount / weeklyData.workoutTotalCount;
  if (workoutRate >= 0.85) {
    insights.push("🎉 Konsistensi latihan luar biasa! Kamu menyelesaikan 85%+ workout.");
  } else if (workoutRate < 0.5) {
    insights.push("⚠️ Konsistensi latihan perlu ditingkatkan. Coba kurangi intensitas minggu depan.");
  }

  // Meal logging
  const mealRate = weeklyData.mealLoggedCount / weeklyData.mealTotalCount;
  if (mealRate >= 0.8) {
    insights.push("✅ Meal logging bagus (80%+). Ini membantu tracking kalori akurat.");
  }

  // Weight progress
  const weightDiff = weeklyData.weightChangeKg;
  const targetDiff = weeklyData.weightTargetChangeKg;
  if (Math.abs(weightDiff - targetDiff) < 0.2) {
    insights.push("🎯 Progres berat badan sesuai target! Pertahankan pola ini.");
  } else if (weightDiff < targetDiff - 0.3) {
    insights.push("📈 Berat turun lebih lambat dari target. Coba kurangi kalori atau tambah intensitas.");
  }

  // Most skipped exercise
  if (weeklyData.mostSkippedExercises.length > 0) {
    const ex = weeklyData.mostSkippedExercises[0];
    insights.push(`🔄 Latihan paling sering diskip: ${ex.name}. Akan diganti otomatis minggu depan.`);
  }

  return insights;
}
```

**Motivasi Personal:**
```typescript
function generateMotivation(score: number): string {
  if (score >= 80) {
    return "Performamu luar biasa minggu ini! Kamu adalah contoh konsistensi. 🔥";
  } else if (score >= 60) {
    return "Progres bagus! Sedikit lagi untuk mencapai performa optimal. 💪";
  } else if (score >= 40) {
    return "Minggu ini cukup menantang, tapi kamu tetap berusaha. Ayo bangkit minggu depan! 🌟";
  } else {
    return "Tidak apa-apa, semua orang punya minggu yang sulit. Yang penting kamu tidak menyerah. 💙";
  }
}
```


### 13.4 Notification Strategy

**Timing & Frequency:**
| Notification Type | Default Time | Frequency | Customizable |
|-------------------|--------------|-----------|--------------|
| Workout Reminder | 18:00 | Daily (jika ada workout) | ✅ |
| Pre-Reminder | 17:45 | 15 min before workout | ❌ |
| Meal Reminder | 07:00, 12:00, 19:00 | Per meal time | ✅ |
| Hydration | Every 2 hours | 08:00-20:00 | ✅ Interval |
| Streak Milestone | 20:00 | On milestone | ❌ |
| Badge Unlocked | Immediately | On unlock | ❌ |
| Replan Due | Sunday 20:00 | Weekly | ❌ |

**Smart Notification:**
- Tidak kirim workout reminder jika sudah selesai workout hari ini
- Tidak kirim meal reminder jika sudah log meal tersebut
- Tidak kirim hydration reminder jika sudah 8/8 gelas
- Batch notification jika user tidak buka app >24 jam

---

## 14. TIMELINE IMPLEMENTASI

### 14.1 Sprint 1: Foundation (Minggu 1-2)

#### Week 1: Backend + ML Setup
**Backend (3 hari):**
- ✅ Setup Express.js + TypeScript + Prisma
- ✅ Database schema (19 tables)
- ✅ Auth endpoints (signup, login, refresh, logout)
- ✅ User & health profile endpoints
- ✅ Seed exercise_master (200 items) & food_master (1,346 items)

**ML Service (3 hari):**
- ✅ Setup FastAPI + scikit-learn
- ✅ Train Workout Recommender (Random Forest)
- ✅ Implement Meal Planner (Knapsack)
- ✅ Implement Intensity Adjuster (Rule-based)
- ✅ Implement Replanner (Rule-based)
- ✅ API endpoints: /predict/workout-plan, /predict/meal-plan, /predict/replan

**Testing (1 hari):**
- ✅ Unit tests backend (Jest)
- ✅ Unit tests ML (pytest)
- ✅ Integration test: Backend ↔ ML

#### Week 2: Frontend Foundation
**Setup (1 hari):**
- ✅ Flutter project setup
- ✅ Folder structure (47 screens)
- ✅ Theme (colors, text styles, sizes)
- ✅ Router (GoRouter)
- ✅ State management (Provider + GetIt)

**Screens (4 hari):**
- ✅ Splash & Onboarding (S-01 to S-03)
- ✅ Auth (S-04, S-05)
- ✅ Setup Wizard (S-06 to S-12)
- ✅ Plan Generation (S-13, S-14)
- ✅ Home Dashboard (S-15)

**Testing (2 hari):**
- ✅ Widget tests (setup wizard flow)
- ✅ Integration test (signup → setup → plan generation)

### 14.2 Sprint 2: Core Features (Minggu 3-4)

#### Week 3: Workout Features
**Backend (2 hari):**
- ✅ Workout endpoints (active-plan, check-in, session complete)
- ✅ Exercise log tracking
- ✅ Streak calculation logic

**Frontend (3 hari):**
- ✅ Workout Week View (S-18)
- ✅ Workout Day Detail (S-19)
- ✅ Pre-Workout Check-in (S-20)
- ✅ Active Workout (S-21)
- ✅ Exercise Detail (S-22)
- ✅ Rest Timer (S-23)
- ✅ Workout Complete (S-24)

**Testing (2 hari):**
- ✅ E2E test: Pre-workout check-in → Active workout → Complete
- ✅ Timer accuracy test

#### Week 4: Meal Features
**Backend (2 hari):**
- ✅ Meal endpoints (active-plan, log, swap)
- ✅ Meal logging idempotency

**Frontend (3 hari):**
- ✅ Meal Week View (S-26)
- ✅ Meal Day Detail (S-27)
- ✅ Meal Time Detail (S-28)
- ✅ Food Item Detail (S-29)
- ✅ Meal Swap (S-30)
- ✅ Meal Logging (S-31)

**Testing (2 hari):**
- ✅ E2E test: Meal swap → Log meal
- ✅ Idempotency test (double log)


### 14.3 Sprint 3: Progress & Gamification (Minggu 5-6)

#### Week 5: Progress Tracking
**Backend (2 hari):**
- ✅ Progress endpoints (daily, weekly-review, weight, water)
- ✅ Badge system (15 badges)
- ✅ Badge unlock logic

**Frontend (3 hari):**
- ✅ Progress Dashboard (S-33)
- ✅ Weight History (S-36)
- ✅ Weight Log Form (S-37)
- ✅ Streak Detail (S-38)
- ✅ Badges Collection (S-39)
- ✅ Badge Detail (S-40)

**Testing (2 hari):**
- ✅ Badge unlock test (streak, workout, weight)
- ✅ Weight chart rendering test

#### Week 6: Replanning & Notifications
**Backend (2 hari):**
- ✅ Replan endpoint
- ✅ Weekly review aggregation
- ✅ Notification scheduling (cron jobs)

**Frontend (3 hari):**
- ✅ Weekly Review Modal (S-34)
- ✅ New Plan Ready (S-35)
- ✅ Notifications Screen (S-16)
- ✅ Local notifications setup

**Testing (2 hari):**
- ✅ Replan strategy test (REDUCE, MAINTAIN, INTENSIFY)
- ✅ Notification delivery test

### 14.4 Sprint 4: Offline & Polish (Minggu 7-8)

#### Week 7: Offline-First
**Backend (1 hari):**
- ✅ Sync batch endpoint
- ✅ Idempotency tracking (sync_ops_log)

**Frontend (4 hari):**
- ✅ Connectivity detection
- ✅ Sync queue implementation
- ✅ Cache strategy (Shared Preferences)
- ✅ Offline indicator UI
- ✅ Drain queue on reconnect

**Testing (2 hari):**
- ✅ Offline mode test (workout, meal, weight log)
- ✅ Sync queue drain test
- ✅ Conflict resolution test

#### Week 8: Polish & Deployment
**Frontend (3 hari):**
- ✅ Settings screens (S-41 to S-47)
- ✅ Profile edit (S-45, S-46)
- ✅ Theme switcher (S-43)
- ✅ Language switcher (S-44)
- ✅ UI polish (animations, transitions)
- ✅ Accessibility (semantic labels, contrast)

**Backend (1 hari):**
- ✅ Rate limiting (Redis)
- ✅ Error logging (Pino)
- ✅ Health check endpoints

**Deployment (2 hari):**
- ✅ Deploy backend ke Render
- ✅ Deploy ML service ke Render (Docker)
- ✅ Setup MySQL (PlanetScale)
- ✅ Setup Redis (Upstash)
- ✅ CI/CD (GitHub Actions)

**Final Testing (1 hari):**
- ✅ E2E test full flow (signup → setup → workout → meal → replan)
- ✅ Performance test (API latency, ML inference)
- ✅ Security audit (JWT, password hashing, SQL injection)

### 14.5 Post-Launch (Minggu 9+)

**Phase 1: Monitoring (Minggu 9-10)**
- Setup Sentry untuk error tracking
- Setup Uptime Robot untuk uptime monitoring
- Collect user feedback (in-app survey)
- Fix critical bugs

**Phase 2: Iteration (Minggu 11-12)**
- Improve ML model accuracy (retrain dengan user data)
- Add more exercises (300+ items)
- Add more foods (2,000+ items)
- Optimize API performance (caching, query optimization)

**Phase 3: New Features (Minggu 13+)**
- Social features (leaderboard, challenges)
- Wearable integration (optional)
- Export data (PDF report)
- Premium features (personal coach chat, custom meal plan)

---

## PENUTUP

### Ringkasan Keunggulan Heltigo

1. **AI-Powered Personalization** - 4 model AI yang bekerja sama untuk program yang benar-benar personal
2. **Budget-Aware** - Meal planning dengan constraint optimization, terjangkau untuk semua kalangan
3. **Adaptive Real-Time** - Intensity adjustment berdasarkan kondisi psikologis, bukan hanya fisiologis
4. **Offline-First** - Fitur kritis tetap berfungsi tanpa internet, cocok untuk Indonesia
5. **Gamified** - Streak, badge, weekly review untuk meningkatkan konsistensi jangka panjang
6. **No Wearable** - Hanya butuh smartphone, tidak butuh smartwatch mahal
7. **Local Context** - Database makanan Indonesia, bahasa Indonesia, halal-aware

### Target Kompetisi MSU iREX 2026

Heltigo memenuhi kriteria kompetisi:
- ✅ **Innovation:** Hybrid ML approach (RF + Knapsack + Rule-based)
- ✅ **Social Impact:** Mengatasi obesitas & PTM dengan solusi terjangkau
- ✅ **Technical Excellence:** Microservice architecture, offline-first, property-based testing
- ✅ **Scalability:** Dapat melayani 100 juta+ pengguna Indonesia
- ✅ **Sustainability:** Model bisnis freemium, dapat berkembang jangka panjang

### Kontak Tim

**Tim Hackathon Core3D**
- Email: team@heltigo.app
- GitHub: github.com/heltigo
- Website: heltigo.app

---

**Dokumen ini dibuat pada 15 Mei 2026 untuk kompetisi MSU iREX 2026.**

**Versi:** 1.0.0  
**Total Halaman:** ~50 halaman  
**Total Kata:** ~15,000 kata

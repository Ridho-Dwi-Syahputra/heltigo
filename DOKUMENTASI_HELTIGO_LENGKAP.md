# DOKUMENTASI LENGKAP APLIKASI HELTIGO
## AI-Powered Personal Health & Fitness App

**Versi:** 1.0.0  
**Tanggal Update:** 17 Mei 2026  
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
8. [Gemini AI — Lapisan Enrichment](#8-gemini-ai--lapisan-enrichment)
9. [Tech Stack Detail](#9-tech-stack-detail)
10. [Database Schema](#10-database-schema)
11. [API Endpoints](#11-api-endpoints)
12. [Frontend Mobile Flutter](#12-frontend-mobile-flutter)
13. [Sync & Offline Queue](#13-sync--offline-queue)
14. [Gamifikasi & Motivasi](#14-gamifikasi--motivasi)
15. [Cara Menjalankan](#15-cara-menjalankan)

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
- **Budget-aware** dengan database 1.346+ makanan lokal Indonesia, mulai Rp 15.000/hari
- **Tanpa wearable device** — hanya butuh smartphone
- **Gamified** dengan streak, badge, dan motivasi AI personal untuk meningkatkan konsistensi
- **Didukung 4 model ML + Gemini AI** untuk personalisasi, analisis makanan, dan narasi motivasi

---

## 2. PERMASALAHAN YANG DISELESAIKAN

### 2.1 Gap Penelitian yang Diisi Heltigo

| Gap | Masalah Existing | Solusi Heltigo |
|-----|------------------|----------------|
| **G1: Integrasi Holistik** | Aplikasi fitness dan nutrisi terpisah | Single platform yang mengintegrasikan latihan, nutrisi, dan budget dalam satu pipeline AI |
| **G2: Ketergantungan Wearable** | Butuh smartwatch/fitness tracker mahal | Hanya butuh smartphone, AI bekerja dengan input manual sederhana |
| **G3: Database Makanan** | Fokus makanan Western | 1.346 item makanan lokal Indonesia dengan estimasi harga |
| **G4: Faktor Psikologis** | Hanya fokus data fisiologis | Pre-workout check-in (mood, energi, tidur) untuk adaptasi real-time intensitas latihan |
| **G5: Privasi Data** | Data kesehatan dikirim ke cloud pihak ketiga | Server isolated, ML service internal (tidak exposed ke public), API key tidak pernah sampai ke FE |

### 2.2 Masalah Spesifik yang Diselesaikan

**A. Personalisasi Tidak Memadai**  
Heltigo menghasilkan program 7 hari yang disesuaikan dengan profil pengguna: kondisi kesehatan, fitness level, equipment tersedia (HOME/GYM/HYBRID), waktu yang tersedia, dan goal.

**B. Ketidaksesuaian Budget Nutrisi**  
Meal planner AI menggunakan Knapsack + Genetic Algorithm untuk mengoptimalkan nilai gizi dalam batasan budget mulai Rp 15.000/hari, dengan database makanan lokal Indonesia yang terjangkau.

**C. Kurangnya Adaptasi Real-Time**  
Pre-workout check-in (mood, energi, kualitas tidur) memicu intensity adjuster yang mengurangi atau menambah volume latihan secara otomatis sebelum sesi dimulai.

**D. Rendahnya Konsistensi Jangka Panjang**  
Sistem gamifikasi dengan streak tracking, 15 badge pencapaian, weekly review dengan narasi AI personal (Gemini), dan notifikasi motivasi.

---

## 3. RELEVANSI APLIKASI

### 3.1 Relevansi untuk Kompetisi MSU iREX 2026

Heltigo memenuhi kriteria kompetisi innovation & research excellence:

1. **Innovation in AI Application**
   - Hybrid AI: ML numerik (XGBoost, Knapsack+GA) + Generative AI (Gemini) untuk narasi personal
   - Pre-workout intensity adaptation berdasarkan faktor psikologis
   - Food scan: Gemini Vision → TF-IDF cosine matching → XGBoost health score

2. **Social Impact**
   - Target: 100 juta+ orang Indonesia yang tidak mampu personal trainer
   - Meal planning mulai Rp 15.000/hari dengan optimasi gizi
   - Mendukung pola makan halal dan makanan lokal Indonesia

3. **Technical Excellence**
   - Microservice architecture: Flutter + Express.js/Node + FastAPI/Python
   - Dual Gemini integration: Vision (ML service) + Enrichment text (backend)
   - Prisma ORM dengan 19 tabel relasional MySQL

### 3.2 Relevansi untuk Masyarakat Indonesia

- **Gratis** vs personal trainer Rp 500K-2jt/bulan
- **Budget meal planning** mulai Rp 15.000/hari
- **Tidak butuh gym membership** — home workout dengan bodyweight tersedia
- **Bahasa Indonesia** sebagai bahasa utama
- **Halal-aware** meal planning
- **Tidak butuh wearable** — input manual sederhana

---

## 4. FITUR-FITUR UTAMA

### 4.1 Setup Profil Cerdas (7 Langkah)

Wizard interaktif yang mengumpulkan data untuk personalisasi AI:

1. **Data Dasar** — Nama, usia, gender
2. **Data Fisik** — Tinggi, berat badan
3. **BMI Result** — Kalkulasi otomatis BMI, BMR, TDEE
4. **Target Kesehatan** — Turun berat / Jaga berat / Naikkan massa otot / Performa
5. **Kondisi Khusus** — Cedera, diabetes, hipertensi, hamil (multi-select)
6. **Preferensi Latihan** — HOME/GYM/HYBRID, hari/minggu, menit/sesi, fitness level
7. **Budget & Diet** — Budget harian mulai Rp 15K, frekuensi makan, pantangan diet (halal, vegetarian, dll), waktu favorit latihan

**Output:** Setelah save `health_profile`, user bisa generate plan — AI menghasilkan program 7 hari workout + meal dalam sekali call.

### 4.2 Program Latihan Personal

**A. Workout Plan Generation (ML Model 1)**
- Input dari health profile + XGBoost type/intensity classifier
- Schedule 7 hari berbasis template (fitness_level + goal) + condition overrides
- Exercise per hari: WARMUP → MAIN → COOLDOWN
- Adaptasi kondisi kesehatan: cedera → FLEXIBILITY, hamil → low impact, obese → kurangi HIIT

**B. Pre-Workout Check-in (Intensity Adjuster)**
- Input: Mood (VERY_BAD/BAD/NEUTRAL/GOOD/VERY_GOOD), Energi (1-10), Sleep Band (<5h, 5-6, 6-7, 7-8, >8)
- Logic rule-based di backend: `intensityAdjusterService.getMultiplier(mood, energy, sleepBand)`
- Multiplier: 0.5 (min) – 1.5 (max) terhadap volume latihan
- Membuat `WorkoutSession` dengan intensitas yang disesuaikan

**C. Active Workout Tracking**
- Log per set: reps actual, durasi, berat yang diangkat, rest actual
- Pause session (dicatat di notes)
- Wakelock (`wakelock_plus`) agar layar tidak mati

**D. Workout Complete + Gemini Motivasi**
- Hitung kalori terbakar: `weight_kg × 0.1 × durationMin × intensityMultiplier`
- Update streak (+1 hari jika konsisten)
- Auto-check badge unlock (streak, workouts done, weight lost)
- Gemini menghasilkan pesan selamat personal + tips recovery (1-2 kalimat Bahasa Indonesia)

### 4.3 Meal Planning Budget-Aware

**A. Meal Plan Generation (ML Model 2)**
- Algoritma: Knapsack scoring + Genetic Algorithm (DEAP, 20 populasi, 30 generasi)
- Constraint: Budget harian (HARD), kalori target ±15% (SOFT), diversifikasi menu antar hari
- Output: 7 hari × 2-4 meals/hari × 1-4 foods/meal

**B. Meal Swap Alternatives**
- Trigger: User tap "Cari Alternatif" di meal detail
- Backend call ML `predictMealAlternatives` → top 3 alternatif dalam kategori sama
- Gemini enrich tiap alternatif dengan 1 kalimat alasan kenapa cocok untuk goal user

**C. Meal Logging**
- Tandai meal sudah dimakan → update `meal_logs` + `daily_logs.caloriesConsumed`
- Idempotent via `upsert` (tidak bisa double-log)
- Auto-update badge check setelah log

**D. Budget Update**
- User bisa ubah budget harian minimum Rp 10.000
- Tersimpan ke `health_profiles.budget_per_day_idr`
- Hint: apply sepenuhnya saat replan berikutnya

### 4.4 Food Scan dengan Kamera (AI Model 4 + Gemini Vision)

**Flow:**
1. User foto makanan dengan kamera / pilih dari galeri (`image_picker`)
2. FE compress + encode ke base64
3. FE `POST /api/v1/meal/food-scan { imageBase64 }`
4. Backend forward ke ML service `POST /predict/food-scan`
5. ML: Gemini Vision identifikasi nama makanan dari gambar
6. ML: TF-IDF + cosine similarity → match ke 1.346 food item database
7. ML: XGBoost health scorer → GOOD/MODERATE/POOR + health_score (0-1)
8. Backend: Gemini enrich → saran keseimbangan + tips konkret (2 kalimat)
9. FE tampilkan: daftar makanan teridentifikasi + nutrisi total + assessment + Gemini advice
10. (Opsional) User konfirmasi → kalori dicatat ke daily_logs

### 4.5 Progress Tracking & Gamifikasi

**A. Daily Dashboard**
- Kalori consumed vs burned (dari daily_logs)
- Hidrasi: X/8 gelas — update via `PATCH /progress/daily/water`
- Mood log via `POST /progress/daily/mood`
- Workout status hari ini + streak aktif

**B. Weekly Review**
- Skor mingguan: 0-100 (50% workout completion + 50% meal compliance)
- Delta berat: sekarang vs start_weight
- Charts: bar workout compliance, data per hari
- Rekomendasi: REDUCE / MAINTAIN / INTENSIFY (dari ML replan)

**C. Streak & Badges**
- Streak dihitung dari `daily_logs.workoutCompleted` secara consecutif
- Tersimpan di tabel `streaks` (currentStreak, bestStreak, activeDates)
- Badge auto-unlock saat complete workout / log meal

### 4.6 Adaptive Replanning (ML Model 3)

**Trigger:** Manual dari Weekly Review atau setelah 7 hari aktif

**Flow:**
1. Backend load 7-hari workout_sessions + meal_logs + daily_logs
2. Hitung weekly_score (scoringService) dan weight_diff
3. Panggil ML `/predict/replan` → volume_multiplier + action (REDUCE/MAINTAIN/INTENSIFY)
4. Gemini enrich → 2 kalimat narasi personal (rangkuman minggu + alasan)
5. (Opsional) `applyImmediately: true` → trigger regenerate plan baru

**Multiplier range:** 0.5 (min, REDUCE) – 1.5 (max, INTENSIFY)

### 4.7 Smart Notifications

- **Workout Reminder** — waktu yang user setting
- **Meal Reminder** — per meal type
- **Streak Milestone** — saat tercapai 3, 7, 30 hari berturut
- **Badge Unlocked** — saat unlock badge baru
- **Replan Due** — setelah 7 hari plan aktif
- **FCM Token** — backend simpan per-device ke tabel `fcm_tokens`

---

## 5. ARSITEKTUR SISTEM

### 5.1 Arsitektur 3-Tier

```
┌───────────────────────────────────────────────────────────────┐
│                   TIER 1: MOBILE CLIENT                        │
│  Flutter 3.x (Dart 3.10+, Android SDK min 21)                 │
│  - go_router (routing), provider + get_it (state)             │
│  - dio (HTTP), shared_preferences, flutter_secure_storage      │
│  - fl_chart (charts), google_fonts, image_picker              │
│  - connectivity_plus, wakelock_plus, uuid                      │
└───────────────────┬───────────────────────────────────────────┘
                    │ HTTPS + JWT Bearer token
                    │ Base: http://10.0.2.2:3000/api/v1 (emulator)
                    ▼
┌───────────────────────────────────────────────────────────────┐
│                   TIER 2: BACKEND API (port 3000)             │
│  Express.js + TypeScript (Node 20)                            │
│  - Prisma ORM → MySQL 8.0 (19 tabel)                          │
│  - JWT access 15 min + refresh 7 hari (SHA256 hash di DB)     │
│  - Zod validation, pino logging                               │
│  - @google/generative-ai (Gemini enrichment layer)            │
│  - axios (ML client dengan retry/backoff)                     │
└───────────────────┬───────────────────────────────────────────┘
                    │ HTTP + X-ML-KEY header
                    │ url: http://localhost:8001
                    ▼
┌──────────────────────────────────────────────────────────────┐
│                   TIER 3: ML SERVICE (port 8001)              │
│  FastAPI + Python 3.11                                        │
│  Model 1: Workout Recommender (XGBoost v3 + Rules Config)    │
│  Model 2: Meal Planner (Knapsack + GA dengan DEAP)           │
│  Model 3: Adaptive Replanner (XGBoost Regressor)             │
│  Model 4: Food Scan (TF-IDF + cosine + XGBoost scorer)       │
│  + Gemini Vision (google-generativeai 0.7.0) untuk food scan  │
└──────────────────────────────────────────────────────────────┘
                    │ HTTPS
                    ▼
              Gemini API (Google AI Studio)
              gemini-1.5-flash — dual role:
              [ML] Vision (identifikasi makanan dari foto)
              [Backend] Enrichment teks personal (4 method)
```

### 5.2 Komponen Kunci

| Komponen | Detail |
|----------|--------|
| **Prisma ORM** | Type-safe DB access, auto-migration, BigInt ID, Decimal untuk nilai finansial |
| **ML Client** | `ml.client.ts` — axios, timeout 10s, retry 2x backoff eksponensial (300ms→600ms→1200ms) |
| **Auth** | JWT access 15 menit, refresh token 7 hari disimpan hashed (SHA256) di tabel `refresh_tokens`, rotation saat refresh |
| **Gemini Service** | `gemini.service.ts` — 4 method, timeout 3s, fallback statis Bahasa Indonesia jika Gemini down/kosong |
| **Sync** | `POST /sync/batch` — idempotent via `sync_ops_log (userId + opId unique)`, support 5 opType |

### 5.3 Data Flow: Plan Generation

```
[Setup Wizard selesai — user save health profile]
         │
         │ POST /user/health-profile
         ▼
   Backend simpan ke health_profiles
         │
         │ POST /plan/generate
         ▼
   Backend baca HealthProfile
   Hitung BMI, BMR, TDEE (healthService)
         │
         ├──────────────────────────────┐
         │ POST /predict/workout-plan   │ POST /predict/meal-plan
         │ (ML service port 8001)       │ (ML service port 8001)
         ▼                             ▼
   XGBoost + Rules → 7 hari       Knapsack + GA → 7 hari
   workout plan                   meal plan
         │                             │
         └──────────────┬──────────────┘
                        │
                        ▼
         Backend $transaction (Prisma):
         - Archive old active plans
         - INSERT workout_plans → workout_days → exercises
         - INSERT meal_plans → meal_days → meal_times → food_items
                        │
                        ▼
         Return plan lengkap dengan nested data (IDs real dari DB)
                        │
                        ▼
         [plan_ready_screen] — FE tampilkan
```

### 5.4 Data Flow: Workout Session

```
[Pre-workout check-in]
   Input: mood, energy, sleepBand
         │
         │ POST /workout/:dayId/check-in
         ▼
   intensityAdjusterService.getMultiplier(...)
   → multiplier 0.5 – 1.5
   INSERT workout_sessions (status=IN_PROGRESS)
         │
   [Active Workout — tiap set]
   PATCH /workout/session/:id/exercise
   → INSERT exercise_logs
         │
   [Selesai latihan]
   POST /workout/session/:id/complete
         │
         ├─ Hitung durasi + kalori terbakar
         ├─ UPDATE workout_sessions (COMPLETED)
         ├─ UPDATE workout_days.isCompleted=true
         ├─ UPSERT daily_logs
         ├─ UPDATE streaks
         ├─ badgeService.checkUnlocks
         └─ geminiService.enrichWorkoutComplete → pesan personal
         │
         ▼
   [workout_complete_screen] tampilkan stats + Gemini message + badge baru
```

---

## 6. 4 MODEL AI YANG DIGUNAKAN

> **Penting:** Model yang "terlatih" menghasilkan artifact `.pkl` / `.npy`. Model yang bersifat rule-based menggunakan config JSON. Keduanya di-load saat startup ML service.

---

### 6.1 Model 1: Workout Recommender

**File artifact:**
- `workout_xgb_v3_type.pkl` — XGBoost classifier untuk workout_type
- `workout_xgb_v3_intensity.pkl` — XGBoost classifier untuk intensity
- `scaler_v3.pkl` — StandardScaler fitur
- `workout_rules_config.json` — schedule templates + sets/reps/rest per intensity

**Arsitektur:**
- XGBoost v3 dengan Knowledge Distillation (F1 ≈ 1.0 pada test set)
- Schedule 7 hari digenerate dari `schedule_templates[fitness_level + "_" + goal]`
- Exercise list dari `EXERCISE_MAP[workout_type]` dengan warmup/cooldown tetap
- **Condition overrides**: INJURY/JOINT_PAIN → ubah HIIT/CARDIO ke FLEXIBILITY; PREGNANT → low impact; OBESE (BMI≥35) → kurangi HIIT ke CARDIO + turunkan intensity

**Input (dari health_profile):**

| Parameter | Tipe | Contoh |
|-----------|------|--------|
| `fitness_level` | str | BEGINNER / INTERMEDIATE / ADVANCED |
| `goal` | str | WEIGHT_LOSS / MUSCLE_GAIN / MAINTENANCE / PERFORMANCE |
| `bmi` | float | 26.5 |
| `age` | int | 28 |
| `gender` | str | MALE / FEMALE |
| `workout_mode` | str | HOME / GYM / HYBRID |
| `days_per_week` | int | 3-7 |
| `session_minutes` | int | 15-180 |
| `has_injury` | bool | false |
| `has_chronic` | bool | false |
| `conditions` | list[str] | ["diabetes"] |

**Output:**
```json
{
  "days": [
    {
      "day_index": 0,
      "workout_type": "STRENGTH",
      "intensity": "MID",
      "is_rest_day": false,
      "estimated_minutes": 45,
      "exercises": [
        { "name": "Dynamic Stretching", "phase": "WARMUP", "sets": 1, "reps": 10, "rest_seconds": 30 },
        { "name": "Push Up", "phase": "MAIN", "sets": 3, "reps": 12, "rest_seconds": 60 }
      ]
    }
  ],
  "model_version": "v3-knowledge-distillation"
}
```

---

### 6.2 Model 2: Meal Planner (Knapsack + Genetic Algorithm)

**File artifact:**
- `food_master_v3.parquet` — 1.346 item makanan lokal Indonesia
- `knapsack_config_v3.json` — goal weights, meal splits per frekuensi

**Algoritma:**

1. **Scoring function** (Knapsack-style per food item):
   ```
   score = protein × w_protein / (price/1000)
          + calories × w_cal / (price/1000)
          - fat × w_fat_penalty / (price/1000)
   ```

2. **Genetic Algorithm** (DEAP library):
   - Populasi: 20 individu (chromosome = indeks food per meal × 7 hari)
   - Generasi: 30
   - Crossover (one-point): 70%; Mutasi (uniform int): 20%
   - Fitness: total score − penalti duplikasi STAPLE/PROTEIN antar 2 hari berurutan

3. **Diversifikasi**: Penalty 2.0 jika food STAPLE/PROTEIN sama muncul dalam 3 hari terakhir

**Goal Weights:**

| Goal | Protein | Fiber | Fat Penalty | Cal Bonus |
|------|---------|-------|-------------|-----------|
| WEIGHT_LOSS | 0.40 | 0.30 | 0.20 | 0.10 |
| MUSCLE_GAIN | 0.50 | 0.10 | 0.10 | 0.30 |
| MAINTENANCE | 0.35 | 0.20 | 0.20 | 0.25 |
| PERFORMANCE | 0.40 | 0.10 | 0.15 | 0.35 |

**Meal Splits (dari `MEAL_SPLITS`):**
- 2 meals: Breakfast 40%, Dinner 60%
- 3 meals: Breakfast 28%, Lunch 40%, Dinner 32%
- 4 meals: Breakfast 22%, Lunch 35%, Snack 10%, Dinner 33%

**Input:**

| Parameter | Tipe | Range | Default |
|-----------|------|-------|---------|
| `tdee` | int | 800-5000 | — |
| `target_calorie_adj` | int | -800 to +800 | 0 |
| `budget_per_day_idr` | int | **min 10.000** | 35.000 |
| `meal_frequency` | int | 2-4 | 3 |
| `goal` | str | — | MAINTENANCE |
| `dietary_restrictions` | list[str] | halal/vegetarian/vegan | [] |
| `excluded_food_ids` | list[int] | — | [] |

**Output:**
```json
{
  "days": [
    {
      "day_index": 0,
      "total_calories": 1720.0,
      "total_protein_g": 92.4,
      "total_fat_g": 48.1,
      "total_carbs_g": 220.3,
      "total_cost_idr": 33500,
      "meals": [
        {
          "meal_type": "BREAKFAST",
          "total_calories": 480.0,
          "total_cost_idr": 9000,
          "foods": [
            { "food_id": 12, "name": "Nasi uduk", "category": "STAPLE", "calories": 250, "protein_g": 5.0, "fat_g": 3.0, "carbs_g": 50.0, "price_idr": 5000, "is_halal": true }
          ]
        }
      ]
    }
  ],
  "diversity_score": 0.78,
  "calorie_coverage_pct": 98.5,
  "algorithm": "knapsack-ga-v3"
}
```

---

### 6.3 Model 3: Adaptive Replanner (XGBoost Regressor)

**File artifact:**
- `replanner_xgb.pkl` — XGBoost Regressor untuk prediksi volume_multiplier

**Cara kerja:**

Input 6 fitur → XGBoost predict → multiplier (di-clamp ke 0.5–1.5) → rule-based action:

| Multiplier | Action | Rekomendasi |
|-----------|--------|-------------|
| < 0.85 | REDUCE | "Kurangi volume X%. Tubuh perlu lebih banyak recovery." |
| 0.85 – 1.10 | MAINTAIN | "Pertahankan ritme yang ada." |
| > 1.10 | INTENSIFY | "Tingkatkan volume X%. Progress bagus!" |

**Input:**

| Parameter | Tipe | Keterangan |
|-----------|------|------------|
| `weekly_score` | float | 0–100 (50% workout + 50% meal compliance) |
| `weight_diff_kg` | float | weightKg − startWeightKg (negatif = turun BB) |
| `bmi` | float | saat ini |
| `experience_level` | int | 1=BEGINNER, 2=INTERMEDIATE, 3=ADVANCED |
| `age` | int | usia user |
| `workout_frequency` | int | frekuensi latihan per minggu yang direncanakan |

**Output:**
```json
{
  "volume_multiplier": 1.10,
  "recommendation": "Tingkatkan volume 10%. Progress bagus, siap untuk tantangan lebih besar!",
  "action": "INTENSIFY",
  "model_version": "xgb-regressor"
}
```

**Setelah ML:** Backend tambah narasi Gemini (2 kalimat personal) sebelum return ke FE.

---

### 6.4 Model 4: Food Scan Analyzer

**Dua tahap:**

#### Tahap 1 — Identifikasi Makanan (Gemini Vision, di ML service)
- Model: `gemini-1.5-flash`
- Input: base64 JPEG/PNG dari kamera
- Prompt: "Identifikasi semua makanan yang terlihat... daftar nama Bahasa Indonesia, satu per baris"
- Output: list nama makanan (mis. ["nasi goreng", "telur ceplok", "es teh"])
- **Aktif hanya jika** `GEMINI_API_KEY` di ml-service `.env` terisi

#### Tahap 2 — Analisis Nutrisi + Health Score (TF-IDF + XGBoost)

**File artifact:**
- `food_tfidf_vectorizer.pkl` — TF-IDF vectorizer nama makanan
- `food_name_matrix.npy` — matrix TF-IDF pre-computed untuk 1.346 item
- `nutrition_scorer.pkl` — XGBoost 3-class classifier (GOOD=2 / MODERATE=1 / POOR=0)
- `scanner_config.json` — label_map, goal_map, condition_map
- `alias_map.json` — normalisasi nama (mis. "nasi gor" → "nasi goreng")
- `food_processed.parquet` — dataset makanan ter-preprocessed

**Matching logic (per food):**
1. Normalize: lowercase, remove accent, strip non-alphanumeric
2. Check alias_map → remap jika ada alias
3. TF-IDF transform → cosine similarity dengan seluruh food matrix
4. Best match jika confidence ≥ 0.20, else null
5. Hitung nutrisi per portion × user-defined portion multiplier

**Health scoring:**
```
X_in = [total_cal, total_protein, total_fat, total_carb,
        jumlah_makanan, goal_encoded, condition_encoded]
→ XGBoost predict → GOOD / MODERATE / POOR + confidence score
```

**Output:**
```json
{
  "identified_by_gemini": ["nasi goreng", "telur ceplok"],
  "matches": [
    { "query": "nasi goreng", "matched": "Nasi goreng kampung", "confidence": 0.91, "calories": 350.0, "protein_g": 12.0, "fat_g": 10.0, "carbs_g": 55.0, "category": "STAPLE", "is_halal": true }
  ],
  "nutrition_total": { "calories": 530.0, "protein_g": 20.0, "fat_g": 18.0, "carbs_g": 62.0 },
  "health_score": 0.72,
  "assessment": "MODERATE",
  "user_goal": "WEIGHT_LOSS",
  "user_condition": "None"
}
```

**Setelah ML:** Backend tambah Gemini advice (2 kalimat: penilaian keseimbangan + tips konkret).

---

## 7. CARA KERJA MICROSERVICE

### 7.1 Komunikasi Antar Service

#### Frontend ↔ Backend
- **Protocol:** HTTPS REST (dev: HTTP)
- **Auth:** `Authorization: Bearer <accessToken>`
- **Base URL (emulator):** `http://10.0.2.2:3000/api/v1`
- **Format:** JSON

#### Backend ↔ ML Service
- **Protocol:** HTTP internal (tidak di-expose ke public)
- **Auth:** Header `X-ML-KEY: <ML_SERVICE_KEY>` — shared secret
- **Port ML:** 8001 (bukan 8000)
- **Format:** JSON
- **Retry:** 2x dengan backoff 300ms → 600ms → 1200ms
- **Timeout:** 10 detik per request

#### Backend ↔ Gemini API (enrichment)
- **Protocol:** HTTPS via `@google/generative-ai` Node SDK
- **Auth:** `GEMINI_API_KEY` — hanya ada di backend, tidak pernah ke FE
- **Model:** `gemini-1.5-flash`
- **Timeout:** 3 detik (fallback statis jika lewat)

#### ML Service ↔ Gemini API (Vision, food-scan only)
- **Protocol:** HTTPS via `google-generativeai` Python SDK
- **Auth:** `GEMINI_API_KEY` — di ml-service `.env`
- **Model:** `gemini-1.5-flash`

### 7.2 Error Mapping

| Kondisi | Backend response ke FE |
|---------|----------------------|
| ML service mati | `502 ML_UNREACHABLE` |
| ML timeout | `502 ML_TIMEOUT` |
| ML response 5xx | `502 ML_ERROR` |
| Gemini error/timeout | fallback statis (tidak error ke FE) |
| Gemini API key kosong | fallback statis (tidak error ke FE) |
| Validation gagal | `400 VALIDATION_ERROR` (Zod) |
| Token expired | `401 TOKEN_EXPIRED` |
| Refresh invalid | `401 REFRESH_INVALID` |

### 7.3 Pre-load Model saat Startup

Semua model di-load saat `FastAPI lifespan` startup (sebelum menerima request pertama). Ini menghindari cold-start latency di request pertama:

```python
@asynccontextmanager
async def lifespan(app):
    _load_models()   # workout XGBoost + scaler + rules
    _load_data()     # meal parquet + knapsack config
    _load()          # replanner XGBoost
    _load()          # food scan: vectorizer + matrix + scorer
    yield
```

---

## 8. GEMINI AI — LAPISAN ENRICHMENT

### 8.1 Filosofi

> **"ML jawab dengan angka, Gemini jawab dengan kata-kata."**

ML model dilatih untuk akurasi numerik. Gemini mengubah output numerik menjadi narasi personal Bahasa Indonesia yang user-friendly, tanpa membebani reliabilitas sistem.

### 8.2 Dual Role Gemini

| Role | Lokasi | Tujuan |
|------|--------|--------|
| **Gemini Vision** | ML service (Python) | Identifikasi nama makanan dari foto kamera |
| **Gemini Text Enrichment** | Backend (Node.js) | Teks personal: motivasi, alasan, narasi mingguan |

### 8.3 4 Method Enrichment (gemini.service.ts)

| Method | Dipanggil saat | Output (maks 2 kalimat) |
|--------|----------------|------------------------|
| `enrichWorkoutComplete(stats)` | Selesai sesi workout | Selamat + tips recovery spesifik |
| `enrichMealRecommendation(food)` | Tiap alternatif di swap meal | Alasan 1 kalimat kenapa cocok untuk goal |
| `enrichReplanNarrative(metrics)` | Hasil weekly replan | Rangkuman minggu + alasan rekomendasi |
| `enrichFoodScanAdvice(scan)` | Hasil food scan | Penilaian keseimbangan + 1 tips konkret |

### 8.4 Reliability

- **Timeout:** 3 detik (env `GEMINI_TIMEOUT_MS`)
- **Fallback:** Template statis Bahasa Indonesia untuk setiap method
- **Tidak pernah throw:** Error di-log (`pino warn`), caller selalu dapat string
- **Tidak pernah blocking:** FE tidak pernah gagal hanya karena Gemini down
- **Prompt design:** Bahasa Indonesia, tanpa emoji, tanpa heading, tanpa list, maks 2 kalimat

### 8.5 Contoh Output Gemini

**enrichWorkoutComplete:**
> "Latihan Strength hari ini selesai dalam 43 menit dengan estimasi 280 kkal terbakar — performa luar biasa! Pastikan minum air cukup dan istirahat minimal 7 jam malam ini untuk pemulihan optimal."

**enrichFoodScanAdvice:**
> "Total 530 kkal dari nasi goreng + telur ceplok memberikan protein cukup, namun lemak mendekati batas atas untuk goal penurunan berat. Tambahkan sayur atau buah sebagai snack sore untuk meningkatkan serat dan kenyang lebih lama."

---

## 9. TECH STACK DETAIL

### 9.1 Frontend (Flutter)

| Kategori | Package | Versi |
|----------|---------|-------|
| SDK | Flutter | 3.x (Dart 3.10+) |
| Routing | go_router | 14.6.2 |
| State | provider + get_it | 6.1.2 + 8.0.3 |
| HTTP | dio | 5.7.0 |
| Storage | shared_preferences + flutter_secure_storage | 2.3.5 + 9.2.4 |
| Charts | fl_chart | 0.70.2 |
| Fonts | google_fonts | 6.2.1 |
| Camera | image_picker + permission_handler | 1.1.2 + 11.3.1 |
| Connectivity | connectivity_plus | 6.1.4 |
| Util | wakelock_plus, share_plus, uuid, intl | latest |

**Target platform:** Android (API 21+), iOS (12+)

### 9.2 Backend (Express.js)

| Kategori | Package | Versi |
|----------|---------|-------|
| Framework | express | 4.19 |
| Language | TypeScript | 5.4 + Node 20 |
| ORM | @prisma/client + prisma | 5.22 |
| Database | MySQL | 8.0 |
| Auth | jsonwebtoken + bcrypt | 9.0 + 5.1 |
| HTTP Client | axios | 1.6 |
| Validation | zod | 3.22 |
| Gemini SDK | @google/generative-ai | 0.24 |
| Logging | pino + pino-http + pino-pretty | 8.x |
| Security | helmet + cors | latest |

**Tidak menggunakan:** Redis, Docker (dev mode lokal), ~~Hive~~

### 9.3 ML Service (FastAPI)

| Kategori | Package | Versi |
|----------|---------|-------|
| Framework | fastapi + uvicorn | 0.111 + 0.30 |
| ML | scikit-learn + xgboost | latest |
| Data | pandas + numpy + pyarrow | latest |
| Genetic Algo | deap | 1.4.1 |
| Gemini Vision | google-generativeai | 0.7.0 |
| Serialization | pydantic + pydantic-settings | 2.7 + 2.3 |
| Performance | joblib + ujson | 1.4.2 + 5.10 |

**Port:** 8001  
**Startup:** pre-load semua model via `lifespan` event

---

## 10. DATABASE SCHEMA

### 10.1 Overview (19 Tabel)

**Core Users**
- `users` — id, email, password_hash, name, avatar_url, last_login_at
- `health_profiles` — age, gender, height_cm, weight_kg, start_weight_kg, target_weight_kg, fitness_level, goal, workout_mode, budget_per_day_idr, health_conditions (JSON), dietary_restrictions (JSON)
- `settings` — theme (LIGHT/DARK/SYSTEM), language, timezone, notification prefs
- `refresh_tokens` — token_hash (SHA256), expires_at, revoked_at
- `fcm_tokens` — FCM push token per device (ANDROID/IOS/WEB)

**Plans**
- `workout_plans` — id, name, start_date, end_date, status, is_active, ml_metadata (JSON)
- `workout_days` — day_number, date, workout_type, intensity, is_completed
- `exercises` — name, category (WARMUP/MAIN/COOLDOWN), sets, reps, rest_sec, order_index
- `exercise_master` — library latihan (slug, muscle_groups, equipment, video_url, instructions)
- `meal_plans` — target_calories_per_day, target_protein_g, budget_per_day_idr
- `meal_days` — day_number, date, total_calories, total_cost_idr
- `meal_times` — meal_type (BREAKFAST/LUNCH/DINNER/SNACK), is_logged
- `food_items` — name, portion, calories, protein_g, carbs_g, fat_g, estimated_cost_idr
- `food_master` — library makanan (category, is_halal, is_vegetarian, image_url)

**Sessions & Logs**
- `workout_sessions` — started_at, completed_at, duration_sec, calories_burned, effort_score, mood_before, energy_before, sleep_band_before, status (IN_PROGRESS/COMPLETED/ABANDONED)
- `exercise_logs` — set_number, reps_actual, weight_kg, duration_actual_sec, is_completed
- `meal_logs` — logged_at, actual_portion_gram (unique: userId + mealTimeId + foodItemId)
- `daily_logs` — date, workout_completed, meals_logged_count, water_glasses, mood, calories_consumed, calories_burned (unique: userId + date)
- `streaks` — current_streak, best_streak, last_active_date, active_dates (JSON array)

**Gamifikasi & Sosial**
- `badges` — code, title, description, icon_name, category, criterion_type, criterion_value
- `user_badges` — userId + badgeId + unlocked_at
- `notifications` — type, title, body, action_url, is_read
- `sync_ops_log` — op_id, op_type, status (OK/DUPLICATE/CONFLICT/ERROR), result_snapshot

### 10.2 Enums

| Enum | Values |
|------|--------|
| Gender | M, F, OTHER |
| FitnessLevel | BEGINNER, INTERMEDIATE, ADVANCED |
| Goal | WEIGHT_LOSS, MUSCLE_GAIN, MAINTENANCE, PERFORMANCE |
| WorkoutMode | HOME, GYM, HYBRID |
| WorkoutType | STRENGTH, CARDIO, HIIT, FLEXIBILITY, REST |
| Intensity | LOW, MID, HIGH |
| MealType | BREAKFAST, LUNCH, DINNER, SNACK |
| SessionStatus | IN_PROGRESS, COMPLETED, ABANDONED |
| PlanStatus | ACTIVE, COMPLETED, ARCHIVED, SKIPPED |
| Theme | LIGHT, DARK, SYSTEM |
| BadgeCategory | STREAK, MILESTONE, GOAL, SPECIAL |
| BadgeCriterion | STREAK, WORKOUTS_DONE, WEIGHT_LOST, MEALS_LOGGED, CUSTOM |

---

## 11. API ENDPOINTS

### Auth (`/api/v1/auth`)

| Method | Path | Auth | Keterangan |
|--------|------|------|------------|
| POST | `/register` | public | Register + return accessToken + refreshToken |
| POST | `/login` | public | Login + update last_login_at |
| GET | `/me` | JWT | User + healthProfile |
| POST | `/logout` | JWT | Revoke refreshToken di DB |
| POST | `/refresh-token` | public | Token rotation (SHA256 hash, revoke lama) |
| POST | `/forgot-password` | public | Dev: return token; prod: kirim email |
| POST | `/reset-password` | public | (stub 501 untuk demo) |

### User (`/api/v1/user`) — semua require JWT

| Method | Path | Keterangan |
|--------|------|------------|
| GET | `/profile` | User + healthProfile |
| PUT | `/profile` | Update name / avatarUrl |
| PATCH | `/profile/avatar` | Update avatarUrl |
| POST | `/health-profile` | Buat profil (trigger sebelum generate plan) |
| PUT | `/health-profile` | Update partial |
| GET | `/health-metrics` | BMI/weight saat ini |
| POST | `/health-metrics` | Log berat baru → update DB + daily_logs |
| GET | `/health-metrics/history` | 30 hari terakhir dari daily_logs |
| DELETE | `/account` | Soft delete |

### Plan (`/api/v1/plan`) — semua require JWT

| Method | Path | Keterangan |
|--------|------|------------|
| POST | `/generate` | Baca profil → ML workout+meal → persist DB → return |
| GET | `/active` | Ambil plan aktif (workout + meal) |
| GET | `/history` | 20 plan terakhir |
| GET | `/:planId` | Detail plan dengan nested days |
| POST | `/replan` | 7-day metrics → ML → Gemini narrative → optional generate baru |
| POST | `/replan/skip` | User lewati replan |

### Workout (`/api/v1/workout`) — semua require JWT

| Method | Path | Keterangan |
|--------|------|------------|
| GET | `/today` | Workout hari ini |
| GET | `/day/:dayId` | Detail day + exercises |
| GET | `/exercise/:exerciseId` | Detail exercise + master (video/tips) |
| POST | `/:dayId/check-in` | Buat sesi, hitung intensity multiplier |
| PATCH | `/session/:sessionId/exercise` | Log satu set (reps/weight/duration) |
| POST | `/session/:sessionId/pause` | Catat pause di notes |
| POST | `/session/:sessionId/complete` | Selesai → stats + Gemini motivasi + badge |
| GET | `/session/:sessionId` | Detail sesi |
| GET | `/sessions` | History sesi (limit query param) |
| POST | `/exercise/:exerciseId/swap` | Ganti exercise |

### Meal (`/api/v1/meal`) — semua require JWT

| Method | Path | Keterangan |
|--------|------|------------|
| GET | `/today` | Meal hari ini (meal_day + meal_times + foods) |
| GET | `/day/:dayId` | Detail meal day |
| GET | `/:mealId` | Detail satu meal_time |
| POST | `/:mealId/log` | Catat sudah makan → update daily_logs + badge check |
| POST | `/:mealId/swap` | ML alternatives → Gemini reason → return top 3 |
| POST | `/:mealId/replace` | Apply alternatif pilihan user |
| GET | `/food/:foodId` | Detail food item |
| GET | `/log` | History log (days query param) |
| PUT | `/budget` | Update budget harian (min Rp 10.000) |
| **POST** | **/food-scan** | **Image → Gemini Vision → TF-IDF → XGBoost → Gemini advice** |

### Progress (`/api/v1/progress`) — semua require JWT

| Method | Path | Keterangan |
|--------|------|------------|
| GET | `/daily` | Daily log hari ini (atau ?date=YYYY-MM-DD) |
| PATCH | `/daily/water` | Update gelas air ({glasses} atau {delta}) |
| POST | `/daily/mood` | Log mood hari ini |
| GET | `/weekly` | 7-day aggregate + daily breakdown |
| GET | `/weekly-review` | Weekly + weight diff + goal context |
| GET | `/streak` | Current streak + best + active dates |
| GET | `/badges` | Semua badge + isUnlocked flag |
| GET | `/badge/:code` | Detail satu badge |
| GET | `/share-image` | Payload untuk share (URL null, render di FE) |

### Settings (`/api/v1/settings`) — require JWT

| Method | Path | Keterangan |
|--------|------|------------|
| GET | `/` | Get settings (auto-create jika belum ada) |
| PUT | `/` | Update theme / language / reminder times |

### Notifications (`/api/v1/notifications`) — require JWT

| Method | Path | Keterangan |
|--------|------|------------|
| GET | `/` | List notifikasi (?unreadOnly=true) + unreadCount |
| PATCH | `/:id/read` | Mark satu notif as read |
| PATCH | `/read-all` | Mark semua as read |
| POST | `/fcm-token` | Register FCM token device |
| DELETE | `/fcm-token` | Hapus FCM token |

### Sync (`/api/v1/sync`) — require JWT

| Method | Path | Keterangan |
|--------|------|------------|
| POST | `/batch` | Idempotent batch sync dari offline queue |

**Sync opType yang didukung:** `log_meal`, `update_water`, `log_mood`, `complete_session`, `update_exercise_log`

---

## 12. FRONTEND MOBILE FLUTTER

### 12.1 Struktur Layar (Screen Groups)

| Group | Files | Keterangan |
|-------|-------|------------|
| `splash/` | `splash_screen.dart`, `onboarding_screen.dart` | Boot + 3-slide onboarding |
| `auth/` | `login_screen.dart`, `register_screen.dart`, `forgot_password_screen.dart` | Auth flow |
| `setup/` | `setup_basic_info_screen.dart`, `setup_physical_screen.dart`, `setup_bmi_result_screen.dart`, `setup_goal_screen.dart`, `setup_conditions_screen.dart`, `setup_fitness_level_screen.dart`, `setup_preferences_screen.dart` | 7-step onboarding |
| `home/` | `home_screen.dart` | Dashboard utama |
| `plan/` | `plan_generating_screen.dart`, `plan_ready_screen.dart` | Generate + preview plan |
| `workout/` | `workout_list_screen.dart`, `workout_detail_screen.dart`, `exercise_detail_screen.dart`, `pre_workout_checkin_screen.dart`, `active_workout_screen.dart`, `workout_complete_screen.dart`, `workout_session_detail_screen.dart` | Session lifecycle |
| `meal/` | `meal_list_screen.dart`, `meal_detail_screen.dart`, `meal_log_screen.dart`, `meal_swap_screen.dart`, `food_item_detail_screen.dart`, `budget_settings_screen.dart`, `food_scan_screen.dart` | Meal flow + kamera |
| `progress/` | `progress_screen.dart`, `weekly_review_screen.dart`, `streak_detail_screen.dart`, `badge_gallery_screen.dart` | Progress + gamifikasi |
| `replanning/` | `replanning_update_data_screen.dart` | Weekly replan |
| `notification/` | `notification_list_screen.dart` | Notifikasi |
| `profile/` | `profile_screen.dart`, `edit_profile_screen.dart`, `health_metrics_screen.dart` | Profil user |
| `settings/` | `settings_screen.dart` | Theme toggle (SYSTEM/LIGHT/DARK) + preferences |
| `main/` | `main_scaffold.dart` | Bottom nav wrapper |
| `error/` | `not_found_screen.dart` | 404 |

### 12.2 State Management

- **`ThemeProvider`** — WidgetsBindingObserver, sinkronisasi `AppColors.setBrightness()`, persist ke SharedPreferences
- **Provider** — state reactive per feature
- **GetIt** — dependency injection service locator

### 12.3 Adaptive Theme

- `AppColors` — semua warna surface/text/border sebagai `static Color get` (dievaluasi ulang tiap build)
- Light mode: background `#F5F7FA`, surface `#FFFFFF`, teal primary `#1D6766`
- Dark mode: background `#0D0D0D`, surface `#1A1A1A`, teal primary sama
- Toggle di settings: SISTEM / TERANG / GELAP
- `AppTextStyles` — semua sebagai `static TextStyle get` (bukan const) agar warna ikut mode

### 12.4 Fitur Camera (Food Scan)

- `image_picker: ^1.1.2` — ambil dari kamera atau galeri
- `permission_handler: ^11.3.1` — request CAMERA, READ_MEDIA_IMAGES
- AndroidManifest: `android.permission.CAMERA`, `READ_MEDIA_IMAGES`, `READ_EXTERNAL_STORAGE` (maxSdk 32)
- FE compress → base64 → `POST /api/v1/meal/food-scan { imageBase64 }`

### 12.5 Responsivitas

- Adaptive font size dan image ratio berdasarkan `constraints.maxHeight` di LayoutBuilder
- `FittedBox(fit: BoxFit.scaleDown)` untuk teks di tombol/chip agar tidak clipping
- `GridView childAspectRatio` dikalibrasi per card untuk menghindari overflow
- `SingleChildScrollView` di halaman konten panjang

---

## 13. SYNC & OFFLINE QUEUE

### 13.1 Arsitektur

Heltigo menggunakan pola **optimistic offline queue** sederhana:

1. **FE enqueue**: Saat offline, simpan operasi dengan UUID ke antrian lokal
2. **FE drain**: Saat online kembali (`connectivity_plus`), kirim ke `POST /sync/batch`
3. **BE idempotent**: Backend check `sync_ops_log` — duplikat dikembalikan hasil lama (DUPLICATE), tidak di-execute ulang
4. **BE dispatch**: Setiap op diteruskan ke service yang sesuai

### 13.2 opType yang Didukung

| opType | Diteruskan ke |
|--------|--------------|
| `log_meal` | `mealService.logMeal` |
| `update_water` | `progressService.updateWater` |
| `log_mood` | `progressService.logMood` |
| `complete_session` | `workoutService.completeSession` (include Gemini enrich) |
| `update_exercise_log` | `workoutService.updateExerciseLog` |

### 13.3 Format Request

```json
{
  "operations": [
    { "opId": "<uuid-v4>", "opType": "log_meal", "payload": { "mealId": "123", "foodItemId": "456" } },
    { "opId": "<uuid-v4>", "opType": "update_water", "payload": { "delta": 1 } }
  ]
}
```

### 13.4 Fitur yang Berfungsi Tanpa Internet (FE Side)

| Fitur | Status |
|-------|--------|
| Lihat plan workout & meal (data ter-cache) | ✅ |
| Active workout timer (local) | ✅ |
| Kalkulasi BMI/BMR/TDEE (pure Dart) | ✅ |
| Log exercise set (enqueue sync) | ✅ |
| Log meal (enqueue sync) | ✅ |
| Update water (enqueue sync) | ✅ |

| Fitur yang Butuh Online | Status |
|------------------------|--------|
| Register / Login | ❌ |
| Generate plan pertama (butuh ML) | ❌ |
| Food Scan kamera (butuh Gemini + ML) | ❌ |
| Meal swap alternatives | ❌ |
| Weekly replan | ❌ |

---

## 14. GAMIFIKASI & MOTIVASI

### 14.1 Streak System

- Streak increment: setiap `POST /workout/session/:id/complete` yang sukses
- Cek consecutive via `workoutService._updateStreak()`: compare `lastActiveDate` dengan yesterday
- Reset ke 1 jika tidak consecutive
- Data: `streaks.currentStreak`, `streaks.bestStreak`, `streaks.activeDates` (JSON array tanggal)

### 14.2 Badge System

**Kriteria auto-check setelah:** complete workout dan log meal

| BadgeCriterion | Trigger |
|---------------|---------|
| STREAK | currentStreak ≥ criterionValue |
| WORKOUTS_DONE | total completed sessions ≥ criterionValue |
| MEALS_LOGGED | total meal logs ≥ criterionValue |
| WEIGHT_LOST | startWeightKg − currentWeightKg ≥ criterionValue |

Badge unlock → insert `user_badges` → response include `newBadges` array (animasi di FE)

### 14.3 Motivasi AI (Gemini)

Setiap milestone memicu Gemini text yang personal:
- Selesai workout → pesan selamat + tips recovery
- Swap meal → penjelasan kenapa alternatif ini cocok untuk goal
- Weekly replan → rangkuman performa + alasan tindak lanjut
- Food scan → penilaian keseimbangan gizi + tips konkret

---

## 15. CARA MENJALANKAN

### 15.1 Prerequisites

- Node.js 20+, npm
- Python 3.11+, pip
- MySQL 8.0 (XAMPP/standalone)
- Flutter SDK 3.x (Dart 3.10+)
- Android Studio / Android emulator (API 21+)

### 15.2 Setup ML Service

```powershell
cd machine-learning\ml-service
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt

# Buat .env (dari .env.example)
# Isi ML_SERVICE_KEY dan GEMINI_API_KEY (dari aistudio.google.com/apikey)
```

### 15.3 Setup Backend

```powershell
cd backend
npm install    # termasuk @google/generative-ai

# Buat .env dari .env.example:
# DATABASE_URL=mysql://root:@localhost:3306/heltigo
# JWT_SECRET=<min 32 char>
# ML_SERVICE_URL=http://localhost:8001
# ML_SERVICE_KEY=<sama dengan ml-service>
# GEMINI_API_KEY=<sama atau terpisah>

npx prisma migrate dev    # buat semua 19 tabel
```

### 15.4 Menjalankan (3 terminal)

```powershell
# Terminal 1 — ML Service (port 8001)
cd machine-learning\ml-service
.\.venv\Scripts\Activate.ps1
uvicorn main:app --reload --port 8001

# Terminal 2 — Backend (port 3000)
cd backend
npm run dev

# Terminal 3 — Flutter (emulator/device)
cd frontend\heltigo
flutter run
```

### 15.5 Sanity Check

```powershell
# Health check
curl http://localhost:8001/health    # ML: { "status": "ok", "models": {...} }
curl http://localhost:3000/health    # BE: { "status": "ok" }

# Test auth
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"testpass123","name":"Test"}'
```

### 15.6 Environment Variables Lengkap

**backend/.env:**
```ini
NODE_ENV=development
PORT=3000
DATABASE_URL=mysql://root:@localhost:3306/heltigo
JWT_SECRET=supersecretjwtkey_minimum_32_chars_long
JWT_ACCESS_EXPIRES=900s
JWT_REFRESH_EXPIRES=604800s
BCRYPT_ROUNDS=12
ML_SERVICE_URL=http://localhost:8001
ML_SERVICE_KEY=shared-secret-with-fastapi
GEMINI_API_KEY=                    # dari aistudio.google.com/apikey
GEMINI_MODEL=gemini-1.5-flash
GEMINI_TIMEOUT_MS=3000
CORS_ORIGINS=http://localhost:*,http://10.0.2.2:*
LOG_LEVEL=debug
```

**machine-learning/ml-service/.env:**
```ini
ML_SERVICE_KEY=shared-secret-with-fastapi
GEMINI_API_KEY=                    # untuk Gemini Vision di food-scan
PORT=8001
```

---

*Dokumentasi ini mencerminkan state sistem pada 17 Mei 2026 sesuai implementasi aktual. Dibuat untuk keperluan MSU iREX 2026 — Hackathon Core3D.*

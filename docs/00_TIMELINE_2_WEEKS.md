# Heltigo — Timeline 2 Minggu (Day 1–14)

**Mulai:** 2026-05-07 (Day 1)
**Demo deadline:** 2026-05-21 (Day 14)
**Buffer:** Sabtu–Minggu untuk catch-up.

Format kanban harian: setiap hari punya checklist 3 tim. Centang `[x]` saat selesai. Jika geser, tulis catatan di kolom paling kanan.

Kode prioritas: **P0** wajib demo, **P1** untuk UX lengkap, **P2** enhancement.

---

## WEEK 1 — Foundation + UI Mock

### Day 1 — 2026-05-07 (Selasa)

**Mobile FE (Flutter)**
- [ ] Init Flutter project di `frontend/heltigo/` (Flutter 3.x stable)
- [ ] Setup folder `lib/core/`, `lib/features/`, `lib/shared/` (lihat `frontend/02_PROJECT_STRUCTURE.md`)
- [ ] `lib/core/theme/app_colors.dart` (light + dark palette dari `Heltigo_UI_Screens.docx` §1.1-1.2)
- [ ] `lib/core/theme/app_sizes.dart` (xs/sm/md/base/lg/xl/xxl)
- [ ] `lib/core/theme/app_text_styles.dart` (Display/H1/H2/H3/Body/Caption + Inter via `google_fonts`)
- [ ] `lib/core/theme/app_theme.dart` (ThemeData light & dark)
- [ ] Setup Riverpod root: wrap `MyApp` dengan `ProviderScope`

**Backend (Express)**
- [ ] Init Node project di `backend/` (TypeScript opsional, JS murni juga ok)
- [ ] Setup Express + `dotenv` + `cors` + `helmet` + `morgan`
- [ ] Setup MySQL via Docker compose (`docker-compose.yml` dengan service `db`)
- [ ] Pilih ORM: **Prisma** (recommended) atau Sequelize
- [ ] `prisma/schema.prisma` skeleton: User, UserProfile (lihat `backend/03_DATABASE_SCHEMA.md`)
- [ ] `npx prisma migrate dev --name init` → migrasi v1

**ML (Python)**
- [ ] Eksplorasi `notebook/dataset/`: identifikasi field tiap dataset
- [ ] `notebook/01_eda_workout.ipynb`: EDA gym_member_exercise_dataset
- [ ] `notebook/02_eda_nutrition.ipynb`: EDA Indonesian Food & Drink
- [ ] Catat data quality issues di `docs/machine-learning/02_DATASETS.md`

---

### Day 2 — 2026-05-08 (Rabu)

**Mobile FE**
- [ ] Komponen reusable di `lib/shared/widgets/`:
  - `primary_button.dart`, `secondary_button.dart`, `heltigo_card.dart`
  - `input_field.dart`, `status_chip.dart`
- [ ] Setup GoRouter di `lib/core/router/app_router.dart`
- [ ] Skeleton routes untuk semua S-01..S-35 (placeholder Scaffold per screen)
- [ ] Smoke run: `flutter run` di emulator → app menampilkan splash placeholder

**Backend**
- [ ] Endpoint `POST /v1/auth/signup` (validasi email, hash password bcrypt)
- [ ] Endpoint `POST /v1/auth/login` (verify password, sign JWT)
- [ ] Endpoint `GET /v1/auth/me` (protected, return user)
- [ ] Middleware `requireAuth` (verify JWT, attach `req.user`)
- [ ] Smoke test dengan `curl` atau REST Client extension

**ML**
- [ ] Cleaning `gym_members_exercise_dataset.csv`: handle missing, encode kategorikal
- [ ] Cleaning `nutrition.csv`: parsing kolom kalori/protein/karbo/lemak (sering string), validasi nilai
- [ ] `notebook/03_clean_workout.ipynb`, `notebook/04_clean_nutrition.ipynb`
- [ ] Simpan cleaned dataset ke `notebook/dataset/clean/`

---

### Day 3 — 2026-05-09 (Kamis)

**Mobile FE — Onboarding (P0)**
- [ ] S-01 SplashScreen (Lottie / fade animation, primary bg, 2.5 detik)
- [ ] S-02 Onboarding Slide 1 (AI Personal — badge, judul, deskripsi, dot indicator)
- [ ] S-03 Onboarding Slide 2 (Hemat Budget — feature chips)
- [ ] S-04 Onboarding Slide 3 (Offline & Privasi — 3 feature cards)
- [ ] S-05 Welcome / Auth Screen (gradient, kartu bawah, tombol)
- [ ] PageView controller untuk swipe slide

**Backend**
- [ ] Endpoint `POST /v1/profile` (create user_profile)
- [ ] Endpoint `GET /v1/profile`, `PUT /v1/profile`
- [ ] Server-side BMI/BMR/TDEE calculator di `services/health.service.js` (lihat `backend/07_BUSINESS_LOGIC.md`)
- [ ] Validasi input dengan Zod atau express-validator

**ML**
- [ ] Train baseline Random Forest workout classifier
  - Fitur: bmi, gender, age, level, mode (home/gym), session_minutes
  - Target: workout_type (cardio/strength/yoga/hiit)
- [ ] Eval: accuracy, classification report → simpan di `notebook/05_train_workout.ipynb`
- [ ] Simpan model: `ml-service/models/workout_rf_v1.joblib`

---

### Day 4 — 2026-05-10 (Jumat)

**Mobile FE — Setup Profile (P0)**
- [ ] Layout shared setup screen (AppBar transparan, progress bar, step label, scrollable, sticky tombol bawah)
- [ ] S-06 Setup Step 1: Data Dasar (nama, usia, gender 2-card)
- [ ] S-07 Setup Step 2: Data Fisik (slider tinggi/berat, lingkar pinggang opsional)
- [ ] S-08 Setup Step 3: Hasil BMI (BMI Card gradient, 4 metric grid, BMI Scale Visual)
- [ ] Implementasi formula di `lib/features/profile/services/health_calculator.dart`

**Backend**
- [ ] Tabel `weekly_plans`, `workouts`, `meals` di Prisma schema (migrasi v2)
- [ ] Endpoint stub `POST /v1/plan/generate` (return mock plan dummy)
- [ ] Endpoint stub `GET /v1/plan/current`

**ML**
- [ ] Tune hyperparameter RF (GridSearchCV: n_estimators, max_depth)
- [ ] Re-train dengan best params
- [ ] Simpan: `ml-service/models/workout_rf_v2.joblib`

---

### Day 5 — 2026-05-11 (Sabtu)

**Mobile FE — Setup Profile lanjutan (P0)**
- [ ] S-09 Setup Step 4: Target Kesehatan (3 goal cards, slider timeline, kalori card)
- [ ] S-10 Setup Step 5: Kondisi Khusus (CheckboxList, info card amber)
- [ ] S-11 Setup Step 6: Preferensi Latihan (mode, hari/minggu, durasi, waktu favorit, level)
- [ ] S-12 Setup Step 7: Diet & Budget (toggle IDR/MYR, input, quick chips, frekuensi, pantangan)
- [ ] S-13 Setup Step 8: AI Processing (Lottie + step labels rotating + progress bar)
- [ ] S-14 Plan Ready (animasi konfeti, ringkasan latihan, makan, target, tombol Mulai)

**Backend**
- [ ] Tabel `food_items` di MySQL → seeder dari `nutrition.csv`
- [ ] Tabel `exercise_items` → seeder dari `gym_member_exercise` + `600K+ exercises`
- [ ] Script `prisma/seed.ts` untuk populate

**ML**
- [ ] Implementasi knapsack meal optimizer di `ml-service/optimizers/meal_knapsack.py`
- [ ] Input: food_items list (price, calorie, protein, carb, fat), budget_max, target_macro
- [ ] Output: pilihan kombinasi makanan optimal
- [ ] Smoke test dengan dataset Indonesian food

---

### Day 6 — 2026-05-12 (Minggu)

**Mobile FE — Home Dashboard (P0)**
- [ ] S-15 Home Screen lengkap dengan mock data dari Hive
- [ ] AppBar greeting dinamis (Pagi/Siang/Sore/Malam berdasarkan jam)
- [ ] Stats sticky bar (kalori sisa, hidrasi, streak)
- [ ] Card Latihan Hari Ini gradient hijau + tombol Mulai orange
- [ ] Card Makan Hari Ini (3 waktu makan + status)
- [ ] Ringkasan Makro (4 progress bar berwarna)
- [ ] Streak Card (purpleLight + flame icon)
- [ ] Jadwal Minggu (horizontal scroll 7 chip)
- [ ] Pull-to-refresh

**Backend**
- [ ] `GET /v1/plan/current` return real data dari MySQL (mock plan dari setup)

**ML — FastAPI Scaffold**
- [ ] Init project di `ml-service/` dengan `FastAPI`, `uvicorn`, `pydantic`, `joblib`
- [ ] `main.py`: app instance + `/healthz`
- [ ] Endpoint `POST /infer/workout` (load model joblib + return prediksi)
- [ ] Pydantic schemas di `ml-service/schemas/workout.py`
- [ ] Smoke test: `curl localhost:8001/infer/workout`

---

### Day 7 — 2026-05-13 (Senin)

**Mobile FE — Workout Tab (P0)**
- [ ] S-16 Workout Home: Week navigator, 7-day list, stats grid 2x2, FAB
- [ ] S-17 Workout Day: Header card, fase section (pemanasan/utama/pendinginan), exercise list dengan checkbox

**Backend**
- [ ] Endpoint `POST /v1/workout/checklist` (toggle complete satu exercise)
- [ ] Endpoint `POST /v1/progress/weight` (catat berat baru)
- [ ] Endpoint `GET /v1/progress/summary` (agregasi untuk dashboard)

**ML**
- [ ] Endpoint `POST /infer/meal` di FastAPI (panggil knapsack optimizer)
- [ ] Endpoint `POST /infer/replan` di FastAPI (rule-based skor 3-cabang sementara)
- [ ] Pydantic schemas lengkap

---

## WEEK 2 — Integration + Adaptive + Polish

### Day 8 — 2026-05-14 (Selasa)

**Mobile FE — Active Workout (P0)**
- [ ] S-19 Pre-Workout Check-in: Mood selector 5 emoji, energy selector, sleep chip, AI preview card
- [ ] S-20 Active Workout Screen: Fullscreen, timer 56sp, exercise card, rest timer countdown, 3 kontrol button (prev/pause/next), progress bar
- [ ] S-21 Workout Complete: Lottie konfeti, stats row, perbandingan vs minggu lalu, badge baru, streak

**Backend**
- [ ] Integrasi Express → FastAPI: `POST /v1/plan/generate` orchestrate panggilan ke `/infer/workout` dan `/infer/meal`
- [ ] HTTP client `services/ml.client.js` (axios + retry + timeout 10s)
- [ ] Header `X-ML-KEY` shared secret

**ML**
- [ ] Smoke test 3 endpoint dari Express (Postman/curl)
- [ ] Eval akhir akurasi RF, knapsack benchmark

---

### Day 9 — 2026-05-15 (Rabu)

**Mobile FE — Nutrition Tab (P0)**
- [ ] S-22 Nutrition Home: Date navigator, budget card gradient orange, makro summary, meal sections, hydration card
- [ ] S-23 Meal Detail: Header card, food list, nutrition breakdown, AI explanation card, tombol "Tandai Selesai" + "Minta Alternatif"
- [ ] S-24 Food Item Detail: Image placeholder, harga card, nutrition facts donut chart, konteks AI
- [ ] S-25 Budget Settings: Quick chips, preview real-time, toggle IDR/MYR

**Backend**
- [ ] Endpoint `POST /v1/plan/generate` final (real call ke FastAPI, simpan ke MySQL)
- [ ] Endpoint `POST /v1/nutrition/checklist` (toggle meal complete)
- [ ] Endpoint `POST /v1/nutrition/alternative` (minta alternatif → call FastAPI lagi dengan exclude list)

**ML**
- [ ] Dockerfile FastAPI
- [ ] `docker-compose.yml` integrasi: db (MySQL) + api (Express) + ml (FastAPI) di network sama

---

### Day 10 — 2026-05-16 (Kamis)

**Mobile FE — Progress Tab (P0)**
- [ ] S-26 Progress Dashboard: Target card gradient, line chart fl_chart, stats grid 2x2, streak card mini calendar, shortcuts row
- [ ] S-27 Add Weight (modal bottom sheet): Tanggal, input berat, catatan, preview delta

**Backend**
- [ ] node-cron job: setiap Sunday 20:00 jalankan replanning untuk semua user dengan plan aktif
- [ ] Service `services/replanning.service.js`: hitung skor, panggil `/infer/replan`, simpan plan baru
- [ ] Endpoint manual trigger `POST /v1/plan/replan` (untuk demo non-Sunday)

**ML**
- [ ] Refine replanner: skor <50% → reduce volume; 50-80% → swap; >80% → increase
- [ ] Edge cases: user baru tanpa data minggu lalu, plan kosong

---

### Day 11 — 2026-05-17 (Jumat)

**Mobile FE — Progress Polish (P1)**
- [ ] S-28 Achievement Badges: Counter, filter chips, grid 3 kolom, bottom sheet detail badge
- [ ] S-29 Weekly Report: Header card lingkaran progress, latihan section bar chart, nutrisi section, berat grafik, AI rekomendasi card

**Backend**
- [ ] Endpoint `GET /v1/report/weekly?week=N`: agregasi SQL untuk weekly report
- [ ] Logic perhitungan skor kepatuhan, latihan paling sering diskip

**ML**
- [ ] Joint smoke test end-to-end: full demo flow dari setup sampai weekly report

---

### Day 12 — 2026-05-18 (Sabtu)

**Mobile FE — Profile + Settings (P1)**
- [ ] S-30 Profile Screen: Header gradient, stats row, info card, menu list, version
- [ ] S-31 Edit Profile: Fields data dasar+fisik, BMI realtime, warning ubah goal
- [ ] S-32 Notification Settings: Master switch, per-jenis switch + TimePicker, dropdown frekuensi
- [ ] S-33 App Settings (P2 — skip jika tipis): Dark mode toggle, satuan, bahasa, reset, ekspor, tentang

**Backend**
- [ ] Endpoint `POST /v1/sync/batch` (terima array sync_queue, idempotent dengan UUID)
- [ ] Konflik resolution: last-write-wins per item

**ML**
- [ ] Stand by, pastikan service stabil

---

### Day 13 — 2026-05-19 (Minggu)

**Mobile FE — Replanning + Wiring**
- [ ] S-34 Weekly Review Modal: Auto modal Sunday 20:00 (atau manual trigger), gradient header, lingkaran progress, breakdown, AI analisis card, processing bar
- [ ] S-35 New Plan Ready: Konfeti, perubahan AI list, preview 7 hari, target update, motivasi
- [ ] Integrasi Dio + JWT interceptor, auto refresh token
- [ ] Implementasi sync queue Hive: deteksi connectivity → drain queue
- [ ] flutter_local_notifications: pengingat makan, latihan, hidrasi, weekly report

**Backend**
- [ ] Bug fix berdasarkan integration test
- [ ] Load test ringan (10 concurrent users via k6 atau wrk)

**ML**
- [ ] Bug fix, stress test inference latency (target <500ms per request)

---

### Day 14 — 2026-05-20 (Senin) — POLISH & DEMO

**All teams**
- [ ] Polish dark mode QA (cek semua 35 layar di dark mode)
- [ ] Demo data: seed 1 akun demo dengan plan minggu 1-3 sudah ada (untuk progress chart penuh)
- [ ] Record video demo end-to-end (3-5 menit) sebagai backup jika live demo bermasalah
- [ ] Build APK release (`flutter build apk --release`)
- [ ] Deploy Express ke Railway (atau staging final)
- [ ] Deploy FastAPI ke Render (atau staging final)
- [ ] Smoke test live: signup baru → setup → plan → workout → report

**Demo deadline:** 2026-05-21 (Day 15) — submit / present.

---

## Buffer & Catatan

- Sabtu D5, D12 dan Minggu D6, D13 adalah hari kerja — disesuaikan dengan ritme tim hackathon (biasanya intensif).
- Jika slip 1 hari, geser P1 (S-28, S-29 polish, S-32, S-33) ke buffer Day 14.
- Jika slip 2+ hari, **prioritas tertinggi** yang harus tetap selesai (jangan dikorbankan):
  1. Setup profile flow lengkap (S-06..S-14) — cerita demo dimulai dari sini
  2. Plan generate dari Express → FastAPI → response cepat
  3. Active Workout (S-20) — wow factor saat demo
  4. Nutrition Home (S-22) — highlight novelty budget + lokal Indonesia
- Boleh dipotong jika sangat tipis: S-24 (Food Item Detail), S-28 (Badges), S-33 (App Settings).

---

## Sumber Cross-Reference

- Spec layar: `docs/frontend/05_SCREENS_SPEC.md`
- API contract: `docs/backend/04_API_ENDPOINTS.md`
- ML contract: `docs/machine-learning/06_SERVING_FASTAPI.md`
- Risiko: `docs/00_MASTER_PLAN.md` §6

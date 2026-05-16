# Heltigo — Arsitektur Sistem

**Status dokumen:** v1.0 — 2026-05-07
**Berlaku sejak:** Sprint 2 minggu MSU iREX 2026

---

## 1. Diagram Arsitektur 3-Tier

```
┌──────────────────────────┐
│   FLUTTER MOBILE APP     │
│   (Android & iOS)        │
│                          │
│  Riverpod (state)        │
│  Hive (cache lokal)      │
│  Dio (HTTP client)       │
│  flutter_local_           │
│   notifications          │
│  fl_chart (grafik)       │
└─────────────┬────────────┘
              │ HTTPS + JWT (Bearer)
              ▼
┌──────────────────────────┐
│   EXPRESS.JS API         │       ┌────────────────────────┐
│   (Node 20+)             │       │   PYTHON FastAPI       │
│                          │       │   ML INFERENCE SERVICE │
│  /auth/* (signup,login)  │ HTTP  │                        │
│  /profile (CRUD)         │ ───▶  │  /infer/workout        │
│  /plan/* (generate,get)  │  X-   │  /infer/meal           │
│  /workout/* (logs)       │  ML-  │  /infer/replan         │
│  /nutrition/* (logs)     │  KEY  │  /healthz              │
│  /progress/* (weight)    │       │                        │
│  /report/* (weekly)      │       │  scikit-learn models   │
│                          │       │  (.joblib)             │
│  node-cron (Sun 20:00)   │       │  knapsack optimizer    │
└─────────────┬────────────┘       └────────────────────────┘
              │
              ▼
        ┌──────────┐
        │  MySQL   │
        │  (DB)    │
        └──────────┘
```

**Tiga tier dipisah karena:**
- Express.js cepat untuk REST API + auth + orchestration; ekosistem JS kaya.
- Python FastAPI native untuk scikit-learn/TensorFlow tanpa konversi format.
- Pemisahan memungkinkan tim ML dan tim BE bekerja paralel tanpa saling block.
- Memungkinkan ML scaling independen (tambah replica saat traffic naik).

---

## 2. Alur Data Kunci

### 2.1 Generate Plan Mingguan Pertama (Setup Selesai)

```
User selesai setup S-12 (Diet & Budget)
   │
   ▼
Flutter S-13 (AI Processing) tampilkan Lottie + progress bar
   │
   ▼
POST /plan/generate ke Express
   {profile_id, mode, day_count, budget, diet_prefs, mood?, energy?, sleep?}
   │
   ▼
Express: validasi profile, lock row, lalu paralel:
   ├─▶ POST /infer/workout (FastAPI)
   │     {bmi, gender, level, mode, mood, energy} → 7 hari workout plan
   ├─▶ POST /infer/meal (FastAPI)
   │     {tdee, budget, diet_prefs, frequency} → 7 hari meal plan
   └─▶ Disimpan ke tabel weekly_plans + child rows (workouts, meals)
   │
   ▼
Response 200 + plan_id ke Flutter
   │
   ▼
Flutter cache plan ke Hive box `current_plan`
   │
   ▼
Navigasi ke S-14 (Plan Ready) lalu S-15 (Home)
```

### 2.2 Pre-Workout Check-in (Adaptasi Real-Time)

```
User tap "Mulai Latihan" di Home / Workout Day
   │
   ▼
Flutter S-19 minta input mood (1-5), energi (1-5), sleep (5 chip)
   │
   ▼
POST /workout/checkin {plan_id, day, mood, energy, sleep_band}
   │
   ▼
Express → POST /infer/workout (mode: adjust)
   {original_workout, mood, energy, sleep_band} → workout dengan volume disesuaikan
   │
   ▼
Response 200: adjusted_workout (volume +10% atau -20%)
   │
   ▼
Flutter tampilkan AI Preview Card (S-19) + simpan adjusted_workout di Riverpod
   │
   ▼
User tap "Ayo Mulai" → S-20 Active Workout pakai adjusted_workout
```

### 2.3 Replanning Mingguan Otomatis

```
node-cron di Express, Sunday 20:00
   │
   ▼
Untuk tiap user dengan plan aktif:
   ├─▶ Hitung skor: workout_done/total × 100, meal_done/total × 100
   ├─▶ POST /infer/replan {previous_plan, score, weight_trend, skipped_exercises}
   ├─▶ FastAPI return new_plan + AI notes
   └─▶ Insert weekly_plans baru, mark previous as archived
   │
   ▼
Express push FCM/APNS notif "Rencana Minggu Baru Siap"
   │
   ▼
User buka app → S-34 (Weekly Review modal otomatis muncul)
   │
   ▼
User tap "Lihat Rencana" → S-35 (New Plan Ready) → reset Hive cache
```

### 2.4 Sync Offline-Online

```
User offline:
  - Centang checklist latihan/makan → simpan ke Hive box `sync_queue`
  - Add weight → simpan ke Hive box `sync_queue`

App detect online (connectivity_plus):
   │
   ▼
Drain sync_queue → POST /sync/batch ke Express (idempotent, pakai client-generated UUID)
   │
   ▼
Express upsert ke MySQL, return success/conflict per item
   │
   ▼
Flutter clear queue, refresh state
```

---

## 3. Decision Log

| ID | Tanggal | Keputusan | Alasan | Konsekuensi |
|---|---|---|---|---|
| D-01 | 2026-05-07 | Backend dipisah (online), bukan TFLite on-device | Akurasi ML lebih tinggi dengan model penuh | Privacy narrative perlu reframing; offline scope dibatasi |
| D-02 | 2026-05-07 | Express.js (Node) sebagai API gateway | Tim familiar dengan JS, cepat shipping, ekosistem matang | Perlu microservice Python terpisah untuk ML |
| D-03 | 2026-05-07 | Python FastAPI untuk ML serving | Native untuk scikit-learn, async-friendly, Pydantic validasi | Operasional 2 service (Express + FastAPI) |
| D-04 | 2026-05-07 | MySQL bukan PostgreSQL/MongoDB | User pilih MySQL; relational fit untuk schema food/exercise | Fitur JSON column dipakai untuk plan structure |
| D-05 | 2026-05-07 | Auth mandatory JWT (bukan opsional sesuai dokumen) | Setiap request bawa user_id, simplifikasi BE | Hilangkan flow "Lanjutkan tanpa akun" S-05 |
| D-06 | 2026-05-07 | Flutter 3.x (sesuai dokumen) | Cross-platform satu codebase, library matang | Tim ikut Dart syntax |
| D-07 | 2026-05-07 | Riverpod (bukan Provider/Bloc) | Type-safe, scalable, fit untuk async state ML | Learning curve untuk yang belum kenal |
| D-08 | 2026-05-07 | Knapsack meal optimizer di Python (bukan Express) | Numerik berat, lebih cepat di NumPy | Express kirim TDEE+budget ke FastAPI |
| D-09 | 2026-05-07 | Cron replanning di Express (bukan FastAPI) | Express punya akses MySQL untuk batch query user | FastAPI stateless, hanya inference |

Jika ada keputusan baru, tambahkan baris dengan ID berikutnya. **Jangan hapus baris lama** — supaya alasan pergeseran terlacak.

---

## 4. Privacy & Security

### 4.1 Yang Dilindungi
- Email & password user → bcrypt hash, JWT issued ke client.
- Profile data (BMI, berat, target) → tabel `user_profiles` di MySQL, akses HANYA via API authenticated.
- Log mood/energi/sleep harian → field di `workout_logs`, **zero-retention policy**: hapus otomatis setelah 90 hari (cron job).
- Komunikasi Flutter ↔ Express: HTTPS (TLS 1.2+).
- Komunikasi Express ↔ FastAPI: HTTP internal (di docker network), shared secret `X-ML-KEY` header.

### 4.2 Yang Tidak Disimpan
- Foto wajah / biometrik
- Lokasi GPS
- Kontak / telepon
- Transaction history (Heltigo gratis, no payment)

### 4.3 Reframing Novelty K3 untuk Presentasi
> "Heltigo memproses semua data kesehatan pribadi di environment isolated yang dienkripsi at-rest. Kami menerapkan **zero-retention policy** untuk log mood, energi, dan kualitas tidur — data tersebut otomatis dihapus setelah 90 hari. Selain itu, **fitur inti seperti kalkulasi BMI, checklist harian, dan notifikasi pengingat tetap berjalan offline** — sehingga user di area koneksi tidak stabil tetap dapat memantau kesehatannya tanpa internet."

---

## 5. Skalabilitas (Out of Scope untuk Hackathon, Catatan untuk Pasca-Demo)

- **Stateless Express.js** → bisa scale horizontal di Railway/Render dengan load balancer.
- **MySQL** → mulai dari single instance, scale up vertical dulu, lalu read replica.
- **FastAPI ML** → scale horizontal independent. Models di-load saat startup, no shared state.
- **Hive cache di mobile** → meredam beban backend saat traffic tinggi.

---

## 6. Open Architecture Questions

Pertanyaan yang **belum** harus dijawab di dokumen ini, akan diputuskan saat eksekusi:

1. **Hosting target final** — default Railway (Express+MySQL) + Render (FastAPI), bisa diubah ke VPS Hetzner jika perlu lebih banyak control.
2. **Logging & monitoring** — minimum: Pino di Express, FastAPI stdlib logging. Optional: Sentry untuk error tracking jika waktu cukup.
3. **CI/CD** — minimum: GitHub Actions trigger deploy ke staging on push main. Optional skip untuk hackathon.
4. **Background fallback TFLite di mobile** — default tidak. Jika ada budget waktu di Week 2, ML team bisa export model ringan untuk darurat offline.

Lihat juga `00_MASTER_PLAN.md` §6 (Risiko Utama).

# Heltigo — Master Plan

**Status dokumen:** v1.0 — 2026-05-07
**Pemilik:** Tim Heltigo
**Kompetisi:** MSU iREX 2026 — Kategori AI & Machine Learning
**Deadline implementasi:** 2 minggu (target demo 2026-05-21)

---

## 1. Ringkasan Proyek

Heltigo adalah aplikasi mobile kesehatan dan kebugaran personal berbasis AI yang menyatukan tiga pilar yang biasanya terpisah dalam aplikasi sejenis:

1. **Perencana latihan personal** berbasis BMI, level kebugaran, mood/energi harian.
2. **Perencana makan berbasis anggaran (budget-aware)** dengan database makanan lokal Indonesia (1.346 item).
3. **Mesin replanning adaptif mingguan** yang membaca skor kepatuhan dan meresponsnya secara otonom.

Tagline: *Cerdas. Hybrid Offline. Hemat Budget. Relevan Secara Lokal.*

---

## 2. Pergeseran Arsitektur dari Dokumen Original

| Aspek | Dokumen original | Implementasi sprint ini |
|---|---|---|
| Inferensi ML | TFLite on-device (kuantisasi INT8, 1–5 MB) | Server-side full model di FastAPI Python |
| Database | SQLite/Hive lokal | MySQL di server + Hive cache lokal |
| Konektivitas | 100% offline | Hybrid: online untuk inferensi & sync, offline untuk fitur inti |
| Auth | Opsional ("Lanjutkan tanpa akun") | Mandatory email/password + JWT |

**Alasan:** Akurasi inferensi adalah jualan utama Heltigo di MSU iREX. Model penuh (full Random Forest, knapsack tanpa pemangkasan fitur) memberi akurasi yang signifikan lebih baik daripada versi terkuantisasi 1–5 MB.

**Yang dipertahankan:**
- Narasi "Offline-First Hybrid" untuk presentasi (lihat §6.7 dokumen original).
- Fitur kritis tetap berjalan offline:
  - Kalkulasi BMI/BMR/TDEE (formula matematika murni di Dart)
  - Cached weekly plan (Hive — sudah di-fetch saat online)
  - Checklist & streak harian (Hive + sync queue)
  - Notifikasi lokal (`flutter_local_notifications`)

**Konsekuensi novelty:**
- K3 ("Privacy-First ML On-Device") perlu reframing saat presentasi:
  *"Data sensitif dienkripsi at-rest di MySQL, inference di server isolated, zero-retention untuk log mood/energi harian."*
- Atau, opsi cadangan: tetap embed satu TFLite ringan untuk fallback offline jika koneksi mati total. **Default tim: tidak**, andalkan cached plan.

---

## 3. Tiga Tim Paralel

| Tim | Output utama | Tooling | Lokasi kerja |
|---|---|---|---|
| **Mobile FE** | App Flutter Android/iOS, 35 layar | Flutter 3.x, Dart, Riverpod, Hive, Dio | `frontend/` |
| **Backend** | REST API + MySQL + auth | Node 20+, Express.js, Prisma/Sequelize, JWT | `backend/` (akan dibuat) |
| **Machine Learning** | 3 model + FastAPI service | Python 3.11+, scikit-learn, FastAPI, Pydantic | `notebook/` + `ml-service/` (akan dibuat) |

Lihat dokumentasi spesifik di `docs/frontend/`, `docs/backend/`, `docs/machine-learning/`.

---

## 4. Timeline 2 Minggu (Ringkasan)

Detail per-hari ada di [`00_TIMELINE_2_WEEKS.md`](./00_TIMELINE_2_WEEKS.md).

**Week 1 — Foundation (UI Focus)**
- D1–D2: Setup proyek 3 tim, design system Flutter, auth backend, eksplorasi dataset
- D3–D5: Onboarding + setup profile (S-01..S-14), profile API, train model workout
- D6–D7: Home + Workout tab dengan mock data, FastAPI scaffold

**Week 2 — Integration (Demo-Ready)**
- D8–D9: Active Workout flow + Nutrition tab, integrasi Express ↔ FastAPI
- D10–D11: Progress tab + Weekly Report, cron replanning
- D12–D13: Profile/Settings, replanning modal, full FE↔BE wiring
- D14: Polish, demo data, video record

---

## 5. Demo End-to-End yang Harus Berhasil

Skenario demo wajib berhasil tanpa cacat:

1. **Signup** dengan email/password baru → JWT diterima.
2. **Setup profile 8-step** → AI processing screen (S-13) memanggil `/plan/generate` ke Express → Express orchestrate 3 panggilan ke FastAPI ML → respon dalam <8 detik.
3. **Plan Ready (S-14)** menampilkan ringkasan rencana minggu pertama.
4. **Home Dashboard (S-15)** menampilkan greeting dinamis, kalori sisa, latihan hari ini, makan hari ini.
5. **Mulai latihan** → Pre-Workout Check-in (mood/energi/tidur) → AI menyesuaikan volume → Active Workout (timer, set counter) → Workout Complete dengan badge & streak.
6. **Nutrisi** menampilkan 3 waktu makan hari ini, budget tracker orange, tap untuk Meal Detail.
7. **Progress** menampilkan grafik berat (line chart fl_chart), streak card, badges.
8. **Trigger replanning** manual (atau auto Sunday 20:00) → Weekly Review Modal (S-34) → New Plan Ready (S-35).

Jika salah satu cacat, demo gagal. Karenanya tiga jalur kritis ini di-flag P0 di timeline.

---

## 6. Risiko Utama & Mitigasi

| Risiko | Probabilitas | Dampak | Mitigasi |
|---|---|---|---|
| ML model akurasi rendah karena dataset kecil | Tinggi | Demo terlihat hambar | Mulai cleaning dataset Day 1, gunakan baseline rule-based jika ML belum siap |
| Integrasi Express ↔ FastAPI gagal di Day 8 | Sedang | Block Week 2 | Stub mock response di Express dari Day 6 supaya FE bisa lanjut |
| Hosting (Railway/Render) lambat saat demo live | Sedang | Demo lag | Punya video recording + APK lokal dengan pointing ke staging stable |
| Flutter UI Dark mode banyak bug saat polish Day 14 | Sedang | Visual jelek | Build Dark mode parallel sejak Day 2 (theme di setup pertama) |
| Dataset `Model_Perencana_latihan/` kosong | Sudah teridentifikasi | Block training model latihan | Klarifikasi user atau merge dengan `Model_rekomendasi_Pelatihan/` |

---

## 7. Daftar Dokumen Lain

**Top-level:**
- [`00_ARCHITECTURE.md`](./00_ARCHITECTURE.md) — diagram, alur data, decision log
- [`00_TIMELINE_2_WEEKS.md`](./00_TIMELINE_2_WEEKS.md) — kanban harian Day 1–14

**Per-tim:**
- `frontend/` — 9 dokumen mobile
- `backend/` — 8 dokumen Express.js
- `machine-learning/` — 7 dokumen ML & FastAPI

---

## 8. Sumber Kebenaran (Source of Truth)

| Dokumen | Otoritas atas |
|---|---|
| `Heltigo_Deskripsi_Aplikasi_Updated.docx` | Fitur, modul, novelty, gap penelitian, dataset references, SDG narrative |
| `Heltigo_UI_Screens.docx` | 35 layar UI, color palette, typography, komponen, navigasi |
| `docs/00_ARCHITECTURE.md` | Keputusan arsitektur final (override dokumen original di mana berbeda) |
| `docs/backend/04_API_ENDPOINTS.md` | Kontrak API antara FE ↔ BE |
| `docs/machine-learning/06_SERVING_FASTAPI.md` | Kontrak API antara BE ↔ ML |

Jika konflik antar sumber, urutan precedence: **02_ARCHITECTURE > kontrak API > UI Screens > Deskripsi Aplikasi**.

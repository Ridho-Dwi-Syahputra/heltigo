# Progress Laporan: Kondisi Aplikasi & Implementasi Screen

**Tanggal terakhir update:** 16 Mei 2026
**Status:** 🚀 Dalam Pengembangan Aktif
**Tema Aktif:** Dark / Light / System (user-configurable)

> 📌 **Sprint update 2026-05-16 (Light Mode + Food Scan):**
> - ✅ **Light/Dark/System Theme** — user bisa pilih tema di Settings (disimpan ke SharedPreferences)
>   - `ThemeProvider` (ChangeNotifier) + `ThemeMode` dari `MaterialApp`
>   - `AppTheme.lightTheme` ditambahkan dengan warna sesuai design system
>   - Settings screen: toggle 3-way (Sistem / Terang / Gelap) menggantikan locked switch
> - ✅ **Food Scan Screen** (`/meal/food-scan`) — baru:
>   - `image_picker` untuk kamera + galeri
>   - Tampilan hasil: nama makanan terdeteksi, kalori, protein, lemak, karbo
>   - Assessment badge: GOOD / MODERATE / POOR
>   - Terhubung dari card "Scan Makanan" di Rencana Makanku
>   - TODO: Integrasikan ke FastAPI `/predict/food-scan` dengan Gemini Vision
> - ✅ **Multi-select labels** di screen kondisi khusus & pantangan diet
> - ✅ **Button text responsive** (`FittedBox` di SegmentedSelector + Konfirmasi button)
> - ✅ **Ubah Manual modal** — bottom sheet dengan input berat badan
> - 📦 Dependency baru: `image_picker: ^1.1.2`, `permission_handler: ^11.3.1`
> - `flutter analyze lib/` → **No issues found**
>
> 📌 **Sprint update 2026-05-16 (ML Fix):**
> - ✅ **Workout Recommender**: Switched dari XGBoost (F1=0.23, gagal) ke **Rule-Based Engine** — 5/5 test cases PASSED
> - ✅ **Meal Planner**: Calorie deviation diperbaiki dari **48.7% → 4.9%** (target ≤15% — MET!)
> - ✅ **Adaptive Replanner**: Sudah memenuhi target (MAE=0.026, R²=0.965)
> - ✅ **Data Cleaning**: Dataset gym_members verified clean (973 rows)
> - ⚠️ **Known issue**: Macro balance masih rendah (protein%), budget Rp25K undershoot
> - 📄 Detail: [`docs/machine-learning/progress/01_ML_FIX_REPORT.md`](../../machine-learning/progress/01_ML_FIX_REPORT.md)
>
> 📌 **Sprint update 2026-05-15:**
> - ✅ **S-21b Workout Session Detail** — selesai, terhubung dari S-21 "Lihat Detail"
> - ✅ **Replanning flow** 4 screens (S-34, S-34b, S-34c, S-35) — selesai + routes wired
> - ✅ **S-16 Workout List** rebuilt jadi vertical list (sebelumnya carousel) + sticky CTA "Mulai Hari Ini"
> - ✅ **S-17 Workout Detail** rebuilt jadi compact checkbox row dengan hero card teal kecil
> - ✅ **S-38 Health Metrics**, **S-39 Plan History** screens — selesai
> - ✅ **Error & Offline screens** — selesai
> - ✅ Bug fix navigasi (`MainScaffold.didUpdateWidget`) → "Lihat semua" dan "Lihat Minggu" sekarang berfungsi
> - ✅ Bug fix chart Y-axis spacing (`weight_line_chart.dart`) → label tidak nabrak garis lagi
> - ✅ Onboarding responsive (LayoutBuilder + image ratio adaptif)
> - 📌 **Docs sync 2026-05-15:** Backend & ML docs di-update untuk konsisten dengan kode (`backend/FE_requirement/`, `machine-learning/FE-model-requirement/`)
>
> Total **47 screens** sudah built. `flutter analyze` → No issues found.

---

---

## 1. Status Proyek Saat Ini

Project **Heltigo** saat ini telah berhasil membangun fondasi arsitektur frontend dengan Flutter. Seluruh konfigurasi *Design System*, struktur folder, dan sistem *routing* (navigasi) sudah dipersiapkan dan dihubungkan satu sama lain.

Kondisi proyek saat ini adalah **stabil** dengan 0 error dan 0 warning berdasarkan hasil analisis *Flutter Lint*.

### Penyesuaian Brand Identity Terbaru
1. **Logo Aplikasi:** Telah diimplementasikan menggunakan `logo_polos.png` (background putih dengan tema utama teal). Android App Name juga sudah disesuaikan menjadi **Heltigo**.
2. **Palet Warna Utama:** Diubah menjadi **Teal (#1D6766)** sebagai warna *Primary* dan **Orange (#FB3A01)** sebagai warna *Accent* untuk menyesuaikan warna asli logo aplikasi.
3. **App Name:** Kapitalisasi huruf telah disesuaikan di *AndroidManifest.xml* menjadi **Heltigo** (dengan huruf H kapital).

---

## 2. Screen yang Telah Diimplementasikan

Berikut adalah rincian halaman aplikasi (Screens) yang saat ini **sudah 100% selesai dibangun (UI & Logic Layout)** dan bisa dijalankan:

### ✅ S-01: Splash Screen
- **Fungsi:** Halaman pertama kali saat aplikasi dibuka.
- **Implementasi:** Menggunakan `logo_with_tulisan.png`. Terdapat animasi berurutan yang sangat mulus (fade in & scale pada logo, kemudian disusul animasi *slide up* motto aplikasi). Durasi telah dioptimalkan menjadi 3.5 detik agar pengguna sempat melihat logo dengan nyaman.

### ✅ S-02: Onboarding Carousel
- **Fungsi:** Penjelasan fitur utama untuk pengguna baru.
- **Implementasi:** Terdiri dari 3 halaman fitur (Latihan, Nutrisi, AI Progress) menggunakan sistem carousel yang responsif, dilengkapi indikator titik (dot indicator) yang bisa berubah ukuran saat aktif. Menggunakan *Linear Gradient* gelap ke hitam di bawah gambar untuk memastikan teks tetap terbaca dengan jelas. Tombol *Get Started* membawa user ke rute `/login`.

### ✅ S-03: Login Screen
- **Fungsi:** Halaman autentikasi utama.
- **Implementasi:** Telah mengadopsi logo Heltigo di bagian atas (menggantikan icon hati sebelumnya). Form input untuk Email dan Password dilengkapi dengan validasi format dasar, *obscure text toggle* (tampilkan/sembunyikan password), fitur "Lupa Password" dengan warna orange accent, dan navigasi "Daftar" di bawah tombol utama.

---

## 3. Komponen Pendukung yang Telah Selesai (Widgets & Styles)

Semua screen di atas dibangun menggunakan komponen *Universal* yang sudah dirancang khusus untuk Heltigo agar konsisten:

- **Primary Button & Secondary Button:** Tombol dengan *drop shadow* teal (warna baru) agar menyala di latar gelap.
- **Form Input (TextFormField):** Didesain dengan *dark surface light* (#242424) agar nyaman di mata saat mengetik.
- **Typography:** Semua font (ukuran dan tebal-tipis) sudah dikonfigurasi melalui `GoogleFonts.inter` dengan kontras teks terang terhadap latar belakang hitam pekat (#0D0D0D).

---

## 4. Status Machine Learning (Update 16 Mei 2026)

### Model 1 — Rekomendasi Latihan: ✅ Rule-Based Engine
- **Sebelumnya:** XGBoost, F1=0.23 (≈ random), gagal setelah 2 round debugging
- **Sekarang:** Rule engine deterministik — 12 templates × BMI/condition overrides
- **Validasi:** 5/5 test cases PASSED (beginner, obese, advanced, underweight, hamil)
- **File:** `notebook/training_model/Model_Rekomendasi_Latihan/rule_engine_workout.py`

### Model 2 — Perencana Makan: ✅ Calorie Fixed
- **Sebelumnya:** Calorie deviation 48.7%
- **Sekarang:** Calorie deviation **4.9%** (target ≤15% — MET!)
- **Metode:** Multi-pass knapsack + normalisasi porsi + fractional serving
- **File:** `notebook/training_model/Model_Perencana_Makan/fix_meal_planner.py`

### Model 3 — Adaptive Replanner: ✅ Sudah Lulus
- MAE = 0.026 (target < 0.04), R² = 0.965 (target > 0.90)
- Rule 3-cabang + XGBoost fine-tune multiplier

---

## 5. Next Step (Langkah Selanjutnya)

### Frontend
1. **Implementasi UI Auth Lainnya:** Pembuatan UI untuk `RegisterScreen` (S-04) dan `ForgotPasswordScreen` (S-05).
2. **Setup Profile Wizard:** Membangun *flow* pengisian data personal (S-06 hingga S-09) untuk menghitung preferensi olahraga pengguna baru.
3. **Koneksi State Management:** Mengaktifkan tombol "Masuk" pada halaman Login menggunakan `AuthProvider` untuk menembak API dan menyimpan *Auth Token* ke dalam `SecureStorage`.
4. **Implementasi Main Scaffold:** Mengaktifkan *Bottom Navigation Bar* (S-35) yang sudah dibuat, untuk mengakses halaman utama Home, Workout, Meal, dan Progress.

### Machine Learning
1. **Macro balance improvement** — boost protein scoring weight di meal planner
2. **FastAPI integration** — copy fix scripts ke `heltigo-ml-service/app/services/`
3. **E2E smoke test** — Flutter ↔ Backend ↔ ML service

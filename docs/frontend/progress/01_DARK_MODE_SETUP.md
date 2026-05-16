# Progress: Dark Mode Setup & Splash/Onboarding Implementation

**Tanggal:** 10 Mei 2026  
**Status:** ✅ Selesai  
**Flutter Analyze:** 0 error, 0 warning

---

## 1. Perubahan Utama

### Keputusan Desain
- **Dark Mode Only** — Light mode dihapus sepenuhnya
- **Warna dominan:** Teal (#1D6766) + Orange Accent (#FB3A01)
- **Referensi visual:** Premium dark fitness app style

---

## 2. Daftar File & Fungsinya

### 📂 `lib/styles/` — Design System (Dark Mode)

| File | Fungsi |
|------|--------|
| `colors.dart` | Palet warna dark-mode: brand primary (hijau), surfaces (hitam bertingkat), semantic colors (error/success/warning/info), accent colors, gradients, shimmer |
| `typography.dart` | Sistem tipografi Inter font dengan default warna terang. Heading, body, caption, button, motto, link, onboarding styles |
| `dimensions.dart` | Spacing (xs–xxxl), border radius, component heights, icon sizes, dot indicator sizes, screen padding, animation durations (AppDurations) |
| `theme.dart` | ThemeData dark-only: colorScheme, appBar, card, input, button (elevated/outlined/text), bottomNav, dialog, bottomSheet, snackbar, switch, progressIndicator |
| `styles.dart` | Barrel export — re-export semua file styles |

### 📂 `lib/screens/splash/` — Splash & Onboarding

| File | Screen ID | Fungsi |
|------|-----------|--------|
| `splash_screen.dart` | S-01 | Tampilan awal: logo `logo_with_tulisan.png` dengan animasi fade-in + scale, motto "Your AI-Powered Health & Fitness Partner", auto-navigate ke onboarding setelah 2.5 detik |
| `onboarding_screen.dart` | S-02 | Carousel 3 halaman fitur unggulan dengan gambar full-bleed + gradient overlay, dot indicators animasi, tombol Skip/Next/Get Started, link Sign In |

**Onboarding Pages:**
1. **Latihan Terbaik Untuk Kamu** — Rekomendasi latihan personal berdasarkan profil (gambar: gym equipment)
2. **Nutrisi Cerdas Sesuai Budget** — Rekomendasi makanan sehat sesuai anggaran (gambar: healthy food)
3. **AI Mengatur Progress Mingguan** — Analisis progress & penyesuaian otomatis (gambar: AI body scan)

### 📂 `lib/screens/auth/` — Autentikasi

| File | Screen ID | Fungsi |
|------|-----------|--------|
| `login_screen.dart` | S-03 | Halaman login (email + password) |
| `register_screen.dart` | S-04 | Halaman registrasi akun baru |
| `forgot_password_screen.dart` | S-05 | Reset password via email |

### 📂 `lib/screens/setup/` — Setup Profil Awal

| File | Screen ID | Fungsi |
|------|-----------|--------|
| `setup_basic_info_screen.dart` | S-06 | Input info dasar (nama, usia, gender, TB/BB) |
| `setup_goal_screen.dart` | S-07 | Pilih tujuan kesehatan |
| `setup_fitness_level_screen.dart` | S-08 | Pilih level kebugaran |
| `setup_preferences_screen.dart` | S-09 | Preferensi latihan & makanan |

### 📂 `lib/screens/plan/` — Plan Generation

| File | Screen ID | Fungsi |
|------|-----------|--------|
| `plan_generating_screen.dart` | S-10 | Loading screen saat AI generate plan |
| `plan_ready_screen.dart` | S-11 | Tampilkan plan yang sudah jadi |

### 📂 `lib/screens/main/` — Main Scaffold

| File | Screen ID | Fungsi |
|------|-----------|--------|
| `main_scaffold.dart` | S-35 | Container utama dengan bottom nav (4 tab: Home, Workout, Meal, Progress) |

### 📂 `lib/screens/home/` — Dashboard

| File | Screen ID | Fungsi |
|------|-----------|--------|
| `home_screen.dart` | S-12 | Dashboard utama: ringkasan harian, workout hari ini, progress |

### 📂 `lib/screens/workout/` — Workout

| File | Screen ID | Fungsi |
|------|-----------|--------|
| `workout_list_screen.dart` | S-13 | Daftar workout tersedia |
| `pre_workout_checkin_screen.dart` | S-14 | Check-in sebelum mulai workout |
| `active_workout_screen.dart` | S-15 | Screen aktif saat workout berlangsung |
| `workout_complete_screen.dart` | S-16 | Ringkasan setelah workout selesai |
| `workout_detail_screen.dart` | S-17 | Detail satu workout |

### 📂 `lib/screens/meal/` — Meal Planning

| File | Screen ID | Fungsi |
|------|-----------|--------|
| `meal_list_screen.dart` | S-18 | Daftar meal plan harian |
| `meal_detail_screen.dart` | S-19 | Detail satu menu makanan |
| `meal_swap_screen.dart` | S-20 | Tukar menu dengan alternatif |
| `meal_log_screen.dart` | S-21 | Log makanan yang sudah dikonsumsi |

### 📂 `lib/screens/progress/` — Progress & Tracking

| File | Screen ID | Fungsi |
|------|-----------|--------|
| `progress_screen.dart` | S-22 | Dashboard progress keseluruhan |
| `weekly_review_screen.dart` | S-23 | Review mingguan dari AI |
| `badge_gallery_screen.dart` | S-24 | Koleksi badge/achievement |
| `streak_detail_screen.dart` | S-25 | Detail streak harian |

### 📂 `lib/screens/profile/` — Profil User

| File | Screen ID | Fungsi |
|------|-----------|--------|
| `profile_screen.dart` | S-26 | Halaman profil utama |
| `edit_profile_screen.dart` | S-27 | Edit data profil |
| `health_metrics_screen.dart` | S-28 | Metrik kesehatan (TB, BB, BMI, dll) |
| `plan_history_screen.dart` | S-29 | Riwayat plan yang pernah dibuat |

### 📂 `lib/screens/settings/` — Pengaturan

| File | Screen ID | Fungsi |
|------|-----------|--------|
| `settings_screen.dart` | S-30 | Halaman pengaturan utama |
| `about_screen.dart` | S-31 | Tentang aplikasi |

### 📂 `lib/screens/notification/` — Notifikasi

| File | Screen ID | Fungsi |
|------|-----------|--------|
| `notification_screen.dart` | S-32 | Daftar notifikasi |

### 📂 `lib/screens/error/` — Error Handling

| File | Screen ID | Fungsi |
|------|-----------|--------|
| `error_screen.dart` | S-33 | Tampilan error generik |
| `offline_screen.dart` | S-34 | Tampilan saat tidak ada koneksi |

### 📂 `lib/widgets/universal/` — Reusable Widgets

| File | Fungsi |
|------|--------|
| `primary_button.dart` | Tombol utama (filled hijau) dengan loading state, ikon opsional, dan glow shadow |
| `secondary_button.dart` | Tombol sekunder (outlined hijau) untuk aksi alternatif |
| `heltigo_card.dart` | Card container dark dengan border opsional, tap handler, dan shadow |
| `input_field.dart` | Text input wrapper dengan label, prefix/suffix icon, dan validator |
| `loading_overlay.dart` | Overlay loading semi-transparan dengan spinner hijau dan pesan opsional |
| `status_chip.dart` | Badge status kecil (Active/Completed/Skipped/Pending/Error) dengan warna otomatis |
| `navbottom.dart` | **Bottom navigation bar custom** — 4 tab (Home, Workout, Meal, Progress) dengan active indicator dot animasi, dark surface background, ikon + label yang berubah warna hijau saat aktif |

### 📂 `lib/router/` — Routing

| File | Fungsi |
|------|--------|
| `app_router.dart` | Konfigurasi GoRouter untuk semua 35 rute. Menggunakan `NoTransitionPage` untuk tab utama. Error route mengarah ke `ErrorScreen`. |

### 📂 `lib/providers/` — State Management

| File | Fungsi |
|------|--------|
| `auth_provider.dart` | State autentikasi: login, logout, register, cek session |
| `profile_provider.dart` | State profil user: data user, health metrics |
| `plan_provider.dart` | State AI plan: generate, update, riwayat plan |
| `workout_provider.dart` | State workout: daftar, active workout, complete |
| `meal_provider.dart` | State meal: daftar menu, log, swap |
| `progress_provider.dart` | State progress: statistik, streak, badges |

### 📂 `lib/data/api/` — API Layer

| File | Fungsi |
|------|--------|
| `api_service.dart` | HTTP client wrapper (Dio) dengan interceptor, base URL, dan error handling |
| `endpoints.dart` | Mapping semua API endpoint backend |

### 📂 `lib/data/services/` — Service Layer

| File | Fungsi |
|------|--------|
| `auth_service.dart` | Komunikasi API untuk autentikasi |
| `profile_service.dart` | Komunikasi API untuk profil |
| `plan_service.dart` | Komunikasi API untuk AI plan generation |
| `workout_service.dart` | Komunikasi API untuk workout |
| `meal_service.dart` | Komunikasi API untuk meal planning |
| `progress_service.dart` | Komunikasi API untuk progress tracking |

### 📂 `lib/data/repositories/` — Repository Layer

| File | Fungsi |
|------|--------|
| `auth_repository.dart` | Abstraksi data auth (interface + implementasi) |
| `profile_repository.dart` | Abstraksi data profil |
| `plan_repository.dart` | Abstraksi data plan |
| `workout_repository.dart` | Abstraksi data workout |
| `meal_repository.dart` | Abstraksi data meal |
| `progress_repository.dart` | Abstraksi data progress |

### 📂 `lib/data/models/` — Data Models

| File | Fungsi |
|------|--------|
| `auth_response_model.dart` | Model respons autentikasi (token, user data) |
| `user_model.dart` | Model data user |
| `health_profile_model.dart` | Model profil kesehatan (TB, BB, BMI, dll) |
| `workout_model.dart` | Model data workout |
| `meal_model.dart` | Model data meal/menu |
| `progress_model.dart` | Model data progress/statistik |
| `badge_model.dart` | Model data badge/achievement |

### 📂 `lib/utils/` — Utilities

| File | Fungsi |
|------|--------|
| `constants.dart` | Konstanta global (API base URL, app name, dll) |
| `validators.dart` | Validasi input (email, password, nama, dll) |
| `date_utils.dart` | Helper format tanggal dan waktu |
| `responsive_utils.dart` | Helper responsive layout (breakpoint, screen size) |

### Root Files

| File | Fungsi |
|------|--------|
| `main.dart` | Entry point: setup DI, restore auth session, jalankan app dengan dark theme only (`ThemeMode.dark`) |
| `service_locator.dart` | Registrasi dependency injection via GetIt: External → Core → Services → Repositories → Providers |

---

## 3. Assets

| Path | Fungsi |
|------|--------|
| `assets/logo/logo_polos.png` | Logo Heltigo tanpa teks (untuk ikon/favicon) |
| `assets/logo/logo_with_tulisan.png` | Logo Heltigo + teks "HELTIGO" (untuk splash screen) |
| `assets/screen/onboarding/onboarding 1.jpg` | Gambar gym — halaman onboarding 1 |
| `assets/screen/onboarding/onboarding 2.jpg` | Gambar healthy food — halaman onboarding 2 |
| `assets/screen/onboarding/onboarding 3.jpg` | Gambar AI body analysis — halaman onboarding 3 |

---

## 4. Arsitektur Pattern

```
User Interaction
      ↓
  Screen (UI)
      ↓
  Provider (State/ChangeNotifier)
      ↓
  Repository (Abstraction)
      ↓
  Service (API Communication)
      ↓
  ApiService (Dio HTTP Client)
      ↓
  Backend API
```

**DI Pattern:** GetIt Service Locator → semua dependency diregistrasi di `service_locator.dart`

---

## 5. Total File Count

| Kategori | Jumlah |
|----------|--------|
| Screens | 30 files |
| Widgets | 7 files |
| Providers | 6 files |
| Repositories | 6 files |
| Services | 6 files |
| Models | 7 files |
| Styles | 5 files |
| Utils | 4 files |
| Router | 1 file |
| Core (main + DI) | 2 files |
| API | 2 files |
| **Total** | **76 files** |

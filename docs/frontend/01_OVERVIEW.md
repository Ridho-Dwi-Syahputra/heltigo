# Frontend Mobile — Overview

> 📌 **Update 2026-05-15:**
> - Jumlah layar **47** (bukan 35) — lihat `05_SCREENS_SPEC.md`.
> - State management pakai **Provider + GetIt** (bukan Riverpod) sesuai keputusan project.
> - Endpoint API: source of truth ada di [`../backend/FE_requirement/00_API_REQUIREMENTS.md`](../backend/FE_requirement/00_API_REQUIREMENTS.md).
> - Design system: Dark mode only, Teal `#1D6766` + Orange `#FB3A01` — lihat `03_DESIGN_SYSTEM.md`.

## 1. Tujuan

Membangun aplikasi mobile **Heltigo** dengan **Flutter 3.x** sebagai client utama yang menyajikan UI **47 layar**, mengonsumsi REST API backend Express.js, dan menyediakan pengalaman hybrid offline-first untuk fitur kritis.

## 2. Tech Stack

| Layer | Pilihan | Alasan |
|---|---|---|
| Framework | Flutter 3.x (Dart 3.x) | Cross-platform satu codebase, performa native, dokumentasi spec sudah berbasis Flutter |
| State management | **Riverpod 2.x** (`flutter_riverpod`) | Type-safe, scalable, AsyncValue untuk loading/error/data, fit untuk pemanggilan API ML |
| HTTP client | **Dio** | Interceptor mature, retry, timeout, auth header injection |
| Routing | **GoRouter** | Declarative, deep-linkable, nested routes per tab |
| Local DB / cache | **Hive** | Lightweight key-value, no SQL, ideal untuk plan cache & sync queue |
| Charts | **fl_chart** | Native Flutter, performant, customizable |
| Notifikasi | **flutter_local_notifications** | Reminder offline, scheduled, cross-platform |
| Animation | **lottie** | Onboarding, AI processing, celebration |
| Fonts | **google_fonts** (Inter, Poppins fallback) | Sesuai spec UI dokumen |
| Connectivity | **connectivity_plus** | Detect online/offline untuk sync queue |
| Secure storage | **flutter_secure_storage** | Simpan JWT token aman |
| Form validation | Built-in `Form` + custom validators | Cukup untuk scope |
| i18n | Built-in `flutter_localizations` | ID + EN nanti, ID dulu untuk demo |

Versi spesifik di `09_DEPENDENCIES.md`.

## 3. Target Platform

- **Android** (min SDK 21 / Android 5.0+)
- **iOS** (min iOS 12+)
- Layar: phone portrait (5"–6.7"). Tablet support tidak prioritas hackathon.

## 4. Prinsip Desain

1. **Konsistensi visual:** semua 35 layar pakai komponen reusable yang sudah didefinisikan di Design System (lihat `03_DESIGN_SYSTEM.md`). Tidak ada custom one-off styling kecuali sangat perlu.
2. **Offline-first untuk fitur kritis:** kalkulasi BMI/BMR/TDEE, checklist harian, streak, notifikasi, dan cached weekly plan **harus** berfungsi tanpa internet.
3. **Optimistic UI:** saat user centang checklist offline, langsung update UI; sync ke server di background.
4. **Loading states proper:** AsyncValue.when di Riverpod → tampilkan skeleton/shimmer, bukan blank screen.
5. **Error handling user-friendly:** snackbar ramah ID, opsi retry. Tidak boleh ada raw stack trace.
6. **Dark mode dari hari pertama:** ThemeData light & dark setup di Day 1, jangan ditunda. Setiap widget pakai `Theme.of(context).colorScheme.*` dan `AppColors`.
7. **Accessibility minimum:** semantics labels untuk tombol kritis, kontras WCAG AA untuk teks.

## 5. Struktur Proyek (High Level)

Detail lengkap di `02_PROJECT_STRUCTURE.md`.

```
frontend/heltigo/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/                  # Theme, router, http, storage
│   ├── features/              # Per fitur: profile, workout, nutrition, progress
│   └── shared/                # Widget & util reusable
├── assets/
│   ├── images/
│   ├── lottie/
│   └── fonts/
├── pubspec.yaml
└── test/
```

## 6. Cakupan Online vs Offline

| Fitur | Online (butuh API) | Offline (Hive cache) |
|---|---|---|
| Signup / Login | ✅ wajib online | ❌ |
| Setup profile (S-06..S-12) | ✅ submit ke /profile | ✅ kalkulasi BMI lokal |
| Plan Generate (S-13) | ✅ wajib online (call ML) | ❌ |
| Plan Ready (S-14) & Home (S-15) | Sync saat online | ✅ baca dari cache |
| Workout Day & Active (S-17, S-19, S-20, S-21) | Sync log saat online | ✅ checklist offline |
| Nutrition Home (S-22, S-23) | Sync saat online | ✅ baca dari cache |
| Add Weight (S-27) | Queue → sync | ✅ tampilkan langsung |
| Weekly Report (S-29) | ✅ butuh agregasi server | ❌ |
| Pre-checkin (S-19) submit | ✅ butuh ML adjust | Fallback: pakai original tanpa adjust |
| Notifikasi pengingat | ❌ | ✅ flutter_local_notifications |

## 7. Kontrak dengan Backend

Frontend mengikuti kontrak API yang didefinisikan di `docs/backend/04_API_ENDPOINTS.md`. Setiap perubahan kontrak HARUS dikoordinasikan dengan tim BE — tidak ada perubahan unilateral di FE atau BE.

Format umum:
- Base URL dev: `http://localhost:3000/v1`
- Base URL staging: `https://heltigo-api.staging.example.com/v1`
- Auth: header `Authorization: Bearer <jwt>`
- Content-Type: `application/json`
- Error: `{ "error": { "code": "STRING", "message": "..." } }` HTTP 4xx/5xx

## 8. Definition of Done — UI Layar

Sebuah layar dianggap selesai jika:

1. Layout sesuai spec di `05_SCREENS_SPEC.md` (visual match >95%).
2. Semua interaksi yang disebut di spec berfungsi (tap, swipe, scroll, validasi form).
3. Loading state, error state, empty state ditangani.
4. Light mode + Dark mode keduanya tested.
5. Tidak ada hardcoded string warna / size — semua via `AppColors`, `AppSizes`, `AppTextStyles`.
6. Tidak ada `print()` atau `debugPrint()` debug yang tertinggal.
7. Routing dari/ke layar ini berjalan via GoRouter.
8. Untuk layar yang fetch API: state via Riverpod AsyncValue, retry pada error.

## 9. Sumber Spec UI

- `Heltigo_UI_Screens.docx` — sumber utama 35 layar (di-extract di repo).
- `docs/frontend/03_DESIGN_SYSTEM.md` — terjemahan §1 dokumen UI ke kode Dart.
- `docs/frontend/05_SCREENS_SPEC.md` — terjemahan §3-§10 dokumen UI per layar dengan tambahan kontrak API.

## 10. Quick Start Pengembang

```bash
cd frontend/heltigo
flutter pub get
flutter run -d <device-id>
```

Setup `.env` (atau `--dart-define`) untuk `API_BASE_URL`. Lihat `08_API_INTEGRATION.md`.

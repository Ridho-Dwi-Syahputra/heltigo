# Heltigo Frontend — Documentation Index

> Folder ini berisi dokumentasi Flutter mobile app Heltigo: design system, screen spec, state management, navigation, dan integrasi API.
> **Kode aktual** ada di [`frontend/heltigo/`](../../frontend/heltigo/).

---

## 📂 File di folder ini

| File | Topik | Status |
|---|---|---|
| [`01_OVERVIEW.md`](01_OVERVIEW.md) | Tujuan, tech stack (Flutter 3.x + Provider + GetIt + GoRouter), 47 screens | ✅ Aktif (patched 2026-05-15) |
| [`02_PROJECT_STRUCTURE.md`](02_PROJECT_STRUCTURE.md) | Folder layout, naming convention, feature-first | ✅ Aktif |
| [`03_DESIGN_SYSTEM.md`](03_DESIGN_SYSTEM.md) | Tokens warna/typo/spacing, Teal `#1D6766` + Orange `#FB3A01` | ✅ Aktif (patched 2026-05-15) |
| [`04_NAVIGATION.md`](04_NAVIGATION.md) | GoRouter setup, 4-tab bottom nav, sub-routes | ✅ Aktif (patched 2026-05-15) |
| [`05_SCREENS_SPEC.md`](05_SCREENS_SPEC.md) | Spec 47 layar (auth, setup, home, workout, meal, progress, profile, replanning) | ✅ Aktif (patched 2026-05-15) |
| [`06_STATE_MANAGEMENT.md`](06_STATE_MANAGEMENT.md) | Provider pattern, GetIt service locator | ✅ Aktif |
| [`07_OFFLINE_STRATEGY.md`](07_OFFLINE_STRATEGY.md) | Hive cache, sync batch, queue offline | ✅ Aktif |
| [`08_API_INTEGRATION.md`](08_API_INTEGRATION.md) | Dio setup, interceptor, repository, endpoint mapping | ✅ Aktif (patched 2026-05-15) |
| [`09_DEPENDENCIES.md`](09_DEPENDENCIES.md) | pubspec.yaml dependencies | ✅ Aktif |
| [`progress/`](progress/) | Catatan progress sprint | Updated 2026-05-15 |

---

## 📖 Reading Order untuk Engineer Baru

1. **Konteks high-level:** `../00_ARCHITECTURE.md` + `01_OVERVIEW.md`
2. **Design language:** `03_DESIGN_SYSTEM.md`
3. **Structure & navigation:** `02_PROJECT_STRUCTURE.md`, `04_NAVIGATION.md`
4. **Screen-by-screen spec:** `05_SCREENS_SPEC.md`
5. **State + API integration:** `06_STATE_MANAGEMENT.md`, `08_API_INTEGRATION.md`
6. **Offline strategy:** `07_OFFLINE_STRATEGY.md`
7. **Setup & dependencies:** `09_DEPENDENCIES.md`

---

## 🎯 Tech Stack

| Layer | Pilihan |
|---|---|
| Framework | Flutter 3.x (Dart 3.x) |
| State management | Provider (ChangeNotifier) + GetIt (service locator) |
| Routing | GoRouter |
| HTTP | Dio + Retrofit (opsional) |
| Local DB | Hive (offline cache) + SharedPreferences (token) |
| Charts | CustomPaint (donut, line, score ring) |
| Theme | Dark mode only, Inter via `google_fonts` |
| Localization | `intl` + `flutter_localizations` (locale `id_ID`) |

---

## 🎨 Brand Colors (Dark mode)

- **Primary:** Teal `#1D6766`
- **Accent:** Orange `#FB3A01`
- **Background:** `#0D0D0D`
- **Surface:** `#1A1A1A`

Tokens: `AppColors.*` di `frontend/heltigo/lib/styles/colors.dart`.

---

## 🔄 Update History

| Tanggal | Update |
|---|---|
| 2026-05-15 | Patched docs untuk konsisten dengan kode aktual: 47 screens, route baru (session detail, meal swap, plan history, replanning expanded), endpoint baru, color tokens final. Source of truth API/DB pindah ke `../backend/FE_requirement/`. |

---

## 🤝 Cross-References

- **Backend API contract:** [`../backend/FE_requirement/00_API_REQUIREMENTS.md`](../backend/FE_requirement/00_API_REQUIREMENTS.md)
- **Database schema:** [`../backend/FE_requirement/01_DATABASE_DESIGN.md`](../backend/FE_requirement/01_DATABASE_DESIGN.md)
- **ML triggers:** [`../machine-learning/FE-model-requirement/00_OVERVIEW.md`](../machine-learning/FE-model-requirement/00_OVERVIEW.md)
- **Top-level:** [`../00_ARCHITECTURE.md`](../00_ARCHITECTURE.md), [`../README.md`](../README.md)

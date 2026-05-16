# Frontend — Struktur Proyek Flutter

## 1. Pendekatan: Feature-First (bukan Type-First)

Per fitur, kode UI + state + repository + model dikelompokkan dalam satu folder. Lebih scalable dari pendekatan `models/`, `screens/`, `services/` global.

```
frontend/heltigo/
├── lib/
│   ├── main.dart                        # Entry point: setup Hive, ProviderScope, runApp
│   ├── app.dart                         # MaterialApp.router + ThemeData
│   │
│   ├── core/                            # Hal lintas fitur
│   │   ├── theme/
│   │   │   ├── app_colors.dart          # AppColors light + dark
│   │   │   ├── app_sizes.dart           # Spacing constants
│   │   │   ├── app_text_styles.dart     # Typography
│   │   │   └── app_theme.dart           # ThemeData light & dark
│   │   ├── router/
│   │   │   └── app_router.dart          # GoRouter config
│   │   ├── http/
│   │   │   ├── dio_client.dart          # Dio instance + interceptor JWT
│   │   │   └── api_exception.dart       # Custom exception
│   │   ├── storage/
│   │   │   ├── hive_setup.dart          # Hive boxes registry
│   │   │   └── secure_storage.dart      # Wrapper flutter_secure_storage
│   │   ├── connectivity/
│   │   │   └── connectivity_service.dart
│   │   ├── notifications/
│   │   │   └── notification_service.dart # Wrapper flutter_local_notifications
│   │   └── env.dart                     # Env loader (API_BASE_URL, etc)
│   │
│   ├── features/
│   │   ├── auth/                        # Signup, Login (S-05)
│   │   │   ├── data/
│   │   │   │   ├── auth_repository.dart
│   │   │   │   └── models/auth_dto.dart
│   │   │   ├── presentation/
│   │   │   │   ├── welcome_screen.dart  # S-05
│   │   │   │   ├── signup_screen.dart
│   │   │   │   └── login_screen.dart
│   │   │   └── providers/
│   │   │       └── auth_providers.dart  # Riverpod
│   │   │
│   │   ├── onboarding/                  # S-01..S-04
│   │   │   ├── presentation/
│   │   │   │   ├── splash_screen.dart   # S-01
│   │   │   │   └── onboarding_pager.dart # S-02..S-04
│   │   │   └── providers/
│   │   │
│   │   ├── profile/                     # Setup profile (S-06..S-14), Edit (S-31)
│   │   │   ├── data/
│   │   │   │   ├── profile_repository.dart
│   │   │   │   └── models/profile.dart  # Hive adapter
│   │   │   ├── domain/
│   │   │   │   └── health_calculator.dart # BMI/BMR/TDEE pure Dart
│   │   │   ├── presentation/
│   │   │   │   ├── setup/
│   │   │   │   │   ├── setup_step1_basic.dart # S-06
│   │   │   │   │   ├── setup_step2_physical.dart # S-07
│   │   │   │   │   ├── setup_step3_bmi_result.dart # S-08
│   │   │   │   │   ├── setup_step4_target.dart # S-09
│   │   │   │   │   ├── setup_step5_conditions.dart # S-10
│   │   │   │   │   ├── setup_step6_workout_pref.dart # S-11
│   │   │   │   │   ├── setup_step7_diet_budget.dart # S-12
│   │   │   │   │   ├── setup_step8_processing.dart # S-13
│   │   │   │   │   └── setup_plan_ready.dart # S-14
│   │   │   │   ├── profile_screen.dart # S-30
│   │   │   │   └── edit_profile_screen.dart # S-31
│   │   │   └── providers/
│   │   │
│   │   ├── home/                        # S-15
│   │   │   ├── presentation/
│   │   │   │   └── home_screen.dart
│   │   │   └── providers/
│   │   │
│   │   ├── workout/                     # S-16..S-21
│   │   │   ├── data/
│   │   │   │   ├── workout_repository.dart
│   │   │   │   └── models/workout_plan.dart
│   │   │   ├── presentation/
│   │   │   │   ├── workout_home_screen.dart # S-16
│   │   │   │   ├── workout_day_screen.dart # S-17
│   │   │   │   ├── exercise_detail_screen.dart # S-18
│   │   │   │   ├── pre_workout_checkin_screen.dart # S-19
│   │   │   │   ├── active_workout_screen.dart # S-20
│   │   │   │   └── workout_complete_screen.dart # S-21
│   │   │   └── providers/
│   │   │
│   │   ├── nutrition/                   # S-22..S-25
│   │   │   ├── data/
│   │   │   ├── presentation/
│   │   │   │   ├── nutrition_home_screen.dart # S-22
│   │   │   │   ├── meal_detail_screen.dart # S-23
│   │   │   │   ├── food_item_detail_screen.dart # S-24
│   │   │   │   └── budget_settings_screen.dart # S-25
│   │   │   └── providers/
│   │   │
│   │   ├── progress/                    # S-26..S-29
│   │   │   ├── data/
│   │   │   ├── presentation/
│   │   │   │   ├── progress_dashboard_screen.dart # S-26
│   │   │   │   ├── add_weight_sheet.dart # S-27 (modal bottom sheet)
│   │   │   │   ├── badges_screen.dart # S-28
│   │   │   │   └── weekly_report_screen.dart # S-29
│   │   │   └── providers/
│   │   │
│   │   ├── settings/                    # S-32, S-33
│   │   │   ├── presentation/
│   │   │   │   ├── notification_settings_screen.dart # S-32
│   │   │   │   └── app_settings_screen.dart # S-33
│   │   │   └── providers/
│   │   │
│   │   └── replanning/                  # S-34, S-35
│   │       ├── presentation/
│   │       │   ├── weekly_review_modal.dart # S-34
│   │       │   └── new_plan_ready_screen.dart # S-35
│   │       └── providers/
│   │
│   └── shared/                          # Widget & util reusable
│       ├── widgets/
│       │   ├── primary_button.dart
│       │   ├── secondary_button.dart
│       │   ├── heltigo_card.dart
│       │   ├── input_field.dart
│       │   ├── status_chip.dart
│       │   ├── progress_bar_with_label.dart
│       │   ├── stat_card.dart
│       │   ├── empty_state.dart
│       │   ├── error_state.dart
│       │   └── loading_skeleton.dart
│       ├── widgets/scaffold/
│       │   ├── main_scaffold.dart       # Bottom nav 4 tab
│       │   └── setup_scaffold.dart      # Setup profile shared layout
│       └── utils/
│           ├── date_utils.dart
│           ├── currency_formatter.dart
│           └── greeting_helper.dart     # Pagi/Siang/Sore/Malam
│
├── assets/
│   ├── images/
│   │   ├── logo.png
│   │   ├── onboarding_1.png
│   │   ├── onboarding_2.png
│   │   └── onboarding_3.png
│   ├── lottie/
│   │   ├── splash.json
│   │   ├── ai_processing.json
│   │   ├── celebration.json
│   │   └── empty_box.json
│   └── fonts/                           # Optional, jika tidak pakai google_fonts
│
├── pubspec.yaml
├── analysis_options.yaml
└── test/
    ├── unit/
    │   ├── features/profile/health_calculator_test.dart
    │   └── shared/utils/greeting_helper_test.dart
    └── widget/
        └── shared/primary_button_test.dart
```

## 2. Naming Conventions

- File: `snake_case.dart`
- Class: `PascalCase`
- Variable & function: `camelCase`
- Private member: prefix `_`
- Constant: `kCamelCase` atau `SCREAMING_SNAKE` di file constants

## 3. Pattern: Repository + Provider

Tiap fitur yang fetch API:

```dart
// data/workout_repository.dart
class WorkoutRepository {
  WorkoutRepository(this._dio, this._hive);
  final Dio _dio;
  final HiveInterface _hive;

  Future<WorkoutPlan> getCurrentPlan() async {
    // 1. Try cache
    final cached = _hive.box<WorkoutPlan>('plans').get('current');
    if (cached != null && !_isStale(cached)) return cached;

    // 2. Fetch network
    final res = await _dio.get('/plan/current');
    final plan = WorkoutPlan.fromJson(res.data);

    // 3. Update cache
    await _hive.box<WorkoutPlan>('plans').put('current', plan);
    return plan;
  }
}

// providers/workout_providers.dart
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return WorkoutRepository(dio, Hive);
});

final currentPlanProvider = FutureProvider<WorkoutPlan>((ref) async {
  return ref.watch(workoutRepositoryProvider).getCurrentPlan();
});
```

UI consume via `ref.watch(currentPlanProvider).when(...)`.

## 4. Aturan Import

- File di `features/X/` boleh import:
  - `core/`, `shared/`, dan **HANYA** `features/X/...` (file dalam fitur sama)
- File di `features/X/` **TIDAK** boleh import langsung dari `features/Y/`
  - Jika butuh data fitur lain → ekspos via shared service di `core/` atau lewat Riverpod provider
- Ini mencegah coupling tinggi antar fitur.

## 5. Aturan File Size

- Maksimum ~300 baris per file. Jika lebih, refactor ke widget terpisah.
- Widget kompleks dipecah menjadi sub-widget privat (`_HeaderCard`, `_StatsRow`) di file sama, atau file terpisah jika reusable.

## 6. Test Setup (Minimum untuk Hackathon)

- Wajib unit test untuk `health_calculator.dart` (BMI/BMR/TDEE) — formula matematika, harus akurat.
- Wajib unit test untuk knapsack helper jika ada di FE.
- Widget test untuk `PrimaryButton` (loading state, disabled state).
- E2E test SKIP untuk hackathon — fokus pada manual QA.

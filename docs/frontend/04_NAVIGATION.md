# Frontend — Navigasi

> 📌 **Routes baru 2026-05-15** — tambahkan ke GoRouter config:
>
> ```dart
> GoRoute(path: '/workout/session/:sessionId',
>   builder: (c, s) => WorkoutSessionDetailScreen(sessionId: s.pathParameters['sessionId']!)),
> GoRoute(path: '/meal/swap/:mealId',
>   builder: (c, s) => MealSwapScreen(mealId: s.pathParameters['mealId']!)),
> GoRoute(path: '/meal/log/:mealId',
>   builder: (c, s) => MealLogScreen(mealId: s.pathParameters['mealId']!)),
> GoRoute(path: '/profile/health-metrics',
>   builder: (c, s) => const HealthMetricsScreen()),
> GoRoute(path: '/profile/plan-history',
>   builder: (c, s) => const PlanHistoryScreen()),
> GoRoute(path: '/replanning/evaluation', builder: (c, s) => const ReplanningEvaluationScreen()),
> GoRoute(path: '/replanning/update', builder: (c, s) => const ReplanningUpdateDataScreen()),
> GoRoute(path: '/replanning/choose', builder: (c, s) => const ReplanningChooseScreen()),
> GoRoute(path: '/replanning/ready', builder: (c, s) => const ReplanningReadyScreen()),
> ```
>
> Total route sekarang **40+** (sebelumnya ~28). Lihat `lib/router/app_router.dart` untuk implementasi final.

---

Sumber: `Heltigo_UI_Screens.docx` §2.

## 1. Bottom Navigation Bar (4 Tab)

Selalu tampil di layar utama. **Disembunyikan di:** setup profil (S-06..S-14), active workout (S-20), onboarding (S-01..S-05), fullscreen modal (S-34, S-35).

| Tab # | Label | Icon | Root Screen | Kode |
|---|---|---|---|---|
| 1 | Beranda | `Icons.home_rounded` | HomeScreen | S-15 |
| 2 | Latihan | `Icons.fitness_center` | WorkoutHomeScreen | S-16 |
| 3 | Nutrisi | `Icons.restaurant_menu` | NutritionHomeScreen | S-22 |
| 4 | Progres | `Icons.bar_chart_rounded` | ProgressDashboardScreen | S-26 |

### Style Navbar

```dart
BottomNavigationBar(
  type: BottomNavigationBarType.fixed,
  backgroundColor: Theme.of(context).cardTheme.color,
  selectedItemColor: AppColors.primary,
  unselectedItemColor: AppColors.textTertiary,
  showSelectedLabels: true,
  showUnselectedLabels: true,
  selectedLabelStyle: AppTextStyles.caption.copyWith(
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  ),
  unselectedLabelStyle: AppTextStyles.caption,
  elevation: 0,
)
```

Border atas 1px `AppColors.border`, height 64dp (`AppSizes.bottomNavHeight`).

State aktif: icon **filled** + label SemiBold + warna primary.
State tidak aktif: icon **outlined** + label Regular + warna textTertiary.

### Transisi Antar Tab

- `FadeTransition` saat ganti tab.
- Setiap tab punya **stack navigator independen** (StatefulShellRoute di GoRouter).
- Tab yang sama dipencet ulang → reset ke root screen tab tersebut.

---

## 2. GoRouter Config

File: `lib/core/router/app_router.dart`

```dart
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingPager()),
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),

      // Setup flow (linear)
      GoRoute(path: '/setup/step1', builder: (_, __) => const SetupStep1Basic()),
      GoRoute(path: '/setup/step2', builder: (_, __) => const SetupStep2Physical()),
      GoRoute(path: '/setup/step3', builder: (_, __) => const SetupStep3BmiResult()),
      GoRoute(path: '/setup/step4', builder: (_, __) => const SetupStep4Target()),
      GoRoute(path: '/setup/step5', builder: (_, __) => const SetupStep5Conditions()),
      GoRoute(path: '/setup/step6', builder: (_, __) => const SetupStep6WorkoutPref()),
      GoRoute(path: '/setup/step7', builder: (_, __) => const SetupStep7DietBudget()),
      GoRoute(path: '/setup/processing', builder: (_, __) => const SetupStep8Processing()),
      GoRoute(path: '/setup/plan-ready', builder: (_, __) => const SetupPlanReady()),

      // Main shell with bottom nav
      StatefulShellRoute.indexedStack(
        builder: (ctx, state, shell) => MainScaffold(shell: shell),
        branches: [
          // Branch 1 — Beranda
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              builder: (_, __) => const HomeScreen(),
              routes: [
                GoRoute(path: 'profile',
                  builder: (_, __) => const ProfileScreen(),
                  routes: [
                    GoRoute(path: 'edit', builder: (_, __) => const EditProfileScreen()),
                    GoRoute(path: 'notification-settings', builder: (_, __) => const NotificationSettingsScreen()),
                    GoRoute(path: 'app-settings', builder: (_, __) => const AppSettingsScreen()),
                  ],
                ),
              ],
            ),
          ]),
          // Branch 2 — Latihan
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/workout',
              builder: (_, __) => const WorkoutHomeScreen(),
              routes: [
                GoRoute(
                  path: 'day/:dayIndex',
                  builder: (ctx, state) => WorkoutDayScreen(
                    dayIndex: int.parse(state.pathParameters['dayIndex']!),
                  ),
                  routes: [
                    GoRoute(
                      path: 'exercise/:exerciseId',
                      builder: (ctx, state) => ExerciseDetailScreen(
                        exerciseId: state.pathParameters['exerciseId']!,
                      ),
                    ),
                    GoRoute(path: 'checkin', builder: (_, __) => const PreWorkoutCheckinScreen()),
                    GoRoute(path: 'active', builder: (_, __) => const ActiveWorkoutScreen()),
                    GoRoute(path: 'complete', builder: (_, __) => const WorkoutCompleteScreen()),
                  ],
                ),
              ],
            ),
          ]),
          // Branch 3 — Nutrisi
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/nutrition',
              builder: (_, __) => const NutritionHomeScreen(),
              routes: [
                GoRoute(path: 'meal/:mealId',
                  builder: (ctx, state) => MealDetailScreen(mealId: state.pathParameters['mealId']!),
                  routes: [
                    GoRoute(path: 'food/:foodId',
                      builder: (ctx, state) => FoodItemDetailScreen(foodId: state.pathParameters['foodId']!),
                    ),
                  ],
                ),
                GoRoute(path: 'budget-settings', builder: (_, __) => const BudgetSettingsScreen()),
              ],
            ),
          ]),
          // Branch 4 — Progres
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/progress',
              builder: (_, __) => const ProgressDashboardScreen(),
              routes: [
                GoRoute(path: 'badges', builder: (_, __) => const BadgesScreen()),
                GoRoute(path: 'weekly-report', builder: (_, __) => const WeeklyReportScreen()),
              ],
            ),
          ]),
        ],
      ),

      // Modal full-screen overlays (di luar shell)
      GoRoute(path: '/replanning/review', builder: (_, __) => const WeeklyReviewModal()),
      GoRoute(path: '/replanning/new-plan', builder: (_, __) => const NewPlanReadyScreen()),
    ],
    redirect: (context, state) {
      final auth = container.read(authStateProvider);
      // Logic redirect ke /welcome jika belum login,
      // ke /setup/step1 jika belum setup profile,
      // ke /home jika sudah lengkap
      // Detail di 06_STATE_MANAGEMENT.md
      return null;
    },
  );
});
```

---

## 3. Peta Navigasi Lengkap

### 3.1 Onboarding (5 layar)

```
SplashScreen (S-01)
  └─[2.5s auto / Cek Hive: profile ada?]
     ├─[ada]→ HomeScreen (S-15)
     └─[tidak ada]→ Onboarding1 (S-02)
                     └─[Lanjut/Swipe]→ Onboarding2 (S-03)
                                       └─[Lanjut/Swipe]→ Onboarding3 (S-04)
                                                         └─[Mulai]→ WelcomeScreen (S-05)
                                                                    ├─[Daftar]→ SignupScreen
                                                                    └─[Masuk]→ LoginScreen
                                                                              └─[Sukses]→ Setup Step 1 (S-06)
```

### 3.2 Setup Profil (9 layar, linear)

```
S-06 → S-07 → S-08 → S-09 → S-10 → S-11 → S-12 → S-13 → S-14 → HomeScreen (S-15)
```

- Back button kembali ke step sebelumnya.
- Data tiap step disimpan ke Riverpod state setup + Hive cache draft.
- Saat S-13 selesai (response /plan/generate sukses), navigasi otomatis ke S-14.
- Tap "Ayo Mulai!" di S-14 → push & replace ke `/home`.

### 3.3 Tab Latihan (6 layar)

```
WorkoutHome (S-16)
  └─[tap day]→ WorkoutDay (S-17)
                ├─[tap exercise]→ ExerciseDetail (S-18)
                └─[Mulai Latihan]→ PreWorkoutCheckin (S-19)
                                    └─[Ayo Mulai]→ ActiveWorkout (S-20)
                                                    └─[selesai/auto]→ WorkoutComplete (S-21)
                                                                       └─[Kembali]→ HomeScreen (S-15)
```

### 3.4 Tab Nutrisi (4 layar)

```
NutritionHome (S-22)
  ├─[tap meal section]→ MealDetail (S-23)
  │                       └─[tap food item]→ FoodItemDetail (S-24)
  └─[tap settings icon]→ BudgetSettings (S-25)
```

### 3.5 Tab Progres (4 layar)

```
ProgressDashboard (S-26)
  ├─[+ Catat Timbangan]→ AddWeight modal (S-27)
  ├─[Lencana]→ BadgesScreen (S-28)
  └─[Laporan]→ WeeklyReport (S-29)
```

### 3.6 Profil & Pengaturan (4 layar)

Akses: avatar di AppBar HomeScreen.

```
HomeScreen → ProfileScreen (S-30)
              ├─[Edit Profil]→ EditProfile (S-31)
              ├─[Notifikasi]→ NotificationSettings (S-32)
              └─[Tema/Pengaturan]→ AppSettings (S-33)
```

### 3.7 Replanning Otomatis (2 layar)

Trigger: notifikasi push setiap Sunday 20:00, atau tap "Lihat Rencana" di S-29.

```
WeeklyReviewModal (S-34) — fullscreen
  └─[Lihat Rencana Minggu Depan]→ NewPlanReady (S-35)
                                    └─[Mulai Minggu Baru]→ HomeScreen (S-15) — reset tab Latihan ke minggu baru
```

---

## 4. Layout Wrapper: MainScaffold

File: `lib/shared/widgets/scaffold/main_scaffold.dart`

Wrapper untuk semua layar dengan bottom nav. StatefulShellRoute auto preserve state per tab.

```dart
class MainScaffold extends StatelessWidget {
  const MainScaffold({required this.shell, super.key});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: shell.currentIndex,
        onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center_outlined), activeIcon: Icon(Icons.fitness_center), label: 'Latihan'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu_outlined), activeIcon: Icon(Icons.restaurant_menu), label: 'Nutrisi'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart_rounded), label: 'Progres'),
        ],
      ),
    );
  }
}
```

---

## 5. Layout Wrapper: SetupScaffold

File: `lib/shared/widgets/scaffold/setup_scaffold.dart`

Wrapper untuk semua layar setup (S-06..S-12). AppBar transparan, progress bar, step label, scrollable content, sticky button bawah.

```dart
class SetupScaffold extends StatelessWidget {
  const SetupScaffold({
    required this.step,                  // 1..8
    required this.title,
    required this.subtitle,
    required this.body,
    required this.primaryButton,
    super.key,
  });

  final int step;
  final String title;
  final String subtitle;
  final Widget body;
  final Widget primaryButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: step / 8,
                      minHeight: 6,
                      backgroundColor: AppColors.surface,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text('Langkah $step dari 8', style: AppTextStyles.caption),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary)),
                    const SizedBox(height: AppSizes.sm),
                    Text(subtitle, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: AppSizes.xl),
                    body,
                    const SizedBox(height: AppSizes.xxl),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.base),
              child: primaryButton,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 6. Catatan Implementasi

- **Deep link**: tidak prioritas hackathon, tapi GoRouter siap.
- **Back gesture iOS**: pakai default GoRouter behavior; jangan override kecuali kasus khusus.
- **Navigasi dari notifikasi**: handle di `notification_service.dart` → `appRouter.go(...)`.
- **Replanning auto-trigger**: saat user buka app pada hari Senin, cek apakah ada `pendingWeeklyReview` di Hive → jika ya, push `/replanning/review`.

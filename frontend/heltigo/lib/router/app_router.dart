/// App Router — GoRouter configuration dengan auth guard.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:heltigo/service_locator.dart';
import 'package:heltigo/providers/auth_provider.dart';

// Screens
import 'package:heltigo/screens/splash/splash_screen.dart';
import 'package:heltigo/screens/splash/onboarding_screen.dart';
import 'package:heltigo/screens/auth/login_screen.dart';
import 'package:heltigo/screens/auth/register_screen.dart';
import 'package:heltigo/screens/auth/forgot_password_screen.dart';
import 'package:heltigo/screens/setup/setup_basic_info_screen.dart';
import 'package:heltigo/screens/setup/setup_physical_screen.dart';
import 'package:heltigo/screens/setup/setup_bmi_result_screen.dart';
import 'package:heltigo/screens/setup/setup_goal_screen.dart';
import 'package:heltigo/screens/setup/setup_conditions_screen.dart';
import 'package:heltigo/screens/setup/setup_fitness_level_screen.dart';
import 'package:heltigo/screens/setup/setup_preferences_screen.dart';
import 'package:heltigo/screens/plan/plan_generating_screen.dart';
import 'package:heltigo/screens/plan/plan_ready_screen.dart';
import 'package:heltigo/screens/main/main_scaffold.dart';
import 'package:heltigo/screens/workout/pre_workout_checkin_screen.dart';
import 'package:heltigo/screens/workout/active_workout_screen.dart';
import 'package:heltigo/screens/workout/workout_complete_screen.dart';
import 'package:heltigo/screens/workout/workout_detail_screen.dart';
import 'package:heltigo/screens/workout/exercise_detail_screen.dart';
import 'package:heltigo/screens/workout/workout_session_detail_screen.dart';
import 'package:heltigo/screens/meal/meal_detail_screen.dart';
import 'package:heltigo/screens/meal/meal_swap_screen.dart';
import 'package:heltigo/screens/meal/meal_log_screen.dart';
import 'package:heltigo/screens/meal/food_item_detail_screen.dart';
import 'package:heltigo/screens/meal/budget_settings_screen.dart';
import 'package:heltigo/screens/meal/food_scan_screen.dart';
import 'package:heltigo/screens/progress/weekly_review_screen.dart';
import 'package:heltigo/screens/progress/badge_gallery_screen.dart';
import 'package:heltigo/screens/progress/streak_detail_screen.dart';
import 'package:heltigo/screens/profile/profile_screen.dart';
import 'package:heltigo/screens/profile/edit_profile_screen.dart';
import 'package:heltigo/screens/profile/health_metrics_screen.dart';
import 'package:heltigo/screens/profile/plan_history_screen.dart';
import 'package:heltigo/screens/settings/settings_screen.dart';
import 'package:heltigo/screens/settings/about_screen.dart';
import 'package:heltigo/screens/notification/notification_screen.dart';
import 'package:heltigo/screens/error/error_screen.dart';

import 'package:heltigo/screens/replanning/replanning_evaluation_screen.dart';
import 'package:heltigo/screens/replanning/replanning_update_data_screen.dart';
import 'package:heltigo/screens/replanning/replanning_choose_screen.dart';
import 'package:heltigo/screens/replanning/replanning_ready_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Path yang BOLEH diakses tanpa login.
const _publicRoutes = {
  '/',
  '/onboarding',
  '/login',
  '/register',
  '/forgot-password',
};

/// Path 7 setup wizard — boleh diakses kalau login tapi belum punya profile.
bool _isSetupRoute(String location) =>
    location.startsWith('/setup-') ||
    location == '/plan-generating' ||
    location == '/plan-ready';

class AppRouter {
  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: getIt<AuthProvider>(),
    redirect: (context, state) {
      final auth = getIt<AuthProvider>();
      final loc = state.matchedLocation;
      final isPublic = _publicRoutes.contains(loc);

      // Splash selalu jalan dulu (untuk render animasi)
      if (loc == '/') return null;

      // Belum login + bukan public → ke /login
      if (!auth.isLoggedIn && !isPublic) {
        return '/login';
      }

      // Sudah login + di public auth route → langsung ke home
      if (auth.isLoggedIn && (loc == '/login' || loc == '/register')) {
        return auth.hasHealthProfile ? '/home' : '/setup-profile';
      }

      // Sudah login tapi belum punya health profile + bukan setup → paksa setup
      if (auth.isLoggedIn &&
          !auth.hasHealthProfile &&
          !_isSetupRoute(loc) &&
          !isPublic) {
        return '/setup-profile';
      }

      return null;
    },
    routes: [
      // ═══ SPLASH & ONBOARDING ═══
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),

      // ═══ AUTH ═══
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),

      // ═══ SETUP PROFILE (7 steps) ═══
      GoRoute(
        path: '/setup-profile',
        builder: (_, __) => const SetupBasicInfoScreen(),
      ),
      GoRoute(
        path: '/setup-physical',
        builder: (_, __) => const SetupPhysicalScreen(),
      ),
      GoRoute(
        path: '/setup-bmi-result',
        builder: (_, __) => const SetupBmiResultScreen(),
      ),
      GoRoute(
        path: '/setup-goal',
        builder: (_, __) => const SetupGoalScreen(),
      ),
      GoRoute(
        path: '/setup-conditions',
        builder: (_, __) => const SetupConditionsScreen(),
      ),
      GoRoute(
        path: '/setup-fitness-level',
        builder: (_, __) => const SetupFitnessLevelScreen(),
      ),
      GoRoute(
        path: '/setup-preferences',
        builder: (_, __) => const SetupPreferencesScreen(),
      ),

      // ═══ PLAN GENERATION ═══
      GoRoute(
        path: '/plan-generating',
        builder: (_, __) => const PlanGeneratingScreen(),
      ),
      GoRoute(
        path: '/plan-ready',
        builder: (_, __) => const PlanReadyScreen(),
      ),

      // ═══ MAIN SCAFFOLD (4 tabs) ═══
      GoRoute(
        path: '/home',
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: MainScaffold(initialIndex: 0)),
      ),
      GoRoute(
        path: '/workout',
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: MainScaffold(initialIndex: 1)),
      ),
      GoRoute(
        path: '/meal',
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: MainScaffold(initialIndex: 2)),
      ),
      GoRoute(
        path: '/progress',
        pageBuilder: (_, __) =>
            const NoTransitionPage(child: MainScaffold(initialIndex: 3)),
      ),

      // ═══ WORKOUT SUB-SCREENS ═══
      GoRoute(
        path: '/workout/checkin/:workoutId',
        builder: (_, state) => PreWorkoutCheckInScreen(
          workoutId: state.pathParameters['workoutId']!,
        ),
      ),
      GoRoute(
        path: '/workout/active/:workoutId',
        builder: (_, state) => ActiveWorkoutScreen(
          workoutId: state.pathParameters['workoutId']!,
        ),
      ),
      GoRoute(
        path: '/workout/complete/:workoutId',
        builder: (_, state) => WorkoutCompleteScreen(
          workoutId: state.pathParameters['workoutId']!,
        ),
      ),
      GoRoute(
        path: '/workout/detail/:workoutId',
        builder: (_, state) => WorkoutDetailScreen(
          workoutId: state.pathParameters['workoutId']!,
        ),
      ),
      GoRoute(
        path: '/workout/exercise/:exerciseId',
        builder: (_, state) => ExerciseDetailScreen(
          exerciseId: state.pathParameters['exerciseId']!,
        ),
      ),
      GoRoute(
        path: '/workout/session/:sessionId',
        builder: (_, state) => WorkoutSessionDetailScreen(
          sessionId: state.pathParameters['sessionId']!,
        ),
      ),

      // ═══ MEAL SUB-SCREENS ═══
      GoRoute(
        path: '/meal/detail/:mealId',
        builder: (_, state) => MealDetailScreen(
          mealId: state.pathParameters['mealId']!,
        ),
      ),
      GoRoute(
        path: '/meal/swap/:mealId',
        builder: (_, state) =>
            MealSwapScreen(mealId: state.pathParameters['mealId']!),
      ),
      GoRoute(
        path: '/meal/food/:foodId',
        builder: (_, state) =>
            FoodItemDetailScreen(foodId: state.pathParameters['foodId']!),
      ),
      GoRoute(
        path: '/meal/budget-settings',
        builder: (_, __) => const BudgetSettingsScreen(),
      ),
      GoRoute(
        path: '/meal/food-scan',
        builder: (_, __) => const FoodScanScreen(),
      ),
      GoRoute(
        path: '/meal/log/:mealId',
        builder: (_, state) =>
            MealLogScreen(mealId: state.pathParameters['mealId']!),
      ),

      // ═══ PROGRESS SUB-SCREENS ═══
      GoRoute(
        path: '/progress/weekly-review',
        builder: (_, __) => const WeeklyReviewScreen(),
      ),
      GoRoute(
        path: '/progress/badges',
        builder: (_, __) => const BadgeGalleryScreen(),
      ),
      GoRoute(
        path: '/progress/streak',
        builder: (_, __) => const StreakDetailScreen(),
      ),

      // ═══ PROFILE SUB-SCREENS ═══
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(
        path: '/profile/edit',
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/health-metrics',
        builder: (_, __) => const HealthMetricsScreen(),
      ),
      GoRoute(
        path: '/profile/plan-history',
        builder: (_, __) => const PlanHistoryScreen(),
      ),

      // ═══ SETTINGS & INFO ═══
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/about', builder: (_, __) => const AboutScreen()),
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationScreen(),
      ),

      // ═══ REPLANNING FLOW ═══
      GoRoute(
        path: '/replanning/evaluation',
        builder: (_, __) => const ReplanningEvaluationScreen(),
      ),
      GoRoute(
        path: '/replanning/update',
        builder: (_, __) => const ReplanningUpdateDataScreen(),
      ),
      GoRoute(
        path: '/replanning/choose',
        builder: (_, __) => const ReplanningChooseScreen(),
      ),
      GoRoute(
        path: '/replanning/ready',
        builder: (_, __) => const ReplanningReadyScreen(),
      ),
    ],
    errorBuilder: (_, state) => ErrorScreen(message: state.error?.message),
  );
}

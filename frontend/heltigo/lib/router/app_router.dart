/// App Router — GoRouter configuration
/// Sumber: docs/frontend/04_NAVIGATION.md
/// Pattern: sama dengan reference repo (app_router.dart)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

// Replanning flow
import 'package:heltigo/screens/replanning/replanning_evaluation_screen.dart';
import 'package:heltigo/screens/replanning/replanning_update_data_screen.dart';
import 'package:heltigo/screens/replanning/replanning_choose_screen.dart';
import 'package:heltigo/screens/replanning/replanning_ready_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // ═══════════════════════════════════════
      // SPLASH & ONBOARDING
      // ═══════════════════════════════════════
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ═══════════════════════════════════════
      // AUTH
      // ═══════════════════════════════════════
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ═══════════════════════════════════════
      // SETUP PROFILE (7 steps)
      // Flow: basic → physical → bmi → goal → conditions → fitness → preferences
      // ═══════════════════════════════════════
      GoRoute(
        path: '/setup-profile',
        builder: (context, state) => const SetupBasicInfoScreen(),
      ),
      GoRoute(
        path: '/setup-physical',
        builder: (context, state) => const SetupPhysicalScreen(),
      ),
      GoRoute(
        path: '/setup-bmi-result',
        builder: (context, state) => const SetupBmiResultScreen(),
      ),
      GoRoute(
        path: '/setup-goal',
        builder: (context, state) => const SetupGoalScreen(),
      ),
      GoRoute(
        path: '/setup-conditions',
        builder: (context, state) => const SetupConditionsScreen(),
      ),
      GoRoute(
        path: '/setup-fitness-level',
        builder: (context, state) => const SetupFitnessLevelScreen(),
      ),
      GoRoute(
        path: '/setup-preferences',
        builder: (context, state) => const SetupPreferencesScreen(),
      ),

      // ═══════════════════════════════════════
      // PLAN GENERATION
      // ═══════════════════════════════════════
      GoRoute(
        path: '/plan-generating',
        builder: (context, state) => const PlanGeneratingScreen(),
      ),
      GoRoute(
        path: '/plan-ready',
        builder: (context, state) => const PlanReadyScreen(),
      ),

      // ═══════════════════════════════════════
      // MAIN SCAFFOLD (4 tabs via Bottom Nav)
      // ═══════════════════════════════════════
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: MainScaffold(initialIndex: 0),
        ),
      ),
      GoRoute(
        path: '/workout',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: MainScaffold(initialIndex: 1),
        ),
      ),
      GoRoute(
        path: '/meal',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: MainScaffold(initialIndex: 2),
        ),
      ),
      GoRoute(
        path: '/progress',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: MainScaffold(initialIndex: 3),
        ),
      ),

      // ═══════════════════════════════════════
      // WORKOUT SUB-SCREENS
      // ═══════════════════════════════════════
      GoRoute(
        path: '/workout/checkin/:workoutId',
        builder: (context, state) => PreWorkoutCheckInScreen(
          workoutId: state.pathParameters['workoutId']!,
        ),
      ),
      GoRoute(
        path: '/workout/active/:workoutId',
        builder: (context, state) => ActiveWorkoutScreen(
          workoutId: state.pathParameters['workoutId']!,
        ),
      ),
      GoRoute(
        path: '/workout/complete/:workoutId',
        builder: (context, state) => WorkoutCompleteScreen(
          workoutId: state.pathParameters['workoutId']!,
        ),
      ),
      GoRoute(
        path: '/workout/detail/:workoutId',
        builder: (context, state) => WorkoutDetailScreen(
          workoutId: state.pathParameters['workoutId']!,
        ),
      ),
      GoRoute(
        path: '/workout/exercise/:exerciseId',
        builder: (context, state) => ExerciseDetailScreen(
          exerciseId: state.pathParameters['exerciseId']!,
        ),
      ),
      GoRoute(
        path: '/workout/session/:sessionId',
        builder: (context, state) => WorkoutSessionDetailScreen(
          sessionId: state.pathParameters['sessionId']!,
        ),
      ),

      // ═══════════════════════════════════════
      // MEAL SUB-SCREENS
      // ═══════════════════════════════════════
      GoRoute(
        path: '/meal/detail/:mealId',
        builder: (context, state) => MealDetailScreen(
          mealId: state.pathParameters['mealId']!,
        ),
      ),
      GoRoute(
        path: '/meal/swap/:mealId',
        builder: (context, state) => MealSwapScreen(
          mealId: state.pathParameters['mealId']!,
        ),
      ),
      GoRoute(
        path: '/meal/food/:foodId',
        builder: (context, state) => FoodItemDetailScreen(
          foodId: state.pathParameters['foodId']!,
        ),
      ),
      GoRoute(
        path: '/meal/budget-settings',
        builder: (context, state) => const BudgetSettingsScreen(),
      ),
      GoRoute(
        path: '/meal/log/:mealId',
        builder: (context, state) => MealLogScreen(
          mealId: state.pathParameters['mealId']!,
        ),
      ),

      // ═══════════════════════════════════════
      // PROGRESS SUB-SCREENS
      // ═══════════════════════════════════════
      GoRoute(
        path: '/progress/weekly-review',
        builder: (context, state) => const WeeklyReviewScreen(),
      ),
      GoRoute(
        path: '/progress/badges',
        builder: (context, state) => const BadgeGalleryScreen(),
      ),
      GoRoute(
        path: '/progress/streak',
        builder: (context, state) => const StreakDetailScreen(),
      ),

      // ═══════════════════════════════════════
      // PROFILE SUB-SCREENS
      // ═══════════════════════════════════════
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/health-metrics',
        builder: (context, state) => const HealthMetricsScreen(),
      ),
      GoRoute(
        path: '/profile/plan-history',
        builder: (context, state) => const PlanHistoryScreen(),
      ),

      // ═══════════════════════════════════════
      // SETTINGS & INFO
      // ═══════════════════════════════════════
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationScreen(),
      ),

      // ═══════════════════════════════════════
      // REPLANNING FLOW (4 step)
      // ═══════════════════════════════════════
      GoRoute(
        path: '/replanning/evaluation',
        builder: (context, state) => const ReplanningEvaluationScreen(),
      ),
      GoRoute(
        path: '/replanning/update',
        builder: (context, state) => const ReplanningUpdateDataScreen(),
      ),
      GoRoute(
        path: '/replanning/choose',
        builder: (context, state) => const ReplanningChooseScreen(),
      ),
      GoRoute(
        path: '/replanning/ready',
        builder: (context, state) => const ReplanningReadyScreen(),
      ),
    ],

    // Error handler
    errorBuilder: (context, state) => ErrorScreen(
      message: state.error?.message,
    ),
  );
}

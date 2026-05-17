/// Heltigo API Endpoints
/// Base URL dibaca dari `.env` (key: `API_BASE_URL`) saat startup via flutter_dotenv.
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  /// Default fallback ke ngrok dev URL. Override via `.env` file.
  static const String _defaultBaseUrl =
      'https://cheryll-unintelligent-fuzzily.ngrok-free.dev/api/v1';

  /// Base URL aktif. Dibaca dari `.env` saat app start. Fallback ke default
  /// jika `.env` belum di-load atau key tidak ada.
  static String get baseUrl =>
      dotenv.maybeGet('API_BASE_URL') ?? _defaultBaseUrl;

  // === AUTH ===
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String getMe = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // === USER PROFILE ===
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String updateAvatar = '/user/profile/avatar';

  // === HEALTH PROFILE (onboarding) ===
  static const String createHealthProfile = '/user/health-profile';
  static const String updateHealthProfile = '/user/health-profile';

  // === HEALTH METRICS (BMI/weight log) ===
  static const String healthMetrics = '/user/health-metrics';
  static const String healthMetricsHistory = '/user/health-metrics/history';

  // === PLAN GENERATION ===
  static const String generatePlan = '/plan/generate';
  static const String activePlan = '/plan/active';
  static const String planHistory = '/plan/history';
  static String planById(String id) => '/plan/$id';

  // === REPLANNING ===
  static const String replan = '/plan/replan';
  static const String replanSkip = '/plan/replan/skip';

  // === WORKOUT ===
  static const String todayWorkout = '/workout/today';
  static const String workoutSessions = '/workout/sessions';
  static String workoutDayDetail(String dayId) => '/workout/day/$dayId';
  static String workoutExerciseDetail(String exerciseId) =>
      '/workout/exercise/$exerciseId';
  static String workoutCheckIn(String dayId) => '/workout/$dayId/check-in';
  static String workoutSessionDetail(String sessionId) =>
      '/workout/session/$sessionId';
  static String workoutSessionComplete(String sessionId) =>
      '/workout/session/$sessionId/complete';
  static String workoutSessionPause(String sessionId) =>
      '/workout/session/$sessionId/pause';
  static String workoutSessionUpdateExercise(String sessionId) =>
      '/workout/session/$sessionId/exercise';
  static String workoutExerciseSwap(String exerciseId) =>
      '/workout/exercise/$exerciseId/swap';

  // === MEAL ===
  static const String todayMeal = '/meal/today';
  static const String mealLog = '/meal/log';
  static const String updateBudget = '/meal/budget';
  static const String foodScan = '/meal/food-scan';
  static String mealDayDetail(String dayId) => '/meal/day/$dayId';
  static String mealDetail(String mealId) => '/meal/$mealId';
  static String logMeal(String mealId) => '/meal/$mealId/log';
  static String mealSwap(String mealId) => '/meal/$mealId/swap';
  static String mealReplace(String mealId) => '/meal/$mealId/replace';
  static String foodDetail(String foodId) => '/meal/food/$foodId';

  // === PROGRESS ===
  static const String dailyProgress = '/progress/daily';
  static const String updateWater = '/progress/daily/water';
  static const String logMood = '/progress/daily/mood';
  static const String weeklyProgress = '/progress/weekly';
  static const String weeklyReview = '/progress/weekly-review';
  static const String streak = '/progress/streak';
  static const String badges = '/progress/badges';
  static String badgeDetail(String code) => '/progress/badge/$code';
  static const String shareImage = '/progress/share-image';

  // === NOTIFICATIONS ===
  static const String notifications = '/notifications';
  static const String readAllNotifications = '/notifications/read-all';
  static const String fcmToken = '/notifications/fcm-token';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static const String registerFcmToken = '/notifications/fcm-token';

  // === SETTINGS ===
  static const String settings = '/settings';

  // === SYNC (offline queue) ===
  static const String syncBatch = '/sync/batch';
}

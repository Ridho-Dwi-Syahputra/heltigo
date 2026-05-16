/// Heltigo API Endpoints
/// Sumber: docs/backend/04_API_ENDPOINTS.md
class ApiEndpoints {
  // Base URL — dikonfigurasi via environment
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api/v1',
  );

  // === AUTH ===
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';

  // === USER PROFILE ===
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';

  // === HEALTH METRICS (BMI/TDEE) ===
  static const String healthMetrics = '/user/health-metrics';
  static const String healthMetricsHistory = '/user/health-metrics/history';

  // === PLAN GENERATION ===
  static const String generatePlan = '/plan/generate';
  static const String activePlan = '/plan/active';
  static const String planHistory = '/plan/history';

  // === WORKOUT ===
  static const String todayWorkout = '/workout/today';
  static String workoutDetail(String id) => '/workout/$id';
  static String workoutCheckIn(String id) => '/workout/$id/check-in';
  static String workoutComplete(String id) => '/workout/$id/complete';
  static String exerciseComplete(String id) => '/workout/$id/exercise/complete';

  // === MEAL ===
  static const String todayMeal = '/meal/today';
  static String mealDetail(String id) => '/meal/$id';
  static String mealLog(String id) => '/meal/$id/log';
  static String mealSwap(String id) => '/meal/$id/swap';

  // === PROGRESS ===
  static const String weeklyProgress = '/progress/weekly';
  static const String dailyProgress = '/progress/daily';
  static const String streak = '/progress/streak';
  static const String badges = '/progress/badges';

  // === REPLANNING ===
  static const String replan = '/plan/replan';

  // === SYNC (offline queue) ===
  static const String syncBatch = '/sync/batch';
}

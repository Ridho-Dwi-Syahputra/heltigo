/// App Constants — konfigurasi global aplikasi
/// Sumber: docs/frontend/01_OVERVIEW.md
class AppConstants {
  // App Info
  static const String appName = 'Heltigo';
  static const String appTagline = 'Your AI Health Partner';

  // Storage Keys
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String onboardingKey = 'onboarding_completed';
  static const String themeKey = 'theme_mode';
  static const String cacheTTLKey = 'cache_ttl';

  // Cache
  static const Duration cacheTTL = Duration(minutes: 30);

  // Pagination
  static const int defaultPageSize = 20;

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 10);
  static const Duration syncInterval = Duration(minutes: 5);
}

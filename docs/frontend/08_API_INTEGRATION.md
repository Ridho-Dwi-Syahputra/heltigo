# Frontend — API Integration

> 📌 **Source of truth API 2026-05-15:** [`../backend/FE_requirement/00_API_REQUIREMENTS.md`](../backend/FE_requirement/00_API_REQUIREMENTS.md).
>
> Dokumen lama `docs/backend/04_API_ENDPOINTS.md` sudah **deprecated**. Endpoint path baru:
> - `/auth/register` (bukan `/v1/auth/signup`)
> - `/user/profile`, `/user/health-profile`, `/user/health-metrics` (split, bukan unified `/profile`)
> - `PATCH /progress/daily/water` (increment-only, bukan `POST /nutrition/hydration`)
> - `POST /workout/:dayId/check-in`, `PATCH .../exercise`, `POST .../complete` (granular, bukan single endpoint)
> - `POST /meal/:id/swap` + `POST /meal/:id/replace` (2-step)
> - Tambah: `/auth/refresh-token`, `/workout/session/:id`, `/meal/food/:id`, `/sync/batch`
>
> Body case: **camelCase** (bukan snake_case). Auth header: `Bearer <accessToken>` (15 min TTL, refresh via `/auth/refresh-token`).

---

Sumber kontrak API: [`../backend/FE_requirement/00_API_REQUIREMENTS.md`](../backend/FE_requirement/00_API_REQUIREMENTS.md). Dokumen ini fokus ke implementasi client di Flutter.

## 1. Konfigurasi Environment

File: `lib/core/env.dart`

```dart
class Env {
  Env({required this.apiBaseUrl, required this.appEnv});
  final String apiBaseUrl;
  final String appEnv;  // 'dev' | 'staging' | 'prod'

  static Env fromDartDefine() {
    return Env(
      apiBaseUrl: const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:3000/v1'),
      appEnv: const String.fromEnvironment('APP_ENV', defaultValue: 'dev'),
    );
  }
}

final envProvider = Provider<Env>((_) => Env.fromDartDefine());
```

Build dengan environment:
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/v1
flutter build apk --dart-define=API_BASE_URL=https://heltigo-api.staging.com/v1 --dart-define=APP_ENV=staging
```

**Catatan:** `10.0.2.2` adalah loopback ke host dari Android emulator. Untuk iOS simulator pakai `localhost`. Untuk physical device pakai LAN IP.

## 2. Dio Client Setup

File: `lib/core/http/dio_client.dart`

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';
import 'logging_interceptor.dart';
import '../env.dart';

final dioClientProvider = Provider<Dio>((ref) {
  final env = ref.watch(envProvider);
  final dio = Dio(BaseOptions(
    baseUrl: env.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  dio.interceptors.addAll([
    AuthInterceptor(ref),
    if (env.appEnv == 'dev') LoggingInterceptor(),
    ErrorInterceptor(),
  ]);

  return dio;
});
```

## 3. AuthInterceptor

File: `lib/core/http/auth_interceptor.dart`

```dart
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._ref);
  final Ref _ref;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final skipPaths = ['/auth/signup', '/auth/login'];
    if (skipPaths.any((p) => options.path.contains(p))) {
      return handler.next(options);
    }

    final token = await _ref.read(secureStorageProvider).read('token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired or invalid → logout
      await _ref.read(authStateProvider.notifier).logout();
      // Optional: trigger redirect ke /welcome via router
    }
    handler.next(err);
  }
}
```

## 4. ErrorInterceptor

File: `lib/core/http/error_interceptor.dart`

```dart
class ApiException implements Exception {
  ApiException({required this.code, required this.message, this.statusCode});
  final String code;
  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($code): $message';
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiError = _toApiException(err);
    handler.next(err.copyWith(error: apiError));
  }

  ApiException _toApiException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          code: 'TIMEOUT',
          message: 'Koneksi terlalu lambat. Coba lagi nanti.',
          statusCode: null,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          code: 'NO_CONNECTION',
          message: 'Tidak dapat terhubung ke server. Periksa koneksi internetmu.',
          statusCode: null,
        );
      case DioExceptionType.badResponse:
        final data = err.response?.data;
        if (data is Map && data['error'] is Map) {
          return ApiException(
            code: data['error']['code'] ?? 'UNKNOWN',
            message: data['error']['message'] ?? 'Terjadi kesalahan',
            statusCode: err.response?.statusCode,
          );
        }
        return ApiException(
          code: 'SERVER_ERROR',
          message: 'Server error (${err.response?.statusCode})',
          statusCode: err.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return ApiException(code: 'CANCELLED', message: 'Permintaan dibatalkan');
      default:
        return ApiException(code: 'UNKNOWN', message: 'Terjadi kesalahan yang tidak diketahui');
    }
  }
}
```

## 5. Repository Pattern

Setiap fitur punya `<Feature>Repository` yang abstrak detail HTTP. UI tidak panggil Dio langsung.

### Contoh: AuthRepository

```dart
class AuthRepository {
  AuthRepository(this._dio);
  final Dio _dio;

  Future<AuthResponse> signup(String email, String password) async {
    final res = await _dio.post('/auth/signup', data: {
      'email': email,
      'password': password,
    });
    return AuthResponse.fromJson(res.data);
  }

  Future<AuthResponse> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return AuthResponse.fromJson(res.data);
  }

  Future<User> me() async {
    final res = await _dio.get('/auth/me');
    return User.fromJson(res.data['user']);
  }
}

final authRepoProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioClientProvider));
});
```

### Contoh: PlanRepository

```dart
class PlanRepository {
  PlanRepository(this._dio, this._cache);
  final Dio _dio;
  final Box<Plan> _cache;

  Future<Plan> getCurrentPlan() async {
    final cached = _cache.get('current');
    final cachedAt = _cache.get('current_cached_at') as DateTime?;
    final isStale = cachedAt == null ||
        DateTime.now().difference(cachedAt) > const Duration(minutes: 30);

    if (cached != null && !isStale) return cached;

    try {
      final res = await _dio.get('/plan/current');
      final plan = Plan.fromJson(res.data['plan']);
      await _cache.put('current', plan);
      await _cache.put('current_cached_at', DateTime.now());
      return plan;
    } on DioException {
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<Plan> generate() async {
    // Profile sudah disubmit di repo profile, plan generate butuh user_id (dari JWT)
    final res = await _dio.post('/plan/generate');
    final plan = Plan.fromJson(res.data['plan']);
    await _cache.put('current', plan);
    await _cache.put('current_cached_at', DateTime.now());
    return plan;
  }

  Future<Plan> replan() async {
    final res = await _dio.post('/plan/replan');
    final plan = Plan.fromJson(res.data['plan']);
    await _cache.put('current', plan);
    await _cache.put('current_cached_at', DateTime.now());
    return plan;
  }
}

final planRepositoryProvider = Provider<PlanRepository>((ref) {
  return PlanRepository(
    ref.watch(dioClientProvider),
    ref.watch(hiveProvider).box<Plan>(HiveBoxes.plans),
  );
});
```

## 6. DTO / Model dengan json_serializable (Opsional) atau Manual

Untuk kecepatan hackathon, **manual `fromJson` / `toJson`** lebih cepat dari setup `json_serializable`. Contoh:

```dart
class Plan {
  Plan({
    required this.id,
    required this.weekNumber,
    required this.startDate,
    required this.workoutDays,
    required this.mealDays,
  });

  final String id;
  final int weekNumber;
  final DateTime startDate;
  final List<WorkoutDay> workoutDays;
  final List<MealDay> mealDays;

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
        id: json['id'] as String,
        weekNumber: json['week_number'] as int,
        startDate: DateTime.parse(json['start_date'] as String),
        workoutDays: (json['workout_days'] as List)
            .map((e) => WorkoutDay.fromJson(e as Map<String, dynamic>))
            .toList(),
        mealDays: (json['meal_days'] as List)
            .map((e) => MealDay.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'week_number': weekNumber,
        'start_date': startDate.toIso8601String(),
        'workout_days': workoutDays.map((e) => e.toJson()).toList(),
        'meal_days': mealDays.map((e) => e.toJson()).toList(),
      };
}
```

Jika tipe yang disimpan ke Hive, tambahkan `@HiveType(typeId: ...)` annotation dan generate adapter dengan `build_runner`.

## 7. Endpoint yang Wajib Diintegrasikan (Mapping Layar → API)

| Layar | Endpoint | Method |
|---|---|---|
| Signup | `/auth/signup` | POST |
| Login | `/auth/login` | POST |
| Splash (cek user) | `/auth/me` | GET |
| Setup S-12 → S-13 (submit profile) | `/profile` | POST |
| Setup S-13 (generate) | `/plan/generate` | POST |
| Plan Ready (S-14), Home (S-15), Workout Home (S-16) | `/plan/current` | GET |
| Daily Summary (S-15) | `/progress/summary` | GET |
| Workout Day (S-17) checklist | `/workout/checklist` | POST |
| Pre-checkin (S-19) | `/workout/checkin` | POST |
| Workout Complete (S-21) log | `/workout/log` | POST |
| Workout Complete mood after | `/workout/mood-after` | POST |
| Nutrition Home (S-22) | `/nutrition/day?date=X` | GET |
| Nutrition checklist | `/nutrition/checklist` | POST |
| Nutrition hydration | `/nutrition/hydration` | POST |
| Meal Detail (S-23) request alternatif | `/nutrition/alternative` | POST |
| Food Item Detail (S-24) | `/foods/:id` | GET |
| Budget Settings (S-25) | `/profile` (update budget field) | PUT |
| Progress Dashboard (S-26) | `/progress/summary`, `/progress/weight-history?weeks=4` | GET |
| Add Weight (S-27) | `/progress/weight` | POST |
| Badges (S-28) | `/progress/badges` | GET |
| Weekly Report (S-29) | `/report/weekly?week=N` | GET |
| Edit Profile (S-31) | `/profile` | PUT |
| Notification Settings (S-32) | `/profile/notification-prefs` | PUT |
| Replanning (S-34) trigger manual | `/plan/replan` | POST |
| Sync queue drain | `/sync/batch` | POST |

## 8. Retry & Resilience

Pakai `dio` retry pattern manual atau library `dio_retry` (opsional). Untuk hackathon, manual:

```dart
Future<T> withRetry<T>(Future<T> Function() task, {int maxAttempts = 3}) async {
  var attempt = 0;
  while (true) {
    try {
      return await task();
    } on DioException catch (e) {
      attempt++;
      final shouldRetry = (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.connectionError ||
              (e.response?.statusCode != null && e.response!.statusCode! >= 500)) &&
          attempt < maxAttempts;
      if (!shouldRetry) rethrow;
      await Future.delayed(Duration(milliseconds: 500 * attempt));
    }
  }
}
```

Apply hanya untuk read endpoint (GET) atau idempotent POST (sync queue dengan UUID).

## 9. Loading & Error UI di UI Layer

```dart
final planAsync = ref.watch(currentPlanProvider);

planAsync.when(
  loading: () => const HomeSkeletonWidget(),
  error: (error, stack) {
    if (error is DioException) {
      final api = error.error as ApiException?;
      return ErrorState(
        title: api?.code == 'NO_CONNECTION' ? 'Offline' : 'Gagal Memuat',
        message: api?.message ?? error.message ?? 'Tidak diketahui',
        onRetry: () => ref.invalidate(currentPlanProvider),
      );
    }
    return ErrorState(message: error.toString());
  },
  data: (plan) => HomeContent(plan: plan),
);
```

## 10. Logging (Dev Only)

File: `lib/core/http/logging_interceptor.dart`

```dart
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('→ ${options.method} ${options.uri}');
    if (options.data != null) debugPrint('  body: ${options.data}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('✗ ${err.response?.statusCode} ${err.requestOptions.uri}');
    debugPrint('  ${err.message}');
    handler.next(err);
  }
}
```

Hanya pasang di env=dev. Hapus untuk production build.

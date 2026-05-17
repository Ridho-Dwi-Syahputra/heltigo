/// Service Locator — dependency injection registry (GetIt).
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

// Core
import 'package:heltigo/data/api/api_service.dart';
import 'package:heltigo/services/secure_storage_service.dart';

// Services
import 'package:heltigo/data/services/auth_service.dart';
import 'package:heltigo/data/services/profile_service.dart';
import 'package:heltigo/data/services/plan_service.dart';
import 'package:heltigo/data/services/workout_service.dart';
import 'package:heltigo/data/services/meal_service.dart';
import 'package:heltigo/data/services/progress_service.dart';
import 'package:heltigo/data/services/settings_service.dart';
import 'package:heltigo/data/services/notification_service.dart';

// Repositories
import 'package:heltigo/data/repositories/auth_repository.dart';
import 'package:heltigo/data/repositories/profile_repository.dart';
import 'package:heltigo/data/repositories/plan_repository.dart';
import 'package:heltigo/data/repositories/workout_repository.dart';
import 'package:heltigo/data/repositories/meal_repository.dart';
import 'package:heltigo/data/repositories/progress_repository.dart';
import 'package:heltigo/data/repositories/settings_repository.dart';
import 'package:heltigo/data/repositories/notification_repository.dart';

// Providers
import 'package:heltigo/providers/auth_provider.dart';
import 'package:heltigo/providers/profile_provider.dart';
import 'package:heltigo/providers/profile_draft_provider.dart';
import 'package:heltigo/providers/plan_provider.dart';
import 'package:heltigo/providers/workout_provider.dart';
import 'package:heltigo/providers/meal_provider.dart';
import 'package:heltigo/providers/progress_provider.dart';
import 'package:heltigo/providers/settings_provider.dart';
import 'package:heltigo/providers/notification_provider.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // ═══ External ═══
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  getIt.registerSingleton<Logger>(Logger());

  // ═══ Storage ═══
  getIt.registerSingleton<SecureStorageService>(SecureStorageService());

  // ═══ Core HTTP ═══
  getIt.registerSingleton<ApiService>(
    ApiService(getIt<SecureStorageService>(), getIt<Logger>()),
  );

  // ═══ Services ═══
  getIt.registerSingleton<AuthService>(AuthService(getIt<ApiService>()));
  getIt.registerSingleton<ProfileService>(ProfileService(getIt<ApiService>()));
  getIt.registerSingleton<PlanService>(PlanService(getIt<ApiService>()));
  getIt.registerSingleton<WorkoutService>(WorkoutService(getIt<ApiService>()));
  getIt.registerSingleton<MealService>(MealService(getIt<ApiService>()));
  getIt.registerSingleton<ProgressService>(ProgressService(getIt<ApiService>()));
  getIt.registerSingleton<SettingsService>(SettingsService(getIt<ApiService>()));
  getIt.registerSingleton<NotificationApiService>(
    NotificationApiService(getIt<ApiService>()),
  );

  // ═══ Repositories ═══
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(getIt<AuthService>()),
  );
  getIt.registerSingleton<ProfileRepository>(
    ProfileRepositoryImpl(getIt<ProfileService>()),
  );
  getIt.registerSingleton<PlanRepository>(
    PlanRepositoryImpl(getIt<PlanService>()),
  );
  getIt.registerSingleton<WorkoutRepository>(
    WorkoutRepositoryImpl(getIt<WorkoutService>()),
  );
  getIt.registerSingleton<MealRepository>(
    MealRepositoryImpl(getIt<MealService>()),
  );
  getIt.registerSingleton<ProgressRepository>(
    ProgressRepositoryImpl(getIt<ProgressService>()),
  );
  getIt.registerSingleton<SettingsRepository>(
    SettingsRepositoryImpl(getIt<SettingsService>()),
  );
  getIt.registerSingleton<NotificationRepository>(
    NotificationRepositoryImpl(getIt<NotificationApiService>()),
  );

  // ═══ Providers (LazySingleton) ═══
  getIt.registerLazySingleton<AuthProvider>(
    () => AuthProvider(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<ProfileProvider>(
    () => ProfileProvider(getIt<ProfileRepository>()),
  );
  getIt.registerLazySingleton<ProfileDraftProvider>(
    () => ProfileDraftProvider(),
  );
  getIt.registerLazySingleton<PlanProvider>(
    () => PlanProvider(getIt<PlanRepository>()),
  );
  getIt.registerLazySingleton<WorkoutProvider>(
    () => WorkoutProvider(getIt<WorkoutRepository>()),
  );
  getIt.registerLazySingleton<MealProvider>(
    () => MealProvider(getIt<MealRepository>()),
  );
  getIt.registerLazySingleton<ProgressProvider>(
    () => ProgressProvider(getIt<ProgressRepository>()),
  );
  getIt.registerLazySingleton<SettingsProvider>(
    () => SettingsProvider(getIt<SettingsRepository>()),
  );
  getIt.registerLazySingleton<NotificationProvider>(
    () => NotificationProvider(getIt<NotificationRepository>()),
  );

  getIt<Logger>().i('Service Locator setup complete');
}

Future<void> resetServiceLocator() async {
  await getIt.reset();
}

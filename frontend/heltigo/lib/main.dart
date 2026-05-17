/// Heltigo — AI-Powered Personal Health & Fitness App
/// Entry point aplikasi.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'router/app_router.dart';
import 'styles/styles.dart';
import 'service_locator.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/profile_draft_provider.dart';
import 'providers/plan_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/meal_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env (mengandung API_BASE_URL). Wajib sebelum ApiService dipakai.
  // Tidak fatal jika gagal — endpoints.dart punya fallback default.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // silent: pakai default base URL
  }

  await initializeDateFormatting('id_ID', null);
  await initializeDateFormatting('id', null);

  await setupServiceLocator();

  final authProvider = getIt<AuthProvider>();
  await authProvider.initialize();

  final themeProvider = ThemeProvider();
  await themeProvider.load();

  runApp(HeltigoApp(themeProvider: themeProvider));
}

class HeltigoApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  const HeltigoApp({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: getIt<AuthProvider>()),
        ChangeNotifierProvider<ProfileProvider>.value(
          value: getIt<ProfileProvider>(),
        ),
        ChangeNotifierProvider<ProfileDraftProvider>.value(
          value: getIt<ProfileDraftProvider>(),
        ),
        ChangeNotifierProvider<PlanProvider>.value(
          value: getIt<PlanProvider>(),
        ),
        ChangeNotifierProvider<WorkoutProvider>.value(
          value: getIt<WorkoutProvider>(),
        ),
        ChangeNotifierProvider<MealProvider>.value(
          value: getIt<MealProvider>(),
        ),
        ChangeNotifierProvider<ProgressProvider>.value(
          value: getIt<ProgressProvider>(),
        ),
        ChangeNotifierProvider<SettingsProvider>.value(
          value: getIt<SettingsProvider>(),
        ),
        ChangeNotifierProvider<NotificationProvider>.value(
          value: getIt<NotificationProvider>(),
        ),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          final isDark = theme.mode == ThemeMode.dark ||
              (theme.mode == ThemeMode.system &&
                  WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                      Brightness.dark);

          SystemChrome.setSystemUIOverlayStyle(
            isDark
                ? const SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.light,
                    statusBarBrightness: Brightness.dark,
                  )
                : const SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.dark,
                    statusBarBrightness: Brightness.light,
                  ),
          );

          return MaterialApp.router(
            title: 'Heltigo',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme.copyWith(
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: _NoTransitionsBuilder(),
                  TargetPlatform.iOS: _NoTransitionsBuilder(),
                },
              ),
            ),
            darkTheme: AppTheme.darkTheme.copyWith(
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: _NoTransitionsBuilder(),
                  TargetPlatform.iOS: _NoTransitionsBuilder(),
                },
              ),
            ),
            themeMode: theme.mode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('id', 'ID'),
              Locale('en', 'US'),
            ],
            locale: const Locale('id', 'ID'),
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}

class _NoTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

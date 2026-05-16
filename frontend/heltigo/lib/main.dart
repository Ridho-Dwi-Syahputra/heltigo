/// Heltigo — AI-Powered Personal Health & Fitness App
/// Entry point aplikasi
/// Sumber: docs/frontend/09_DEPENDENCIES.md & reference repo main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'router/app_router.dart';
import 'styles/styles.dart';
import 'service_locator.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';

void main() async {
  // WAJIB: Pastikan Flutter binding sudah siap
  WidgetsFlutterBinding.ensureInitialized();

  // FIX BUG: Initialize Indonesian locale data untuk DateFormat & DatePicker.
  // Required untuk semua DateFormat dengan locale 'id' / 'id_ID' di seluruh app
  // (mis. setup_basic_info_screen DOB picker).
  await initializeDateFormatting('id_ID', null);
  await initializeDateFormatting('id', null);

  // Set status bar style untuk dark mode
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  // WAJIB: Setup dependency injection
  await setupServiceLocator();

  // Initialize auth untuk restore session dari SharedPreferences
  final authProvider = getIt<AuthProvider>();
  await authProvider.initialize();

  runApp(const HeltigoApp());
}

class HeltigoApp extends StatelessWidget {
  const HeltigoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // AuthProvider = GLOBAL (dibutuhkan di banyak screen)
        ChangeNotifierProvider(create: (_) => getIt<AuthProvider>()),
        // ProfileProvider = GLOBAL (dibutuhkan di home & profile)
        ChangeNotifierProvider(create: (_) => getIt<ProfileProvider>()),
      ],
      child: MaterialApp.router(
        title: 'Heltigo',
        debugShowCheckedModeBanner: false,

        // Dark theme ONLY — tidak ada light mode
        theme: AppTheme.darkTheme.copyWith(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: _NoTransitionsBuilder(),
              TargetPlatform.iOS: _NoTransitionsBuilder(),
            },
          ),
        ),

        // Force dark mode
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,

        // ─── Localization ───
        // Wajib untuk DatePicker/TimePicker Indonesian, dan supaya
        // GlobalMaterialLocalizations tersedia di seluruh app.
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

        // Router
        routerConfig: AppRouter.router,
      ),
    );
  }
}

/// Disable page transitions (sama seperti reference repo)
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

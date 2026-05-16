/// ThemeProvider — manages app theme mode (system / light / dark)
/// Persists to SharedPreferences. Updates AppColors brightness so that
/// ALL adaptive AppColors/AppTextStyles getters return the correct color
/// on every widget rebuild.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../styles/colors.dart';
import '../utils/constants.dart';

class ThemeProvider extends ChangeNotifier with WidgetsBindingObserver {
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  ThemeProvider() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Called by Flutter when device theme changes (only matters in system mode).
  @override
  void didChangePlatformBrightness() {
    if (_mode == ThemeMode.system) {
      _syncAppColors();
      notifyListeners();
    }
  }

  /// Load saved preference from SharedPreferences on app start.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppConstants.themeKey);
    _mode = switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    _syncAppColors();
    notifyListeners();
  }

  /// Set a new theme mode and persist it.
  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    _syncAppColors();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.themeKey,
      switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        _ => 'system',
      },
    );
  }

  /// Push the current resolved Brightness into AppColors so that all
  /// adaptive getters (AppColors.background, AppColors.textPrimary, etc.)
  /// return the correct color before the next widget rebuild.
  void _syncAppColors() {
    final Brightness resolved;
    if (_mode == ThemeMode.light) {
      resolved = Brightness.light;
    } else if (_mode == ThemeMode.dark) {
      resolved = Brightness.dark;
    } else {
      // System — read the platform's current brightness
      resolved =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
    }
    AppColors.setBrightness(resolved);
  }
}

/// Heltigo Color Palette — Adaptive (Light + Dark)
/// Sumber: docs/frontend/03_DESIGN_SYSTEM.md §1
/// Brand: Teal #1D6766 + Orange #FB3A01
/// Adaptive colors auto-switch via AppColors.setBrightness()
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Internal brightness (set by ThemeProvider) ──────────────
  static Brightness _brightness = Brightness.dark;

  /// Called by ThemeProvider whenever theme changes.
  static void setBrightness(Brightness b) => _brightness = b;

  static bool get _dark => _brightness == Brightness.dark;

  // ═══════════════════════════════════════
  // BRAND PRIMARY — teal (CONST, same both themes)
  // ═══════════════════════════════════════
  static const Color primary = Color(0xFF1D6766);
  static const Color primaryDark = Color(0xFF155150);
  static const Color primaryLight = Color(0xFF2A8584);
  static const Color primaryMuted = Color(0x331D6766);

  // ═══════════════════════════════════════
  // BRAND ACCENT — orange (CONST, same both themes)
  // ═══════════════════════════════════════
  static const Color accent = Color(0xFFFB3A01);
  static const Color accentDark = Color(0xFFD63200);
  static const Color accentLight = Color(0xFFFF6B3D);
  static const Color accentMuted = Color(0x33FB3A01);

  // ═══════════════════════════════════════
  // ADAPTIVE SURFACES
  // ═══════════════════════════════════════
  static Color get background =>
      _dark ? const Color(0xFF0D0D0D) : const Color(0xFFF5F7FA);

  static Color get surface =>
      _dark ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF);

  static Color get surfaceLight =>
      _dark ? const Color(0xFF1F1F1F) : const Color(0xFFEEF0F4);

  static Color get surfaceElevated =>
      _dark ? const Color(0xFF242424) : const Color(0xFFE4E7EC);

  // ═══════════════════════════════════════
  // ADAPTIVE BORDERS & DIVIDERS
  // ═══════════════════════════════════════
  static Color get border =>
      _dark ? const Color(0xFF333333) : const Color(0xFFDDE1E7);

  static const Color borderFocused = Color(0xFF1D6766); // always primary

  static Color get divider =>
      _dark ? const Color(0xFF1F1F1F) : const Color(0xFFE9ECEF);

  // ═══════════════════════════════════════
  // ADAPTIVE TEXT COLORS
  // ═══════════════════════════════════════
  static Color get textPrimary =>
      _dark ? const Color(0xFFF5F5F5) : const Color(0xFF111827);

  static Color get textSecondary =>
      _dark ? const Color(0xFFB0B0B0) : const Color(0xFF6B7280);

  static Color get textTertiary =>
      _dark ? const Color(0xFF707070) : const Color(0xFF9CA3AF);

  // Always white on teal button
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════
  // SEMANTIC — feedback (CONST, same both themes)
  // ═══════════════════════════════════════
  static const Color error = Color(0xFFEF4444);
  static const Color errorMuted = Color(0x33EF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color successMuted = Color(0x3322C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningMuted = Color(0x33F59E0B);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoMuted = Color(0x333B82F6);

  // ═══════════════════════════════════════
  // FEATURE ACCENT (CONST)
  // ═══════════════════════════════════════
  static const Color energyOrange = Color(0xFFFB3A01);
  static const Color streakPurple = Color(0xFF8B5CF6);
  static const Color waterBlue = Color(0xFF06B6D4);
  static const Color heartRed = Color(0xFFF43F5E);

  // ═══════════════════════════════════════
  // GRADIENTS (CONST)
  // ═══════════════════════════════════════
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1D6766), Color(0xFF155150)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFB3A01), Color(0xFFD63200)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient darkFade = LinearGradient(
    colors: [Color(0x00000000), Color(0xE6000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static LinearGradient get splashGradient => _dark
      ? const LinearGradient(
          colors: [Color(0xFF111111), Color(0xFF0D0D0D)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        )
      : const LinearGradient(
          colors: [Color(0xFFF5F7FA), Color(0xFFFFFFFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );

  // ═══════════════════════════════════════
  // UTILITY (CONST)
  // ═══════════════════════════════════════
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // ═══════════════════════════════════════
  // ADAPTIVE SHIMMER
  // ═══════════════════════════════════════
  static Color get shimmerBase =>
      _dark ? const Color(0xFF1A1A1A) : const Color(0xFFE0E5EC);

  static Color get shimmerHighlight =>
      _dark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F7FA);
}

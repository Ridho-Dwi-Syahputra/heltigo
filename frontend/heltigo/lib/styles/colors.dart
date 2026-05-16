/// Heltigo Color Palette — Dark Mode Only
/// Sumber: docs/frontend/03_DESIGN_SYSTEM.md §1
/// Warna brand: Teal #1D6766 + Orange #FB3A01 (sesuai logo)
import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Prevent instantiation

  // ═══════════════════════════════════════
  // BRAND PRIMARY — teal khas Heltigo (sesuai logo)
  // ═══════════════════════════════════════
  static const Color primary = Color(0xFF1D6766);       // Teal utama (tombol, aksen)
  static const Color primaryDark = Color(0xFF155150);    // Teal gelap (pressed state)
  static const Color primaryLight = Color(0xFF2A8584);   // Teal muda (highlight)
  static const Color primaryMuted = Color(0x331D6766);   // Teal 20% (container bg)

  // ═══════════════════════════════════════
  // BRAND ACCENT — orange khas Heltigo (sesuai logo)
  // ═══════════════════════════════════════
  static const Color accent = Color(0xFFFB3A01);         // Orange utama
  static const Color accentDark = Color(0xFFD63200);     // Orange gelap
  static const Color accentLight = Color(0xFFFF6B3D);    // Orange muda
  static const Color accentMuted = Color(0x33FB3A01);    // Orange 20%

  // ═══════════════════════════════════════
  // SURFACES — latar gelap bertingkat
  // ═══════════════════════════════════════
  static const Color background = Color(0xFF0D0D0D);     // Layar utama (#0D0D0D)
  static const Color surface = Color(0xFF1A1A1A);        // Card / elevated area
  static const Color surfaceLight = Color(0xFF242424);   // Input field bg
  static const Color surfaceElevated = Color(0xFF2A2A2A);// Modal / bottom sheet

  // ═══════════════════════════════════════
  // BORDER & DIVIDER
  // ═══════════════════════════════════════
  static const Color border = Color(0xFF333333);         // Border default
  static const Color borderFocused = Color(0xFF1D6766);  // Border aktif (= primary)
  static const Color divider = Color(0xFF1F1F1F);        // Divider tipis

  // ═══════════════════════════════════════
  // TEXT
  // ═══════════════════════════════════════
  static const Color textPrimary = Color(0xFFF5F5F5);    // Teks utama (putih off)
  static const Color textSecondary = Color(0xFFB0B0B0);  // Teks pendukung (abu)
  static const Color textTertiary = Color(0xFF707070);   // Teks hint / disabled
  static const Color textOnPrimary = Color(0xFFFFFFFF);  // Teks di atas tombol teal

  // ═══════════════════════════════════════
  // SEMANTIC — feedback colors
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
  // FEATURE ACCENT — warna pendukung fitur
  // ═══════════════════════════════════════
  static const Color energyOrange = Color(0xFFFB3A01);   // Kalori / energy (= accent)
  static const Color streakPurple = Color(0xFF8B5CF6);   // Streak / badges
  static const Color waterBlue = Color(0xFF06B6D4);      // Hidrasi
  static const Color heartRed = Color(0xFFF43F5E);       // Detak jantung

  // ═══════════════════════════════════════
  // GRADIENT — untuk tombol dan background
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

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF111111), Color(0xFF0D0D0D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ═══════════════════════════════════════
  // UTILITY
  // ═══════════════════════════════════════
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // ═══════════════════════════════════════
  // SHIMMER — untuk loading skeleton
  // ═══════════════════════════════════════
  static const Color shimmerBase = Color(0xFF1A1A1A);
  static const Color shimmerHighlight = Color(0xFF2A2A2A);
}

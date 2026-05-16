/// Heltigo Spacing, Radius, Shadow & Animation constants
/// Sumber: docs/frontend/03_DESIGN_SYSTEM.md §3
import 'package:flutter/material.dart';

class AppDimensions {
  AppDimensions._(); // Prevent instantiation

  // ═══════════════════════════════════════
  // SPACING — konsisten di seluruh app
  // ═══════════════════════════════════════
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // Screen padding (horizontal)
  static const double screenPaddingH = 24;

  // ═══════════════════════════════════════
  // BORDER RADIUS
  // ═══════════════════════════════════════
  static const double radiusSmall = 8;
  static const double radiusInput = 12;
  static const double radiusCard = 16;
  static const double radiusBadge = 20;
  static const double radiusButton = 28;
  static const double radiusBottomSheetTop = 24;
  static const double radiusFull = 999;

  // ═══════════════════════════════════════
  // COMPONENT HEIGHTS
  // ═══════════════════════════════════════
  static const double buttonHeight = 56;
  static const double buttonHeightSmall = 44;
  static const double inputHeight = 56;
  static const double bottomNavHeight = 64;
  static const double appBarHeight = 56;

  // ═══════════════════════════════════════
  // ICON SIZES
  // ═══════════════════════════════════════
  static const double iconSmall = 16;
  static const double iconMedium = 20;
  static const double iconLarge = 24;
  static const double iconXLarge = 32;

  // ═══════════════════════════════════════
  // TOUCH TARGETS (accessibility)
  // ═══════════════════════════════════════
  static const double minTouchTarget = 48;

  // ═══════════════════════════════════════
  // PAGE INDICATORS (onboarding dots)
  // ═══════════════════════════════════════
  static const double dotSize = 8;
  static const double dotActiveWidth = 24;
  static const double dotSpacing = 6;
}

class AppShadows {
  AppShadows._(); // Prevent instantiation

  static const List<BoxShadow> card = [
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 16,
      color: Color(0x40000000), // black 25%
    ),
  ];

  static const List<BoxShadow> elevated = [
    BoxShadow(
      offset: Offset(0, 8),
      blurRadius: 24,
      color: Color(0x60000000), // black 38%
    ),
  ];

  static const List<BoxShadow> buttonPrimary = [
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 16,
      color: Color(0x4D1D6766), // primary teal 30%
    ),
  ];

  static const List<BoxShadow> glow = [
    BoxShadow(
      offset: Offset(0, 0),
      blurRadius: 20,
      spreadRadius: 2,
      color: Color(0x331D6766), // primary teal 20% glow
    ),
  ];
}

class AppDurations {
  AppDurations._(); // Prevent instantiation

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration splash = Duration(milliseconds: 2000);
  static const Duration pageTransition = Duration(milliseconds: 350);
}

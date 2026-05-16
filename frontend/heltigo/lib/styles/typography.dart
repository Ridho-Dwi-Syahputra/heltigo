/// Heltigo Typography — Inter font, adaptive (light + dark)
/// Sumber: docs/frontend/03_DESIGN_SYSTEM.md §2
/// Semua style adalah GETTER sehingga color re-evaluate setiap build
/// (wajib untuk adaptive theme support)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ═══════════════════════════════════════
  // HEADING
  // ═══════════════════════════════════════
  static TextStyle get display => GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 1.1,
        color: AppColors.textPrimary,
      );

  static TextStyle get h1 => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get h2 => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.25,
        color: AppColors.textPrimary,
      );

  static TextStyle get h3 => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: AppColors.textPrimary,
      );

  // ═══════════════════════════════════════
  // BODY
  // ═══════════════════════════════════════
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppColors.textSecondary,
      );

  // ═══════════════════════════════════════
  // CAPTION & LABEL
  // ═══════════════════════════════════════
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.3,
        color: AppColors.textTertiary,
      );

  static TextStyle get label => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: AppColors.textTertiary,
      );

  static TextStyle get overline => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: AppColors.textTertiary,
      );

  // ═══════════════════════════════════════
  // BUTTON
  // ═══════════════════════════════════════
  static TextStyle get button => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary,
      );

  static TextStyle get buttonSmall => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary,
      );

  // ═══════════════════════════════════════
  // SPECIAL
  // ═══════════════════════════════════════
  static TextStyle get numberBold => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1,
        color: AppColors.textPrimary,
      );

  static TextStyle get motto => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.3,
        color: AppColors.textSecondary,
      );

  static TextStyle get link => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        decoration: TextDecoration.none,
      );

  static TextStyle get onboardingTitle => GoogleFonts.inter(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: AppColors.textPrimary,
      );

  static TextStyle get onboardingDesc => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: AppColors.textSecondary,
      );
}

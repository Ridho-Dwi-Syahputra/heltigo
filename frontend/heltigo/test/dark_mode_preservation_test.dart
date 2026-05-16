/// Preservation Property Tests for Dark Mode Theme Consistency
/// 
/// **Property 2: Preservation** - Light Mode and Intentional White Elements
/// 
/// **IMPORTANT**: These tests should PASS on UNFIXED code.
/// They verify that light mode appearance and intentional white elements
/// remain unchanged after the fix is implemented.
/// 
/// This follows the observation-first methodology:
/// 1. Observe behavior on UNFIXED code for non-buggy inputs
/// 2. Write property-based tests capturing observed behavior patterns
/// 3. Run tests on UNFIXED code - they should PASS
/// 4. After fix, re-run tests - they should still PASS (no regressions)
/// 
/// **Validates Requirements**: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heltigo/styles/colors.dart';

void main() {
  group('Preservation Property Tests: Light Mode and Intentional White Elements', () {
    
    // ═══════════════════════════════════════════════════════════════
    // Property 2.1: Light Mode Color Palette Preservation
    // Validates Requirement 3.1
    // ═══════════════════════════════════════════════════════════════
    
    test('Property 2.1: Light mode displays correct light color palette', () {
      // GIVEN: Light mode is enabled
      AppColors.setBrightness(Brightness.light);

      // WHEN: We check adaptive color getters
      final background = AppColors.background;
      final surface = AppColors.surface;
      final surfaceLight = AppColors.surfaceLight;
      final textPrimary = AppColors.textPrimary;
      final textSecondary = AppColors.textSecondary;
      final textTertiary = AppColors.textTertiary;

      // THEN: All colors should match the light mode palette
      expect(background.toARGB32(), equals(0xFFF5F7FA),
          reason: 'AppColors.background should be 0xFFF5F7FA in light mode');
      expect(surface.toARGB32(), equals(0xFFFFFFFF),
          reason: 'AppColors.surface should be 0xFFFFFFFF in light mode');
      expect(surfaceLight.toARGB32(), equals(0xFFEEF0F4),
          reason: 'AppColors.surfaceLight should be 0xFFEEF0F4 in light mode');
      expect(textPrimary.toARGB32(), equals(0xFF111827),
          reason: 'AppColors.textPrimary should be 0xFF111827 in light mode');
      expect(textSecondary.toARGB32(), equals(0xFF6B7280),
          reason: 'AppColors.textSecondary should be 0xFF6B7280 in light mode');
      expect(textTertiary.toARGB32(), equals(0xFF9CA3AF),
          reason: 'AppColors.textTertiary should be 0xFF9CA3AF in light mode');
    });

    test('Property 2.1 (Parameterized): Light mode adaptive colors remain consistent', () {
      // Test multiple brightness switches to ensure consistency
      final testCases = [
        {'brightness': Brightness.light, 'background': 0xFFF5F7FA, 'surface': 0xFFFFFFFF},
        {'brightness': Brightness.light, 'background': 0xFFF5F7FA, 'surface': 0xFFFFFFFF},
        {'brightness': Brightness.light, 'background': 0xFFF5F7FA, 'surface': 0xFFFFFFFF},
      ];

      for (var testCase in testCases) {
        AppColors.setBrightness(testCase['brightness'] as Brightness);
        
        expect(AppColors.background.toARGB32(), equals(testCase['background']),
            reason: 'Background should be consistent in light mode');
        expect(AppColors.surface.toARGB32(), equals(testCase['surface']),
            reason: 'Surface should be consistent in light mode');
      }
    });

    // ═══════════════════════════════════════════════════════════════
    // Property 2.2: Brand Colors Preservation
    // Validates Requirement 3.2
    // ═══════════════════════════════════════════════════════════════
    
    test('Property 2.2: Brand colors remain constant across both themes', () {
      // Test in light mode
      AppColors.setBrightness(Brightness.light);
      final primaryLight = AppColors.primary;
      final accentLight = AppColors.accent;

      // Test in dark mode
      AppColors.setBrightness(Brightness.dark);
      final primaryDark = AppColors.primary;
      final accentDark = AppColors.accent;

      // THEN: Brand colors should be identical in both themes
      expect(primaryLight.toARGB32(), equals(primaryDark.toARGB32()),
          reason: 'Primary teal (#1D6766) should remain constant across themes');
      expect(accentLight.toARGB32(), equals(accentDark.toARGB32()),
          reason: 'Accent orange (#FB3A01) should remain constant across themes');
      
      // Verify exact color values
      expect(primaryLight.toARGB32(), equals(0xFF1D6766),
          reason: 'Primary should be #1D6766');
      expect(accentLight.toARGB32(), equals(0xFFFB3A01),
          reason: 'Accent should be #FB3A01');
    });

    test('Property 2.2 (Extended): All brand color variants remain constant', () {
      final brandColors = {
        'primary': AppColors.primary,
        'primaryDark': AppColors.primaryDark,
        'primaryLight': AppColors.primaryLight,
        'primaryMuted': AppColors.primaryMuted,
        'accent': AppColors.accent,
        'accentDark': AppColors.accentDark,
        'accentLight': AppColors.accentLight,
        'accentMuted': AppColors.accentMuted,
      };

      // Capture colors in light mode
      AppColors.setBrightness(Brightness.light);
      final lightModeColors = brandColors.map(
        (key, value) => MapEntry(key, value.toARGB32())
      );

      // Capture colors in dark mode
      AppColors.setBrightness(Brightness.dark);
      final darkModeColors = brandColors.map(
        (key, value) => MapEntry(key, value.toARGB32())
      );

      // Verify all brand colors are identical across themes
      for (var key in lightModeColors.keys) {
        expect(lightModeColors[key], equals(darkModeColors[key]),
            reason: 'Brand color $key should remain constant across themes');
      }
    });

    // ═══════════════════════════════════════════════════════════════
    // Property 2.3: Semantic Colors Preservation
    // Validates Requirement 3.3
    // ═══════════════════════════════════════════════════════════════
    
    test('Property 2.3: Semantic colors remain constant across both themes', () {
      final semanticColors = {
        'error': AppColors.error,
        'errorMuted': AppColors.errorMuted,
        'success': AppColors.success,
        'successMuted': AppColors.successMuted,
        'warning': AppColors.warning,
        'warningMuted': AppColors.warningMuted,
        'info': AppColors.info,
        'infoMuted': AppColors.infoMuted,
      };

      // Capture colors in light mode
      AppColors.setBrightness(Brightness.light);
      final lightModeColors = semanticColors.map(
        (key, value) => MapEntry(key, value.toARGB32())
      );

      // Capture colors in dark mode
      AppColors.setBrightness(Brightness.dark);
      final darkModeColors = semanticColors.map(
        (key, value) => MapEntry(key, value.toARGB32())
      );

      // Verify all semantic colors are identical across themes
      for (var key in lightModeColors.keys) {
        expect(lightModeColors[key], equals(darkModeColors[key]),
            reason: 'Semantic color $key should remain constant across themes');
      }

      // Verify exact color values
      expect(AppColors.error.toARGB32(), equals(0xFFEF4444),
          reason: 'Error should be #EF4444');
      expect(AppColors.success.toARGB32(), equals(0xFF22C55E),
          reason: 'Success should be #22C55E');
      expect(AppColors.warning.toARGB32(), equals(0xFFF59E0B),
          reason: 'Warning should be #F59E0B');
      expect(AppColors.info.toARGB32(), equals(0xFF3B82F6),
          reason: 'Info should be #3B82F6');
    });

    // ═══════════════════════════════════════════════════════════════
    // Property 2.4: Intentional White Elements Preservation
    // Validates Requirement 3.5
    // ═══════════════════════════════════════════════════════════════
    
    test('Property 2.4: textOnPrimary remains white in both themes', () {
      // Test in light mode
      AppColors.setBrightness(Brightness.light);
      final textOnPrimaryLight = AppColors.textOnPrimary;

      // Test in dark mode
      AppColors.setBrightness(Brightness.dark);
      final textOnPrimaryDark = AppColors.textOnPrimary;

      // THEN: textOnPrimary should be white (0xFFFFFFFF) in both themes
      expect(textOnPrimaryLight.toARGB32(), equals(0xFFFFFFFF),
          reason: 'textOnPrimary should be white in light mode');
      expect(textOnPrimaryDark.toARGB32(), equals(0xFFFFFFFF),
          reason: 'textOnPrimary should be white in dark mode');
      expect(textOnPrimaryLight.toARGB32(), equals(textOnPrimaryDark.toARGB32()),
          reason: 'textOnPrimary should be identical in both themes');
    });

    test('Property 2.4 (Extended): Utility colors remain constant', () {
      final utilityColors = {
        'white': AppColors.white,
        'black': AppColors.black,
        'transparent': AppColors.transparent,
      };

      // Capture colors in light mode
      AppColors.setBrightness(Brightness.light);
      final lightModeColors = utilityColors.map(
        (key, value) => MapEntry(key, value.toARGB32())
      );

      // Capture colors in dark mode
      AppColors.setBrightness(Brightness.dark);
      final darkModeColors = utilityColors.map(
        (key, value) => MapEntry(key, value.toARGB32())
      );

      // Verify all utility colors are identical across themes
      for (var key in lightModeColors.keys) {
        expect(lightModeColors[key], equals(darkModeColors[key]),
            reason: 'Utility color $key should remain constant across themes');
      }

      // Verify exact values
      expect(AppColors.white.toARGB32(), equals(0xFFFFFFFF),
          reason: 'white should be 0xFFFFFFFF');
      expect(AppColors.black.toARGB32(), equals(0xFF000000),
          reason: 'black should be 0xFF000000');
      expect(AppColors.transparent.toARGB32(), equals(0x00000000),
          reason: 'transparent should be 0x00000000');
    });

    // ═══════════════════════════════════════════════════════════════
    // Property 2.5: Feature Accent Colors Preservation
    // Validates Requirement 3.6
    // ═══════════════════════════════════════════════════════════════
    
    test('Property 2.5: Feature accent colors remain constant across both themes', () {
      final accentColors = {
        'energyOrange': AppColors.energyOrange,
        'streakPurple': AppColors.streakPurple,
        'waterBlue': AppColors.waterBlue,
        'heartRed': AppColors.heartRed,
      };

      // Capture colors in light mode
      AppColors.setBrightness(Brightness.light);
      final lightModeColors = accentColors.map(
        (key, value) => MapEntry(key, value.toARGB32())
      );

      // Capture colors in dark mode
      AppColors.setBrightness(Brightness.dark);
      final darkModeColors = accentColors.map(
        (key, value) => MapEntry(key, value.toARGB32())
      );

      // Verify all accent colors are identical across themes
      for (var key in lightModeColors.keys) {
        expect(lightModeColors[key], equals(darkModeColors[key]),
            reason: 'Feature accent color $key should remain constant across themes');
      }

      // Verify exact color values
      expect(AppColors.energyOrange.toARGB32(), equals(0xFFFB3A01),
          reason: 'energyOrange should be #FB3A01');
      expect(AppColors.streakPurple.toARGB32(), equals(0xFF8B5CF6),
          reason: 'streakPurple should be #8B5CF6');
      expect(AppColors.waterBlue.toARGB32(), equals(0xFF06B6D4),
          reason: 'waterBlue should be #06B6D4');
      expect(AppColors.heartRed.toARGB32(), equals(0xFFF43F5E),
          reason: 'heartRed should be #F43F5E');
    });

    // ═══════════════════════════════════════════════════════════════
    // Property 2.6: Gradients Preservation
    // Validates Requirement 3.8
    // ═══════════════════════════════════════════════════════════════
    
    test('Property 2.6: Constant gradients remain unchanged across themes', () {
      // Test primaryGradient (should be constant)
      AppColors.setBrightness(Brightness.light);
      final primaryGradientLight = AppColors.primaryGradient;
      
      AppColors.setBrightness(Brightness.dark);
      final primaryGradientDark = AppColors.primaryGradient;

      // Verify gradient colors are identical
      expect(primaryGradientLight.colors.length, equals(primaryGradientDark.colors.length),
          reason: 'primaryGradient should have same number of colors in both themes');
      
      for (var i = 0; i < primaryGradientLight.colors.length; i++) {
        expect(primaryGradientLight.colors[i].toARGB32(), 
               equals(primaryGradientDark.colors[i].toARGB32()),
               reason: 'primaryGradient color $i should be identical in both themes');
      }

      // Verify exact colors
      expect(primaryGradientLight.colors[0].toARGB32(), equals(0xFF1D6766),
          reason: 'primaryGradient first color should be #1D6766');
      expect(primaryGradientLight.colors[1].toARGB32(), equals(0xFF155150),
          reason: 'primaryGradient second color should be #155150');
    });

    test('Property 2.6 (Extended): accentGradient and darkFade remain constant', () {
      // Test accentGradient
      AppColors.setBrightness(Brightness.light);
      final accentGradientLight = AppColors.accentGradient;
      
      AppColors.setBrightness(Brightness.dark);
      final accentGradientDark = AppColors.accentGradient;

      expect(accentGradientLight.colors[0].toARGB32(), 
             equals(accentGradientDark.colors[0].toARGB32()),
             reason: 'accentGradient should be identical in both themes');

      // Test darkFade
      final darkFadeLight = AppColors.darkFade;
      final darkFadeDark = AppColors.darkFade;

      expect(darkFadeLight.colors[0].toARGB32(), 
             equals(darkFadeDark.colors[0].toARGB32()),
             reason: 'darkFade should be identical in both themes');
    });

    test('Property 2.6 (Adaptive): splashGradient adapts correctly to theme', () {
      // splashGradient is adaptive - it should return different values per theme
      AppColors.setBrightness(Brightness.light);
      final splashGradientLight = AppColors.splashGradient;

      AppColors.setBrightness(Brightness.dark);
      final splashGradientDark = AppColors.splashGradient;

      // Verify light mode gradient uses light colors
      expect(_isLightColor(splashGradientLight.colors[0]), isTrue,
          reason: 'splashGradient should use light colors in light mode');

      // Verify dark mode gradient uses dark colors
      expect(_isLightColor(splashGradientDark.colors[0]), isFalse,
          reason: 'splashGradient should use dark colors in dark mode');

      // Verify exact colors for light mode
      expect(splashGradientLight.colors[0].toARGB32(), equals(0xFFF5F7FA),
          reason: 'splashGradient light mode first color should be #F5F7FA');
      expect(splashGradientLight.colors[1].toARGB32(), equals(0xFFFFFFFF),
          reason: 'splashGradient light mode second color should be #FFFFFF');

      // Verify exact colors for dark mode
      expect(splashGradientDark.colors[0].toARGB32(), equals(0xFF111111),
          reason: 'splashGradient dark mode first color should be #111111');
      expect(splashGradientDark.colors[1].toARGB32(), equals(0xFF0D0D0D),
          reason: 'splashGradient dark mode second color should be #0D0D0D');
    });

    // ═══════════════════════════════════════════════════════════════
    // Property 2.7: Theme Switching Mechanism Preservation
    // Validates Requirement 3.7
    // ═══════════════════════════════════════════════════════════════
    
    test('Property 2.7: setBrightness correctly updates adaptive color getters', () {
      // Test switching from light to dark
      AppColors.setBrightness(Brightness.light);
      final backgroundLight = AppColors.background.toARGB32();
      
      AppColors.setBrightness(Brightness.dark);
      final backgroundDark = AppColors.background.toARGB32();

      // Verify colors change when brightness changes
      expect(backgroundLight, isNot(equals(backgroundDark)),
          reason: 'Adaptive colors should change when brightness changes');

      // Test switching back to light
      AppColors.setBrightness(Brightness.light);
      final backgroundLightAgain = AppColors.background.toARGB32();

      expect(backgroundLight, equals(backgroundLightAgain),
          reason: 'Adaptive colors should return to original values when brightness switches back');
    });

    test('Property 2.7 (Stress Test): Multiple rapid theme switches maintain consistency', () {
      // Perform multiple rapid theme switches
      for (var i = 0; i < 10; i++) {
        AppColors.setBrightness(Brightness.light);
        final lightBg = AppColors.background.toARGB32();
        expect(lightBg, equals(0xFFF5F7FA),
            reason: 'Light mode background should remain consistent after switch $i');

        AppColors.setBrightness(Brightness.dark);
        final darkBg = AppColors.background.toARGB32();
        expect(darkBg, equals(0xFF0D0D0D),
            reason: 'Dark mode background should remain consistent after switch $i');
      }
    });

    // ═══════════════════════════════════════════════════════════════
    // Property 2.8: Comprehensive Preservation Test
    // Validates all preservation requirements
    // ═══════════════════════════════════════════════════════════════
    
    test('Property 2.8: Comprehensive preservation - all non-adaptive colors remain constant', () {
      // Collect all constant (non-adaptive) colors
      final constantColors = {
        // Brand colors
        'primary': AppColors.primary,
        'primaryDark': AppColors.primaryDark,
        'primaryLight': AppColors.primaryLight,
        'accent': AppColors.accent,
        'accentDark': AppColors.accentDark,
        'accentLight': AppColors.accentLight,
        
        // Semantic colors
        'error': AppColors.error,
        'success': AppColors.success,
        'warning': AppColors.warning,
        'info': AppColors.info,
        
        // Feature accent colors
        'energyOrange': AppColors.energyOrange,
        'streakPurple': AppColors.streakPurple,
        'waterBlue': AppColors.waterBlue,
        'heartRed': AppColors.heartRed,
        
        // Intentional white elements
        'textOnPrimary': AppColors.textOnPrimary,
        'white': AppColors.white,
        'black': AppColors.black,
      };

      // Capture colors in light mode
      AppColors.setBrightness(Brightness.light);
      final lightModeColors = constantColors.map(
        (key, value) => MapEntry(key, value.toARGB32())
      );

      // Capture colors in dark mode
      AppColors.setBrightness(Brightness.dark);
      final darkModeColors = constantColors.map(
        (key, value) => MapEntry(key, value.toARGB32())
      );

      // Verify ALL constant colors are identical across themes
      var allMatch = true;
      var mismatchCount = 0;
      for (var key in lightModeColors.keys) {
        if (lightModeColors[key] != darkModeColors[key]) {
          allMatch = false;
          mismatchCount++;
          print('MISMATCH: $key - Light: ${lightModeColors[key]}, Dark: ${darkModeColors[key]}');
        }
      }

      expect(allMatch, isTrue,
          reason: 'All ${constantColors.length} constant colors should remain identical across themes (found $mismatchCount mismatches)');
    });

    test('Property 2.8 (Extended): Comprehensive preservation - adaptive colors change correctly', () {
      // Collect all adaptive colors
      final adaptiveColorGetters = {
        'background': () => AppColors.background,
        'surface': () => AppColors.surface,
        'surfaceLight': () => AppColors.surfaceLight,
        'surfaceElevated': () => AppColors.surfaceElevated,
        'border': () => AppColors.border,
        'divider': () => AppColors.divider,
        'textPrimary': () => AppColors.textPrimary,
        'textSecondary': () => AppColors.textSecondary,
        'textTertiary': () => AppColors.textTertiary,
        'shimmerBase': () => AppColors.shimmerBase,
        'shimmerHighlight': () => AppColors.shimmerHighlight,
      };

      // Capture colors in light mode
      AppColors.setBrightness(Brightness.light);
      final lightModeColors = adaptiveColorGetters.map(
        (key, getter) => MapEntry(key, getter().toARGB32())
      );

      // Capture colors in dark mode
      AppColors.setBrightness(Brightness.dark);
      final darkModeColors = adaptiveColorGetters.map(
        (key, getter) => MapEntry(key, getter().toARGB32())
      );

      // Verify ALL adaptive colors are DIFFERENT across themes
      var allDifferent = true;
      var sameCount = 0;
      for (var key in lightModeColors.keys) {
        if (lightModeColors[key] == darkModeColors[key]) {
          allDifferent = false;
          sameCount++;
          print('SAME: $key - Light: ${lightModeColors[key]}, Dark: ${darkModeColors[key]}');
        }
      }

      expect(allDifferent, isTrue,
          reason: 'All ${adaptiveColorGetters.length} adaptive colors should be different across themes (found $sameCount that are the same)');
    });
  });
}

/// Helper function to determine if a color is "light" (luminance > 0.5)
bool _isLightColor(Color color) {
  // Calculate relative luminance using the formula:
  // L = 0.2126 * R + 0.7152 * G + 0.0722 * B
  final r = (color.r * 255.0).round().clamp(0, 255) / 255.0;
  final g = (color.g * 255.0).round().clamp(0, 255) / 255.0;
  final b = (color.b * 255.0).round().clamp(0, 255) / 255.0;
  final luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b;
  return luminance > 0.5;
}

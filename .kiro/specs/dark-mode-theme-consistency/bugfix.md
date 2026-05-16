# Bugfix Requirements Document

## Introduction

This bugfix addresses the dark mode theme consistency issue in the Heltigo Flutter app where many screens display white or light gray areas when dark mode is enabled, creating excessive contrast and a "kacau" (messy/glitchy) visual experience. The root cause is the use of non-adaptive color references (`AppColors.white`, hardcoded `Color(0xFFFFFFFF)`) that do not respond to theme changes, despite the app having a properly configured adaptive color system via `AppColors.setBrightness()`.

The fix will ensure all UI components use adaptive color getters (`AppColors.background`, `AppColors.surface`, `AppColors.textPrimary`, etc.) so that dark mode displays consistent dark colors across all 40+ screens.

## Bug Analysis

### Current Behavior (Defect)

1.1 WHEN dark mode is enabled THEN many screens display white or light gray areas instead of dark backgrounds (0xFF0D0D0D, 0xFF1A1A1A, 0xFF1F1F1F)

1.2 WHEN switching between light and dark mode THEN theme transitions appear glitchy and inconsistent across different screens

1.3 WHEN widgets use `AppColors.white` or hardcoded `Color(0xFFFFFFFF)` THEN these colors do not adapt to the current theme brightness

1.4 WHEN components use hardcoded light colors for backgrounds, surfaces, or text THEN they create excessive contrast in dark mode

1.5 WHEN viewing priority screens (Settings, Home, Meal screens, Profile) in dark mode THEN white/light areas are prominently visible

### Expected Behavior (Correct)

2.1 WHEN dark mode is enabled THEN all screens SHALL display consistent dark colors: background (0xFF0D0D0D), surface (0xFF1A1A1A), and surfaceLight (0xFF1F1F1F)

2.2 WHEN switching between light and dark mode THEN theme transitions SHALL be smooth without visual glitches or inconsistent color rendering

2.3 WHEN widgets need background or surface colors THEN they SHALL use adaptive getters (`AppColors.background`, `AppColors.surface`, `AppColors.surfaceLight`) instead of `AppColors.white` or hardcoded values

2.4 WHEN components need text colors THEN they SHALL use adaptive getters (`AppColors.textPrimary`, `AppColors.textSecondary`, `AppColors.textTertiary`) that respond to theme changes

2.5 WHEN viewing any screen in dark mode THEN no white or light gray areas SHALL appear except for intentional accent elements (icons, illustrations, or brand elements)

### Unchanged Behavior (Regression Prevention)

3.1 WHEN light mode is enabled THEN all screens SHALL CONTINUE TO display the existing light color palette (background: 0xFFF5F7FA, surface: 0xFFFFFFFF, surfaceLight: 0xFFEEF0F4)

3.2 WHEN brand colors (primary teal #1D6766, accent orange #FB3A01) are used THEN they SHALL CONTINUE TO remain constant across both themes

3.3 WHEN semantic colors (error, success, warning, info) are displayed THEN they SHALL CONTINUE TO use their defined constant values in both themes

3.4 WHEN the onboarding screen is displayed in light mode THEN the previously fixed shader issue SHALL CONTINUE TO work correctly without regression

3.5 WHEN `AppColors.textOnPrimary` is used for text on teal buttons THEN it SHALL CONTINUE TO be white (0xFFFFFFFF) in both themes

3.6 WHEN feature accent colors (energyOrange, streakPurple, waterBlue, heartRed) are used THEN they SHALL CONTINUE TO remain constant across both themes

3.7 WHEN the ThemeProvider switches theme mode THEN `AppColors.setBrightness()` SHALL CONTINUE TO be called to update adaptive color getters

3.8 WHEN gradients (primaryGradient, accentGradient, darkFade, splashGradient) are used THEN they SHALL CONTINUE TO render correctly in their respective themes

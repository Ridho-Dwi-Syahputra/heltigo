/// Responsive Utils — helper untuk UI adaptif
/// Sumber: docs/frontend/03_DESIGN_SYSTEM.md
///
/// Provides responsive utilities for adaptive layouts across different device sizes.
/// Includes breakpoint definitions, screen size detection, and responsive sizing helpers.
import 'package:flutter/material.dart';

class ResponsiveUtils {
  // ============================================================================
  // BREAKPOINT CONSTANTS
  // ============================================================================
  
  /// Breakpoint for small screen width (e.g., iPhone SE)
  static const double smallScreenWidth = 375.0;
  
  /// Breakpoint for medium screen width (e.g., iPhone 12)
  static const double mediumScreenWidth = 414.0;
  
  /// Breakpoint for large screen width (e.g., tablets)
  static const double largeScreenWidth = 768.0;
  
  /// Breakpoint for small screen height (e.g., iPhone SE)
  static const double smallScreenHeight = 667.0;
  
  /// Breakpoint for medium screen height (e.g., iPhone 12)
  static const double mediumScreenHeight = 812.0;
  
  /// Breakpoint for large screen height (e.g., iPhone Pro Max)
  static const double largeScreenHeight = 896.0;

  // ============================================================================
  // SCREEN SIZE DETECTION
  // ============================================================================
  
  /// Checks if the current screen is a small screen (width < 375px)
  /// 
  /// Returns `true` for devices like iPhone SE (1st gen), small Android phones.
  /// Use this to apply compact layouts and smaller spacing.
  /// 
  /// Example:
  /// ```dart
  /// if (ResponsiveUtils.isSmallScreen(context)) {
  ///   return CompactLayout();
  /// }
  /// ```
  static bool isSmallScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < smallScreenWidth;
  }

  /// Checks if the current screen is a medium screen (375px <= width < 768px)
  /// 
  /// Returns `true` for most modern smartphones (iPhone 12, Pixel 5, etc.).
  /// This is the most common screen size category for mobile apps.
  /// 
  /// Example:
  /// ```dart
  /// if (ResponsiveUtils.isMediumScreen(context)) {
  ///   return StandardLayout();
  /// }
  /// ```
  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= smallScreenWidth && width < largeScreenWidth;
  }

  /// Checks if the current screen is a large screen (width >= 768px)
  /// 
  /// Returns `true` for tablets and large devices (iPad, Android tablets).
  /// Use this to apply expanded layouts with multiple columns.
  /// 
  /// Example:
  /// ```dart
  /// if (ResponsiveUtils.isLargeScreen(context)) {
  ///   return TabletLayout();
  /// }
  /// ```
  static bool isLargeScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= largeScreenWidth;
  }

  /// Cek apakah layar termasuk tablet (legacy method, kept for compatibility)
  /// 
  /// Note: Consider using `isLargeScreen()` for new code.
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }

  // ============================================================================
  // RESPONSIVE SIZING
  // ============================================================================
  
  /// Returns a responsive width value based on the current screen size
  /// 
  /// Automatically selects the appropriate value based on screen width:
  /// - Small screens (< 375px): returns `small` value
  /// - Medium screens (375-768px): returns `medium` value
  /// - Large screens (>= 768px): returns `large` value
  /// 
  /// Example:
  /// ```dart
  /// double cardWidth = ResponsiveUtils.responsiveWidth(
  ///   context,
  ///   small: 280.0,
  ///   medium: 340.0,
  ///   large: 400.0,
  /// );
  /// ```
  static double responsiveWidth(
    BuildContext context, {
    required double small,
    required double medium,
    required double large,
  }) {
    if (isSmallScreen(context)) return small;
    if (isMediumScreen(context)) return medium;
    return large;
  }

  /// Returns a responsive height value based on the current screen size
  /// 
  /// Automatically selects the appropriate value based on screen height:
  /// - Small screens (< 667px): returns `small` value
  /// - Medium screens (667-896px): returns `medium` value
  /// - Large screens (>= 896px): returns `large` value
  /// 
  /// Example:
  /// ```dart
  /// double imageHeight = ResponsiveUtils.responsiveHeight(
  ///   context,
  ///   small: 200.0,
  ///   medium: 280.0,
  ///   large: 350.0,
  /// );
  /// ```
  static double responsiveHeight(
    BuildContext context, {
    required double small,
    required double medium,
    required double large,
  }) {
    final height = MediaQuery.of(context).size.height;
    if (height < smallScreenHeight) return small;
    if (height < largeScreenHeight) return medium;
    return large;
  }

  /// Returns a responsive font size based on the current screen width
  /// 
  /// Applies scaling factors to the base font size:
  /// - Small screens (< 375px): 0.9x (90% of base size)
  /// - Medium screens (375-414px): 1.0x (100% of base size)
  /// - Large screens (414-768px): 1.05x (105% of base size)
  /// - Extra large screens (>= 768px): 1.1x (110% of base size)
  /// 
  /// This ensures text remains readable on small screens while taking advantage
  /// of extra space on larger screens.
  /// 
  /// Example:
  /// ```dart
  /// TextStyle(
  ///   fontSize: ResponsiveUtils.responsiveFontSize(context, 16.0),
  /// )
  /// ```
  static double responsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < smallScreenWidth) return baseSize * 0.9;
    if (width < mediumScreenWidth) return baseSize;
    if (width < largeScreenWidth) return baseSize * 1.05;
    return baseSize * 1.1;
  }

  /// Returns responsive padding based on the current screen size
  /// 
  /// Automatically selects the appropriate padding based on screen width:
  /// - Small screens (< 375px): returns `small` padding
  /// - Medium screens (375-768px): returns `medium` padding
  /// - Large screens (>= 768px): returns `large` padding
  /// 
  /// Use this to ensure consistent spacing that adapts to screen size.
  /// 
  /// Example:
  /// ```dart
  /// Padding(
  ///   padding: ResponsiveUtils.responsivePadding(
  ///     context,
  ///     small: EdgeInsets.all(12.0),
  ///     medium: EdgeInsets.all(16.0),
  ///     large: EdgeInsets.all(24.0),
  ///   ),
  ///   child: YourWidget(),
  /// )
  /// ```
  static EdgeInsets responsivePadding(
    BuildContext context, {
    required EdgeInsets small,
    required EdgeInsets medium,
    required EdgeInsets large,
  }) {
    if (isSmallScreen(context)) return small;
    if (isMediumScreen(context)) return medium;
    return large;
  }

  // ============================================================================
  // LEGACY METHODS (kept for compatibility)
  // ============================================================================

  /// Lebar layar
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Tinggi layar
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Safe area padding
  static EdgeInsets safeArea(BuildContext context) {
    return MediaQuery.of(context).padding;
  }
}

/// Responsive Utils — helper untuk UI adaptif
/// Sumber: docs/frontend/03_DESIGN_SYSTEM.md
import 'package:flutter/material.dart';

class ResponsiveUtils {
  /// Cek apakah layar termasuk tablet
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }

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

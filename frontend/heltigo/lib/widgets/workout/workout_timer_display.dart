/// WorkoutTimerDisplay — big timer angka untuk S-20 Active Workout
///
/// Format MM:SS atau HH:MM:SS jika >1 jam.
/// Pakai font numberBold dengan size besar (default 56sp).
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class WorkoutTimerDisplay extends StatelessWidget {
  /// Total detik untuk ditampilkan
  final int totalSeconds;

  /// Font size untuk angka utama (default 56)
  final double fontSize;

  /// Warna angka (default primary)
  final Color? color;

  /// Label kecil di atas timer (e.g., "TOTAL WAKTU")
  final String? label;

  const WorkoutTimerDisplay({
    super.key,
    required this.totalSeconds,
    this.fontSize = 56,
    this.color,
    this.label,
  });

  String _format(int total) {
    final h = total ~/ 3600;
    final m = (total ~/ 60) % 60;
    final s = total % 60;
    String two(int v) => v.toString().padLeft(2, '0');
    if (h > 0) {
      return '${two(h)}:${two(m)}:${two(s)}';
    }
    return '${two(m)}:${two(s)}';
  }

  @override
  Widget build(BuildContext context) {
    final tColor = color ?? AppColors.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Text(
            label!,
            style: AppTextStyles.overline.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        const SizedBox(height: AppDimensions.xs),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _format(totalSeconds),
            maxLines: 1,
            style: AppTextStyles.numberBold.copyWith(
              fontSize: fontSize,
              color: tColor,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}

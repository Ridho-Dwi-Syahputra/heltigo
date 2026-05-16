/// MacroProgressBar — horizontal progress bar dengan label & nilai
///
/// Digunakan di Home Dashboard untuk Kalori/Protein/Karbo/Lemak.
/// Layout: Row [label kiri | bar tengah | nilai kanan]
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class MacroProgressBar extends StatelessWidget {
  /// Label di kiri (mis. "Kalori")
  final String label;

  /// Nilai saat ini
  final double current;

  /// Target maksimum
  final double target;

  /// Unit suffix (mis. "kkal", "g")
  final String unit;

  /// Warna bar progress
  final Color color;

  const MacroProgressBar({
    super.key,
    required this.label,
    required this.current,
    required this.target,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Clamp 0..1 untuk progress
    final progress =
        target <= 0 ? 0.0 : (current / target).clamp(0.0, 1.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row: label + nilai
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${_format(current)}/${_format(target)} $unit',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.xs + 2),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.surfaceLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  /// Format angka — buang trailing .0 jika integer
  String _format(double v) {
    if (v == v.roundToDouble()) {
      // Integer: pakai thousand separator titik (ID-style)
      return v.toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]}.',
          );
    }
    return v.toStringAsFixed(1);
  }
}

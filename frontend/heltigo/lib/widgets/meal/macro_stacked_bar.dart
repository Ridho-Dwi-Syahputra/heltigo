/// MacroStackedBar — horizontal stacked bar untuk macro breakdown
///
/// Dipakai di S-23 Meal Detail KANDUNGAN GIZI section.
/// Layout: stacked bar 100% width dengan 3-4 segmen warna, lalu legend di bawah.
import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import 'nutrition_donut_chart.dart' show MacroSegment;

class MacroStackedBar extends StatelessWidget {
  final List<MacroSegment> segments;

  /// Height bar (default 10)
  final double barHeight;

  const MacroStackedBar({
    super.key,
    required this.segments,
    this.barHeight = 10,
  });

  @override
  Widget build(BuildContext context) {
    final total = segments.fold<double>(0, (sum, s) => sum + s.grams);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stacked bar
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          child: SizedBox(
            height: barHeight,
            width: double.infinity,
            child: total <= 0
                ? Container(color: AppColors.surfaceLight)
                : Row(
                    children: segments.where((s) => s.grams > 0).map((seg) {
                      final flex = (seg.grams * 1000).round();
                      return Expanded(
                        flex: flex,
                        child: Container(color: seg.color),
                      );
                    }).toList(),
                  ),
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        // Legend row
        LayoutBuilder(
          builder: (context, constraints) {
            // Wrap untuk responsive di layar sempit
            return Wrap(
              spacing: AppDimensions.base,
              runSpacing: AppDimensions.sm,
              children: segments.map((seg) {
                return _LegendItem(segment: seg);
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final MacroSegment segment;

  const _LegendItem({required this.segment});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: segment.color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: AppDimensions.xs + 2),
        Text(
          segment.label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: AppDimensions.xs),
        Text(
          '${segment.grams.toStringAsFixed(0)}g',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

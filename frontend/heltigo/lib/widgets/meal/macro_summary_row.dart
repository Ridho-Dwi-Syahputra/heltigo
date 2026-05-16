/// MacroSummaryRow — row compact 4 macro inline dengan divider
///
/// Dipakai di S-22 Meal List. Layout horizontal: Kalori | Protein | Karbo | Lemak.
/// Setiap cell: angka besar + label + mini bar tipis.
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class MacroSummaryItem {
  final String label;
  final double current;
  final double target;
  final String unit;
  final Color color;

  const MacroSummaryItem({
    required this.label,
    required this.current,
    required this.target,
    required this.unit,
    required this.color,
  });
}

class MacroSummaryRow extends StatelessWidget {
  final List<MacroSummaryItem> items;

  const MacroSummaryRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          return Expanded(
            child: Row(
              children: [
                if (i > 0)
                  Container(
                    width: 1,
                    height: 36,
                    color: AppColors.border,
                  ),
                Expanded(child: _MacroCell(item: items[i])),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _MacroCell extends StatelessWidget {
  final MacroSummaryItem item;

  const _MacroCell({required this.item});

  @override
  Widget build(BuildContext context) {
    final progress = item.target <= 0
        ? 0.0
        : (item.current / item.target).clamp(0.0, 1.0).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xs),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatNumber(item.current),
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '${_formatNumber(item.target)} ${item.unit}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: AppColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(item.color),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double v) {
    if (v == v.roundToDouble()) {
      return v.toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]}.',
          );
    }
    return v.toStringAsFixed(0);
  }
}

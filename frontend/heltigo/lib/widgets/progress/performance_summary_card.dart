/// PerformanceSummaryCard — daftar baris ringkasan performa
///
/// Dipakai di S-29 Weekly Report & S-34 Replanning Evaluation.
/// Setiap baris: icon avatar + label + nilai utama.
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class PerformanceSummaryRowData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const PerformanceSummaryRowData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class PerformanceSummaryCard extends StatelessWidget {
  final List<PerformanceSummaryRowData> rows;

  const PerformanceSummaryCard({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(rows.length, (i) {
          final isLast = i == rows.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.base,
              vertical: AppDimensions.md,
            ),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(
                        color: AppColors.divider,
                        width: 1,
                      ),
                    ),
            ),
            child: _PerformanceRow(data: rows[i]),
          );
        }),
      ),
    );
  }
}

class _PerformanceRow extends StatelessWidget {
  final PerformanceSummaryRowData data;

  const _PerformanceRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: data.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          ),
          child: Icon(data.icon, size: 18, color: data.color),
        ),
        const SizedBox(width: AppDimensions.md),
        Expanded(
          child: Text(
            data.label,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.sm),
        Text(
          data.value,
          style: AppTextStyles.bodyLarge.copyWith(
            color: data.color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

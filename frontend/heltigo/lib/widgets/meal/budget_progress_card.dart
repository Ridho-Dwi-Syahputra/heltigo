/// BudgetProgressCard — kartu budget harian orange gradient
///
/// Dipakai di S-22 Meal List. Tap → navigasi ke Budget Settings.
/// Display: label "BUDGET HARIAN" + spent + sisa besar di kanan + progress bar.
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class BudgetProgressCard extends StatelessWidget {
  /// Jumlah yang sudah dipakai
  final int spent;

  /// Total budget harian
  final int total;

  /// Currency prefix (default "Rp")
  final String currencyPrefix;

  /// Callback saat card di-tap
  final VoidCallback? onTap;

  const BudgetProgressCard({
    super.key,
    required this.spent,
    required this.total,
    this.currencyPrefix = 'Rp',
    this.onTap,
  });

  String _formatThousand(int v) {
    return v.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = (total - spent).clamp(0, total);
    final progress = total <= 0 ? 0.0 : (spent / total).clamp(0.0, 1.0).toDouble();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.base),
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 4),
              blurRadius: 16,
              color: Color(0x33FB3A01),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side — label + spent
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'BUDGET HARIAN',
                            style: AppTextStyles.overline.copyWith(
                              color: AppColors.white.withValues(alpha: 0.85),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.xs),
                          Icon(
                            Icons.chevron_right,
                            size: 14,
                            color: AppColors.white.withValues(alpha: 0.85),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.xs),
                      Text(
                        '$currencyPrefix ${_formatThousand(spent)}',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'dipakai dari $currencyPrefix ${_formatThousand(total)}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                // Right side — sisa
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'SISA',
                      style: AppTextStyles.overline.copyWith(
                        color: AppColors.white.withValues(alpha: 0.85),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      '$currencyPrefix ${_formatThousand(remaining)}',
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.white.withValues(alpha: 0.25),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

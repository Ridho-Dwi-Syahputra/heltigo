/// MealSectionCard — kartu section per waktu makan dengan list food
///
/// Dipakai di S-22 Meal List. Tap card → navigate ke detail.
/// State: completed (✓), highlighted (aktif/sekarang), pending.
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class FoodItemRow {
  final String name;
  final int kcal;
  final int priceIdr;

  const FoodItemRow({
    required this.name,
    required this.kcal,
    required this.priceIdr,
  });
}

class MealSectionCard extends StatelessWidget {
  /// Tipe meal (Sarapan, Makan Siang, Makan Malam, Cemilan)
  final String mealType;

  /// Waktu (mis. "07:00")
  final String time;

  /// Total kalori untuk meal ini
  final int totalCalories;

  /// Status: sudah selesai dimakan
  final bool isCompleted;

  /// Highlight sebagai meal aktif (waktu sekarang)
  final bool isHighlighted;

  /// List food item di dalam meal
  final List<FoodItemRow> foods;

  /// Icon untuk meal type (default Icons.restaurant_outlined)
  final IconData icon;

  /// Callback saat card di-tap
  final VoidCallback? onTap;

  const MealSectionCard({
    super.key,
    required this.mealType,
    required this.time,
    required this.totalCalories,
    required this.foods,
    this.isCompleted = false,
    this.isHighlighted = false,
    this.icon = Icons.restaurant_outlined,
    this.onTap,
  });

  String _formatThousand(int v) {
    return v.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }

  String _formatPrice(int idr) {
    if (idr >= 1000) {
      final k = idr / 1000;
      if (k == k.roundToDouble()) {
        return 'Rp ${k.toInt()}K';
      }
      return 'Rp ${k.toStringAsFixed(1)}K';
    }
    return 'Rp $idr';
  }

  Color get _bgColor {
    if (isHighlighted) return AppColors.primaryMuted;
    if (isCompleted) return AppColors.surface;
    return AppColors.surface;
  }

  Color get _borderColor {
    if (isHighlighted) return AppColors.primary;
    if (isCompleted) return AppColors.success.withValues(alpha: 0.4);
    return AppColors.border;
  }

  Widget _buildStatusBadge() {
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.sm,
          vertical: 3,
        ),
        decoration: BoxDecoration(
          color: AppColors.successMuted,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              size: 12,
              color: AppColors.success,
            ),
            const SizedBox(width: 3),
            Text(
              'SELESAI',
              style: AppTextStyles.overline.copyWith(
                color: AppColors.success,
              ),
            ),
          ],
        ),
      );
    }
    if (isHighlighted) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.sm,
          vertical: 3,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        child: Text(
          'AKTIF',
          style: AppTextStyles.overline.copyWith(
            color: AppColors.white,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        'PENDING',
        style: AppTextStyles.overline.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      child: Container(
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(
            color: _borderColor,
            width: isHighlighted ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── HEADER ───
            Padding(
              padding: const EdgeInsets.all(AppDimensions.base),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusInput,
                      ),
                    ),
                    child: Icon(icon, size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                mealType,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.xs + 2,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusFull,
                                ),
                              ),
                              child: Text(
                                time,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_formatThousand(totalCalories)} kkal',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  _buildStatusBadge(),
                ],
              ),
            ),
            // Divider antara header & body
            Divider(
              height: 1,
              thickness: 1,
              color: AppColors.border.withValues(alpha: 0.5),
              indent: AppDimensions.base,
              endIndent: AppDimensions.base,
            ),
            // ─── FOODS LIST ───
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.base,
                vertical: AppDimensions.sm + 2,
              ),
              child: Column(
                children: foods.map((food) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.textTertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.sm),
                        Expanded(
                          child: Text(
                            food.name,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          _formatPrice(food.priceIdr),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

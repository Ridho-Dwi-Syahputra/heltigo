/// ExerciseListTile — row exercise di S-17 Workout Day Detail
///
/// Status: pending (default) atau completed (bg primaryMuted + check icon).
/// Tap → buka S-18 Exercise Detail.
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

enum ExercisePhase { warmup, main, cooldown }

class ExerciseListTile extends StatelessWidget {
  /// Nomor urut di list (1, 2, 3, ...)
  final int orderNumber;

  /// Nama latihan
  final String name;

  /// Label set × reps (e.g., "4 × 12")
  final String setsRepsLabel;

  /// Detik istirahat antar set
  final int restSeconds;

  /// Status apakah sudah selesai
  final bool isCompleted;

  /// Fase: warmup/main/cooldown (untuk icon)
  final ExercisePhase phase;

  /// Tap callback
  final VoidCallback? onTap;

  const ExerciseListTile({
    super.key,
    required this.orderNumber,
    required this.name,
    required this.setsRepsLabel,
    required this.phase,
    this.restSeconds = 60,
    this.isCompleted = false,
    this.onTap,
  });

  IconData get _phaseIcon {
    switch (phase) {
      case ExercisePhase.warmup:
        return Icons.local_fire_department_outlined;
      case ExercisePhase.main:
        return Icons.fitness_center;
      case ExercisePhase.cooldown:
        return Icons.spa_outlined;
    }
  }

  Color get _phaseColor {
    switch (phase) {
      case ExercisePhase.warmup:
        return AppColors.accent;
      case ExercisePhase.main:
        return AppColors.primary;
      case ExercisePhase.cooldown:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.md,
        ),
        decoration: BoxDecoration(
          color: isCompleted ? AppColors.primaryMuted : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          border: Border.all(
            color: isCompleted
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            // ─── Order number atau check icon ───
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.primary
                    : _phaseColor.withValues(alpha: 0.15),
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusInput),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(
                        Icons.check,
                        size: 18,
                        color: AppColors.white,
                      )
                    : Text(
                        orderNumber.toString().padLeft(2, '0'),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: _phaseColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: AppDimensions.md),

            // ─── Name + sub ───
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(_phaseIcon, size: 12, color: _phaseColor),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '$setsRepsLabel · istirahat ${restSeconds}s',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.sm),

            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

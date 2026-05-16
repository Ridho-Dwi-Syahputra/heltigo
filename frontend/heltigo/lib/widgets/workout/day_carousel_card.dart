/// DayCarouselCard — card untuk satu hari di carousel S-16 Program Latihanku
///
/// Status:
/// - pending: belum mulai (bg surface)
/// - active: hari ini, sedang berjalan (gradient teal, glow)
/// - completed: sudah selesai (bg success-muted)
/// - rest: hari istirahat (bg surface + icon istirahat)
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

enum DayStatus { pending, active, completed, rest }

class DayCarouselCard extends StatelessWidget {
  /// Nama hari (e.g., "Rabu")
  final String dayName;

  /// Label tanggal (e.g., "8 Mei")
  final String dateLabel;

  /// Nama workout (e.g., "Push & Core Day"). Kosong untuk rest day.
  final String workoutName;

  /// Stats: total set
  final int? totalSets;

  /// Stats: rep per set average
  final int? avgReps;

  /// Stats: durasi menit
  final int? durationMinutes;

  /// Preview exercise names (3-4 items)
  final List<String> exercisesPreview;

  /// Status hari
  final DayStatus status;

  /// Callback tap card
  final VoidCallback? onTap;

  /// Callback tap CTA button
  final VoidCallback? onAction;

  const DayCarouselCard({
    super.key,
    required this.dayName,
    required this.dateLabel,
    required this.workoutName,
    required this.status,
    this.totalSets,
    this.avgReps,
    this.durationMinutes,
    this.exercisesPreview = const [],
    this.onTap,
    this.onAction,
  });

  bool get _isActive => status == DayStatus.active;
  bool get _isCompleted => status == DayStatus.completed;
  bool get _isRest => status == DayStatus.rest;

  // ─── Visual config per status ───
  Color get _bgFallback {
    if (_isCompleted) return AppColors.success.withValues(alpha: 0.12);
    return AppColors.surface;
  }

  Color get _borderColor {
    if (_isActive) return AppColors.accent;
    if (_isCompleted) return AppColors.success.withValues(alpha: 0.5);
    return AppColors.border;
  }

  String get _statusLabel {
    switch (status) {
      case DayStatus.active:
        return 'HARI INI';
      case DayStatus.completed:
        return 'SELESAI';
      case DayStatus.pending:
        return 'PENDING';
      case DayStatus.rest:
        return 'ISTIRAHAT';
    }
  }

  Color get _statusColor {
    switch (status) {
      case DayStatus.active:
        return AppColors.accent;
      case DayStatus.completed:
        return AppColors.success;
      case DayStatus.pending:
        return AppColors.textTertiary;
      case DayStatus.rest:
        return AppColors.streakPurple;
    }
  }

  String get _ctaLabel {
    switch (status) {
      case DayStatus.active:
        return 'Mulai Latihan';
      case DayStatus.completed:
        return 'Lihat Hasil';
      case DayStatus.pending:
        return 'Lihat Detail';
      case DayStatus.rest:
        return 'Nikmati Istirahat';
    }
  }

  IconData get _ctaIcon {
    switch (status) {
      case DayStatus.active:
        return Icons.play_arrow_rounded;
      case DayStatus.completed:
        return Icons.check_circle_outline;
      case DayStatus.pending:
        return Icons.chevron_right;
      case DayStatus.rest:
        return Icons.bedtime_outlined;
    }
  }

  Color get _ctaBg {
    switch (status) {
      case DayStatus.active:
        return AppColors.accent;
      case DayStatus.completed:
        return AppColors.success.withValues(alpha: 0.25);
      case DayStatus.pending:
        return AppColors.surfaceLight;
      case DayStatus.rest:
        return AppColors.streakPurple.withValues(alpha: 0.25);
    }
  }

  Color get _ctaFg {
    if (_isActive) return AppColors.white;
    if (_isCompleted) return AppColors.success;
    if (_isRest) return AppColors.streakPurple;
    return AppColors.textPrimary;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.base),
        decoration: BoxDecoration(
          gradient: _isActive ? AppColors.primaryGradient : null,
          color: _isActive ? null : _bgFallback,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(
            color: _borderColor,
            width: _isActive ? 0 : 1.5,
          ),
          boxShadow: _isActive ? AppShadows.glow : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header: dayName + status badge ───
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dayName.toUpperCase(),
                        style: AppTextStyles.overline.copyWith(
                          color: _isActive
                              ? AppColors.white.withValues(alpha: 0.85)
                              : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateLabel,
                        style: AppTextStyles.h3.copyWith(
                          color: _isActive
                              ? AppColors.white
                              : AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _isActive
                        ? AppColors.white.withValues(alpha: 0.2)
                        : _statusColor.withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(
                    _statusLabel,
                    style: AppTextStyles.overline.copyWith(
                      color: _isActive ? AppColors.white : _statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),

            // ─── Workout name ───
            Text(
              workoutName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.h2.copyWith(
                color: _isActive ? AppColors.white : AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimensions.xs),

            // ─── Stats row inline ───
            if (!_isRest)
              Row(
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 14,
                    color: _isActive
                        ? AppColors.white.withValues(alpha: 0.85)
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _buildStatsLabel(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _isActive
                            ? AppColors.white.withValues(alpha: 0.85)
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: AppDimensions.md),

            // ─── Exercises preview ───
            if (!_isRest && exercisesPreview.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sm + 2,
                  vertical: AppDimensions.sm,
                ),
                decoration: BoxDecoration(
                  color: _isActive
                      ? AppColors.white.withValues(alpha: 0.12)
                      : AppColors.surfaceLight,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusInput),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: exercisesPreview.take(4).map((name) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: _isActive
                                  ? AppColors.white.withValues(alpha: 0.8)
                                  : AppColors.textTertiary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.sm),
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: _isActive
                                    ? AppColors.white.withValues(alpha: 0.92)
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppDimensions.md),
            ],
            if (_isRest) ...[
              Container(
                padding: const EdgeInsets.all(AppDimensions.base),
                decoration: BoxDecoration(
                  color: AppColors.streakPurple.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusInput),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.self_improvement,
                      color: AppColors.streakPurple,
                      size: 20,
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: Text(
                        'Hari pemulihan — biarkan otot recovery',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.md),
            ],

            // ─── CTA Button ───
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                onPressed: onAction ?? onTap,
                icon: Icon(_ctaIcon, size: 18),
                label: Text(
                  _ctaLabel,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _ctaFg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _ctaBg,
                  foregroundColor: _ctaFg,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusButton),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildStatsLabel() {
    final parts = <String>[];
    if (totalSets != null) parts.add('$totalSets set');
    if (avgReps != null) parts.add('$avgReps reps');
    if (durationMinutes != null) parts.add('$durationMinutes mnt');
    return parts.join(' · ');
  }
}

/// S-21b: Workout Session Detail — detail riwayat sesi latihan
/// Dipanggil dari S-21 "Lihat Detail" atau dari history.
///
/// Layout:
/// 1. AppBar "Detail Sesi" + back
/// 2. Hero card: workout name + date + status badge
/// 3. Stats grid 2x2 (durasi, set, reps, kalori)
/// 4. Daftar Latihan (list exercises dengan set/reps actual)
/// 5. Catatan AI / mood after
/// 6. Sticky bottom: button bagikan + ulangi
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';
import '../../widgets/universal/primary_button.dart';
import '../../widgets/universal/secondary_button.dart';

class _ExerciseResult {
  final String name;
  final int setsTarget;
  final int setsDone;
  final int repsTarget;
  final int repsDone;
  final bool completed;

  const _ExerciseResult({
    required this.name,
    required this.setsTarget,
    required this.setsDone,
    required this.repsTarget,
    required this.repsDone,
    required this.completed,
  });
}

class WorkoutSessionDetailScreen extends StatelessWidget {
  final String sessionId;

  const WorkoutSessionDetailScreen({super.key, required this.sessionId});

  // ─── Mock data ───
  static const String _workoutName = 'Push & Core Day';
  static const String _dateLabel = 'Rabu, 15 Mei 2026';
  static const String _timeLabel = '07:30 – 07:58';
  static const int _durationMinutes = 28;
  static const int _setsCompleted = 16;
  static const int _totalReps = 156;
  static const int _caloriesBurned = 245;
  static const String _moodBefore = 'Bersemangat';
  static const String _moodAfter = 'Mantap';
  static const String _aiNote =
      'Performa kamu naik 8% dibanding sesi sebelumnya. '
      'Volume push-up bertambah +5 reps. Pertahankan ritme ini!';

  static const List<_ExerciseResult> _results = [
    _ExerciseResult(
      name: 'Jumping Jacks',
      setsTarget: 1,
      setsDone: 1,
      repsTarget: 30,
      repsDone: 30,
      completed: true,
    ),
    _ExerciseResult(
      name: 'Arm Circles',
      setsTarget: 1,
      setsDone: 1,
      repsTarget: 20,
      repsDone: 20,
      completed: true,
    ),
    _ExerciseResult(
      name: 'Push-Up',
      setsTarget: 4,
      setsDone: 4,
      repsTarget: 12,
      repsDone: 12,
      completed: true,
    ),
    _ExerciseResult(
      name: 'Diamond Push-Up',
      setsTarget: 3,
      setsDone: 3,
      repsTarget: 10,
      repsDone: 10,
      completed: true,
    ),
    _ExerciseResult(
      name: 'Plank',
      setsTarget: 3,
      setsDone: 3,
      repsTarget: 30,
      repsDone: 30,
      completed: true,
    ),
    _ExerciseResult(
      name: 'Mountain Climber',
      setsTarget: 3,
      setsDone: 3,
      repsTarget: 20,
      repsDone: 18,
      completed: true,
    ),
    _ExerciseResult(
      name: 'Cobra Stretch',
      setsTarget: 1,
      setsDone: 1,
      repsTarget: 30,
      repsDone: 30,
      completed: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.textPrimary,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text('Detail Sesi', style: AppTextStyles.h3),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.base,
                  vertical: AppDimensions.sm,
                ),
                children: [
                  // ─── 1. Hero card ───
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.base),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusCard),
                      boxShadow: AppShadows.glow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.sm,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusFull,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    size: 12,
                                    color: AppColors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'SELESAI',
                                    style: AppTextStyles.overline.copyWith(
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _timeLabel,
                              style: AppTextStyles.caption.copyWith(
                                color:
                                    AppColors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.md),
                        Text(
                          _workoutName,
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color:
                                  AppColors.white.withValues(alpha: 0.85),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _dateLabel,
                              style: AppTextStyles.bodySmall.copyWith(
                                color:
                                    AppColors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // ─── 2. Stats grid ───
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppDimensions.sm,
                    crossAxisSpacing: AppDimensions.sm,
                    childAspectRatio: 1.7,
                    children: const [
                      _StatTile(
                        icon: Icons.schedule,
                        value: '$_durationMinutes',
                        unit: 'mnt',
                        label: 'Durasi',
                        color: AppColors.primary,
                      ),
                      _StatTile(
                        icon: Icons.fitness_center,
                        value: '$_setsCompleted',
                        unit: 'set',
                        label: 'Set Selesai',
                        color: AppColors.accent,
                      ),
                      _StatTile(
                        icon: Icons.repeat,
                        value: '$_totalReps',
                        unit: 'reps',
                        label: 'Total Reps',
                        color: AppColors.warning,
                      ),
                      _StatTile(
                        icon: Icons.local_fire_department,
                        value: '$_caloriesBurned',
                        unit: 'kkal',
                        label: 'Kalori',
                        color: AppColors.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // ─── 3. AI Insight ───
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.base),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMuted,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusCard),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'CATATAN HELTIGO AI',
                                style: AppTextStyles.overline.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _aiNote,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textPrimary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // ─── 4. Mood Before/After ───
                  Text(
                    'KONDISI SESI',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _MoodBlock(
                          icon: Icons.sentiment_satisfied,
                          label: 'Sebelum',
                          value: _moodBefore,
                          color: AppColors.info,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      Expanded(
                        child: _MoodBlock(
                          icon: Icons.sentiment_very_satisfied,
                          label: 'Setelah',
                          value: _moodAfter,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // ─── 5. Daftar Latihan ───
                  Text(
                    'DAFTAR LATIHAN',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusCard),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: List.generate(_results.length, (i) {
                        final r = _results[i];
                        final isLast = i == _results.length - 1;
                        return _ExerciseRow(
                          orderNumber: i + 1,
                          result: r,
                          isLast: isLast,
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xl),
                ],
              ),
            ),

            // ─── Sticky bottom ───
            Container(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.base,
                AppDimensions.sm,
                AppDimensions.base,
                AppDimensions.base +
                    MediaQuery.of(context).padding.bottom,
              ),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(color: AppColors.divider, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Bagikan',
                      icon: Icons.share_outlined,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fitur bagikan segera tersedia'),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Ulangi',
                      icon: Icons.replay,
                      onPressed: () => context.go('/workout'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// STAT TILE
// ═══════════════════════════════════════════════════════════════

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String unit;
  final String label;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.unit,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                    children: [
                      TextSpan(text: value),
                      TextSpan(
                        text: ' $unit',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MOOD BLOCK
// ═══════════════════════════════════════════════════════════════

class _MoodBlock extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MoodBlock({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// EXERCISE ROW
// ═══════════════════════════════════════════════════════════════

class _ExerciseRow extends StatelessWidget {
  final int orderNumber;
  final _ExerciseResult result;
  final bool isLast;

  const _ExerciseRow({
    required this.orderNumber,
    required this.result,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isFullyDone = result.repsDone >= result.repsTarget &&
        result.setsDone >= result.setsTarget;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.base,
        vertical: AppDimensions.md,
      ),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.divider, width: 1),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isFullyDone
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.warning.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFullyDone ? Icons.check : Icons.warning_amber_rounded,
              size: 16,
              color: isFullyDone ? AppColors.success : AppColors.warning,
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  result.name,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${result.setsDone}/${result.setsTarget} set · '
                  '${result.repsDone}/${result.repsTarget} reps',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Text(
            '#$orderNumber',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

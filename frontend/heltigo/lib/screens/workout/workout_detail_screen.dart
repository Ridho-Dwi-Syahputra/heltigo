/// S-17: Workout Day Detail — daftar exercises untuk hari yang dipilih
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-17
///
/// Layout (matching reference image):
/// 1. Compact header — avatar + tanggal + sub stats
/// 2. Hero card teal — workout name + stats inline
/// 3. Section PEMANASAN (overline accent)
/// 4. Section LATIHAN UTAMA (overline primary) — current exercise highlighted
/// 5. Section PENDINGINAN (overline info)
/// 6. Sticky bottom CTA "Mulai Latihan"
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';
import '../../widgets/universal/primary_button.dart';

enum _Phase { warmup, main, cooldown }

class _Exercise {
  final String id;
  final String name;
  final String detailLabel;
  final _Phase phase;
  final bool isCurrent;

  const _Exercise({
    required this.id,
    required this.name,
    required this.detailLabel,
    required this.phase,
    this.isCurrent = false,
  });
}

class WorkoutDetailScreen extends StatelessWidget {
  final String workoutId;

  const WorkoutDetailScreen({super.key, required this.workoutId});

  // ─── Mock data ───
  static const String _workoutName = 'Push & Core Day';
  static const String _dateLabel = 'Rabu, 8 Mei';
  static const String _subStats = '6 Latihan · 28 Menit · Home';

  static const int _durationMinutes = 28;
  static const int _totalSets = 18;
  static const int _totalExercises = 6;

  static const List<_Exercise> _exercises = [
    // Pemanasan
    _Exercise(
      id: 'ex-jumping-jack',
      name: 'Jumping Jack',
      detailLabel: '30 detik',
      phase: _Phase.warmup,
    ),
    _Exercise(
      id: 'ex-arm-circle',
      name: 'Arm Circle',
      detailLabel: '20 reps',
      phase: _Phase.warmup,
    ),
    // Latihan Utama
    _Exercise(
      id: 'ex-push-up',
      name: 'Push-Up',
      detailLabel: '4 set 12 reps · 45s rest',
      phase: _Phase.main,
      isCurrent: true,
    ),
    _Exercise(
      id: 'ex-diamond-push',
      name: 'Diamond Push-Up',
      detailLabel: '3 set 10 reps · 60s rest',
      phase: _Phase.main,
    ),
    _Exercise(
      id: 'ex-plank',
      name: 'Plank',
      detailLabel: '3 set 40 detik · 30s rest',
      phase: _Phase.main,
    ),
    _Exercise(
      id: 'ex-mountain-climber',
      name: 'Mountain Climber',
      detailLabel: '3 set 20 reps · 30s rest',
      phase: _Phase.main,
    ),
    // Pendinginan
    _Exercise(
      id: 'ex-stretching',
      name: 'Stretching',
      detailLabel: '5 menit',
      phase: _Phase.cooldown,
    ),
  ];

  List<_Exercise> _byPhase(_Phase phase) =>
      _exercises.where((e) => e.phase == phase).toList();

  void _onTapExercise(BuildContext context, _Exercise ex) {
    context.push('/workout/exercise/${ex.id}');
  }

  @override
  Widget build(BuildContext context) {
    final warmup = _byPhase(_Phase.warmup);
    final main = _byPhase(_Phase.main);
    final cooldown = _byPhase(_Phase.cooldown);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ═══════════════════════════════════════
            // 1. COMPACT HEADER
            // ═══════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.sm,
                AppDimensions.xs,
                AppDimensions.base,
                AppDimensions.sm,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    color: AppColors.textPrimary,
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/workout');
                      }
                    },
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm + 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _dateLabel,
                          style: AppTextStyles.h3.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          _subStats,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ═══════════════════════════════════════
            // 2-5. BODY LIST
            // ═══════════════════════════════════════
            Expanded(
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.base,
                  vertical: AppDimensions.xs,
                ),
                children: [
                  // ─── Hero card teal ───
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
                        Text(
                          _workoutName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.xs),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 14,
                              color: AppColors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_durationMinutes mnt',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.white
                                    .withValues(alpha: 0.92),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.sm),
                            const Icon(
                              Icons.fitness_center,
                              size: 14,
                              color: AppColors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_totalSets set',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.white
                                    .withValues(alpha: 0.92),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.sm),
                            const Icon(
                              Icons.list_alt,
                              size: 14,
                              color: AppColors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_totalExercises latihan',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.white
                                    .withValues(alpha: 0.92),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // ─── 3. PEMANASAN ───
                  const _SectionHeader(
                    label: 'PEMANASAN (5 MNT)',
                    icon: Icons.local_fire_department_outlined,
                    color: AppColors.accent,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  ...warmup.map(
                    (ex) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppDimensions.sm),
                      child: _ExerciseCheckRow(
                        exercise: ex,
                        onTap: () => _onTapExercise(context, ex),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),

                  // ─── 4. LATIHAN UTAMA ───
                  const _SectionHeader(
                    label: 'LATIHAN UTAMA',
                    icon: Icons.fitness_center,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  ...List.generate(main.length, (i) {
                    final ex = main[i];
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppDimensions.sm),
                      child: _ExerciseCheckRow(
                        exercise: ex,
                        orderNumber: i + 1,
                        onTap: () => _onTapExercise(context, ex),
                      ),
                    );
                  }),
                  const SizedBox(height: AppDimensions.md),

                  // ─── 5. PENDINGINAN ───
                  const _SectionHeader(
                    label: 'PENDINGINAN',
                    icon: Icons.spa_outlined,
                    color: AppColors.info,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  ...cooldown.map(
                    (ex) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppDimensions.sm),
                      child: _ExerciseCheckRow(
                        exercise: ex,
                        onTap: () => _onTapExercise(context, ex),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xl),
                ],
              ),
            ),

            // ═══════════════════════════════════════
            // 6. STICKY BOTTOM CTA
            // ═══════════════════════════════════════
            Container(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.base,
                AppDimensions.sm,
                AppDimensions.base,
                AppDimensions.base + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(color: AppColors.divider, width: 1),
                ),
              ),
              child: PrimaryButton(
                label: 'Mulai Latihan',
                icon: Icons.play_arrow_rounded,
                onPressed: () =>
                    context.push('/workout/checkin/$workoutId'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SECTION HEADER
// ═══════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: AppDimensions.xs + 2),
        Text(
          label,
          style: AppTextStyles.overline.copyWith(
            color: color,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// EXERCISE CHECK ROW — baris dengan checkbox circle + info icon
// ═══════════════════════════════════════════════════════════════

class _ExerciseCheckRow extends StatelessWidget {
  final _Exercise exercise;
  final int? orderNumber;
  final VoidCallback onTap;

  const _ExerciseCheckRow({
    required this.exercise,
    required this.onTap,
    this.orderNumber,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrent = exercise.isCurrent;

    final bg = isCurrent ? AppColors.primaryMuted : AppColors.surface;
    final borderColor = isCurrent ? AppColors.primary : AppColors.border;
    final borderWidth = isCurrent ? 1.5 : 1.0;

    final displayName = orderNumber != null
        ? '$orderNumber. ${exercise.name}'
        : exercise.name;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.sm + 2,
          vertical: AppDimensions.sm + 2,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Row(
          children: [
            _CheckCircle(isCurrent: isCurrent),
            const SizedBox(width: AppDimensions.sm + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    exercise.detailLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            Icon(
              Icons.info_outline,
              size: 18,
              color: isCurrent
                  ? AppColors.primary
                  : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  final bool isCurrent;

  const _CheckCircle({required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    if (isCurrent) {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
      );
    }
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.textTertiary.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
    );
  }
}

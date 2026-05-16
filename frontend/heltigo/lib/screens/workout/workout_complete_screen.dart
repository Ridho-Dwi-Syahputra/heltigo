/// S-21: Workout Complete Screen — celebration setelah latihan selesai
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-21
///
/// Layout:
/// 1. Hero gradient teal celebration
/// 2. Stats Grid 2x2 (Durasi/Set/Reps/Kalori)
/// 3. Perbandingan card (vs latihan terakhir)
/// 4. Streak card purple
/// 5. Mood After row (3 emoji button)
/// 6. PrimaryButton "Kembali ke Beranda"
/// 7. SecondaryButton "Lihat Detail"
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';
import '../../widgets/universal/primary_button.dart';
import '../../widgets/universal/secondary_button.dart';

class WorkoutCompleteScreen extends StatefulWidget {
  final String workoutId;

  const WorkoutCompleteScreen({super.key, required this.workoutId});

  @override
  State<WorkoutCompleteScreen> createState() => _WorkoutCompleteScreenState();
}

class _WorkoutCompleteScreenState extends State<WorkoutCompleteScreen> {
  // ─── Mock data ───
  static const int _durationMinutes = 28;
  static const int _setsCompleted = 16;
  static const int _totalReps = 156;
  static const int _caloriesBurned = 245;

  static const int _streakDays = 12;
  static const int _repsDelta = 5;
  static const int _minutesDelta = 2;

  int _moodAfterIndex = -1;

  static const List<({IconData icon, String label, Color color})> _moodOptions = [
    (
      icon: Icons.sentiment_dissatisfied,
      label: 'Lelah',
      color: AppColors.warning,
    ),
    (
      icon: Icons.sentiment_neutral,
      label: 'Biasa',
      color: AppColors.info,
    ),
    (
      icon: Icons.sentiment_very_satisfied,
      label: 'Mantap',
      color: AppColors.success,
    ),
  ];

  void _openSessionDetail() {
    context.push('/workout/session/${widget.workoutId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, size: 22),
            color: AppColors.textPrimary,
            onPressed: () => context.go('/home'),
            tooltip: 'Tutup',
          ),
          const SizedBox(width: AppDimensions.xs),
        ],
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
                  // ─── 1. Hero Celebration ───
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.xl,
                      horizontal: AppDimensions.base,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusCard),
                      boxShadow: AppShadows.glow,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.celebration,
                            color: AppColors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.md),
                        Text(
                          'Luar Biasa!',
                          style: AppTextStyles.h1.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 32,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.xs),
                        Text(
                          'Latihan Selesai',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // ─── 2. Stats Grid 2x2 ───
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppDimensions.sm,
                    crossAxisSpacing: AppDimensions.sm,
                    childAspectRatio: 1.6,
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
                  const SizedBox(height: AppDimensions.base),

                  // ─── 3. Comparison ───
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.base),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusCard),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                AppColors.success.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.trending_up,
                            color: AppColors.success,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'PROGRES NAIK',
                                style: AppTextStyles.overline.copyWith(
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '+$_repsDelta reps · +$_minutesDelta mnt vs latihan terakhir',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.base),

                  // ─── 4. Streak Card ───
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.base),
                    decoration: BoxDecoration(
                      color:
                          AppColors.streakPurple.withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusCard),
                      border: Border.all(
                        color: AppColors.streakPurple
                            .withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.streakPurple
                                .withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.local_fire_department,
                            color: AppColors.streakPurple,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Streak $_streakDays Hari!',
                                style: AppTextStyles.h3.copyWith(
                                  color: AppColors.streakPurple,
                                ),
                              ),
                              Text(
                                '+1 hari baru ditambahkan',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // ─── 5. Mood After ───
                  Text(
                    'Perasaan setelah latihan?',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Row(
                    children:
                        List.generate(_moodOptions.length, (i) {
                      final isLast = i == _moodOptions.length - 1;
                      final opt = _moodOptions[i];
                      final isActive = i == _moodAfterIndex;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: isLast ? 0 : AppDimensions.sm,
                          ),
                          child: InkWell(
                            onTap: () =>
                                setState(() => _moodAfterIndex = i),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusCard,
                            ),
                            child: AnimatedContainer(
                              duration: AppDurations.fast,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppDimensions.md,
                                horizontal: AppDimensions.sm,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? opt.color.withValues(alpha: 0.15)
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusCard,
                                ),
                                border: Border.all(
                                  color: isActive
                                      ? opt.color
                                      : AppColors.border,
                                  width: isActive ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedScale(
                                    duration: AppDurations.fast,
                                    scale: isActive ? 1.15 : 1.0,
                                    child: Icon(
                                      opt.icon,
                                      size: 28,
                                      color: isActive
                                          ? opt.color
                                          : AppColors.textTertiary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    opt.label,
                                    style:
                                        AppTextStyles.caption.copyWith(
                                      color: isActive
                                          ? AppColors.textPrimary
                                          : AppColors.textTertiary,
                                      fontWeight: isActive
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // ─── Sticky bottom buttons ───
            Container(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.base,
                AppDimensions.sm,
                AppDimensions.base,
                AppDimensions.base +
                    MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(color: AppColors.divider, width: 1),
                ),
              ),
              child: Column(
                children: [
                  PrimaryButton(
                    label: 'Kembali ke Beranda',
                    icon: Icons.home_rounded,
                    onPressed: () => context.go('/home'),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  SecondaryButton(
                    label: 'Lihat Detail',
                    icon: Icons.bar_chart_outlined,
                    onPressed: _openSessionDetail,
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
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
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
                      fontSize: 22,
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

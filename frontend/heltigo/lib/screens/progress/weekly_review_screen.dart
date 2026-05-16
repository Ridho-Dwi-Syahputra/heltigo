/// S-29: Weekly Report Screen — Laporan Mingguan
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-29
///
/// Layout:
/// 1. AppBar dengan share icon
/// 2. Hero gradient: range tanggal + ScoreRing 86%
/// 3. Section LATIHAN: 4/4 sesi + bar chart 7 hari
/// 4. Section NUTRISI: stats inline
/// 5. Section BERAT: -0.6 kg + mini progress to target
/// 6. AI Rekomendasi card (primaryMuted)
/// 7. CTA Button → /replanning/evaluation
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';
import '../../widgets/progress/score_ring.dart';
import '../../widgets/universal/primary_button.dart';

class WeeklyReviewScreen extends StatelessWidget {
  const WeeklyReviewScreen({super.key});

  // Mock data minggu ke-3
  static const int _weekNumber = 3;
  static const double _scorePercent = 86;
  static const String _dateRange = '1 - 7 Mei 2026';

  // Workout: bar chart per hari
  static const List<bool> _workoutCompleted = [
    true, true, false, true, true, false, false
  ];
  static const List<String> _dayLabels = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

  void _showShareSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bagikan laporan akan tersedia segera'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.textPrimary,
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        title: Text('Laporan Minggu ke-$_weekNumber',
            style: AppTextStyles.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share, size: 20),
            color: AppColors.textPrimary,
            onPressed: () => _showShareSnack(context),
            tooltip: 'Bagikan',
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
                  // ═══════════════════════════════════════
                  // 1. HERO GRADIENT
                  // ═══════════════════════════════════════
                  _HeroCard(
                    weekNumber: _weekNumber,
                    dateRange: _dateRange,
                    score: _scorePercent,
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // ═══════════════════════════════════════
                  // 2. LATIHAN
                  // ═══════════════════════════════════════
                  _SectionLabel('LATIHAN'),
                  const SizedBox(height: AppDimensions.sm),
                  _WorkoutSection(
                    daysCompleted: _workoutCompleted,
                    dayLabels: _dayLabels,
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // ═══════════════════════════════════════
                  // 3. NUTRISI
                  // ═══════════════════════════════════════
                  _SectionLabel('NUTRISI'),
                  const SizedBox(height: AppDimensions.sm),
                  const _NutritionSection(),
                  const SizedBox(height: AppDimensions.lg),

                  // ═══════════════════════════════════════
                  // 4. BERAT
                  // ═══════════════════════════════════════
                  _SectionLabel('BERAT BADAN'),
                  const SizedBox(height: AppDimensions.sm),
                  const _WeightSection(),
                  const SizedBox(height: AppDimensions.lg),

                  // ═══════════════════════════════════════
                  // 5. AI REKOMENDASI
                  // ═══════════════════════════════════════
                  _SectionLabel('REKOMENDASI AI MINGGU DEPAN'),
                  const SizedBox(height: AppDimensions.sm),
                  const _AiRecommendationCard(),
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
                label: 'Lihat Rencana Minggu Depan',
                icon: Icons.arrow_forward,
                onPressed: () => context.push('/replanning/evaluation'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HERO CARD — score ring di tengah gradient
// ═══════════════════════════════════════════════════════════════

class _HeroCard extends StatelessWidget {
  final int weekNumber;
  final String dateRange;
  final double score;

  const _HeroCard({
    required this.weekNumber,
    required this.dateRange,
    required this.score,
  });

  String get _performanceLabel {
    if (score >= 80) return 'Performa Sangat Baik';
    if (score >= 60) return 'Performa Cukup Baik';
    if (score >= 40) return 'Perlu Perbaikan';
    return 'Mari Bangkit Lagi';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        boxShadow: AppShadows.glow,
      ),
      child: Column(
        children: [
          Text(
            'MINGGU KE-$weekNumber',
            style: AppTextStyles.overline.copyWith(
              color: AppColors.white.withValues(alpha: 0.8),
            ),
          ),
          Text(
            dateRange,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          ScoreRing(
            score: score,
            size: 130,
            color: AppColors.white,
            whiteText: true,
            label: 'SKOR MINGGU',
          ),
          const SizedBox(height: AppDimensions.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.md,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusFull),
            ),
            child: Text(
              _performanceLabel,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SECTION LABEL (overline)
// ═══════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String label;

  // ignore: unused_element_parameter
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.overline.copyWith(
        color: AppColors.textTertiary,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WORKOUT SECTION — 4/4 + bar chart 7 hari
// ═══════════════════════════════════════════════════════════════

class _WorkoutSection extends StatelessWidget {
  final List<bool> daysCompleted;
  final List<String> dayLabels;

  const _WorkoutSection({
    required this.daysCompleted,
    required this.dayLabels,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = daysCompleted.where((d) => d).length;
    final scheduledCount = 4; // mock total scheduled

    return Container(
      padding: const EdgeInsets.all(AppDimensions.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusInput),
                ),
                child: const Icon(
                  Icons.fitness_center,
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
                      '$completedCount/$scheduledCount sesi',
                      style: AppTextStyles.h3,
                    ),
                    Text(
                      '+1 vs minggu lalu',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = AppDimensions.xs + 2;
              final barWidth =
                  (constraints.maxWidth - spacing * 6) / 7;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(daysCompleted.length, (i) {
                  final completed = daysCompleted[i];
                  return SizedBox(
                    width: barWidth,
                    child: Column(
                      children: [
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: completed
                                ? AppColors.primary
                                : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusSmall,
                            ),
                          ),
                          child: completed
                              ? const Center(
                                  child: Icon(
                                    Icons.check,
                                    size: 14,
                                    color: AppColors.white,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dayLabels[i],
                          style: AppTextStyles.caption.copyWith(
                            color: completed
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// NUTRITION SECTION — 3 stats inline
// ═══════════════════════════════════════════════════════════════

class _NutritionSection extends StatelessWidget {
  const _NutritionSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.base,
        vertical: AppDimensions.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _NutriStat(
              icon: Icons.flag_outlined,
              label: 'Cal target',
              value: '87%',
              color: AppColors.success,
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: AppColors.border,
          ),
          Expanded(
            child: _NutriStat(
              icon: Icons.show_chart,
              label: 'Rata-rata',
              value: '80%',
              color: AppColors.primary,
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: AppColors.border,
          ),
          Expanded(
            child: _NutriStat(
              icon: Icons.payments_outlined,
              label: 'Budget rata',
              value: 'Rp 32K',
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _NutriStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _NutriStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textTertiary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WEIGHT SECTION — delta + mini progress
// ═══════════════════════════════════════════════════════════════

class _WeightSection extends StatelessWidget {
  const _WeightSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusInput),
                ),
                child: const Icon(
                  Icons.trending_down,
                  color: AppColors.success,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.h3,
                        children: [
                          TextSpan(
                            text: '-0.6 kg',
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: '  minggu ini',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '74,8 kg → 74,2 kg',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Text(
                'Progres ke target',
                style: AppTextStyles.caption,
              ),
              const Spacer(),
              Text(
                '38% · 3.8 / 10 kg',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.xs + 2),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(AppDimensions.radiusFull),
            child: LinearProgressIndicator(
              value: 0.38,
              minHeight: 6,
              backgroundColor: AppColors.surfaceLight,
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// AI RECOMMENDATION CARD
// ═══════════════════════════════════════════════════════════════

class _AiRecommendationCard extends StatelessWidget {
  const _AiRecommendationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.base),
      decoration: BoxDecoration(
        color: AppColors.primaryMuted,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.5),
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
            child: Text(
              'Performamu sangat baik. AI akan meningkatkan +10% volume '
              'latihan dan mempertahankan budget makan Rp 35K/hari. '
              'Lanjutkan momentum positif ini!',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// S-34: Replanning — Evaluasi Mingguan
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-34
///
/// Screen pertama dari 4-step replanning flow.
/// Otomatis muncul setelah 7 hari plan berakhir.
///
/// Layout:
/// 1. AppBar transparent + close + "Lihat Nanti"
/// 2. Hero gradient teal + ScoreRing 86%
/// 3. Ringkasan Performa (PerformanceSummaryCard)
/// 4. AI Menganalisis card (amber)
/// 5. Sticky bottom: PrimaryButton "Lanjutkan Evaluasi"
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';
import '../../widgets/progress/performance_summary_card.dart';
import '../../widgets/progress/score_ring.dart';

class ReplanningEvaluationScreen extends StatelessWidget {
  const ReplanningEvaluationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 22),
          color: AppColors.textPrimary,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => context.go('/home'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text('Lihat Nanti'),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.base,
                      vertical: AppDimensions.xl,
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
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color:
                                AppColors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: AppColors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.md),
                        Text(
                          'Evaluasi Mingguan',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.xs),
                        Text(
                          'Minggu ke-3 selesai!',
                          style: AppTextStyles.body.copyWith(
                            color:
                                AppColors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.lg),
                        ScoreRing(
                          score: 86,
                          size: 140,
                          color: AppColors.white,
                          whiteText: true,
                          label: 'SKOR MINGGU',
                          subtitle: 'Performa Sangat Baik',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xl),

                  // ═══════════════════════════════════════
                  // 2. RINGKASAN PERFORMA
                  // ═══════════════════════════════════════
                  Text(
                    'RINGKASAN PERFORMA',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  const PerformanceSummaryCard(
                    rows: [
                      PerformanceSummaryRowData(
                        icon: Icons.fitness_center,
                        label: 'Latihan',
                        value: '4/4 sesi',
                        color: AppColors.success,
                      ),
                      PerformanceSummaryRowData(
                        icon: Icons.restaurant_outlined,
                        label: 'Makan Sesuai',
                        value: '6/7 hari',
                        color: AppColors.success,
                      ),
                      PerformanceSummaryRowData(
                        icon: Icons.trending_down,
                        label: 'Berat',
                        value: '-0,6 kg',
                        color: AppColors.success,
                      ),
                      PerformanceSummaryRowData(
                        icon: Icons.local_fire_department,
                        label: 'Streak Aktif',
                        value: '21 hari',
                        color: AppColors.streakPurple,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // ═══════════════════════════════════════
                  // 3. AI MENGANALISIS CARD
                  // ═══════════════════════════════════════
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.base),
                    decoration: BoxDecoration(
                      color: AppColors.warningMuted,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusCard,
                      ),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(
                              alpha: 0.2,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.psychology_outlined,
                            color: AppColors.warning,
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
                                'AI MENGANALISIS',
                                style: AppTextStyles.overline.copyWith(
                                  color: AppColors.warning,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Latihan paling sering diskip: '
                                'Mountain Climber. Akan diganti otomatis '
                                'di rencana berikutnya.',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xl),
                ],
              ),
            ),

            // ═══════════════════════════════════════
            // 4. STICKY BOTTOM
            // ═══════════════════════════════════════
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
              child: SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/replanning/update'),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('Lanjutkan Evaluasi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusButton,
                      ),
                    ),
                    elevation: 0,
                    textStyle: AppTextStyles.button,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

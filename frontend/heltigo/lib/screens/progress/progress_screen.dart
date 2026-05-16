/// S-26: Progress Dashboard — Tab 4 overview progress
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-26
///
/// Sections:
/// 1. Header inline + share
/// 2. Pending evaluation banner (jika ada)
/// 3. Target Berat hero card
/// 4. Weight line chart (dengan X/Y axis labels)
/// 5. 4 stats grid 2x2
/// 6. Streak calendar grid
/// 7. Action buttons: Catat | Lencana | Laporan
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';
import '../../widgets/progress/add_weight_sheet.dart';
import '../../widgets/progress/performance_summary_card.dart';
import '../../widgets/progress/streak_calendar_grid.dart';
import '../../widgets/progress/weight_line_chart.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  // ─── Mock data ───
  static const double _startWeight = 78.0;
  static const double _targetWeight = 68.0;
  final double _currentWeight = 74.2;

  // Mock weight history 8 minggu (Mar - Mei)
  static const _weightValues = [78.0, 77.5, 77.0, 76.4, 75.8, 75.0, 74.5, 74.2];
  static const _xLabels = ['M1', 'M2', 'M3', 'M4', 'M5', 'M6', 'M7', 'M8'];

  // Mock streak active days (12 hari terakhir dari hari ini)
  Set<DateTime> get _activeDays {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return {
      // 12 hari konsisten ke belakang
      for (int i = 0; i < 12; i++) today.subtract(Duration(days: i)),
      // Sedikit di minggu sebelumnya juga
      today.subtract(const Duration(days: 14)),
      today.subtract(const Duration(days: 15)),
      today.subtract(const Duration(days: 17)),
    };
  }

  DateTime get _gridStartDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.subtract(const Duration(days: 27));
  }

  // Pending evaluation flag (mock — provider nanti)
  static const bool _hasPendingEvaluation = true;

  double get _weightLost => _startWeight - _currentWeight;
  double get _remaining => _currentWeight - _targetWeight;

  void _showShareSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bagikan progres akan tersedia segera'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _onCatatTimbangan() async {
    final saved = await showAddWeightSheet(
      context,
      currentWeight: _currentWeight,
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Timbangan tersimpan'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressPercent =
        ((_startWeight - _currentWeight) / (_startWeight - _targetWeight))
            .clamp(0.0, 1.0)
            .toDouble();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.only(
            left: AppDimensions.base,
            right: AppDimensions.base,
            top: AppDimensions.sm,
            bottom: AppDimensions.xxxl + MediaQuery.of(context).padding.bottom,
          ),
          children: [
            // ═══════════════════════════════════════
            // 1. INLINE HEADER
            // ═══════════════════════════════════════
            Row(
              children: [
                Expanded(
                  child: Text('Progres Saya', style: AppTextStyles.h2),
                ),
                IconButton(
                  icon: const Icon(Icons.ios_share, size: 20),
                  color: AppColors.textPrimary,
                  onPressed: _showShareSnack,
                  tooltip: 'Bagikan',
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),

            // ═══════════════════════════════════════
            // 2. PENDING EVALUATION BANNER (jika ada)
            // ═══════════════════════════════════════
            if (_hasPendingEvaluation) ...[
              _PendingEvaluationBanner(
                onTap: () => context.push('/replanning/evaluation'),
              ),
              const SizedBox(height: AppDimensions.base),
            ],

            // ═══════════════════════════════════════
            // 3. TARGET BERAT HERO
            // ═══════════════════════════════════════
            _TargetWeightCard(
              currentWeight: _currentWeight,
              targetWeight: _targetWeight,
              startWeight: _startWeight,
              progress: progressPercent,
              weightLost: _weightLost,
              remaining: _remaining,
            ),
            const SizedBox(height: AppDimensions.base),

            // ═══════════════════════════════════════
            // 4. WEIGHT LINE CHART
            // ═══════════════════════════════════════
            _WeightChartCard(
              values: _weightValues,
              xLabels: _xLabels,
              targetWeight: _targetWeight,
              deltaKg: _weightValues.last - _weightValues.first,
            ),
            const SizedBox(height: AppDimensions.base),

            // ═══════════════════════════════════════
            // 5. STATS GRID 2x2
            // ═══════════════════════════════════════
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppDimensions.sm,
              crossAxisSpacing: AppDimensions.sm,
              childAspectRatio: 1.45,
              children: const [
                _StatCard(
                  icon: Icons.fitness_center,
                  value: '42',
                  label: 'Total Sesi',
                  color: AppColors.primary,
                ),
                _StatCard(
                  icon: Icons.local_fire_department_outlined,
                  value: '8.4K',
                  label: 'Total Kalori',
                  color: AppColors.accent,
                ),
                _StatCard(
                  icon: Icons.check_circle_outline,
                  value: '86%',
                  label: 'Konsistensi',
                  color: AppColors.success,
                ),
                _StatCard(
                  icon: Icons.schedule,
                  value: '21j',
                  label: 'Total Jam',
                  color: AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.base),

            // ═══════════════════════════════════════
            // 6. STREAK CARD
            // ═══════════════════════════════════════
            _StreakCard(
              streakDays: 12,
              activeDays: _activeDays,
              startDate: _gridStartDate,
            ),
            const SizedBox(height: AppDimensions.base),

            // ═══════════════════════════════════════
            // 7. ACTION BUTTONS
            // ═══════════════════════════════════════
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.add_chart_outlined,
                    label: 'Catat',
                    onTap: _onCatatTimbangan,
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.emoji_events_outlined,
                    label: 'Lencana',
                    onTap: () => context.push('/progress/badges'),
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.assessment_outlined,
                    label: 'Laporan',
                    onTap: () => context.push('/progress/weekly-review'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.lg),

            // ═══════════════════════════════════════
            // 8. PERFORMANCE SUMMARY (extra visualization)
            // ═══════════════════════════════════════
            Text(
              'RINGKASAN MINGGU INI',
              style: AppTextStyles.overline.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            const PerformanceSummaryCard(
              rows: [
                PerformanceSummaryRowData(
                  icon: Icons.fitness_center,
                  label: 'Latihan Selesai',
                  value: '4/4',
                  color: AppColors.success,
                ),
                PerformanceSummaryRowData(
                  icon: Icons.restaurant_outlined,
                  label: 'Makan Sesuai',
                  value: '6/7',
                  color: AppColors.success,
                ),
                PerformanceSummaryRowData(
                  icon: Icons.trending_down,
                  label: 'Perubahan Berat',
                  value: '-0.6 kg',
                  color: AppColors.success,
                ),
                PerformanceSummaryRowData(
                  icon: Icons.water_drop_outlined,
                  label: 'Hidrasi Rata-rata',
                  value: '6.5/8',
                  color: AppColors.waterBlue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PENDING EVALUATION BANNER
// ═══════════════════════════════════════════════════════════════

class _PendingEvaluationBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _PendingEvaluationBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.base),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.accent,
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
                    'Minggu ke-3 selesai!',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Lanjutkan evaluasi untuk rencana minggu depan',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.accent,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TARGET WEIGHT HERO CARD
// ═══════════════════════════════════════════════════════════════

class _TargetWeightCard extends StatelessWidget {
  final double currentWeight;
  final double targetWeight;
  final double startWeight;
  final double progress;
  final double weightLost;
  final double remaining;

  const _TargetWeightCard({
    required this.currentWeight,
    required this.targetWeight,
    required this.startWeight,
    required this.progress,
    required this.weightLost,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.base),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        boxShadow: AppShadows.glow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TARGET BERAT',
            style: AppTextStyles.overline.copyWith(
              color: AppColors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currentWeight.toStringAsFixed(1),
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 32,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(
                  Icons.arrow_forward,
                  color: AppColors.white.withValues(alpha: 0.7),
                  size: 18,
                ),
              ),
              Text(
                '${targetWeight.toStringAsFixed(0)} kg',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(AppDimensions.radiusFull),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.white,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Row(
            children: [
              Icon(
                Icons.flag_outlined,
                size: 13,
                color: AppColors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 4),
              Text(
                'Mulai: ${startWeight.toStringAsFixed(0)} kg · ${weightLost.toStringAsFixed(1)} kg turun',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 13,
                color: AppColors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 4),
              Text(
                'Sisa ${remaining.toStringAsFixed(1)} kg · Estimasi ~12 minggu lagi',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WEIGHT CHART CARD
// ═══════════════════════════════════════════════════════════════

class _WeightChartCard extends StatelessWidget {
  final List<double> values;
  final List<String> xLabels;
  final double targetWeight;
  final double deltaKg;

  const _WeightChartCard({
    required this.values,
    required this.xLabels,
    required this.targetWeight,
    required this.deltaKg,
  });

  @override
  Widget build(BuildContext context) {
    final isDown = deltaKg < 0;
    final deltaColor = isDown ? AppColors.success : AppColors.warning;
    final deltaText = '${isDown ? '' : '+'}${deltaKg.toStringAsFixed(1)} kg';

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
              const Icon(
                Icons.show_chart,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: Text(
                  'Tren Berat (8 Minggu)',
                  style: AppTextStyles.h3.copyWith(fontSize: 15),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: deltaColor.withValues(alpha: 0.15),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDown ? Icons.trending_down : Icons.trending_up,
                      size: 12,
                      color: deltaColor,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      deltaText,
                      style: AppTextStyles.caption.copyWith(
                        color: deltaColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          WeightLineChart(
            values: values,
            xLabels: xLabels,
            targetWeight: targetWeight,
            height: 200,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// STAT CARD (small icon + value + label)
// ═══════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm + 2, vertical: AppDimensions.sm),
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
                child: Text(
                  value,
                  maxLines: 1,
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
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
// STREAK CARD (header + calendar grid)
// ═══════════════════════════════════════════════════════════════

class _StreakCard extends StatelessWidget {
  final int streakDays;
  final Set<DateTime> activeDays;
  final DateTime startDate;

  const _StreakCard({
    required this.streakDays,
    required this.activeDays,
    required this.startDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.base),
      decoration: BoxDecoration(
        color: AppColors.streakPurple.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: AppColors.streakPurple.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.streakPurple.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: AppColors.streakPurple,
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
                      '$streakDays Hari Streak',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.streakPurple,
                      ),
                    ),
                    Text(
                      '4 minggu terakhir',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          StreakCalendarGrid(
            activeDays: activeDays,
            startDate: startDate,
            weeks: 4,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ACTION BUTTON (icon + label)
// ═══════════════════════════════════════════════════════════════

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.sm,
          vertical: AppDimensions.base,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
            const SizedBox(height: AppDimensions.xs + 2),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

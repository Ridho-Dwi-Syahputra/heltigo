/// S-08: Setup Profile Step 3/7 — Hasil BMI
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-08
///
/// Display (MOCK DATA — kalkulasi real nanti via ProfileProvider):
/// - BMI hero card (gradient teal) dengan kategori
/// - Grid 2x2: BMR, TDEE, Lemak%, Ideal weight
/// - BMI Scale visual (rainbow bar dengan marker triangle)
/// - Penjelasan singkat
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';
import '../../widgets/setup/setup_scaffold.dart';

class SetupBmiResultScreen extends StatelessWidget {
  const SetupBmiResultScreen({super.key});

  // Mock BMI values
  static const double _mockBmi = 26.4;
  static const String _mockCategory = 'Sedikit Lebih';

  void _onContinue(BuildContext context) {
    context.push('/setup-goal');
  }

  @override
  Widget build(BuildContext context) {
    return SetupScaffold(
      currentStep: 3,
      title: 'Hasil Profil Kesehatanmu',
      subtitle:
          'Berdasarkan data fisik kamu, ini adalah ringkasan kesehatanmu.',
      buttonLabel: 'Tetapkan Target Saya',
      onContinue: () => _onContinue(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ═══════════════════════════════════════
          // BMI HERO CARD
          // ═══════════════════════════════════════
          const _BmiHeroCard(bmi: _mockBmi, category: _mockCategory),
          const SizedBox(height: AppDimensions.base),

          // ═══════════════════════════════════════
          // METRICS GRID 2x2
          // ═══════════════════════════════════════
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppDimensions.md,
            crossAxisSpacing: AppDimensions.md,
            childAspectRatio: 1.6,
            children: const [
              _MetricCard(
                icon: Icons.local_fire_department_outlined,
                label: 'BMR',
                value: '1.685',
                unit: 'kkal',
                accentColor: AppColors.accent,
              ),
              _MetricCard(
                icon: Icons.bolt_outlined,
                label: 'TDEE',
                value: '2.320',
                unit: 'kkal',
                accentColor: AppColors.warning,
              ),
              _MetricCard(
                icon: Icons.water_drop_outlined,
                label: 'Lemak',
                value: '22',
                unit: '% tubuh',
                accentColor: AppColors.info,
              ),
              _MetricCard(
                icon: Icons.fitness_center_outlined,
                label: 'Ideal',
                value: '68',
                unit: 'kg',
                accentColor: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),

          // ═══════════════════════════════════════
          // BMI SCALE VISUAL
          // ═══════════════════════════════════════
          const _BmiScale(bmi: _mockBmi),
          const SizedBox(height: AppDimensions.lg),

          // ═══════════════════════════════════════
          // PENJELASAN
          // ═══════════════════════════════════════
          Container(
            padding: const EdgeInsets.all(AppDimensions.base),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.tips_and_updates_outlined,
                  color: AppColors.accent,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Text(
                    'BMI kamu sedikit di atas normal. Dengan defisit kalori '
                    'ringan dan latihan teratur, target ideal bisa tercapai '
                    'dalam sekitar 12 minggu.',
                    style: AppTextStyles.body,
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
// BMI HERO CARD — gradient teal dengan angka besar + kategori
// ═══════════════════════════════════════════════════════════════

class _BmiHeroCard extends StatelessWidget {
  final double bmi;
  final String category;

  const _BmiHeroCard({required this.bmi, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.xl),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        boxShadow: AppShadows.glow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overline label
          Text(
            'INDEKS MASSA TUBUH',
            style: AppTextStyles.overline.copyWith(
              color: AppColors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppDimensions.sm),

          // Big BMI number
          Text(
            bmi.toStringAsFixed(1),
            style: AppTextStyles.display.copyWith(
              fontSize: 56,
              color: AppColors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: AppDimensions.md),

          // Category pill
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.md,
              vertical: AppDimensions.xs + 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
            child: Text(
              category,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// METRIC CARD — kartu kecil untuk BMR/TDEE/Lemak/Ideal
// ═══════════════════════════════════════════════════════════════

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color accentColor;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.accentColor,
  });

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accentColor),
              const SizedBox(width: AppDimensions.xs + 2),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTextStyles.h2.copyWith(
                  fontSize: 24,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppDimensions.xs),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
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
// BMI SCALE — horizontal gradient bar dengan marker triangle
// ═══════════════════════════════════════════════════════════════

class _BmiScale extends StatelessWidget {
  final double bmi;

  const _BmiScale({required this.bmi});

  /// Hitung posisi marker (0.0 - 1.0) berdasarkan BMI.
  /// Range: BMI 15 (kurus) — 35 (obesitas)
  double get _markerPosition {
    const minBmi = 15.0;
    const maxBmi = 35.0;
    final clamped = bmi.clamp(minBmi, maxBmi);
    return (clamped - minBmi) / (maxBmi - minBmi);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rainbow gradient bar dengan marker
        LayoutBuilder(
          builder: (context, constraints) {
            final markerLeft =
                (constraints.maxWidth * _markerPosition).clamp(
              0.0,
              constraints.maxWidth - 12,
            );
            return SizedBox(
              height: 28,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Gradient bar
                  Container(
                    height: 10,
                    margin: const EdgeInsets.only(top: 18),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF3B82F6), // blue — kurus
                          Color(0xFF22C55E), // green — normal
                          Color(0xFFF59E0B), // amber — lebih
                          Color(0xFFFB3A01), // orange — obesitas
                          Color(0xFFEF4444), // red — obesitas berat
                        ],
                      ),
                    ),
                  ),
                  // Marker triangle
                  Positioned(
                    left: markerLeft - 6,
                    top: 0,
                    child: Column(
                      children: [
                        Text(
                          bmi.toStringAsFixed(1),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.textPrimary,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: AppDimensions.sm),

        // Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kurus',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            Text(
              'Normal',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            Text(
              'Lebih',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            Text(
              'Obesitas',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

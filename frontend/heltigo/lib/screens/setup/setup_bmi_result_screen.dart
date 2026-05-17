/// S-08: Setup Profile Step 3/7 — Hasil BMI
/// BMI/BMR/TDEE dihitung lokal dari draft data (tanpa API).
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../styles/styles.dart';
import '../../widgets/setup/setup_scaffold.dart';
import '../../providers/profile_draft_provider.dart';

class SetupBmiResultScreen extends StatelessWidget {
  const SetupBmiResultScreen({super.key});

  void _onContinue(BuildContext context) {
    context.push('/setup-goal');
  }

  String _categoryFor(double bmi) {
    if (bmi < 18.5) return 'Kurus';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Sedikit Lebih';
    return 'Obesitas';
  }

  double? _idealWeight(ProfileDraftProvider draft) {
    final h = draft.draft.heightCm;
    if (h == null) return null;
    // BMI target 22 (tengah normal)
    final hm = h / 100;
    return 22 * hm * hm;
  }

  @override
  Widget build(BuildContext context) {
    final draft = context.watch<ProfileDraftProvider>();
    final bmi = draft.bmi ?? 22.0;
    final bmr = draft.bmr ?? 1500;
    final tdee = draft.tdee ?? 2000;
    final ideal = _idealWeight(draft) ?? 65;
    final category = _categoryFor(bmi);

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
          _BmiHeroCard(bmi: bmi, category: category),
          const SizedBox(height: AppDimensions.base),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppDimensions.md,
            crossAxisSpacing: AppDimensions.md,
            childAspectRatio: 1.6,
            children: [
              _MetricCard(
                icon: Icons.local_fire_department_outlined,
                label: 'BMR',
                value: bmr.toStringAsFixed(0),
                unit: 'kkal',
                accentColor: AppColors.accent,
              ),
              _MetricCard(
                icon: Icons.bolt_outlined,
                label: 'TDEE',
                value: tdee.toStringAsFixed(0),
                unit: 'kkal',
                accentColor: AppColors.warning,
              ),
              _MetricCard(
                icon: Icons.water_drop_outlined,
                label: 'BMI',
                value: bmi.toStringAsFixed(1),
                unit: '',
                accentColor: AppColors.info,
              ),
              _MetricCard(
                icon: Icons.fitness_center_outlined,
                label: 'Ideal',
                value: ideal.toStringAsFixed(0),
                unit: 'kg',
                accentColor: AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),

          _BmiScale(bmi: bmi),
          const SizedBox(height: AppDimensions.lg),

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
                    _insightFor(bmi),
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

  String _insightFor(double bmi) {
    if (bmi < 18.5) {
      return 'BMI kamu di bawah normal. Fokus pada penambahan massa otot dengan '
          'asupan protein cukup dan latihan kekuatan progresif.';
    }
    if (bmi < 25) {
      return 'BMI kamu ideal! Pertahankan ritme hidup sehat dengan latihan '
          'teratur dan pola makan seimbang.';
    }
    if (bmi < 30) {
      return 'BMI kamu sedikit di atas normal. Dengan defisit kalori ringan dan '
          'latihan teratur, target ideal bisa tercapai dalam ~12 minggu.';
    }
    return 'BMI kamu masuk kategori obesitas. AI akan rancang program dengan '
        'intensitas rendah-sedang dan defisit kalori aman.';
  }
}

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
          Text(
            'INDEKS MASSA TUBUH',
            style: AppTextStyles.overline.copyWith(
              color: AppColors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            bmi.toStringAsFixed(1),
            style: AppTextStyles.display.copyWith(
              fontSize: 56,
              color: AppColors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
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
              if (unit.isNotEmpty) ...[
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
            ],
          ),
        ],
      ),
    );
  }
}

class _BmiScale extends StatelessWidget {
  final double bmi;

  const _BmiScale({required this.bmi});

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
                  Container(
                    height: 10,
                    margin: const EdgeInsets.only(top: 18),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF3B82F6),
                          Color(0xFF22C55E),
                          Color(0xFFF59E0B),
                          Color(0xFFFB3A01),
                          Color(0xFFEF4444),
                        ],
                      ),
                    ),
                  ),
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
                        Icon(
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Kurus',
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary)),
            Text('Normal',
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary)),
            Text('Lebih',
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary)),
            Text('Obesitas',
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary)),
          ],
        ),
      ],
    );
  }
}

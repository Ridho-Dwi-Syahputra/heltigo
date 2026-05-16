/// S-09: Setup Profile Step 4/7 — Target Kesehatan
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-09
///
/// Input:
/// - Pilih goal: Turunkan Berat / Jaga Berat / Naikkan Massa Otot
/// - Target Berat (kg) — muncul jika goal != 'Jaga'
/// - Timeline (4-52 minggu) — slider dengan card preview
/// - Calorie deficit info card (auto-calculated, mock dulu)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';
import '../../widgets/setup/setup_scaffold.dart';

enum _Goal { lose, maintain, gain }

class SetupGoalScreen extends StatefulWidget {
  const SetupGoalScreen({super.key});

  @override
  State<SetupGoalScreen> createState() => _SetupGoalScreenState();
}

class _SetupGoalScreenState extends State<SetupGoalScreen> {
  _Goal? _selectedGoal;
  final _targetWeightController = TextEditingController(text: '68');
  double _timelineWeeks = 16;

  @override
  void dispose() {
    _targetWeightController.dispose();
    super.dispose();
  }

  /// Mock calorie deficit/surplus calculation (rule of thumb).
  /// 0.5 kg/minggu ≈ 500 kkal/hari defisit.
  int get _calorieAdjustment {
    if (_selectedGoal == _Goal.maintain) return 0;
    // Mock: tergantung timeline, rate ±0.5 kg/minggu = ±500 kkal/hari
    final perWeek = 0.5; // kg per minggu
    final daily = (perWeek * 7700 / 7).round(); // 1 kg = 7700 kkal
    return _selectedGoal == _Goal.lose ? -daily : daily;
  }

  bool get _canContinue => _selectedGoal != null;

  void _onContinue() {
    // TODO: Save goal, target weight, timeline ke ProfileProvider
    context.push('/setup-conditions');
  }

  @override
  Widget build(BuildContext context) {
    final showTargetWeight = _selectedGoal != null && _selectedGoal != _Goal.maintain;
    final calAdj = _calorieAdjustment;
    final isWarning = calAdj.abs() > 600;

    return SetupScaffold(
      currentStep: 4,
      title: 'Apa tujuan kesehatanmu?',
      subtitle: 'Pilih satu tujuan utama yang ingin kamu capai.',
      onContinue: _canContinue ? _onContinue : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ═══════════════════════════════════════
          // 3 GOAL CARDS
          // ═══════════════════════════════════════
          _GoalCard(
            icon: Icons.trending_down,
            label: 'Turunkan Berat',
            description: 'Bakar lemak, capai berat ideal',
            isSelected: _selectedGoal == _Goal.lose,
            onTap: () => setState(() => _selectedGoal = _Goal.lose),
          ),
          const SizedBox(height: AppDimensions.md),
          _GoalCard(
            icon: Icons.trending_flat,
            label: 'Jaga Berat',
            description: 'Pertahankan kondisi & berat saat ini',
            isSelected: _selectedGoal == _Goal.maintain,
            onTap: () => setState(() => _selectedGoal = _Goal.maintain),
          ),
          const SizedBox(height: AppDimensions.md),
          _GoalCard(
            icon: Icons.trending_up,
            label: 'Naikkan Massa Otot',
            description: 'Bulking, tingkatkan kekuatan',
            isSelected: _selectedGoal == _Goal.gain,
            onTap: () => setState(() => _selectedGoal = _Goal.gain),
          ),

          // ═══════════════════════════════════════
          // TARGET BERAT (kondisional)
          // ═══════════════════════════════════════
          if (showTargetWeight) ...[
            const SizedBox(height: AppDimensions.xl),
            Text(
              'Target Berat',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            TextFormField(
              controller: _targetWeightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
              ),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: '68',
                prefixIcon: Icon(
                  Icons.fitness_center_outlined,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
                suffixText: 'kg',
                suffixStyle: TextStyle(color: AppColors.textTertiary),
              ),
            ),
          ],

          // ═══════════════════════════════════════
          // TIMELINE CARD
          // ═══════════════════════════════════════
          if (_selectedGoal != null && _selectedGoal != _Goal.maintain) ...[
            const SizedBox(height: AppDimensions.lg),
            Container(
              padding: const EdgeInsets.all(AppDimensions.base),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TIMELINE TARGET',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _timelineWeeks.round().toString(),
                        style: AppTextStyles.numberBold.copyWith(
                          fontSize: 40,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Minggu',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '±0.5 kg/minggu = ±${(_timelineWeeks * 0.5).toStringAsFixed(0)} kg total',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.surfaceLight,
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primaryMuted,
                      trackHeight: 4,
                    ),
                    child: Slider(
                      min: 4,
                      max: 52,
                      divisions: 48,
                      value: _timelineWeeks,
                      onChanged: (v) => setState(() => _timelineWeeks = v),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ═══════════════════════════════════════
          // CALORIE INFO CARD
          // ═══════════════════════════════════════
          if (_selectedGoal != null && _selectedGoal != _Goal.maintain) ...[
            const SizedBox(height: AppDimensions.md),
            Container(
              padding: const EdgeInsets.all(AppDimensions.base),
              decoration: BoxDecoration(
                color: isWarning ? AppColors.warningMuted : AppColors.accentMuted,
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                border: Border.all(
                  color: isWarning ? AppColors.warning : AppColors.accent,
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: isWarning ? AppColors.warning : AppColors.accent,
                    size: 20,
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            children: [
                              TextSpan(
                                text: _selectedGoal == _Goal.lose
                                    ? 'Target defisit: '
                                    : 'Target surplus: ',
                              ),
                              TextSpan(
                                text: '${calAdj.abs()} kkal/hari',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: isWarning
                                      ? AppColors.warning
                                      : AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isWarning
                              ? 'Defisit terlalu agresif — pertimbangkan timeline lebih panjang.'
                              : 'Aman dan berkelanjutan.',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// GOAL CARD — kartu goal full-width dengan radio
// ═══════════════════════════════════════════════════════════════

class _GoalCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.all(AppDimensions.base),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryMuted : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppDimensions.base),

            // Label + description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.sm),

            // Radio indicator
            AnimatedContainer(
              duration: AppDurations.fast,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: AppColors.textOnPrimary,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

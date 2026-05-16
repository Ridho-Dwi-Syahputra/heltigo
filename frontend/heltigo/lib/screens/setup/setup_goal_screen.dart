/// S-09: Setup Profile Step 4/7 — Target Kesehatan
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-09
///
/// Input:
/// - Pilih goal: Turunkan Berat / Jaga Berat / Naikkan Massa Otot
/// - Target Berat (kg) — muncul jika goal != 'Jaga'
/// - Timeline is determined by ML (not user input)
/// - Calorie adjustment is calculated by ML backend
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

  @override
  void dispose() {
    _targetWeightController.dispose();
    super.dispose();
  }

  bool get _canContinue => _selectedGoal != null;

  void _onContinue() {
    // TODO: Save goal and target weight to ProfileProvider
    // Timeline will be determined by ML backend
    context.push('/setup-conditions');
  }

  @override
  Widget build(BuildContext context) {
    final showTargetWeight = _selectedGoal != null && _selectedGoal != _Goal.maintain;

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

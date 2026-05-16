/// S-12: Setup Profile Step 7/7 — Diet & Budget
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-12
///
/// Input:
/// - Anggaran Harian (IDR/MYR toggle, input + quick chips)
/// - Frekuensi Makan: 2x / 3x / 4x
/// - Pantangan Diet (multi-select): Halal Only, Vegetarian, Bebas Kacang, Bebas Laktosa
///
/// Submit → navigate ke plan generating (S-13).
/// File name kept as setup_preferences_screen.dart untuk kompatibilitas router.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';
import '../../widgets/setup/chip_multi_select.dart';
import '../../widgets/setup/segmented_selector.dart';
import '../../widgets/setup/setup_scaffold.dart';

enum _Currency { idr, myr }

class SetupPreferencesScreen extends StatefulWidget {
  const SetupPreferencesScreen({super.key});

  @override
  State<SetupPreferencesScreen> createState() =>
      _SetupPreferencesScreenState();
}

class _SetupPreferencesScreenState extends State<SetupPreferencesScreen> {
  final _budgetController = TextEditingController(text: '35000');
  _Currency _currency = _Currency.idr;
  int _mealFrequencyIndex = 1; // 0=2x, 1=3x, 2=4x
  Set<int> _dietRestrictions = {0}; // Default: halal

  static const List<String> _mealFrequencyOptions = [
    '2x Makan',
    '3x Makan',
    '4x Makan'
  ];
  static const List<ChipOption> _dietOptions = [
    ChipOption(label: 'Halal Only', icon: Icons.brightness_2_outlined),
    ChipOption(label: 'Vegetarian', icon: Icons.eco_outlined),
    ChipOption(label: 'Bebas Kacang', icon: Icons.no_food_outlined),
    ChipOption(label: 'Bebas Laktosa', icon: Icons.no_drinks_outlined),
  ];

  // Quick budget chips dengan label IDR / MYR
  List<_BudgetChipData> get _budgetChips {
    if (_currency == _Currency.idr) {
      return const [
        _BudgetChipData(label: 'Rp 15K', value: '15000'),
        _BudgetChipData(label: 'Rp 25K', value: '25000'),
        _BudgetChipData(label: 'Rp 35K', value: '35000'),
        _BudgetChipData(label: 'Rp 50K', value: '50000'),
        _BudgetChipData(label: 'Rp 75K', value: '75000'),
      ];
    }
    return const [
      _BudgetChipData(label: 'RM 5', value: '5'),
      _BudgetChipData(label: 'RM 8', value: '8'),
      _BudgetChipData(label: 'RM 12', value: '12'),
      _BudgetChipData(label: 'RM 18', value: '18'),
      _BudgetChipData(label: 'RM 25', value: '25'),
    ];
  }

  String get _currencyPrefix => _currency == _Currency.idr ? 'Rp' : 'RM';

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _selectQuickBudget(String value) {
    setState(() => _budgetController.text = value);
  }

  bool get _canContinue => _budgetController.text.trim().isNotEmpty;

  void _onContinue() {
    // TODO: Save diet & budget ke ProfileProvider, trigger /plan/generate
    context.go('/plan-generating');
  }

  @override
  Widget build(BuildContext context) {
    return SetupScaffold(
      currentStep: 7,
      title: 'Preferensi makan & anggaran',
      subtitle: 'AI memilih makanan sesuai budget dan pantangan dietmu.',
      buttonLabel: 'Buat Rencana Saya!',
      onContinue: _canContinue ? _onContinue : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ═══════════════════════════════════════
          // ANGGARAN HARIAN — header + toggle currency
          // ═══════════════════════════════════════
          Row(
            children: [
              Expanded(
                child: Text(
                  'Anggaran Harian',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _CurrencyToggle(
                selected: _currency,
                onChanged: (c) => setState(() => _currency = c),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),

          // Budget input field
          TextFormField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: '35000',
              prefixIcon: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.base,
                  0,
                  AppDimensions.sm,
                  0,
                ),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    _currencyPrefix,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.md),

          // Quick budget chips
          Wrap(
            spacing: AppDimensions.sm,
            runSpacing: AppDimensions.sm,
            children: _budgetChips.map((chip) {
              final isActive = _budgetController.text == chip.value;
              return _BudgetChip(
                label: chip.label,
                isActive: isActive,
                onTap: () => _selectQuickBudget(chip.value),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimensions.lg),

          // ═══════════════════════════════════════
          // FREKUENSI MAKAN
          // ═══════════════════════════════════════
          _sectionLabel('Frekuensi Makan'),
          const SizedBox(height: AppDimensions.sm),
          SegmentedSelector(
            options: _mealFrequencyOptions,
            selectedIndex: _mealFrequencyIndex,
            onChanged: (i) => setState(() => _mealFrequencyIndex = i),
          ),
          const SizedBox(height: AppDimensions.lg),

          // ═══════════════════════════════════════
          // PANTANGAN DIET (multi-select)
          // ═══════════════════════════════════════
          _sectionLabel('Pantangan Diet'),
          const SizedBox(height: AppDimensions.sm),
          ChipMultiSelect(
            options: _dietOptions,
            selectedIndices: _dietRestrictions,
            onChanged: (next) => setState(() => _dietRestrictions = next),
          ),
          const SizedBox(height: AppDimensions.lg),

          // ═══════════════════════════════════════
          // INFO CARD — AI 1.346+ item
          // ═══════════════════════════════════════
          Container(
            padding: const EdgeInsets.all(AppDimensions.base),
            decoration: BoxDecoration(
              color: AppColors.primaryMuted,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(color: AppColors.primary, width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Text(
                    'AI akan memilih dari 1.346+ item lokal yang memenuhi '
                    'kebutuhan gizi dalam budget kamu.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CURRENCY TOGGLE — IDR/MYR pill compact
// ═══════════════════════════════════════════════════════════════

class _CurrencyToggle extends StatelessWidget {
  final _Currency selected;
  final ValueChanged<_Currency> onChanged;

  const _CurrencyToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _Currency.values.map((c) {
          final isActive = c == selected;
          final label = c == _Currency.idr ? 'IDR' : 'MYR';
          return GestureDetector(
            onTap: () => onChanged(c),
            child: AnimatedContainer(
              duration: AppDurations.fast,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.md,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isActive
                      ? AppColors.textOnPrimary
                      : AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BUDGET CHIP DATA & WIDGET
// ═══════════════════════════════════════════════════════════════

class _BudgetChipData {
  final String label;
  final String value;
  const _BudgetChipData({required this.label, required this.value});
}

class _BudgetChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BudgetChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.base,
          vertical: AppDimensions.sm + 2,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryMuted : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

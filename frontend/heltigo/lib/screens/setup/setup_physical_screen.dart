/// S-07: Setup Profile Step 2/7 — Data Fisik
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-07
///
/// Input:
/// - Tinggi Badan (slider 100-220 cm, toggle cm/inch)
/// - Berat Badan (slider 30-200 kg, toggle kg/lbs)
/// - Lingkar Pinggang (opsional, text input cm)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../styles/styles.dart';
import '../../widgets/setup/setup_scaffold.dart';
import '../../providers/profile_draft_provider.dart';

class SetupPhysicalScreen extends StatefulWidget {
  const SetupPhysicalScreen({super.key});

  @override
  State<SetupPhysicalScreen> createState() => _SetupPhysicalScreenState();
}

class _SetupPhysicalScreenState extends State<SetupPhysicalScreen> {
  // Default values
  double _heightCm = 170;
  double _weightKg = 65;
  final _waistController = TextEditingController();

  // Unit toggles: 0 = metric, 1 = imperial
  int _heightUnit = 0; // 0=cm, 1=inch
  int _weightUnit = 0; // 0=kg, 1=lbs

  @override
  void dispose() {
    _waistController.dispose();
    super.dispose();
  }

  // ─── Conversion helpers ───
  double get _heightDisplayed =>
      _heightUnit == 0 ? _heightCm : _heightCm / 2.54;

  String get _heightUnitLabel => _heightUnit == 0 ? 'cm' : 'inch';

  double get _weightDisplayed =>
      _weightUnit == 0 ? _weightKg : _weightKg * 2.20462;

  String get _weightUnitLabel => _weightUnit == 0 ? 'kg' : 'lbs';

  void _onContinue() {
    final draft = context.read<ProfileDraftProvider>();
    draft.updatePhysical(
      heightCm: _heightCm,
      weightKg: _weightKg,
    );
    context.push('/setup-bmi-result');
  }

  @override
  Widget build(BuildContext context) {
    return SetupScaffold(
      currentStep: 2,
      title: 'Berapa tinggi & berat badanmu?',
      subtitle: 'Geser slider untuk menentukan ukuran yang sesuai.',
      buttonLabel: 'Hitung BMI Saya',
      onContinue: _onContinue,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ═══════════════════════════════════════
          // TINGGI BADAN
          // ═══════════════════════════════════════
          _SliderSection(
            label: 'TINGGI BADAN',
            value: _heightDisplayed,
            unitLabel: _heightUnitLabel,
            unitOptions: const ['cm', 'inch'],
            selectedUnitIndex: _heightUnit,
            onUnitChanged: (i) => setState(() => _heightUnit = i),
            sliderMin: 100,
            sliderMax: 220,
            sliderValue: _heightCm,
            onSliderChanged: (v) => setState(() => _heightCm = v),
          ),
          const SizedBox(height: AppDimensions.lg),

          // ═══════════════════════════════════════
          // BERAT BADAN
          // ═══════════════════════════════════════
          _SliderSection(
            label: 'BERAT BADAN',
            value: _weightDisplayed,
            unitLabel: _weightUnitLabel,
            unitOptions: const ['kg', 'lbs'],
            selectedUnitIndex: _weightUnit,
            onUnitChanged: (i) => setState(() => _weightUnit = i),
            sliderMin: 30,
            sliderMax: 200,
            sliderValue: _weightKg,
            onSliderChanged: (v) => setState(() => _weightKg = v),
          ),
          const SizedBox(height: AppDimensions.lg),

          // ═══════════════════════════════════════
          // LINGKAR PINGGANG (opsional)
          // ═══════════════════════════════════════
          Text(
            'Lingkar Pinggang (opsional)',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          TextFormField(
            controller: _waistController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
            ),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: 'mis. 84',
              prefixIcon: Icon(
                Icons.straighten,
                color: AppColors.textTertiary,
                size: 20,
              ),
              suffixText: 'cm',
              suffixStyle: TextStyle(color: AppColors.textTertiary),
            ),
          ),
          const SizedBox(height: AppDimensions.sm),

          // Caption info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: AppDimensions.xs),
              Expanded(
                child: Text(
                  'Lingkar pinggang digunakan untuk estimasi lemak '
                  'tubuh yang lebih akurat.',
                  style: AppTextStyles.caption,
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
// SLIDER SECTION — display angka besar + unit toggle + slider
// ═══════════════════════════════════════════════════════════════

class _SliderSection extends StatelessWidget {
  final String label;
  final double value;
  final String unitLabel;
  final List<String> unitOptions;
  final int selectedUnitIndex;
  final ValueChanged<int> onUnitChanged;
  final double sliderMin;
  final double sliderMax;
  final double sliderValue;
  final ValueChanged<double> onSliderChanged;

  const _SliderSection({
    required this.label,
    required this.value,
    required this.unitLabel,
    required this.unitOptions,
    required this.selectedUnitIndex,
    required this.onUnitChanged,
    required this.sliderMin,
    required this.sliderMax,
    required this.sliderValue,
    required this.onSliderChanged,
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
        children: [
          // Header: label + unit toggle
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              // Unit toggle compact
              _UnitToggle(
                options: unitOptions,
                selectedIndex: selectedUnitIndex,
                onChanged: onUnitChanged,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),

          // Big number + unit label
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value.toStringAsFixed(0),
                style: AppTextStyles.numberBold.copyWith(
                  fontSize: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  unitLabel,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.surfaceLight,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primaryMuted,
              trackHeight: 4,
            ),
            child: Slider(
              min: sliderMin,
              max: sliderMax,
              value: sliderValue.clamp(sliderMin, sliderMax),
              onChanged: onSliderChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// UNIT TOGGLE — compact 2-option pill (cm/inch, kg/lbs)
// ═══════════════════════════════════════════════════════════════

class _UnitToggle extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _UnitToggle({
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

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
        children: List.generate(options.length, (i) {
          final isActive = i == selectedIndex;
          return GestureDetector(
            onTap: () => onChanged(i),
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
                options[i],
                style: AppTextStyles.bodySmall.copyWith(
                  color: isActive
                      ? AppColors.textOnPrimary
                      : AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

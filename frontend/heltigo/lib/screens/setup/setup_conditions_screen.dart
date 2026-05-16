/// S-10: Setup Profile Step 5/7 — Kondisi Khusus
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-10
///
/// Input multi-select kondisi:
/// - Cedera/Nyeri Sendi, Sedang Hamil, Diabetes Tipe 2,
///   Tekanan Darah Tinggi, Masalah Tulang
/// - Tidak Ada Kondisi Khusus (exclusive — uncheck semua jika dipilih)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';
import '../../widgets/setup/setup_scaffold.dart';

class SetupConditionsScreen extends StatefulWidget {
  const SetupConditionsScreen({super.key});

  @override
  State<SetupConditionsScreen> createState() => _SetupConditionsScreenState();
}

class _SetupConditionsScreenState extends State<SetupConditionsScreen> {
  final Set<int> _selected = {};

  // Index 5 = "Tidak Ada" (exclusive)
  static const int _noneIndex = 5;

  static const List<_ConditionOption> _options = [
    _ConditionOption(
      icon: Icons.warning_amber_outlined,
      label: 'Cedera atau Nyeri Sendi',
    ),
    _ConditionOption(
      icon: Icons.pregnant_woman,
      label: 'Sedang Hamil',
    ),
    _ConditionOption(
      icon: Icons.medication_outlined,
      label: 'Diabetes Tipe 2',
    ),
    _ConditionOption(
      icon: Icons.favorite_outline,
      label: 'Tekanan Darah Tinggi',
    ),
    _ConditionOption(
      icon: Icons.healing_outlined,
      label: 'Masalah Tulang',
    ),
    _ConditionOption(
      icon: Icons.check_circle_outline,
      label: 'Tidak Ada Kondisi Khusus',
    ),
  ];

  void _toggle(int index) {
    setState(() {
      if (index == _noneIndex) {
        // Tap "Tidak Ada" → clear semua, toggle status sendiri
        if (_selected.contains(_noneIndex)) {
          _selected.remove(_noneIndex);
        } else {
          _selected.clear();
          _selected.add(_noneIndex);
        }
      } else {
        // Pilih kondisi → uncheck "Tidak Ada" otomatis
        _selected.remove(_noneIndex);
        if (_selected.contains(index)) {
          _selected.remove(index);
        } else {
          _selected.add(index);
        }
      }
    });
  }

  void _onContinue() {
    // TODO: Save conditions list ke ProfileProvider
    context.push('/setup-fitness-level');
  }

  @override
  Widget build(BuildContext context) {
    return SetupScaffold(
      currentStep: 5,
      title: 'Ada kondisi khusus?',
      subtitle:
          'Opsional. Membantu AI membuat rekomendasi yang aman untukmu.',
      onContinue: _onContinue,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ═══════════════════════════════════════
          // CHECKBOX LIST
          // ═══════════════════════════════════════
          ...List.generate(_options.length, (i) {
            final isLast = i == _options.length - 1;
            return Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : AppDimensions.sm,
              ),
              child: _ConditionTile(
                option: _options[i],
                isSelected: _selected.contains(i),
                isSpecial: i == _noneIndex,
                onTap: () => _toggle(i),
              ),
            );
          }),

          const SizedBox(height: AppDimensions.xl),

          // ═══════════════════════════════════════
          // INFO CARD
          // ═══════════════════════════════════════
          Container(
            padding: const EdgeInsets.all(AppDimensions.base),
            decoration: BoxDecoration(
              color: AppColors.infoMuted,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(color: AppColors.info, width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Text(
                    'Jika memiliki kondisi serius, konsultasikan dengan dokter '
                    'sebelum memulai program latihan.',
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
}

// ═══════════════════════════════════════════════════════════════
// CONDITION OPTION DATA
// ═══════════════════════════════════════════════════════════════

class _ConditionOption {
  final IconData icon;
  final String label;

  const _ConditionOption({required this.icon, required this.label});
}

// ═══════════════════════════════════════════════════════════════
// CONDITION TILE — row dengan icon, label, checkbox custom
// ═══════════════════════════════════════════════════════════════

class _ConditionTile extends StatelessWidget {
  final _ConditionOption option;
  final bool isSelected;
  final bool isSpecial;
  final VoidCallback onTap;

  const _ConditionTile({
    required this.option,
    required this.isSelected,
    required this.isSpecial,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isSpecial ? AppColors.success : AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.base,
          vertical: AppDimensions.md,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (isSpecial
                  ? AppColors.successMuted
                  : AppColors.primaryMuted)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              option.icon,
              size: 20,
              color:
                  isSelected ? activeColor : AppColors.textSecondary,
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Text(
                option.label,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            // Checkbox indicator
            AnimatedContainer(
              duration: AppDurations.fast,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? activeColor : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: AppColors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

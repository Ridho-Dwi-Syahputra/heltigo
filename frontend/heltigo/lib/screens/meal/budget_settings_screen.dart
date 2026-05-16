/// S-25: Budget Settings Screen — atur anggaran harian
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-25
///
/// Layout:
/// 1. AppBar
/// 2. Big budget display (auto-update saat input/chip)
/// 3. TextFormField input
/// 4. Quick chips (Rp 15K..Rp 100K)
/// 5. Currency toggle IDR/MYR
/// 6. Preview gizi card
/// 7. Sticky bottom: Simpan Budget Baru
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';
import '../../widgets/universal/primary_button.dart';

enum _Currency { idr, myr }

class _BudgetChipData {
  final String label;
  final int value;

  const _BudgetChipData({required this.label, required this.value});
}

class BudgetSettingsScreen extends StatefulWidget {
  const BudgetSettingsScreen({super.key});

  @override
  State<BudgetSettingsScreen> createState() => _BudgetSettingsScreenState();
}

class _BudgetSettingsScreenState extends State<BudgetSettingsScreen> {
  final _controller = TextEditingController(text: '35000');
  _Currency _currency = _Currency.idr;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Quick budget options dependent on currency
  List<_BudgetChipData> get _chips {
    if (_currency == _Currency.idr) {
      return const [
        _BudgetChipData(label: 'Rp 15K', value: 15000),
        _BudgetChipData(label: 'Rp 25K', value: 25000),
        _BudgetChipData(label: 'Rp 35K', value: 35000),
        _BudgetChipData(label: 'Rp 50K', value: 50000),
        _BudgetChipData(label: 'Rp 75K', value: 75000),
        _BudgetChipData(label: 'Rp 100K', value: 100000),
      ];
    }
    return const [
      _BudgetChipData(label: 'RM 5', value: 5),
      _BudgetChipData(label: 'RM 8', value: 8),
      _BudgetChipData(label: 'RM 12', value: 12),
      _BudgetChipData(label: 'RM 18', value: 18),
      _BudgetChipData(label: 'RM 25', value: 25),
      _BudgetChipData(label: 'RM 40', value: 40),
    ];
  }

  String get _currencyPrefix => _currency == _Currency.idr ? 'Rp' : 'RM';

  String _formatThousand(int v) {
    return v.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }

  int get _currentBudget {
    final raw = _controller.text.trim();
    return int.tryParse(raw) ?? 0;
  }

  String get _displayValue {
    if (_currentBudget == 0) return '$_currencyPrefix 0';
    return '$_currencyPrefix ${_formatThousand(_currentBudget)}';
  }

  // Preview gizi: rough estimate scale dari 35K = 1820 kkal baseline
  Map<String, String> get _previewMacros {
    final base = _currency == _Currency.idr ? 35000 : 12;
    final ratio = _currentBudget <= 0 ? 0.0 : (_currentBudget / base);
    return {
      'Kalori': '~${(1820 * ratio).round()} kkal',
      'Protein': '~${(120 * ratio).round()} g',
      'Karbo': '~${(220 * ratio).round()} g',
      'Lemak': '~${(60 * ratio).round()} g',
    };
  }

  void _pickChip(_BudgetChipData chip) {
    setState(() => _controller.text = chip.value.toString());
  }

  bool get _canSave => _currentBudget > 0;

  void _onSave() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Budget tersimpan: $_displayValue / hari'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.textPrimary,
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        title: Text('Pengaturan Budget', style: AppTextStyles.h3),
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
                  // 1. BIG DISPLAY
                  // ═══════════════════════════════════════
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.base,
                      vertical: AppDimensions.lg,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusCard,
                      ),
                      boxShadow: AppShadows.glow,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'BUDGET HARIAN',
                          style: AppTextStyles.overline.copyWith(
                            color: AppColors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.xs),
                        FittedBox(
                          child: Text(
                            _displayValue,
                            style: AppTextStyles.display.copyWith(
                              color: AppColors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // ═══════════════════════════════════════
                  // 2. INPUT
                  // ═══════════════════════════════════════
                  Text(
                    'Anggaran ($_currencyPrefix)',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  TextFormField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      hintText: _currency == _Currency.idr ? '35000' : '12',
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

                  // ═══════════════════════════════════════
                  // 3. QUICK CHIPS
                  // ═══════════════════════════════════════
                  Wrap(
                    spacing: AppDimensions.sm,
                    runSpacing: AppDimensions.sm,
                    children: _chips.map((chip) {
                      final isActive = _currentBudget == chip.value;
                      return _BudgetChipTile(
                        label: chip.label,
                        isActive: isActive,
                        onTap: () => _pickChip(chip),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppDimensions.xl),

                  // ═══════════════════════════════════════
                  // 4. CURRENCY TOGGLE
                  // ═══════════════════════════════════════
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Mata Uang',
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
                  const SizedBox(height: AppDimensions.xl),

                  // ═══════════════════════════════════════
                  // 5. PREVIEW CARD
                  // ═══════════════════════════════════════
                  Text(
                    'PREVIEW DENGAN $_displayValue / HARI',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.base),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMuted,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusCard,
                      ),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppDimensions.sm,
                      crossAxisSpacing: AppDimensions.sm,
                      childAspectRatio: 3,
                      children: _previewMacros.entries.map((entry) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.sm + 2,
                            vertical: AppDimensions.xs + 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusInput,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                entry.key,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                              Text(
                                entry.value,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xl),
                ],
              ),
            ),

            // ═══════════════════════════════════════
            // 6. STICKY BOTTOM BUTTON
            // ═══════════════════════════════════════
            Container(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.base,
                AppDimensions.sm,
                AppDimensions.base,
                AppDimensions.base + MediaQuery.of(context).padding.bottom,
              ),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(color: AppColors.divider, width: 1),
                ),
              ),
              child: Column(
                children: [
                  PrimaryButton(
                    label: 'Simpan Budget Baru',
                    icon: Icons.check,
                    onPressed: _canSave ? _onSave : null,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'AI membuat ulang rencana besok dengan budget ini.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BUDGET CHIP TILE
// ═══════════════════════════════════════════════════════════════

class _BudgetChipTile extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BudgetChipTile({
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
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CURRENCY TOGGLE
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
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isActive
                      ? AppColors.textOnPrimary
                      : AppColors.textTertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

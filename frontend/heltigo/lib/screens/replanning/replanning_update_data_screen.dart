/// S-34b: Replanning Step 1/3 — Update Data Mingguan
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-34b
///
/// Form konfirmasi data terbaru: berat, lingkar pinggang, budget, kondisi tubuh.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';
import '../../widgets/universal/primary_button.dart';

enum _BodyCondition { lelah, biasa, prima, penuh }

class ReplanningUpdateDataScreen extends StatefulWidget {
  const ReplanningUpdateDataScreen({super.key});

  @override
  State<ReplanningUpdateDataScreen> createState() =>
      _ReplanningUpdateDataScreenState();
}

class _ReplanningUpdateDataScreenState
    extends State<ReplanningUpdateDataScreen> {
  // ─── State ───
  bool _weightConfirmed = false;
  final _waistController = TextEditingController(text: '86');
  final _manualWeightController = TextEditingController();
  int _budgetChipIndex = 1; // 0=25K, 1=35K, 2=50K, 3=75K, 4=lainnya
  _BodyCondition _condition = _BodyCondition.prima;

  // Mock data
  static const double _prevWeight = 74.4;
  static const double _currentWeight = 74.2;
  static const double _weightDelta = -0.2;
  static const int _waistPrev = 88;
  static const int _budgetPrev = 35000;

  @override
  void dispose() {
    _waistController.dispose();
    _manualWeightController.dispose();
    super.dispose();
  }

  Future<void> _showManualWeightDialog() async {
    _manualWeightController.text = _currentWeight.toStringAsFixed(1);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusCard),
        ),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppDimensions.base,
            right: AppDimensions.base,
            top: AppDimensions.base,
            bottom:
                MediaQuery.of(ctx).viewInsets.bottom + AppDimensions.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusFull,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.base),
              Text('Ubah Berat Manual', style: AppTextStyles.h3),
              const SizedBox(height: AppDimensions.sm),
              Text(
                'Masukkan berat badan terbaru kamu dalam kg.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.base),
              TextField(
                controller: _manualWeightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                autofocus: true,
                cursorColor: AppColors.primary,
                decoration: const InputDecoration(
                  suffixText: 'kg',
                  hintText: '0.0',
                ),
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: AppDimensions.base),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusButton,
                      ),
                    ),
                  ),
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int? get _waistDelta {
    final v = int.tryParse(_waistController.text);
    if (v == null) return null;
    return v - _waistPrev;
  }

  String _budgetLabel(int idx) {
    switch (idx) {
      case 0:
        return 'Rp 25K';
      case 1:
        return 'Rp 35K';
      case 2:
        return 'Rp 50K';
      case 3:
        return 'Rp 75K';
      case 4:
        return 'Lainnya';
      default:
        return '';
    }
  }

  int? _budgetValue(int idx) {
    switch (idx) {
      case 0:
        return 25000;
      case 1:
        return 35000;
      case 2:
        return 50000;
      case 3:
        return 75000;
      default:
        return null;
    }
  }

  bool get _budgetChanged {
    final v = _budgetValue(_budgetChipIndex);
    return v != null && v != _budgetPrev;
  }

  String _conditionLabel(_BodyCondition c) {
    switch (c) {
      case _BodyCondition.lelah:
        return 'Lelah';
      case _BodyCondition.biasa:
        return 'Biasa';
      case _BodyCondition.prima:
        return 'Prima';
      case _BodyCondition.penuh:
        return 'Penuh';
    }
  }

  IconData _conditionIcon(_BodyCondition c) {
    switch (c) {
      case _BodyCondition.lelah:
        return Icons.sentiment_very_dissatisfied_outlined;
      case _BodyCondition.biasa:
        return Icons.sentiment_neutral_outlined;
      case _BodyCondition.prima:
        return Icons.sentiment_satisfied_outlined;
      case _BodyCondition.penuh:
        return Icons.sentiment_very_satisfied_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.textPrimary,
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        title: Text(
          'EVALUASI · LANGKAH 1/3',
          style: AppTextStyles.overline.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ─── Progress indicator step ───
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.base,
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusFull),
                child: LinearProgressIndicator(
                  value: 0.33,
                  minHeight: 4,
                  backgroundColor: AppColors.surfaceLight,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.base,
                  vertical: AppDimensions.base,
                ),
                children: [
                  Text(
                    'Update Data Mingguan',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    'Agar AI dapat memperbarui rencana yang akurat, '
                    'mohon konfirmasi data terbaru kamu minggu ini.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // ═══════════════════════════════════════
                  // 1. BERAT BADAN
                  // ═══════════════════════════════════════
                  _SectionHeader(
                    icon: Icons.monitor_weight_outlined,
                    title: 'Berat Badan Sekarang',
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.base),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusCard,
                      ),
                      border: Border.all(
                        color: _weightConfirmed
                            ? AppColors.success
                            : AppColors.border,
                        width: _weightConfirmed ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sebelumnya: ${_prevWeight.toStringAsFixed(1)} kg',
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(height: AppDimensions.xs),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _currentWeight.toStringAsFixed(1),
                              style: AppTextStyles.display.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                height: 1,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.xs + 2),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                'kg',
                                style: AppTextStyles.h3.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.sm,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusFull,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.trending_down,
                                    size: 12,
                                    color: AppColors.success,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_weightDelta.toStringAsFixed(1)} kg',
                                    style:
                                        AppTextStyles.caption.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.md),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _showManualWeightDialog,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                      AppColors.textSecondary,
                                  side: BorderSide(
                                    color: AppColors.border,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusButton,
                                    ),
                                  ),
                                  minimumSize:
                                      const Size.fromHeight(40),
                                ),
                                child: const Text('Ubah Manual'),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.sm),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _weightConfirmed
                                    ? null
                                    : () => setState(
                                          () => _weightConfirmed = true,
                                        ),
                                icon: Icon(
                                  _weightConfirmed
                                      ? Icons.check_circle
                                      : Icons.check,
                                  size: 16,
                                ),
                                label: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    _weightConfirmed
                                        ? 'Dikonfirmasi'
                                        : 'Konfirmasi',
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _weightConfirmed
                                      ? AppColors.success
                                      : AppColors.primary,
                                  foregroundColor: AppColors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusButton,
                                    ),
                                  ),
                                  minimumSize:
                                      const Size.fromHeight(40),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // ═══════════════════════════════════════
                  // 2. LINGKAR PINGGANG
                  // ═══════════════════════════════════════
                  _SectionHeader(
                    icon: Icons.straighten,
                    title: 'Lingkar Pinggang',
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _waistController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          cursorColor: AppColors.primary,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.straighten,
                              color: AppColors.textTertiary,
                              size: 20,
                            ),
                            suffixText: 'cm',
                            suffixStyle: TextStyle(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      ),
                      if (_waistDelta != null) ...[
                        const SizedBox(width: AppDimensions.sm),
                        _DeltaChip(value: _waistDelta!, unit: 'cm'),
                      ],
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Sebelumnya: $_waistPrev cm',
                      style: AppTextStyles.caption,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // ═══════════════════════════════════════
                  // 3. BUDGET MAKAN
                  // ═══════════════════════════════════════
                  _SectionHeader(
                    icon: Icons.payments_outlined,
                    title: 'Budget Makan Harian',
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  Text(
                    'Sebelumnya: Rp ${_budgetPrev ~/ 1000}.000/hari',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Wrap(
                    spacing: AppDimensions.sm,
                    runSpacing: AppDimensions.sm,
                    children: List.generate(5, (i) {
                      final active = _budgetChipIndex == i;
                      return InkWell(
                        onTap: () => setState(() => _budgetChipIndex = i),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusFull,
                        ),
                        child: AnimatedContainer(
                          duration: AppDurations.fast,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.base,
                            vertical: AppDimensions.sm + 2,
                          ),
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.primaryMuted
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusFull,
                            ),
                            border: Border.all(
                              color: active
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: active ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            _budgetLabel(i),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: active
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.md,
                      vertical: AppDimensions.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMuted,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusInput,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppDimensions.xs + 2),
                        Expanded(
                          child: Text(
                            _budgetChanged
                                ? 'Budget berubah → AI akan menyesuaikan menu lokal'
                                : 'Budget tetap → AI akan tetap pakai 1.346+ menu lokal',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // ═══════════════════════════════════════
                  // 4. KONDISI TUBUH
                  // ═══════════════════════════════════════
                  _SectionHeader(
                    icon: Icons.favorite_outline,
                    title: 'Kondisi Tubuh Minggu Ini',
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Row(
                    children: _BodyCondition.values.map((c) {
                      final active = _condition == c;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: c == _BodyCondition.penuh
                                ? 0
                                : AppDimensions.sm,
                          ),
                          child: InkWell(
                            onTap: () =>
                                setState(() => _condition = c),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusCard,
                            ),
                            child: AnimatedContainer(
                              duration: AppDurations.fast,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppDimensions.sm + 2,
                              ),
                              decoration: BoxDecoration(
                                color: active
                                    ? AppColors.primaryMuted
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusCard,
                                ),
                                border: Border.all(
                                  color: active
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: active ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    _conditionIcon(c),
                                    size: 24,
                                    color: active
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _conditionLabel(c),
                                    style: AppTextStyles.caption.copyWith(
                                      color: active
                                          ? AppColors.textPrimary
                                          : AppColors.textTertiary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppDimensions.xl),
                ],
              ),
            ),

            // ─── Sticky bottom ───
            Container(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.base,
                AppDimensions.sm,
                AppDimensions.base,
                AppDimensions.base +
                    MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(color: AppColors.divider, width: 1),
                ),
              ),
              child: PrimaryButton(
                label: 'Lanjutkan ke Pilihan Rencana',
                icon: Icons.arrow_forward,
                onPressed: () => context.push('/replanning/choose'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SECTION HEADER (icon + title)
// ═══════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppDimensions.sm),
        Text(title, style: AppTextStyles.h3.copyWith(fontSize: 15)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DELTA CHIP (untuk lingkar pinggang)
// ═══════════════════════════════════════════════════════════════

class _DeltaChip extends StatelessWidget {
  final int value;
  final String unit;

  const _DeltaChip({required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    final isDown = value < 0;
    final isZero = value == 0;
    final color = isZero
        ? AppColors.textTertiary
        : (isDown ? AppColors.success : AppColors.warning);
    final sign = isZero ? '' : (value > 0 ? '+' : '');
    final icon = isZero
        ? Icons.remove
        : (isDown ? Icons.trending_down : Icons.trending_up);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm + 2,
        vertical: AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            '$sign$value $unit',
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

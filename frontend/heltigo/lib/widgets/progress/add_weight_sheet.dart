/// S-27: Catat Timbangan modal bottom sheet
///
/// Dipakai dari Progress Dashboard "Catat" button.
/// Helper function: `showAddWeightSheet(context, currentWeight: ...)`.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../styles/styles.dart';
import '../universal/primary_button.dart';

/// Tampilkan modal bottom sheet untuk catat timbangan.
/// Return `true` jika user simpan, `false`/null jika batal.
Future<bool?> showAddWeightSheet(
  BuildContext context, {
  required double currentWeight,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.surfaceElevated,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusBottomSheetTop),
      ),
    ),
    builder: (ctx) => _AddWeightSheetContent(prevWeight: currentWeight),
  );
}

class _AddWeightSheetContent extends StatefulWidget {
  final double prevWeight;

  const _AddWeightSheetContent({required this.prevWeight});

  @override
  State<_AddWeightSheetContent> createState() => _AddWeightSheetContentState();
}

class _AddWeightSheetContentState extends State<_AddWeightSheetContent> {
  late double _weightKg;
  bool _isImperial = false; // false = kg, true = lbs
  DateTime _date = DateTime.now();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _weightKg = widget.prevWeight;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  double get _displayWeight =>
      _isImperial ? _weightKg * 2.20462 : _weightKg;

  String get _unitLabel => _isImperial ? 'lbs' : 'kg';

  double get _delta => _weightKg - widget.prevWeight;

  String get _deltaText {
    if (_delta.abs() < 0.05) return 'Sama dengan kemarin';
    final sign = _delta < 0 ? '-' : '+';
    return '$sign${_delta.abs().toStringAsFixed(1)} kg dari kemarin';
  }

  Color get _deltaColor {
    if (_delta.abs() < 0.05) return AppColors.textTertiary;
    return _delta < 0 ? AppColors.success : AppColors.warning;
  }

  IconData get _deltaIcon {
    if (_delta.abs() < 0.05) return Icons.trending_flat;
    return _delta < 0 ? Icons.trending_down : Icons.trending_up;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _date = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.base),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Drag handle ───
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.base),

                // ─── Header row ───
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Catat Timbangan',
                        style: AppTextStyles.h2,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      color: AppColors.textSecondary,
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.base),

                // ─── Date row ───
                InkWell(
                  onTap: _pickDate,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusInput),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.base,
                      vertical: AppDimensions.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusInput),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.textTertiary,
                          size: 18,
                        ),
                        const SizedBox(width: AppDimensions.md),
                        Expanded(
                          child: Text(
                            DateFormat('EEEE, d MMM yyyy', 'id_ID')
                                .format(_date),
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.textTertiary,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),

                // ─── BERAT BADAN display ───
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'BERAT BADAN',
                        style: AppTextStyles.overline.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    _UnitToggle(
                      isImperial: _isImperial,
                      onChanged: (v) => setState(() => _isImperial = v),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.base,
                    vertical: AppDimensions.md,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusCard),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _displayWeight.toStringAsFixed(1),
                            style: AppTextStyles.display.copyWith(
                              color: AppColors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.sm),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              _unitLabel,
                              style: AppTextStyles.h3.copyWith(
                                color:
                                    AppColors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.white,
                          inactiveTrackColor:
                              AppColors.white.withValues(alpha: 0.3),
                          thumbColor: AppColors.white,
                          overlayColor:
                              AppColors.white.withValues(alpha: 0.2),
                          trackHeight: 3,
                        ),
                        child: Slider(
                          min: 30,
                          max: 200,
                          value: _weightKg.clamp(30, 200).toDouble(),
                          onChanged: (v) => setState(() => _weightKg = v),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.md),

                // ─── Prev weight chip ───
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.sm + 2,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusFull,
                        ),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.history,
                            size: 12,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Kemarin: ${widget.prevWeight.toStringAsFixed(1)} kg',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.sm + 2,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _deltaColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusFull,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_deltaIcon, size: 12, color: _deltaColor),
                          const SizedBox(width: 4),
                          Text(
                            _deltaText,
                            style: AppTextStyles.caption.copyWith(
                              color: _deltaColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.lg),

                // ─── Catatan ───
                Text(
                  'Catatan (opsional)',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                TextField(
                  controller: _noteController,
                  maxLines: 2,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  cursorColor: AppColors.primary,
                  decoration: const InputDecoration(
                    hintText: 'mis. setelah bangun tidur',
                    prefixIcon: Icon(
                      Icons.edit_note_outlined,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.xl),

                // ─── Buttons ───
                PrimaryButton(
                  label: 'Simpan',
                  icon: Icons.check,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
                const SizedBox(height: AppDimensions.sm),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: const Text('Batal'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// UNIT TOGGLE — compact kg/lbs
// ═══════════════════════════════════════════════════════════════

class _UnitToggle extends StatelessWidget {
  final bool isImperial;
  final ValueChanged<bool> onChanged;

  const _UnitToggle({required this.isImperial, required this.onChanged});

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
        children: [
          _UnitChip(label: 'kg', active: !isImperial, onTap: () => onChanged(false)),
          _UnitChip(label: 'lbs', active: isImperial, onTap: () => onChanged(true)),
        ],
      ),
    );
  }
}

class _UnitChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _UnitChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: active ? AppColors.textOnPrimary : AppColors.textTertiary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

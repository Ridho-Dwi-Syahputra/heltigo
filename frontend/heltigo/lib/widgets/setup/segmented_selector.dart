/// SegmentedSelector — pill-style row of options untuk pemilihan single-choice
///
/// Digunakan untuk: hari per minggu, durasi sesi, level kebugaran, frekuensi makan, dll.
/// Active item: bg primary + text putih. Inactive: bg surface + text secondary.
/// Scrollable horizontal jika konten melebihi lebar layar (responsive).
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class SegmentedSelector extends StatelessWidget {
  /// List label opsi (akan dirender sebagai pill)
  final List<String> options;

  /// Index opsi yang sedang dipilih (-1 = tidak ada)
  final int selectedIndex;

  /// Callback saat ada opsi yang dipilih (kirim index)
  final ValueChanged<int> onChanged;

  /// Apakah pill mengisi lebar layar secara merata (Expanded)
  /// True (default): cocok untuk 2-4 opsi, fill width.
  /// False: pakai intrinsic width + horizontal scroll jika overflow.
  final bool fillWidth;

  const SegmentedSelector({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
    this.fillWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    if (fillWidth) {
      return Row(
        children: List.generate(options.length, (i) {
          final isLast = i == options.length - 1;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : AppDimensions.sm),
              child: _Pill(
                label: options[i],
                isSelected: i == selectedIndex,
                onTap: () => onChanged(i),
              ),
            ),
          );
        }),
      );
    }

    // Scrollable mode untuk opsi banyak
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(options.length, (i) {
          final isLast = i == options.length - 1;
          return Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : AppDimensions.sm),
            child: _Pill(
              label: options[i],
              isSelected: i == selectedIndex,
              onTap: () => onChanged(i),
            ),
          );
        }),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.isSelected,
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
          vertical: AppDimensions.md,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: AppTextStyles.body.copyWith(
              color: isSelected
                  ? AppColors.textOnPrimary
                  : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

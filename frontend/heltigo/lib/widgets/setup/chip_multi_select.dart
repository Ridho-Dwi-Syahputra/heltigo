/// ChipMultiSelect — multi-select chips dengan icon untuk pilihan banyak
///
/// Digunakan untuk: waktu favorit (Pagi/Siang/Sore/Malam), preferensi rentang waktu, dll.
/// Pakai Wrap supaya responsive di layar kecil (otomatis ganti baris).
/// Active chip: bg primaryMuted + border primary + text primary.
/// Inactive: bg surface + border default + text secondary.
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

/// Opsi yang ditampilkan dalam ChipMultiSelect
class ChipOption {
  final String label;
  final IconData? icon;

  const ChipOption({required this.label, this.icon});
}

class ChipMultiSelect extends StatelessWidget {
  /// List opsi yang ditampilkan
  final List<ChipOption> options;

  /// Set index opsi yang terpilih (immutable view)
  final Set<int> selectedIndices;

  /// Callback saat selection berubah (kirim `Set<int>` baru)
  final ValueChanged<Set<int>> onChanged;

  const ChipMultiSelect({
    super.key,
    required this.options,
    required this.selectedIndices,
    required this.onChanged,
  });

  void _toggle(int index) {
    final next = Set<int>.from(selectedIndices);
    if (next.contains(index)) {
      next.remove(index);
    } else {
      next.add(index);
    }
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.sm,
      runSpacing: AppDimensions.sm,
      children: List.generate(options.length, (i) {
        final isSelected = selectedIndices.contains(i);
        return _Chip(
          option: options[i],
          isSelected: isSelected,
          onTap: () => _toggle(i),
        );
      }),
    );
  }
}

class _Chip extends StatelessWidget {
  final ChipOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _Chip({
    required this.option,
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
          vertical: AppDimensions.sm + 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryMuted : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (option.icon != null) ...[
              Icon(
                option.icon,
                size: 16,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: AppDimensions.xs + 2),
            ],
            Text(
              option.label,
              style: AppTextStyles.body.copyWith(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

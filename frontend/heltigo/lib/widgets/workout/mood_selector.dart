/// MoodSelector — 5 emoji-icon selector untuk mood/energy
///
/// Active item: scale 1.15x + bg primaryMuted + border primary.
/// Inactive: bg surface + textTertiary icon.
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class MoodSelector extends StatelessWidget {
  /// Index 0-4. -1 = belum dipilih.
  final int selectedIndex;

  /// Callback saat tap item
  final ValueChanged<int> onChanged;

  /// 5 Material icons (low → high)
  final List<IconData> icons;

  /// Label di bawah masing-masing icon (opsional, sama panjang dengan icons)
  final List<String>? labels;

  const MoodSelector({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    required this.icons,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    assert(
      icons.length == 5,
      'MoodSelector expects exactly 5 icons',
    );
    assert(
      labels == null || labels!.length == icons.length,
      'labels length must match icons',
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppDimensions.sm;
        final itemSize =
            (constraints.maxWidth - (spacing * (icons.length - 1))) /
                icons.length;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(icons.length, (i) {
            final isActive = i == selectedIndex;
            return SizedBox(
              width: itemSize,
              child: _MoodItem(
                icon: icons[i],
                label: labels != null ? labels![i] : null,
                isActive: isActive,
                onTap: () => onChanged(i),
              ),
            );
          }),
        );
      },
    );
  }
}

class _MoodItem extends StatelessWidget {
  final IconData icon;
  final String? label;
  final bool isActive;
  final VoidCallback onTap;

  const _MoodItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.xs,
          vertical: AppDimensions.sm,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryMuted : AppColors.surface,
          borderRadius:
              BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: AppDurations.fast,
              scale: isActive ? 1.15 : 1.0,
              child: Icon(
                icon,
                size: 28,
                color: isActive
                    ? AppColors.primary
                    : AppColors.textTertiary,
              ),
            ),
            if (label != null) ...[
              const SizedBox(height: 4),
              Text(
                label!,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: isActive
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                  fontWeight: isActive
                      ? FontWeight.w700
                      : FontWeight.w500,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// SelectionCard — kartu pilihan dengan ikon untuk pemilihan 2-kolom
///
/// Digunakan untuk pilihan binary/few-option (Laki-laki/Perempuan, Home/Gym, dll).
/// Selected: border primary 2px + bg primaryMuted + icon/text primary.
/// Unselected: border default + bg surface + icon/text textSecondary.
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class SelectionCard extends StatelessWidget {
  /// Label utama yang ditampilkan
  final String label;

  /// Subtitle opsional di bawah label
  final String? subtitle;

  /// Ikon Material yang ditampilkan di atas label
  final IconData icon;

  /// Status terpilih atau tidak
  final bool isSelected;

  /// Callback saat ditekan
  final VoidCallback onTap;

  const SelectionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.base,
          vertical: AppDimensions.lg,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryMuted : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

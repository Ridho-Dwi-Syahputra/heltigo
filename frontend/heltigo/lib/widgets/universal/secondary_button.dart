/// SecondaryButton — tombol sekunder Heltigo (outlined)
/// Sumber: docs/frontend/03_DESIGN_SYSTEM.md §Components
///
/// Digunakan untuk aksi alternatif (Cancel, Skip, dll)
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isFullWidth;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: AppDimensions.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: AppDimensions.iconMedium),
              const SizedBox(width: AppDimensions.sm),
            ],
            Text(
              label,
              style: AppTextStyles.button.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

/// PrimaryButton — tombol utama Heltigo (filled, hijau)
/// Sumber: docs/frontend/03_DESIGN_SYSTEM.md §Components
///
/// Digunakan untuk aksi utama di setiap screen (Login, Submit, Next, dll)
/// Props:
/// - label: teks tombol
/// - onPressed: callback saat ditekan
/// - isLoading: tampilkan loading spinner
/// - icon: ikon opsional di kiri teks
/// - isFullWidth: lebar penuh (default: true)
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: AppDimensions.buttonHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: onPressed != null ? AppShadows.buttonPrimary : [],
          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            disabledBackgroundColor: AppColors.surfaceLight,
            disabledForegroundColor: AppColors.textTertiary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.textOnPrimary,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: AppDimensions.iconMedium),
                      const SizedBox(width: AppDimensions.sm),
                    ],
                    Text(label, style: AppTextStyles.button),
                  ],
                ),
        ),
      ),
    );

    return button;
  }
}

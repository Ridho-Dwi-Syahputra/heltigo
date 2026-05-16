/// LoadingOverlay — overlay loading transparan
/// Sumber: docs/frontend/03_DESIGN_SYSTEM.md §Components
///
/// Ditampilkan di atas konten saat proses async (API call, submit form).
/// Menggunakan backdrop gelap semi-transparan + spinner hijau.
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: AppColors.black.withValues(alpha: 0.6),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 3,
                  ),
                  if (message != null) ...[
                    const SizedBox(height: AppDimensions.base),
                    Text(
                      message!,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

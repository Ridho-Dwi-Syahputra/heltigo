// S-33: Error Screen — tampilan error generik
// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-33
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class ErrorScreen extends StatelessWidget {
  final String? message;

  const ErrorScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.base),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Terjadi Kesalahan',
                  style: AppTextStyles.h2,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                message ?? 'Silakan coba lagi nanti',
                style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// S-34: Offline Screen — tampilan saat tidak ada koneksi
// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-34
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.base),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off,
                  size: 64, color: AppColors.textTertiary),
              const SizedBox(height: 16),
              Text('Tidak Ada Koneksi',
                  style: AppTextStyles.h2,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'Kamu bisa menggunakan mode offline.\n'
                'Data akan disinkronkan saat koneksi kembali.',
                style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Lanjut Offline'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

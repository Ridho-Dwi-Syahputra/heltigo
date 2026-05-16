/// S-31: About Screen — informasi tentang aplikasi
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-31
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            const Icon(Icons.favorite, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('Heltigo', style: AppTextStyles.h1),
            const SizedBox(height: 8),
            Text('v1.0.0', style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            Text(
              'AI-Powered Personal Health & Fitness App\n'
              'Dibuat untuk kompetisi MSU iREX 2026',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // TODO: Team credits
            // TODO: Licenses
          ],
        ),
      ),
    );
  }
}

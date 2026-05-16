/// S-21: Meal Log Screen — log makanan yang sudah dimakan
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-21
/// API: POST /meal/:id/log
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class MealLogScreen extends StatelessWidget {
  final String mealId;

  const MealLogScreen({super.key, required this.mealId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Makanan')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Konfirmasi Makanan', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            Text('Apakah kamu sudah memakan makanan ini?',
                style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            // TODO: Meal info card
            // TODO: Porsi adjustment (optional)
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // TODO: Log meal via MealProvider
              },
              child: const Text('Sudah Dimakan ✓'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

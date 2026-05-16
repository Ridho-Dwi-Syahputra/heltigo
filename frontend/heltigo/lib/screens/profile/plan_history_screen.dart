/// S-29: Plan History Screen — riwayat plan yang pernah dibuat
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-29
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class PlanHistoryScreen extends StatelessWidget {
  const PlanHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Rencana')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Riwayat', style: AppTextStyles.h2),
            const SizedBox(height: 24),
            // TODO: List of past plans (tanggal, score, status)
          ],
        ),
      ),
    );
  }
}

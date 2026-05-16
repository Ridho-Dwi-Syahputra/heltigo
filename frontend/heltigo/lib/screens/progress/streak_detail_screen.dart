/// S-25: Streak Detail Screen — detail informasi streak
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-25
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class StreakDetailScreen extends StatelessWidget {
  const StreakDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Streak')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TODO: Current streak number (besar)
            // TODO: Best streak number
            // TODO: Calendar heatmap (30 hari)
            // TODO: Streak milestones
            Text('Streak Kamu', style: AppTextStyles.h2),
          ],
        ),
      ),
    );
  }
}

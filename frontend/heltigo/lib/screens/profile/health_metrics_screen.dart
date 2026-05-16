/// S-28: Health Metrics Screen — detail BMI, TDEE, weight history
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-28
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class HealthMetricsScreen extends StatelessWidget {
  const HealthMetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Metrik Kesehatan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TODO: BMI card with visualization
            // TODO: TDEE breakdown
            // TODO: Weight history chart
            // TODO: Update weight button
            Text('Metrik Kesehatan', style: AppTextStyles.h2),
          ],
        ),
      ),
    );
  }
}

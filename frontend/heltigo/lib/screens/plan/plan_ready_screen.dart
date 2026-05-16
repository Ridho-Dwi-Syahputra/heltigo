/// S-11: Plan Ready Screen — ringkasan plan yang baru dibuat
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-11
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';

class PlanReadyScreen extends StatelessWidget {
  const PlanReadyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(Icons.check_circle,
                  size: 80, color: AppColors.primary),
              const SizedBox(height: 24),
              Text('Rencana Siap!',
                  style: AppTextStyles.h1,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'Rencana 7 hari kamu sudah dibuat oleh AI',
                style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // TODO: Ringkasan plan (jumlah hari, kalori target, dll)
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Mulai Sekarang'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

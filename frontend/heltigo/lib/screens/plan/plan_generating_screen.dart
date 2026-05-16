/// S-10: Plan Generating Screen — animasi loading saat ML generate plan
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-10
/// API: POST /plan/generate
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';

class PlanGeneratingScreen extends StatefulWidget {
  const PlanGeneratingScreen({super.key});

  @override
  State<PlanGeneratingScreen> createState() => _PlanGeneratingScreenState();
}

class _PlanGeneratingScreenState extends State<PlanGeneratingScreen> {
  @override
  void initState() {
    super.initState();
    // TODO: Trigger plan generation via PlanProvider
    // Setelah selesai, navigasi ke /plan-ready
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go('/plan-ready');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TODO: Ganti dengan Lottie animation
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 24),
            Text('Membuat Rencana...', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            Text('AI sedang menyusun rencana latihan & makan',
                style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

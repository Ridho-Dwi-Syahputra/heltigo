/// SetupScaffold — layout wrapper konsisten untuk semua 7 setup screen
/// Sumber: docs/frontend/04_NAVIGATION.md §SetupScaffold
///
/// Komponen:
/// - AppBar transparan dengan back button (Icons.arrow_back_ios_new)
/// - Progress bar LinearProgressIndicator + label "Langkah X dari N"
/// - Title + subtitle opsional
/// - Scrollable body (SingleChildScrollView)
/// - Sticky PrimaryButton di bawah dengan SafeArea
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';
import '../universal/primary_button.dart';

class SetupScaffold extends StatelessWidget {
  /// Step saat ini (1..totalSteps)
  final int currentStep;

  /// Total step dalam wizard (default: 7)
  final int totalSteps;

  /// Judul utama di atas body
  final String title;

  /// Subtitle opsional di bawah judul
  final String? subtitle;

  /// Konten utama (di-wrap SingleChildScrollView)
  final Widget body;

  /// Label tombol bawah (default: "Lanjutkan")
  final String buttonLabel;

  /// Callback saat tombol ditekan. Null = button disabled.
  final VoidCallback? onContinue;

  const SetupScaffold({
    super.key,
    required this.currentStep,
    this.totalSteps = 7,
    required this.title,
    this.subtitle,
    required this.body,
    this.buttonLabel = 'Lanjutkan',
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;

    return Scaffold(
      // AppBar transparan dengan back button
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.textPrimary,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ═══════════════════════════════════════
            // PROGRESS BAR + LABEL
            // ═══════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.screenPaddingH,
                0,
                AppDimensions.screenPaddingH,
                AppDimensions.base,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: AppColors.surfaceLight,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  // Step label
                  Text(
                    'Langkah $currentStep dari $totalSteps',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // ═══════════════════════════════════════
            // BODY (Title + Subtitle + Konten Scrollable)
            // ═══════════════════════════════════════
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.screenPaddingH,
                  AppDimensions.sm,
                  AppDimensions.screenPaddingH,
                  AppDimensions.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(title, style: AppTextStyles.h2),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppDimensions.sm),
                      Text(
                        subtitle!,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppDimensions.xl),

                    // Konten utama yang diberikan caller
                    body,
                  ],
                ),
              ),
            ),

            // ═══════════════════════════════════════
            // STICKY BOTTOM BUTTON
            // ═══════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.screenPaddingH,
                AppDimensions.md,
                AppDimensions.screenPaddingH,
                AppDimensions.base,
              ),
              child: SafeArea(
                top: false,
                child: PrimaryButton(
                  label: buttonLabel,
                  onPressed: onContinue,
                  icon: Icons.arrow_forward,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

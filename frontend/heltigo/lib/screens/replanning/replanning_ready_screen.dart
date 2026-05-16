/// S-35: Replanning — Rencana Minggu Depan Siap
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-35
///
/// Screen terakhir (celebration) — daftar perubahan AI + preview 7 hari
/// + update target + motivasi.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';
import '../../widgets/universal/primary_button.dart';

class ReplanningReadyScreen extends StatelessWidget {
  const ReplanningReadyScreen({super.key});

  // Mock perubahan AI
  static const List<({IconData icon, String text, Color color})> _changes = [
    (
      icon: Icons.trending_up,
      text: 'Volume latihan +10% — konfirmasi prima',
      color: AppColors.success,
    ),
    (
      icon: Icons.swap_horiz,
      text: 'Mountain Climber diganti dengan Burpees',
      color: AppColors.warning,
    ),
    (
      icon: Icons.payments_outlined,
      text: 'Budget makan tetap Rp 35K/hari',
      color: AppColors.accent,
    ),
    (
      icon: Icons.timer_outlined,
      text: 'Sesi cardio diperpanjang 5 menit',
      color: AppColors.primary,
    ),
  ];

  // Preview 7 hari (S S R K J S M)
  static const List<({String label, IconData icon, bool isRest})>
      _weekPreview = [
    (label: 'S', icon: Icons.fitness_center, isRest: false),
    (label: 'S', icon: Icons.fitness_center, isRest: false),
    (label: 'R', icon: Icons.bed_outlined, isRest: true),
    (label: 'K', icon: Icons.fitness_center, isRest: false),
    (label: 'J', icon: Icons.fitness_center, isRest: false),
    (label: 'S', icon: Icons.directions_run, isRest: false),
    (label: 'M', icon: Icons.bed_outlined, isRest: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'EVALUASI · LANGKAH 3/3',
          style: AppTextStyles.overline.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Progress bar step (full)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.base,
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusFull),
                child: LinearProgressIndicator(
                  value: 1,
                  minHeight: 4,
                  backgroundColor: AppColors.surfaceLight,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.success),
                ),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.base,
                  vertical: AppDimensions.base,
                ),
                children: [
                  // ═══════════════════════════════════════
                  // HERO ICON + TITLE
                  // ═══════════════════════════════════════
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color:
                            AppColors.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.glow,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Center(
                    child: Text(
                      'Rencana Minggu Depan Siap!',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h1.copyWith(fontSize: 24),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  Center(
                    child: Text(
                      'Disesuaikan berdasarkan performamu',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xl),

                  // ═══════════════════════════════════════
                  // PERUBAHAN AI
                  // ═══════════════════════════════════════
                  Text(
                    'PERUBAHAN AI',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusCard,
                      ),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: List.generate(_changes.length, (i) {
                        final c = _changes[i];
                        final isLast = i == _changes.length - 1;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.base,
                            vertical: AppDimensions.md,
                          ),
                          decoration: BoxDecoration(
                            border: isLast
                                ? null
                                : Border(
                                    bottom: BorderSide(
                                      color: AppColors.divider,
                                      width: 1,
                                    ),
                                  ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: c.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusSmall,
                                  ),
                                ),
                                child: Icon(
                                  c.icon,
                                  size: 16,
                                  color: c.color,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.md),
                              Expanded(
                                child: Text(
                                  c.text,
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // ═══════════════════════════════════════
                  // PREVIEW 7 HARI
                  // ═══════════════════════════════════════
                  Text(
                    'PREVIEW 7 HARI',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.sm,
                      vertical: AppDimensions.base,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusCard,
                      ),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const spacing = AppDimensions.xs + 2;
                        final chipWidth =
                            (constraints.maxWidth - spacing * 6) / 7;
                        return Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children:
                              List.generate(_weekPreview.length, (i) {
                            final day = _weekPreview[i];
                            return SizedBox(
                              width: chipWidth,
                              child: _DayChip(
                                label: day.label,
                                icon: day.icon,
                                isRest: day.isRest,
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // ═══════════════════════════════════════
                  // UPDATE TARGET CARD
                  // ═══════════════════════════════════════
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.base),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMuted,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusCard,
                      ),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.flag,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppDimensions.xs + 2),
                            Text(
                              'UPDATE TARGET',
                              style: AppTextStyles.overline.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.xs + 2),
                        RichText(
                          text: TextSpan(
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            children: [
                              const TextSpan(text: '3,8 '),
                              TextSpan(
                                text: 'dari',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const TextSpan(text: ' 10 kg turun'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Estimasi 18 minggu lagi',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // ═══════════════════════════════════════
                  // QUOTE / MOTIVASI
                  // ═══════════════════════════════════════
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.base),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusCard,
                      ),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.format_quote,
                          color: AppColors.accent,
                          size: 24,
                        ),
                        const SizedBox(width: AppDimensions.sm),
                        Expanded(
                          child: Text(
                            'Performamu luar biasa! Sampai jumpa next level.',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xl),
                ],
              ),
            ),

            // ─── Sticky bottom ───
            Container(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.base,
                AppDimensions.sm,
                AppDimensions.base,
                AppDimensions.base +
                    MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(color: AppColors.divider, width: 1),
                ),
              ),
              child: PrimaryButton(
                label: 'Mulai Minggu Baru!',
                icon: Icons.rocket_launch,
                onPressed: () => context.go('/home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DAY CHIP (preview 7 hari)
// ═══════════════════════════════════════════════════════════════

class _DayChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isRest;

  const _DayChip({
    required this.label,
    required this.icon,
    required this.isRest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
      decoration: BoxDecoration(
        color: isRest
            ? AppColors.surfaceLight
            : AppColors.primaryMuted,
        borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
        border: Border.all(
          color: isRest
              ? AppColors.border
              : AppColors.primary.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: isRest
                  ? AppColors.textTertiary
                  : AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Icon(
            icon,
            size: 14,
            color: isRest
                ? AppColors.textTertiary
                : AppColors.primary,
          ),
        ],
      ),
    );
  }
}

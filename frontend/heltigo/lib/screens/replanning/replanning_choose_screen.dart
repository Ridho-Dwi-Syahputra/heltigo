/// S-34c: Replanning Step 2/3 — Pilihan Rencana Baru
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-34c
///
/// 2 option cards: Sesuaikan dari Data Sebelumnya (recommended) vs
/// Mulai Ulang Kuesioner (akurasi lebih tinggi).
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';
import '../../widgets/universal/primary_button.dart';

enum _ReplanOption { adjust, restart }

class ReplanningChooseScreen extends StatefulWidget {
  const ReplanningChooseScreen({super.key});

  @override
  State<ReplanningChooseScreen> createState() =>
      _ReplanningChooseScreenState();
}

class _ReplanningChooseScreenState extends State<ReplanningChooseScreen> {
  _ReplanOption _selected = _ReplanOption.adjust;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.textPrimary,
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        title: Text(
          'EVALUASI · LANGKAH 2/3',
          style: AppTextStyles.overline.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Progress bar step
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.base,
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusFull),
                child: LinearProgressIndicator(
                  value: 0.66,
                  minHeight: 4,
                  backgroundColor: AppColors.surfaceLight,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primary),
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
                  Text(
                    'Bagaimana Buat Rencana Baru?',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    'Pilih cara AI menyusun rencana minggu depan. '
                    'Mengisi ulang akan meningkatkan akurasi model.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // ═══════════════════════════════════════
                  // OPTION 1: Sesuaikan dari Data Sebelumnya
                  // ═══════════════════════════════════════
                  _OptionCard(
                    icon: Icons.tune,
                    badgeLabel: 'DIREKOMENDASIKAN',
                    badgeColor: AppColors.success,
                    title: 'Sesuaikan dari Data Sebelumnya',
                    description:
                        'AI menerima ranah 8 preferensi tetap, lalu '
                        'menyesuaikan beberapa hal kecil berdasarkan '
                        'performa minggu ini.',
                    tags: const ['8 Pertanyaan', 'Profil Tetap', 'Cepat'],
                    isSelected: _selected == _ReplanOption.adjust,
                    onTap: () =>
                        setState(() => _selected = _ReplanOption.adjust),
                    accentColor: AppColors.primary,
                  ),
                  const SizedBox(height: AppDimensions.md),

                  // ═══════════════════════════════════════
                  // OPTION 2: Mulai Ulang Kuesioner
                  // ═══════════════════════════════════════
                  _OptionCard(
                    icon: Icons.psychology_alt_outlined,
                    badgeLabel: 'AKURASI LEBIH TINGGI',
                    badgeColor: AppColors.warning,
                    title: 'Mulai Ulang Kuesioner',
                    description:
                        'Jawab kembali pertanyaan setup, preferensi, '
                        'kondisi terbaru. Pilihan ini terbaik untuk '
                        'meningkatkan akurasi rekomendasi minggu ini.',
                    tags: const [
                      '7 Langkah Ulang',
                      'Akurasi +18%',
                      'Lebih Presisi'
                    ],
                    isSelected: _selected == _ReplanOption.restart,
                    onTap: () =>
                        setState(() => _selected = _ReplanOption.restart),
                    accentColor: AppColors.warning,
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // Disclaimer
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusInput,
                      ),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: AppDimensions.sm),
                        Expanded(
                          child: Text(
                            'Disarankan mengulang setiap 4 minggu agar '
                            'model lebih sesuai dengan dirimu.',
                            style: AppTextStyles.caption,
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
              child: Column(
                children: [
                  PrimaryButton(
                    label: _selected == _ReplanOption.restart
                        ? 'Mulai Ulang Kuesioner'
                        : 'Buat Rencana Baru',
                    icon: Icons.arrow_forward,
                    onPressed: () => context.go('/replanning/ready'),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  TextButton(
                    onPressed: () => context.go('/home'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: const Text('Lewati & Pakai Rencana Lama'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// OPTION CARD (radio-like)
// ═══════════════════════════════════════════════════════════════

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String badgeLabel;
  final Color badgeColor;
  final String title;
  final String description;
  final List<String> tags;
  final bool isSelected;
  final VoidCallback onTap;
  final Color accentColor;

  const _OptionCard({
    required this.icon,
    required this.badgeLabel,
    required this.badgeColor,
    required this.title,
    required this.description,
    required this.tags,
    required this.isSelected,
    required this.onTap,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.all(AppDimensions.base),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(
            color: isSelected ? accentColor : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: icon + radio
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusInput,
                    ),
                  ),
                  child: Icon(icon, color: accentColor, size: 22),
                ),
                const Spacer(),
                // Radio indicator
                AnimatedContainer(
                  duration: AppDurations.fast,
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accentColor
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? accentColor
                          : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: AppColors.white,
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),

            // Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.sm + 2,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.18),
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Text(
                badgeLabel,
                style: AppTextStyles.overline.copyWith(
                  color: badgeColor,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.sm),

            // Title
            Text(
              title,
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.xs + 2),

            // Description
            Text(
              description,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.md),

            // Tag chips
            Wrap(
              spacing: AppDimensions.xs + 2,
              runSpacing: AppDimensions.xs,
              children: tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    tag,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

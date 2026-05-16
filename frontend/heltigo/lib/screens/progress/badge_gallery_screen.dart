/// S-28: Badge Gallery — koleksi badge / lencana pencapaian
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-28
///
/// Layout:
/// 1. AppBar
/// 2. Progress header (X dari Y lencana)
/// 3. Filter chips horizontal scrollable
/// 4. GridView 3 kolom badges (locked/unlocked)
/// 5. Tap badge → bottom sheet detail
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';

enum _BadgeCategory { konsistensi, latihan, nutrisi, milestone }

class _Badge {
  final String code;
  final String name;
  final String description;
  final IconData icon;
  final _BadgeCategory category;
  final bool unlocked;
  final String? unlockedAt;
  final String? progressText;

  const _Badge({
    required this.code,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    this.unlocked = false,
    this.unlockedAt,
    this.progressText,
  });
}

class BadgeGalleryScreen extends StatefulWidget {
  const BadgeGalleryScreen({super.key});

  @override
  State<BadgeGalleryScreen> createState() => _BadgeGalleryScreenState();
}

class _BadgeGalleryScreenState extends State<BadgeGalleryScreen> {
  _BadgeCategory? _activeFilter;

  // Mock 24 badges
  static const List<_Badge> _allBadges = [
    // Konsistensi
    _Badge(
      code: 'streak_3',
      name: 'Streak 3',
      description: '3 hari latihan berturut-turut',
      icon: Icons.local_fire_department,
      category: _BadgeCategory.konsistensi,
      unlocked: true,
      unlockedAt: '5 Mei 2026',
    ),
    _Badge(
      code: 'streak_7',
      name: 'Streak 7',
      description: '7 hari latihan berturut-turut',
      icon: Icons.local_fire_department,
      category: _BadgeCategory.konsistensi,
      unlocked: true,
      unlockedAt: '12 Mei 2026',
    ),
    _Badge(
      code: 'streak_14',
      name: 'Streak 14',
      description: '14 hari konsisten',
      icon: Icons.whatshot,
      category: _BadgeCategory.konsistensi,
      progressText: '12/14',
    ),
    _Badge(
      code: 'streak_30',
      name: 'Streak 30',
      description: 'Satu bulan konsisten',
      icon: Icons.whatshot,
      category: _BadgeCategory.konsistensi,
      progressText: '12/30',
    ),
    _Badge(
      code: 'streak_50',
      name: 'Streak 50',
      description: '50 hari tanpa break',
      icon: Icons.whatshot,
      category: _BadgeCategory.konsistensi,
      progressText: '12/50',
    ),
    _Badge(
      code: 'streak_100',
      name: 'Streak 100',
      description: '100 hari konsisten',
      icon: Icons.whatshot,
      category: _BadgeCategory.konsistensi,
      progressText: '12/100',
    ),
    // Latihan
    _Badge(
      code: 'first_workout',
      name: 'Latihan 1',
      description: 'Selesaikan latihan pertama',
      icon: Icons.fitness_center,
      category: _BadgeCategory.latihan,
      unlocked: true,
      unlockedAt: '3 Mei 2026',
    ),
    _Badge(
      code: 'workout_10',
      name: 'Latihan 10',
      description: 'Selesai 10 sesi latihan',
      icon: Icons.fitness_center,
      category: _BadgeCategory.latihan,
      unlocked: true,
      unlockedAt: '14 Mei 2026',
    ),
    _Badge(
      code: 'workout_50',
      name: 'Latihan 50',
      description: 'Selesai 50 sesi latihan',
      icon: Icons.military_tech,
      category: _BadgeCategory.latihan,
      progressText: '42/50',
    ),
    _Badge(
      code: 'workout_100',
      name: 'Latihan 100',
      description: 'Centurion fitness',
      icon: Icons.workspace_premium,
      category: _BadgeCategory.latihan,
      progressText: '42/100',
    ),
    _Badge(
      code: 'morning_5',
      name: 'Pagi 5',
      description: '5x latihan sebelum jam 8',
      icon: Icons.wb_twilight,
      category: _BadgeCategory.latihan,
      unlocked: true,
      unlockedAt: '10 Mei 2026',
    ),
    _Badge(
      code: 'morning_20',
      name: 'Pagi 20',
      description: '20x latihan pagi',
      icon: Icons.wb_sunny_outlined,
      category: _BadgeCategory.latihan,
      progressText: '5/20',
    ),
    // Nutrisi
    _Badge(
      code: 'meal_7d',
      name: 'Makan 7 Hari',
      description: '7 hari makan sesuai rencana',
      icon: Icons.restaurant,
      category: _BadgeCategory.nutrisi,
      unlocked: true,
      unlockedAt: '11 Mei 2026',
    ),
    _Badge(
      code: 'budget_master',
      name: 'Budget Master',
      description: 'Tetap dalam budget 1 minggu',
      icon: Icons.savings_outlined,
      category: _BadgeCategory.nutrisi,
      progressText: '5/7',
    ),
    _Badge(
      code: 'hydration_8',
      name: 'Hidrasi 8',
      description: 'Minum 8 gelas dalam 1 hari',
      icon: Icons.water_drop,
      category: _BadgeCategory.nutrisi,
      unlocked: true,
      unlockedAt: '8 Mei 2026',
    ),
    _Badge(
      code: 'hydration_7d',
      name: 'Hidrasi 7 Hari',
      description: '7 hari target hidrasi tercapai',
      icon: Icons.water_drop_outlined,
      category: _BadgeCategory.nutrisi,
      progressText: '4/7',
    ),
    _Badge(
      code: 'protein_pro',
      name: 'Protein Pro',
      description: 'Target protein 14 hari berturut',
      icon: Icons.egg_outlined,
      category: _BadgeCategory.nutrisi,
      progressText: '6/14',
    ),
    _Badge(
      code: 'veggie',
      name: 'Veggie Lover',
      description: 'Konsumsi sayur 10 hari',
      icon: Icons.eco_outlined,
      category: _BadgeCategory.nutrisi,
      progressText: '4/10',
    ),
    // Milestone
    _Badge(
      code: 'first_target',
      name: 'Target 1',
      description: 'Capai milestone berat pertama',
      icon: Icons.flag,
      category: _BadgeCategory.milestone,
      progressText: '60%',
    ),
    _Badge(
      code: 'weight_5kg',
      name: '-5 kg',
      description: 'Turun 5 kg dari berat awal',
      icon: Icons.trending_down,
      category: _BadgeCategory.milestone,
      progressText: '3.8/5',
    ),
    _Badge(
      code: 'weight_10kg',
      name: '-10 kg',
      description: 'Turun 10 kg total',
      icon: Icons.trending_down,
      category: _BadgeCategory.milestone,
      progressText: '3.8/10',
    ),
    _Badge(
      code: 'master',
      name: 'Master',
      description: 'Capai goal akhir!',
      icon: Icons.emoji_events,
      category: _BadgeCategory.milestone,
      progressText: 'Locked',
    ),
    _Badge(
      code: 'level_up',
      name: 'Level Up',
      description: 'Naikkan level kebugaran',
      icon: Icons.upgrade,
      category: _BadgeCategory.milestone,
      progressText: 'Locked',
    ),
    _Badge(
      code: 'comeback',
      name: 'Comeback',
      description: 'Mulai lagi setelah istirahat',
      icon: Icons.refresh,
      category: _BadgeCategory.milestone,
      unlocked: true,
      unlockedAt: '7 Mei 2026',
    ),
  ];

  List<_Badge> get _filtered {
    if (_activeFilter == null) return _allBadges;
    return _allBadges.where((b) => b.category == _activeFilter).toList();
  }

  int get _unlockedCount => _allBadges.where((b) => b.unlocked).length;

  void _showBadgeDetail(_Badge badge) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusBottomSheetTop),
        ),
      ),
      builder: (ctx) => _BadgeDetailSheet(badge: badge),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

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
        title: Text('Lencana Pencapaian', style: AppTextStyles.h3),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.base,
                0,
                AppDimensions.base,
                AppDimensions.sm,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.base),
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusCard),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: AppTextStyles.body,
                              children: [
                                TextSpan(
                                  text: '$_unlockedCount',
                                  style: AppTextStyles.h2.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                TextSpan(
                                  text: ' dari ${_allBadges.length} lencana',
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppDimensions.xs),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusFull,
                            ),
                            child: LinearProgressIndicator(
                              value: _unlockedCount / _allBadges.length,
                              minHeight: 4,
                              backgroundColor: AppColors.surfaceLight,
                              valueColor: const AlwaysStoppedAnimation(
                                AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Filter chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.base,
                ),
                children: [
                  _FilterChip(
                    label: 'Semua',
                    active: _activeFilter == null,
                    onTap: () => setState(() => _activeFilter = null),
                  ),
                  _FilterChip(
                    label: 'Konsistensi',
                    active: _activeFilter == _BadgeCategory.konsistensi,
                    onTap: () => setState(
                      () => _activeFilter = _BadgeCategory.konsistensi,
                    ),
                  ),
                  _FilterChip(
                    label: 'Latihan',
                    active: _activeFilter == _BadgeCategory.latihan,
                    onTap: () => setState(
                      () => _activeFilter = _BadgeCategory.latihan,
                    ),
                  ),
                  _FilterChip(
                    label: 'Nutrisi',
                    active: _activeFilter == _BadgeCategory.nutrisi,
                    onTap: () => setState(
                      () => _activeFilter = _BadgeCategory.nutrisi,
                    ),
                  ),
                  _FilterChip(
                    label: 'Milestone',
                    active: _activeFilter == _BadgeCategory.milestone,
                    onTap: () => setState(
                      () => _activeFilter = _BadgeCategory.milestone,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.sm),

            // Badge grid
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.fromLTRB(
                  AppDimensions.base,
                  AppDimensions.xs,
                  AppDimensions.base,
                  AppDimensions.lg + MediaQuery.of(context).padding.bottom,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.82,
                  mainAxisSpacing: AppDimensions.sm,
                  crossAxisSpacing: AppDimensions.sm,
                ),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final badge = filtered[i];
                  return _BadgeTile(
                    badge: badge,
                    onTap: () => _showBadgeDetail(badge),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// FILTER CHIP
// ═══════════════════════════════════════════════════════════════

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppDimensions.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.base,
            vertical: AppDimensions.sm,
          ),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            border: Border.all(
              color: active ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: active
                    ? AppColors.textOnPrimary
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BADGE TILE
// ═══════════════════════════════════════════════════════════════

class _BadgeTile extends StatelessWidget {
  final _Badge badge;
  final VoidCallback onTap;

  const _BadgeTile({required this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isUnlocked = badge.unlocked;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.sm),
        decoration: BoxDecoration(
          color:
              isUnlocked ? AppColors.primaryMuted : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(
            color: isUnlocked
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.border,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? AppColors.primary.withValues(alpha: 0.25)
                        : AppColors.surfaceLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    badge.icon,
                    size: 28,
                    color: isUnlocked
                        ? AppColors.primary
                        : AppColors.textTertiary,
                  ),
                ),
                if (!isUnlocked)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(
                        Icons.lock,
                        size: 10,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.xs),
            Flexible(
              child: Text(
                badge.name,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isUnlocked
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isUnlocked ? 'Selesai' : (badge.progressText ?? '—'),
              style: AppTextStyles.caption.copyWith(
                color: isUnlocked
                    ? AppColors.success
                    : AppColors.textTertiary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BADGE DETAIL BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════

class _BadgeDetailSheet extends StatelessWidget {
  final _Badge badge;

  const _BadgeDetailSheet({required this.badge});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.base),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: badge.unlocked
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                badge.icon,
                size: 44,
                color: badge.unlocked
                    ? AppColors.primary
                    : AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            Text(badge.name, style: AppTextStyles.h2),
            const SizedBox(height: AppDimensions.xs),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.base,
              ),
              child: Text(
                badge.description,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.base,
                vertical: AppDimensions.sm,
              ),
              decoration: BoxDecoration(
                color: badge.unlocked
                    ? AppColors.success.withValues(alpha: 0.15)
                    : AppColors.surfaceLight,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    badge.unlocked
                        ? Icons.check_circle
                        : Icons.hourglass_empty,
                    size: 14,
                    color: badge.unlocked
                        ? AppColors.success
                        : AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    badge.unlocked
                        ? 'Selesai · ${badge.unlockedAt}'
                        : 'Belum tercapai · ${badge.progressText ?? "—"}',
                    style: AppTextStyles.caption.copyWith(
                      color: badge.unlocked
                          ? AppColors.success
                          : AppColors.textTertiary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        ),
      ),
    );
  }
}

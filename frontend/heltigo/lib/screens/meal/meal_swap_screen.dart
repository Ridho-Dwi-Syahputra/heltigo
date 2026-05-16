/// S-XX: Meal Swap Screen — pilih makanan pengganti
/// Sumber: docs/frontend/05_SCREENS_SPEC.md
/// API: POST /meal/:id/swap
///
/// Layout:
/// 1. AppBar dengan close icon
/// 2. Section "MENU SAAT INI" + Current food card (badge DIGANTI)
/// 3. Section "PILIH PENGGANTI" + filter chips
/// 4. List of 4-5 alternative foods dengan delta badge
/// 5. AI context card di bawah
/// 6. Sticky bottom: Batal
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';
import '../../widgets/meal/ai_context_card.dart';
import '../../widgets/setup/chip_multi_select.dart';
import '../../widgets/universal/secondary_button.dart';

/// Mock data untuk alternatif makanan
class _AlternativeFood {
  final String id;
  final String name;
  final String portion;
  final int kcal;
  final int proteinG;
  final int priceIdr;
  final bool isVegetarian;
  final IconData icon;

  // Catatan: semua mock alternatif saat ini halal (dataset Indonesia).
  // Field `isHalal` di-hardcode true di tag badge; tidak perlu param.

  const _AlternativeFood({
    required this.id,
    required this.name,
    required this.portion,
    required this.kcal,
    required this.proteinG,
    required this.priceIdr,
    required this.icon,
    this.isVegetarian = false,
  });
}

class MealSwapScreen extends StatefulWidget {
  final String mealId;

  const MealSwapScreen({super.key, required this.mealId});

  @override
  State<MealSwapScreen> createState() => _MealSwapScreenState();
}

class _MealSwapScreenState extends State<MealSwapScreen> {
  // ─── Mock current food (the one being replaced) ───
  static const String _currentName = 'Ayam Bakar';
  static const String _currentPortion = '1 potong (150 g)';
  static const int _currentKcal = 280;
  static const int _currentProtein = 32;
  static const int _currentPrice = 12000;

  // ─── Filter chips state ───
  Set<int> _activeFilters = {0}; // Default: Halal aktif

  static const List<ChipOption> _filterOptions = [
    ChipOption(label: 'Halal', icon: Icons.brightness_2_outlined),
    ChipOption(label: 'Vegetarian', icon: Icons.eco_outlined),
    ChipOption(label: 'Budget ≤ Rp 15K', icon: Icons.payments_outlined),
  ];

  // ─── Mock alternative foods ───
  static const List<_AlternativeFood> _allAlternatives = [
    _AlternativeFood(
      id: 'food-dada-ayam',
      name: 'Dada Ayam Panggang',
      portion: '1 potong (150 g)',
      kcal: 250,
      proteinG: 30,
      priceIdr: 14000,
      icon: Icons.restaurant_outlined,
    ),
    _AlternativeFood(
      id: 'food-ikan-patin',
      name: 'Ikan Patin Panggang',
      portion: '1 potong (140 g)',
      kcal: 210,
      proteinG: 28,
      priceIdr: 10000,
      icon: Icons.set_meal_outlined,
    ),
    _AlternativeFood(
      id: 'food-tempe-goreng',
      name: 'Tempe Goreng',
      portion: '3 potong (90 g)',
      kcal: 190,
      proteinG: 18,
      priceIdr: 5000,
      isVegetarian: true,
      icon: Icons.spa_outlined,
    ),
    _AlternativeFood(
      id: 'food-telur-ceplok',
      name: 'Telur Ceplok',
      portion: '2 butir (100 g)',
      kcal: 155,
      proteinG: 13,
      priceIdr: 4000,
      isVegetarian: true,
      icon: Icons.egg_outlined,
    ),
    _AlternativeFood(
      id: 'food-tahu-bacem',
      name: 'Tahu Bacem',
      portion: '3 potong (100 g)',
      kcal: 145,
      proteinG: 14,
      priceIdr: 4500,
      isVegetarian: true,
      icon: Icons.eco_outlined,
    ),
  ];

  List<_AlternativeFood> get _filteredAlternatives {
    return _allAlternatives.where((f) {
      // Filter "Halal" (index 0) — semua mock data halal, jadi always pass.
      // Filter "Vegetarian" (index 1)
      if (_activeFilters.contains(1) && !f.isVegetarian) return false;
      // Filter "Budget ≤ Rp 15K" (index 2)
      if (_activeFilters.contains(2) && f.priceIdr > 15000) return false;
      return true;
    }).toList();
  }

  String _formatThousand(int v) {
    return v.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }

  String _formatPrice(int idr) {
    if (idr == 0) return 'Gratis';
    if (idr >= 1000) {
      final k = idr / 1000;
      if (k == k.roundToDouble()) return 'Rp ${k.toInt()}K';
      return 'Rp ${k.toStringAsFixed(1)}K';
    }
    return 'Rp $idr';
  }

  /// Format delta dengan sign (+/−) — mengembalikan teks dan warna.
  ({String text, Color color, IconData icon}) _formatDelta({
    required int currentValue,
    required int newValue,
    required String unit,
    required bool lowerIsBetter,
  }) {
    final delta = newValue - currentValue;
    if (delta == 0) {
      return (
        text: '0 $unit',
        color: AppColors.textTertiary,
        icon: Icons.remove,
      );
    }
    final sign = delta > 0 ? '+' : '−';
    final absDelta = delta.abs();
    final isBetter = lowerIsBetter ? delta < 0 : delta > 0;
    final color = isBetter ? AppColors.success : AppColors.warning;
    final icon = delta > 0 ? Icons.arrow_upward : Icons.arrow_downward;
    return (
      text: '$sign$absDelta $unit',
      color: color,
      icon: icon,
    );
  }

  Future<void> _confirmSwap(_AlternativeFood food) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ganti ke ${food.name}?', style: AppTextStyles.h3),
        content: Text(
          'Menu "$_currentName" akan diganti dengan "${food.name}". '
          'AI akan menyesuaikan kandungan gizi & budget meal kamu.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
            child: const Text('Ya, Ganti'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Menu diganti dengan ${food.name}'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.success.withValues(alpha: 0.9),
        ),
      );
      if (context.canPop()) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final alternatives = _filteredAlternatives;

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
        title: Text('Ganti Makanan', style: AppTextStyles.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            color: AppColors.textPrimary,
            iconSize: 20,
            tooltip: 'Tutup',
            onPressed: () {
              if (context.canPop()) context.pop();
            },
          ),
          const SizedBox(width: AppDimensions.xs),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.base,
                  vertical: AppDimensions.sm,
                ),
                children: [
                  // ═══════════════════════════════════════
                  // 1. MENU SAAT INI
                  // ═══════════════════════════════════════
                  Text(
                    'MENU SAAT INI',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  _CurrentFoodCard(
                    name: _currentName,
                    portion: _currentPortion,
                    kcal: _currentKcal,
                    priceText: 'Rp ${_formatThousand(_currentPrice)}',
                  ),
                  const SizedBox(height: AppDimensions.xl),

                  // ═══════════════════════════════════════
                  // 2. PILIH PENGGANTI
                  // ═══════════════════════════════════════
                  Text(
                    'PILIH PENGGANTI',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xs + 2),
                  Text(
                    'Pilih makanan dengan nutrisi serupa dalam budget kamu.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),

                  // Filter chips
                  ChipMultiSelect(
                    options: _filterOptions,
                    selectedIndices: _activeFilters,
                    onChanged: (next) =>
                        setState(() => _activeFilters = next),
                  ),
                  const SizedBox(height: AppDimensions.md),

                  // ═══════════════════════════════════════
                  // 3. ALTERNATIVE FOODS LIST
                  // ═══════════════════════════════════════
                  if (alternatives.isEmpty)
                    _EmptyAlternatives(onResetFilters: () {
                      setState(() => _activeFilters = {});
                    })
                  else
                    ...alternatives.map((food) {
                      final kcalDelta = _formatDelta(
                        currentValue: _currentKcal,
                        newValue: food.kcal,
                        unit: 'kkal',
                        lowerIsBetter: true,
                      );
                      final proteinDelta = _formatDelta(
                        currentValue: _currentProtein,
                        newValue: food.proteinG,
                        unit: 'g protein',
                        lowerIsBetter: false,
                      );
                      final priceDelta = _formatDelta(
                        currentValue: _currentPrice ~/ 1000,
                        newValue: food.priceIdr ~/ 1000,
                        unit: 'rb',
                        lowerIsBetter: true,
                      );
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.sm,
                        ),
                        child: _AlternativeCard(
                          food: food,
                          priceText: _formatPrice(food.priceIdr),
                          kcalDelta: kcalDelta,
                          proteinDelta: proteinDelta,
                          priceDelta: priceDelta,
                          onTap: () => _confirmSwap(food),
                        ),
                      );
                    }),
                  const SizedBox(height: AppDimensions.lg),

                  // ═══════════════════════════════════════
                  // 4. AI CONTEXT
                  // ═══════════════════════════════════════
                  const AiContextCard(
                    title: 'BAGAIMANA AI MEMILIH PENGGANTI?',
                    body:
                        'AI menyaring berdasarkan profil makro, budget, dan '
                        'pantangan dietmu. Pengganti dirancang agar total '
                        'kalori harian tetap on-track.',
                  ),
                ],
              ),
            ),

            // ═══════════════════════════════════════
            // 5. STICKY BOTTOM
            // ═══════════════════════════════════════
            Container(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.base,
                AppDimensions.sm,
                AppDimensions.base,
                AppDimensions.base + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(color: AppColors.divider, width: 1),
                ),
              ),
              child: SecondaryButton(
                label: 'Batal',
                onPressed: () {
                  if (context.canPop()) context.pop();
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
// CURRENT FOOD CARD — menu yang sedang diganti (badge DIGANTI)
// ═══════════════════════════════════════════════════════════════

class _CurrentFoodCard extends StatelessWidget {
  final String name;
  final String portion;
  final int kcal;
  final String priceText;

  const _CurrentFoodCard({
    required this.name,
    required this.portion,
    required this.kcal,
    required this.priceText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.base),
      decoration: BoxDecoration(
        color: AppColors.warningMuted,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
            ),
            child: const Icon(
              Icons.swap_horiz,
              color: AppColors.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.sm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                      child: Text(
                        'DIGANTI',
                        style: AppTextStyles.overline.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$portion · $kcal kkal · $priceText',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ALTERNATIVE CARD — kandidat pengganti dengan delta info
// ═══════════════════════════════════════════════════════════════

class _AlternativeCard extends StatelessWidget {
  final _AlternativeFood food;
  final String priceText;
  final ({String text, Color color, IconData icon}) kcalDelta;
  final ({String text, Color color, IconData icon}) proteinDelta;
  final ({String text, Color color, IconData icon}) priceDelta;
  final VoidCallback onTap;

  const _AlternativeCard({
    required this.food,
    required this.priceText,
    required this.kcalDelta,
    required this.proteinDelta,
    required this.priceDelta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.base),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: icon + name + price
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusInput),
                  ),
                  child: Icon(
                    food.icon,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        food.name,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${food.portion} · ${food.kcal} kkal',
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.sm),
                Text(
                  priceText,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sm + 2),

            // Delta badges row
            Wrap(
              spacing: AppDimensions.xs + 2,
              runSpacing: AppDimensions.xs,
              children: [
                _DeltaBadge(
                  text: kcalDelta.text,
                  color: kcalDelta.color,
                  icon: kcalDelta.icon,
                ),
                _DeltaBadge(
                  text: proteinDelta.text,
                  color: proteinDelta.color,
                  icon: proteinDelta.icon,
                ),
                _DeltaBadge(
                  text: priceDelta.text,
                  color: priceDelta.color,
                  icon: priceDelta.icon,
                ),
                if (food.isVegetarian)
                  _TagBadge(
                    label: 'Vegetarian',
                    color: AppColors.success,
                    icon: Icons.eco_outlined,
                  ),
                // Semua mock data halal (Indonesian food dataset).
                _TagBadge(
                  label: 'Halal',
                  color: AppColors.primary,
                  icon: Icons.verified_outlined,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sm + 2),

            // CTA
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Ganti ke ini',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.primary,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DELTA BADGE — compact chip dengan icon + value berwarna
// ═══════════════════════════════════════════════════════════════

class _DeltaBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;

  const _DeltaBadge({
    required this.text,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.xs + 2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 2),
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAG BADGE — info tag (Halal, Vegetarian, dll)
// ═══════════════════════════════════════════════════════════════

class _TagBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _TagBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.xs + 2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// EMPTY ALTERNATIVES — saat filter terlalu ketat
// ═══════════════════════════════════════════════════════════════

class _EmptyAlternatives extends StatelessWidget {
  final VoidCallback onResetFilters;

  const _EmptyAlternatives({required this.onResetFilters});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            'Tidak ada pengganti yang cocok',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            'Coba lepas beberapa filter untuk melihat lebih banyak opsi.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          TextButton.icon(
            onPressed: onResetFilters,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reset Filter'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

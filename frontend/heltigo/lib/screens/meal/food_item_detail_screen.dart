/// S-24: Food Item Detail Screen — detail satu menu makanan
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-24
///
/// Layout:
/// 1. AppBar dengan bookmark action
/// 2. Category badge
/// 3. Image placeholder (icon besar)
/// 4. Harga estimasi card
/// 5. NutritionDonutChart (4 macro per 100g)
/// 6. Porsi standar info
/// 7. AiContextCard
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';
import '../../widgets/meal/ai_context_card.dart';
import '../../widgets/meal/nutrition_donut_chart.dart';

class FoodItemDetailScreen extends StatefulWidget {
  final String foodId;

  const FoodItemDetailScreen({super.key, required this.foodId});

  @override
  State<FoodItemDetailScreen> createState() => _FoodItemDetailScreenState();
}

class _FoodItemDetailScreenState extends State<FoodItemDetailScreen> {
  bool _isBookmarked = false;

  // ─── Mock data (mapping foodId → details) ───
  String get _foodName {
    if (widget.foodId.contains('nasi')) return 'Nasi Putih';
    if (widget.foodId.contains('sayur')) return 'Sayur Asem';
    if (widget.foodId.contains('teh')) return 'Teh Tawar';
    return 'Ayam Bakar';
  }

  String get _category {
    if (widget.foodId.contains('nasi')) return 'STAPLE';
    if (widget.foodId.contains('sayur')) return 'SAYUR';
    if (widget.foodId.contains('teh')) return 'MINUMAN';
    return 'LAUK';
  }

  Color get _categoryColor {
    switch (_category) {
      case 'STAPLE':
        return AppColors.warning;
      case 'SAYUR':
        return AppColors.success;
      case 'MINUMAN':
        return AppColors.info;
      case 'LAUK':
      default:
        return AppColors.accent;
    }
  }

  int get _priceIdr => 12000;
  int get _kcalPer100g => 280;
  String get _portion => 'Porsi standar: 120 gram / 1 potong';

  static const _macroSegments = [
    MacroSegment(label: 'Protein', grams: 32, color: AppColors.primary),
    MacroSegment(label: 'Karbo', grams: 4, color: AppColors.warning),
    MacroSegment(label: 'Lemak', grams: 14, color: AppColors.streakPurple),
    MacroSegment(label: 'Serat', grams: 0, color: AppColors.info),
  ];

  String _formatThousand(int v) {
    return v.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }

  void _toggleBookmark() {
    setState(() => _isBookmarked = !_isBookmarked);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isBookmarked
            ? 'Disimpan ke favorit'
            : 'Dihapus dari favorit'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

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
        title: Text(_foodName, style: AppTextStyles.h3),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              size: 20,
            ),
            color: _isBookmarked ? AppColors.accent : AppColors.textPrimary,
            onPressed: _toggleBookmark,
            tooltip: 'Simpan',
          ),
          const SizedBox(width: AppDimensions.xs),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.only(
            left: AppDimensions.base,
            right: AppDimensions.base,
            top: AppDimensions.sm,
            bottom: AppDimensions.xxxl + MediaQuery.of(context).padding.bottom,
          ),
          children: [
            // ═══════════════════════════════════════
            // 1. CATEGORY BADGE
            // ═══════════════════════════════════════
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sm + 2,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _categoryColor.withValues(alpha: 0.15),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(
                    color: _categoryColor.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_offer_outlined,
                      size: 12,
                      color: _categoryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _category,
                      style: AppTextStyles.overline.copyWith(
                        color: _categoryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.md),

            // ═══════════════════════════════════════
            // 2. IMAGE PLACEHOLDER
            // ═══════════════════════════════════════
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusCard),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 64,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.base),

            // ═══════════════════════════════════════
            // 3. HARGA CARD
            // ═══════════════════════════════════════
            Container(
              padding: const EdgeInsets.all(AppDimensions.base),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.payments_outlined,
                      color: AppColors.accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Harga estimasi',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rp ${_formatThousand(_priceIdr)}',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'per porsi · harga pasar rata-rata',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            // ═══════════════════════════════════════
            // 4. NUTRISI (donut chart)
            // ═══════════════════════════════════════
            Text(
              'NUTRISI (PER 100 G)',
              style: AppTextStyles.overline.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            Container(
              padding: const EdgeInsets.all(AppDimensions.base),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                border: Border.all(color: AppColors.border),
              ),
              child: NutritionDonutChart(
                kcal: _kcalPer100g,
                segments: _macroSegments,
              ),
            ),
            const SizedBox(height: AppDimensions.base),

            // ═══════════════════════════════════════
            // 5. PORSI STANDAR
            // ═══════════════════════════════════════
            Container(
              padding: const EdgeInsets.all(AppDimensions.base),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusInput),
                    ),
                    child: const Icon(
                      Icons.straighten,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: Text(
                      _portion,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            // ═══════════════════════════════════════
            // 6. AI CONTEXT CARD
            // ═══════════════════════════════════════
            const AiContextCard(
              title: 'KONTEKS AI',
              body:
                  'Sumber protein hewani terjangkau di Indonesia. Cocok untuk '
                  'goal penurunan berat dengan budget terbatas. Pilih bagian '
                  'dada untuk lemak lebih rendah.',
            ),
          ],
        ),
      ),
    );
  }
}

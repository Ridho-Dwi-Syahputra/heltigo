/// S-23: Meal Detail Screen — detail satu waktu makan
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-23
///
/// Layout:
/// 1. AppBar dengan refresh action
/// 2. Header card status (BELUM / SUDAH / AKTIF) + meta
/// 3. Food list (vertical, tap → food detail)
/// 4. Kandungan Gizi: stacked bar
/// 5. AI context card
/// 6. Sticky bottom actions: Tandai + Minta Alternatif
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';
import '../../widgets/meal/ai_context_card.dart';
import '../../widgets/meal/macro_stacked_bar.dart';
import '../../widgets/meal/nutrition_donut_chart.dart' show MacroSegment;
import '../../widgets/universal/primary_button.dart';
import '../../widgets/universal/secondary_button.dart';

enum _MealStatus { pending, active, completed }

class _FoodItem {
  final String id;
  final String name;
  final String portion;
  final int kcal;
  final int priceIdr;

  const _FoodItem({
    required this.id,
    required this.name,
    required this.portion,
    required this.kcal,
    required this.priceIdr,
  });
}

class MealDetailScreen extends StatefulWidget {
  final String mealId;

  const MealDetailScreen({super.key, required this.mealId});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  _MealStatus _status = _MealStatus.active;

  // ─── Mock data ───
  String get _mealName {
    if (widget.mealId.startsWith('breakfast')) return 'Sarapan';
    if (widget.mealId.startsWith('dinner')) return 'Makan Malam';
    return 'Makan Siang';
  }

  String get _mealTime {
    if (widget.mealId.startsWith('breakfast')) return '07:00';
    if (widget.mealId.startsWith('dinner')) return '19:00';
    return '12:30';
  }

  static const _foods = [
    _FoodItem(
      id: 'food-ayam-bakar',
      name: 'Ayam Bakar',
      portion: '1 potong (150 g)',
      kcal: 280,
      priceIdr: 12000,
    ),
    _FoodItem(
      id: 'food-nasi-putih',
      name: 'Nasi Putih',
      portion: '1 piring (200 g)',
      kcal: 195,
      priceIdr: 3000,
    ),
    _FoodItem(
      id: 'food-sayur-asem',
      name: 'Sayur Asem',
      portion: '1 mangkuk',
      kcal: 88,
      priceIdr: 2000,
    ),
    _FoodItem(
      id: 'food-teh-tawar',
      name: 'Teh Tawar',
      portion: '1 gelas',
      kcal: 5,
      priceIdr: 0,
    ),
  ];

  static const _macroSegments = [
    MacroSegment(label: 'Protein', grams: 38, color: AppColors.primary),
    MacroSegment(label: 'Karbo', grams: 62, color: AppColors.warning),
    MacroSegment(label: 'Lemak', grams: 18, color: AppColors.streakPurple),
  ];

  int get _totalKcal => _foods.fold(0, (s, f) => s + f.kcal);
  int get _totalPrice => _foods.fold(0, (s, f) => s + f.priceIdr);

  String _formatThousand(int v) {
    return v.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }

  void _markAsEaten() {
    setState(() => _status = _MealStatus.completed);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Meal ditandai sudah dimakan'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _requestAlternative() {
    context.push('/meal/swap/${widget.mealId}');
  }

  String get _statusLabel {
    switch (_status) {
      case _MealStatus.pending:
        return 'BELUM';
      case _MealStatus.active:
        return 'AKTIF';
      case _MealStatus.completed:
        return 'SELESAI';
    }
  }

  Color get _statusColor {
    switch (_status) {
      case _MealStatus.pending:
        return AppColors.textTertiary;
      case _MealStatus.active:
        return AppColors.accent;
      case _MealStatus.completed:
        return AppColors.success;
    }
  }

  String get _statusSubtitle {
    switch (_status) {
      case _MealStatus.pending:
        return '$_mealTime · belum dimakan';
      case _MealStatus.active:
        return '$_mealTime · waktu makan!';
      case _MealStatus.completed:
        return '$_mealTime · sudah dimakan';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.textPrimary,
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        title: Text(_mealName, style: AppTextStyles.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            color: AppColors.textPrimary,
            iconSize: 20,
            onPressed: _requestAlternative,
            tooltip: 'Minta alternatif',
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
                  // 1. STATUS HEADER CARD
                  // ═══════════════════════════════════════
                  _StatusHeaderCard(
                    statusLabel: _statusLabel,
                    statusColor: _statusColor,
                    subtitle: _statusSubtitle,
                    totalKcal: _totalKcal,
                    totalPrice: _formatThousand(_totalPrice),
                  ),
                  const SizedBox(height: AppDimensions.base),

                  // ═══════════════════════════════════════
                  // 2. FOODS LIST
                  // ═══════════════════════════════════════
                  ..._foods.map((food) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppDimensions.sm),
                      child: _FoodRowCard(
                        food: food,
                        onTap: () => context.push('/meal/food/${food.id}'),
                      ),
                    );
                  }),
                  const SizedBox(height: AppDimensions.base),

                  // ═══════════════════════════════════════
                  // 3. KANDUNGAN GIZI
                  // ═══════════════════════════════════════
                  Text(
                    'KANDUNGAN GIZI',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.base),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusCard),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const MacroStackedBar(segments: _macroSegments),
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // ═══════════════════════════════════════
                  // 4. AI CONTEXT CARD
                  // ═══════════════════════════════════════
                  const AiContextCard(
                    title: 'KENAPA AI MEMILIH INI?',
                    body:
                        'Tinggi protein untuk recovery latihan, sesuai budget '
                        'Rp 15K, dan halal. Karbo cukup untuk energi sore '
                        'tanpa berlebihan.',
                  ),
                  const SizedBox(height: AppDimensions.xl),
                ],
              ),
            ),

            // ═══════════════════════════════════════
            // 5. STICKY BOTTOM ACTIONS
            // ═══════════════════════════════════════
            Container(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.base,
                AppDimensions.sm,
                AppDimensions.base,
                AppDimensions.base + MediaQuery.of(context).padding.bottom,
              ),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(color: AppColors.divider, width: 1),
                ),
              ),
              child: Column(
                children: [
                  PrimaryButton(
                    label: _status == _MealStatus.completed
                        ? 'Sudah Selesai'
                        : 'Tandai Sudah Dimakan',
                    icon: _status == _MealStatus.completed
                        ? Icons.check_circle
                        : Icons.check,
                    onPressed: _status == _MealStatus.completed
                        ? null
                        : _markAsEaten,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  SecondaryButton(
                    label: 'Minta Alternatif',
                    icon: Icons.swap_horiz,
                    onPressed: _requestAlternative,
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
// STATUS HEADER CARD
// ═══════════════════════════════════════════════════════════════

class _StatusHeaderCard extends StatelessWidget {
  final String statusLabel;
  final Color statusColor;
  final String subtitle;
  final int totalKcal;
  final String totalPrice;

  const _StatusHeaderCard({
    required this.statusLabel,
    required this.statusColor,
    required this.subtitle,
    required this.totalKcal,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.base),
      decoration: BoxDecoration(
        color: AppColors.primaryMuted,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  statusLabel,
                  style: AppTextStyles.overline.copyWith(
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                totalKcal.toString(),
                style: AppTextStyles.numberBold.copyWith(
                  fontSize: 36,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppDimensions.xs),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'kkal',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sm + 2,
                  vertical: AppDimensions.xs + 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.payments_outlined,
                      size: 14,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Rp $totalPrice',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// FOOD ROW CARD
// ═══════════════════════════════════════════════════════════════

class _FoodRowCard extends StatelessWidget {
  final _FoodItem food;
  final VoidCallback onTap;

  const _FoodRowCard({required this.food, required this.onTap});

  String _formatPrice(int idr) {
    if (idr == 0) return 'Gratis';
    if (idr >= 1000) {
      final k = idr / 1000;
      if (k == k.roundToDouble()) return 'Rp ${k.toInt()}K';
      return 'Rp ${k.toStringAsFixed(1)}K';
    }
    return 'Rp $idr';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusInput),
              ),
              child: const Icon(
                Icons.restaurant_outlined,
                color: AppColors.primary,
                size: 18,
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
                      fontWeight: FontWeight.w600,
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
              _formatPrice(food.priceIdr),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: AppDimensions.xs),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

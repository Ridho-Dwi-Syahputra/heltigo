/// S-22: Meal List Screen — Tab 3 Nutrisi
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-22
///
/// Layout (top-down):
/// 1. Header inline: "Rencana Makanku" + calendar icon
/// 2. DateNavigator (prev / today / next)
/// 3. BudgetProgressCard (tap → Budget Settings)
/// 4. MacroSummaryRow (4 macros)
/// 5. Section header "Menu Hari Ini"
/// 6. 3x MealSectionCard (Sarapan / Siang / Malam)
/// 7. Hydration card (8 glasses)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../styles/styles.dart';
import '../../widgets/home/water_glasses_row.dart';
import '../../widgets/meal/budget_progress_card.dart';
import '../../widgets/meal/date_navigator.dart';
import '../../widgets/meal/macro_summary_row.dart';
import '../../widgets/meal/meal_section_card.dart';

class MealListScreen extends StatefulWidget {
  const MealListScreen({super.key});

  @override
  State<MealListScreen> createState() => _MealListScreenState();
}

class _MealListScreenState extends State<MealListScreen> {
  // ─── Plan window state ───
  // Plan berlaku 7 hari sejak start date.
  // MOCK: plan dimulai hari ini. Provider integration nanti.
  late final DateTime _planStartDate;
  late final DateTime _planEndDate;
  late DateTime _selectedDate;

  int _waterGlasses = 5;
  static const int _waterTarget = 8;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _planStartDate = DateTime(now.year, now.month, now.day);
    _planEndDate = _planStartDate.add(const Duration(days: 6));
    _selectedDate = _planStartDate;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool get _canGoPrev => _selectedDate.isAfter(_planStartDate);
  bool get _canGoNext => !_isSameDay(_selectedDate, _planEndDate);

  int get _planDayNumber =>
      _selectedDate.difference(_planStartDate).inDays + 1;

  String get _planRangeLabel {
    final start = DateFormat('d', 'id_ID').format(_planStartDate);
    final end = DateFormat('d MMM', 'id_ID').format(_planEndDate);
    return '$start – $end';
  }

  // ─── Mock data ───
  static const int _budgetSpent = 22500;
  static const int _budgetTotal = 35000;

  static const _macros = [
    MacroSummaryItem(
      label: 'Kalori',
      current: 1475,
      target: 1820,
      unit: 'kkal',
      color: AppColors.accent,
    ),
    MacroSummaryItem(
      label: 'Protein',
      current: 78,
      target: 120,
      unit: 'g',
      color: AppColors.primary,
    ),
    MacroSummaryItem(
      label: 'Karbo',
      current: 165,
      target: 220,
      unit: 'g',
      color: AppColors.warning,
    ),
    MacroSummaryItem(
      label: 'Lemak',
      current: 42,
      target: 80,
      unit: 'g',
      color: AppColors.streakPurple,
    ),
  ];

  void _goToPrevDay() {
    if (!_canGoPrev) return;
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _goToNextDay() {
    if (!_canGoNext) return;
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      // Hanya bisa pilih dalam rentang plan aktif (7 hari).
      firstDate: _planStartDate,
      lastDate: _planEndDate,
      helpText: 'Pilih hari dalam plan ini',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  /// Konfirmasi dialog sebelum tambah 1 gelas air.
  /// Setelah tersimpan, gelas TIDAK bisa di-unfill.
  Future<void> _confirmAddWater() async {
    if (_waterGlasses >= _waterTarget) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.water_drop_outlined,
              color: AppColors.waterBlue,
              size: 22,
            ),
            const SizedBox(width: AppDimensions.sm),
            Text('Konfirmasi Hidrasi', style: AppTextStyles.h3),
          ],
        ),
        content: const Text(
          'Apakah kamu sudah minum 1 gelas air?\n\n'
          'Catatan ini tidak bisa dibatalkan setelah disimpan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.waterBlue,
            ),
            child: const Text('Ya, Sudah Minum'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() => _waterGlasses++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            await Future<void>.delayed(const Duration(milliseconds: 500));
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              left: AppDimensions.base,
              right: AppDimensions.base,
              top: AppDimensions.sm,
              bottom: AppDimensions.xxxl + MediaQuery.of(context).padding.bottom,
            ),
            children: [
              // ═══════════════════════════════════════
              // 1. INLINE HEADER
              // ═══════════════════════════════════════
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Rencana Makanku',
                      style: AppTextStyles.h2,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today_outlined),
                    color: AppColors.textPrimary,
                    iconSize: 20,
                    onPressed: _pickDate,
                    tooltip: 'Pilih tanggal',
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.sm),

              // ═══════════════════════════════════════
              // 2. PLAN BADGE + DATE NAVIGATOR
              // ═══════════════════════════════════════
              _PlanBadge(
                dayNumber: _planDayNumber,
                totalDays: 7,
                rangeLabel: _planRangeLabel,
              ),
              const SizedBox(height: AppDimensions.sm),
              DateNavigator(
                date: _selectedDate,
                onPrev: _canGoPrev ? _goToPrevDay : null,
                onNext: _canGoNext ? _goToNextDay : null,
                onTapDate: _pickDate,
              ),
              const SizedBox(height: AppDimensions.base),

              // ═══════════════════════════════════════
              // 3. BUDGET CARD
              // ═══════════════════════════════════════
              BudgetProgressCard(
                spent: _budgetSpent,
                total: _budgetTotal,
                onTap: () => context.push('/meal/budget-settings'),
              ),
              const SizedBox(height: AppDimensions.base),

              // ═══════════════════════════════════════
              // 4. MACRO SUMMARY ROW
              // ═══════════════════════════════════════
              const MacroSummaryRow(items: _macros),
              const SizedBox(height: AppDimensions.lg),

              // ═══════════════════════════════════════
              // 5. SECTION HEADER
              // ═══════════════════════════════════════
              Text(
                'MENU HARI INI',
                style: AppTextStyles.overline.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: AppDimensions.sm),

              // ═══════════════════════════════════════
              // 6. MEAL SECTIONS
              // ═══════════════════════════════════════
              MealSectionCard(
                mealType: 'Sarapan',
                time: '07:00',
                totalCalories: 420,
                isCompleted: true,
                icon: Icons.wb_sunny_outlined,
                foods: const [
                  FoodItemRow(
                      name: 'Nasi uduk telur', kcal: 320, priceIdr: 8000),
                  FoodItemRow(name: 'Teh manis', kcal: 100, priceIdr: 2000),
                ],
                onTap: () => context.push('/meal/detail/breakfast-001'),
              ),
              const SizedBox(height: AppDimensions.sm + 2),
              MealSectionCard(
                mealType: 'Makan Siang',
                time: '12:30',
                totalCalories: 580,
                isHighlighted: true,
                icon: Icons.restaurant_outlined,
                foods: const [
                  FoodItemRow(
                      name: 'Ayam bakar nasi', kcal: 445, priceIdr: 12000),
                  FoodItemRow(name: 'Sayur asem', kcal: 135, priceIdr: 3000),
                ],
                onTap: () => context.push('/meal/detail/lunch-001'),
              ),
              const SizedBox(height: AppDimensions.sm + 2),
              MealSectionCard(
                mealType: 'Makan Malam',
                time: '19:00',
                totalCalories: 510,
                icon: Icons.dinner_dining_outlined,
                foods: const [
                  FoodItemRow(
                      name: 'Tempe orek nasi', kcal: 410, priceIdr: 7000),
                  FoodItemRow(name: 'Buah pisang', kcal: 100, priceIdr: 2000),
                ],
                onTap: () => context.push('/meal/detail/dinner-001'),
              ),
              const SizedBox(height: AppDimensions.lg),

              // ═══════════════════════════════════════
              // 7. HYDRATION CARD
              // ═══════════════════════════════════════
              Container(
                padding: const EdgeInsets.all(AppDimensions.base),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusCard),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.water_drop_outlined,
                          color: AppColors.waterBlue,
                          size: 20,
                        ),
                        const SizedBox(width: AppDimensions.sm),
                        Expanded(
                          child: Text('Hidrasi', style: AppTextStyles.h3),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.sm,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.waterBlue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusFull,
                            ),
                          ),
                          child: Text(
                            '$_waterGlasses/$_waterTarget gelas',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.waterBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.md),
                    WaterGlassesRow(
                      consumed: _waterGlasses,
                      target: _waterTarget,
                      onIncrement: _waterGlasses >= _waterTarget
                          ? null
                          : _confirmAddWater,
                    ),
                    const SizedBox(height: AppDimensions.md),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _waterGlasses >= _waterTarget
                            ? null
                            : _confirmAddWater,
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(
                          _waterGlasses >= _waterTarget
                              ? 'Target tercapai!'
                              : 'Tambah Gelas',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.waterBlue,
                          side: BorderSide(
                            color: AppColors.waterBlue.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusButton,
                            ),
                          ),
                          minimumSize: const Size.fromHeight(40),
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
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PLAN BADGE — "Hari ke X dari 7 · 14 – 20 Mei"
// ═══════════════════════════════════════════════════════════════

class _PlanBadge extends StatelessWidget {
  final int dayNumber;
  final int totalDays;
  final String rangeLabel;

  const _PlanBadge({
    required this.dayNumber,
    required this.totalDays,
    required this.rangeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryMuted,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.event_outlined,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppDimensions.xs + 2),
          Flexible(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                children: [
                  const TextSpan(text: 'Hari ke '),
                  TextSpan(
                    text: '$dayNumber',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text: ' dari $totalDays',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
          Container(
            width: 1,
            height: 12,
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(width: AppDimensions.sm),
          Flexible(
            child: Text(
              rangeLabel,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

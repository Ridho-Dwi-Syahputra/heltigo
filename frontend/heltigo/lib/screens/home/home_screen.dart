/// S-15: Home Dashboard — tab utama setelah login
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-15
///
/// Sections (top-down):
/// 1. Hero header — greeting + avatar + notif + 3 stat strip
/// 2. Workout Hari Ini card (gradient + CTA orange)
/// 3. Makan Hari Ini section (3 meal pills)
/// 4. Makro Harian card (4 progress bars)
/// 5. Hydration tracker (8 glasses visual)
/// 6. Streak card (purple)
/// 7. Jadwal Minggu Ini (7 day chips)
/// 8. AI Insight card
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';
import '../../widgets/home/macro_progress_bar.dart';
import '../../widgets/home/water_glasses_row.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ─── Mock data (provider integration nanti) ───
  static const String _userName = 'Andra';
  static const String _userInitial = 'A';
  static const int _caloriesLeft = 845;
  static const int _streak = 12;
  int _waterGlasses = 5;
  final int _waterTarget = 8;

  // Today's workout mock
  static const String _workoutName = 'Push & Core Day';
  static const String _workoutStats = '4 set · 12 reps · 28 menit';
  static const String _mockWorkoutId = 'wk-001';

  // Meal status mock
  final Set<int> _completedMeals = {0}; // sarapan = done

  // Macros mock
  static const _macros = [
    (label: 'Kalori', current: 1475.0, target: 1820.0, unit: 'kkal'),
    (label: 'Protein', current: 78.0, target: 120.0, unit: 'g'),
    (label: 'Karbo', current: 165.0, target: 220.0, unit: 'g'),
    (label: 'Lemak', current: 42.0, target: 80.0, unit: 'g'),
  ];

  // Week schedule mock — Senin..Minggu (S, S, R, K, J, S, M)
  static const List<({String letter, bool isRest, bool isCompleted})>
      _weekSchedule = [
    (letter: 'S', isRest: false, isCompleted: true),
    (letter: 'S', isRest: false, isCompleted: true),
    (letter: 'R', isRest: false, isCompleted: false), // today
    (letter: 'K', isRest: true, isCompleted: false),
    (letter: 'J', isRest: false, isCompleted: false),
    (letter: 'S', isRest: false, isCompleted: false),
    (letter: 'M', isRest: true, isCompleted: false),
  ];
  static const int _todayIndex = 2; // Rabu

  /// Greeting dinamis berdasarkan jam (lokal device)
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 10) return 'Pagi';
    if (hour >= 10 && hour < 15) return 'Siang';
    if (hour >= 15 && hour < 18) return 'Sore';
    return 'Malam';
  }

  void _showTodoSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Konfirmasi dialog sebelum tambah 1 gelas air.
  /// Gelas yang sudah filled TIDAK bisa di-unfill (no decrement).
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
            // TODO: Refresh data dari provider
            await Future<void>.delayed(const Duration(milliseconds: 600));
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              bottom: AppDimensions.xxxl + MediaQuery.of(context).padding.bottom,
            ),
            children: [
              // ═══════════════════════════════════════
              // 1. HERO HEADER
              // ═══════════════════════════════════════
              _HeroHeader(
                greeting: _getGreeting(),
                userName: _userName,
                userInitial: _userInitial,
                caloriesLeft: _caloriesLeft,
                waterCurrent: _waterGlasses,
                waterTarget: _waterTarget,
                streak: _streak,
                onTapAvatar: () => context.push('/profile'),
                onTapNotif: () => context.push('/notifications'),
              ),
              const SizedBox(height: AppDimensions.lg),

              // ═══════════════════════════════════════
              // 2. WORKOUT HARI INI
              // ═══════════════════════════════════════
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.base,
                ),
                child: _WorkoutTodayCard(
                  workoutName: _workoutName,
                  workoutStats: _workoutStats,
                  onStart: () =>
                      context.push('/workout/checkin/$_mockWorkoutId'),
                ),
              ),
              const SizedBox(height: AppDimensions.lg),

              // ═══════════════════════════════════════
              // 3. MAKAN HARI INI
              // ═══════════════════════════════════════
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.base,
                ),
                child: _MealsSection(
                  completed: _completedMeals,
                  // "Lihat semua" → switch ke Tab Nutrisi
                  onSeeAll: () => context.go('/meal'),
                  // Tap pill → buka detail meal spesifik
                  onTapMeal: (i) {
                    const ids = [
                      'breakfast-001',
                      'lunch-001',
                      'dinner-001',
                    ];
                    context.push('/meal/detail/${ids[i]}');
                  },
                ),
              ),
              const SizedBox(height: AppDimensions.lg),

              // ═══════════════════════════════════════
              // 4. MAKRO HARIAN
              // ═══════════════════════════════════════
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.base,
                ),
                child: _MacrosCard(macros: _macros),
              ),
              const SizedBox(height: AppDimensions.lg),

              // ═══════════════════════════════════════
              // 5. HIDRASI — increment-only dengan konfirmasi
              // ═══════════════════════════════════════
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.base,
                ),
                child: _HydrationCard(
                  consumed: _waterGlasses,
                  target: _waterTarget,
                  onAddGlass: _waterGlasses >= _waterTarget
                      ? null
                      : _confirmAddWater,
                ),
              ),
              const SizedBox(height: AppDimensions.lg),

              // ═══════════════════════════════════════
              // 6. STREAK
              // ═══════════════════════════════════════
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.base,
                ),
                child: _StreakCard(streak: _streak),
              ),
              const SizedBox(height: AppDimensions.lg),

              // ═══════════════════════════════════════
              // 7. JADWAL MINGGU INI
              // ═══════════════════════════════════════
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.base,
                ),
                child: _WeekSchedule(
                  days: _weekSchedule,
                  todayIndex: _todayIndex,
                  onSeeAll: () => context.go('/workout'),
                ),
              ),
              const SizedBox(height: AppDimensions.lg),

              // ═══════════════════════════════════════
              // 8. AI INSIGHT
              // ═══════════════════════════════════════
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.base,
                ),
                child: _AiInsightCard(
                  onTap: () => _showTodoSnack('Lihat insight lengkap'),
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
// 1. HERO HEADER — greeting, avatar, notif, stats strip
// ═══════════════════════════════════════════════════════════════

class _HeroHeader extends StatelessWidget {
  final String greeting;
  final String userName;
  final String userInitial;
  final int caloriesLeft;
  final int waterCurrent;
  final int waterTarget;
  final int streak;
  final VoidCallback onTapAvatar;
  final VoidCallback onTapNotif;

  const _HeroHeader({
    required this.greeting,
    required this.userName,
    required this.userInitial,
    required this.caloriesLeft,
    required this.waterCurrent,
    required this.waterTarget,
    required this.streak,
    required this.onTapAvatar,
    required this.onTapNotif,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.base,
        AppDimensions.base,
        AppDimensions.base,
        AppDimensions.lg,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppDimensions.radiusCard),
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Top row: greeting + actions ───
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat $greeting,',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      '$userName!',
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Notification button dengan dot indicator
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.white,
                      ),
                      onPressed: onTapNotif,
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppDimensions.sm),
              // Avatar circle
              GestureDetector(
                onTap: onTapAvatar,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.white,
                  child: Text(
                    userInitial,
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),

          // ─── Stats strip ───
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _HeroStat(
                    icon: Icons.local_fire_department_outlined,
                    value: '$caloriesLeft',
                    label: 'Sisa kkal',
                  ),
                ),
                _heroDivider(),
                Expanded(
                  child: _HeroStat(
                    icon: Icons.water_drop_outlined,
                    value: '$waterCurrent/$waterTarget',
                    label: 'Hidrasi',
                  ),
                ),
                _heroDivider(),
                Expanded(
                  child: _HeroStat(
                    icon: Icons.local_fire_department,
                    value: '$streak',
                    label: 'Streak',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroDivider() {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.white.withValues(alpha: 0.2),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _HeroStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.white, size: 18),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.h3.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 2. WORKOUT HARI INI CARD
// ═══════════════════════════════════════════════════════════════

class _WorkoutTodayCard extends StatelessWidget {
  final String workoutName;
  final String workoutStats;
  final VoidCallback onStart;

  const _WorkoutTodayCard({
    required this.workoutName,
    required this.workoutStats,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.base),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        boxShadow: AppShadows.glow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LATIHAN HARI INI',
            style: AppTextStyles.overline.copyWith(
              color: AppColors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            workoutName,
            style: AppTextStyles.h2.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: AppDimensions.xs),
          Row(
            children: [
              const Icon(
                Icons.fitness_center,
                size: 14,
                color: AppColors.white,
              ),
              const SizedBox(width: AppDimensions.xs),
              Text(
                workoutStats,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.base),
          SizedBox(
            width: double.infinity,
            height: AppDimensions.buttonHeight - 6,
            child: ElevatedButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: const Text('Mulai Latihan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusButton),
                ),
                elevation: 0,
                textStyle: AppTextStyles.button,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 3. MAKAN HARI INI SECTION
// ═══════════════════════════════════════════════════════════════

class _MealsSection extends StatelessWidget {
  final Set<int> completed;
  final VoidCallback onSeeAll;
  final ValueChanged<int> onTapMeal;

  const _MealsSection({
    required this.completed,
    required this.onSeeAll,
    required this.onTapMeal,
  });

  static const List<({String label, IconData icon})> _meals = [
    (label: 'Sarapan', icon: Icons.wb_sunny_outlined),
    (label: 'Siang', icon: Icons.restaurant_outlined),
    (label: 'Malam', icon: Icons.dinner_dining_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Makan Hari Ini',
                  style: AppTextStyles.h3,
                ),
              ),
              // Pakai Material + InkWell untuk ripple feedback + hit area lebih besar
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onSeeAll,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.sm,
                      vertical: AppDimensions.xs + 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Lihat semua', style: AppTextStyles.link),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: List.generate(_meals.length, (i) {
              final isDone = completed.contains(i);
              final isLast = i == _meals.length - 1;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: isLast ? 0 : AppDimensions.sm,
                  ),
                  child: _MealPill(
                    label: _meals[i].label,
                    icon: _meals[i].icon,
                    isDone: isDone,
                    onTap: () => onTapMeal(i),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _MealPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDone;
  final VoidCallback onTap;

  const _MealPill({
    required this.label,
    required this.icon,
    required this.isDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.sm,
          vertical: AppDimensions.sm + 2,
        ),
        decoration: BoxDecoration(
          color: isDone ? AppColors.primaryMuted : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: isDone ? AppColors.primary : AppColors.border,
            width: isDone ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDone ? Icons.check_circle : icon,
              size: 16,
              color: isDone ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppDimensions.xs + 2),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDone
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 4. MAKRO HARIAN CARD
// ═══════════════════════════════════════════════════════════════

class _MacrosCard extends StatelessWidget {
  final List<({String label, double current, double target, String unit})>
      macros;

  const _MacrosCard({required this.macros});

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.accent,
      AppColors.primary,
      AppColors.warning,
      AppColors.streakPurple,
    ];

    return Container(
      padding: const EdgeInsets.all(AppDimensions.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Makro Harian', style: AppTextStyles.h3),
              ),
              Text(
                'Update real-time',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          ...List.generate(macros.length, (i) {
            final m = macros[i];
            return Padding(
              padding: EdgeInsets.only(
                bottom: i == macros.length - 1 ? 0 : AppDimensions.md,
              ),
              child: MacroProgressBar(
                label: m.label,
                current: m.current,
                target: m.target,
                unit: m.unit,
                color: colors[i % colors.length],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 5. HYDRATION CARD
// ═══════════════════════════════════════════════════════════════

class _HydrationCard extends StatelessWidget {
  final int consumed;
  final int target;

  /// Callback dipanggil saat user mau tambah 1 gelas (lewat tap gelas
  /// berikutnya atau tombol "Tambah Gelas"). Parent sudah handle konfirmasi
  /// dialog & increment. Null = target sudah tercapai.
  final VoidCallback? onAddGlass;

  const _HydrationCard({
    required this.consumed,
    required this.target,
    this.onAddGlass,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
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
              Text(
                '$consumed/$target gelas',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.waterBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          WaterGlassesRow(
            consumed: consumed,
            target: target,
            onIncrement: onAddGlass,
          ),
          const SizedBox(height: AppDimensions.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAddGlass,
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                onAddGlass == null
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
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusButton),
                ),
                minimumSize: const Size.fromHeight(40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 6. STREAK CARD
// ═══════════════════════════════════════════════════════════════

class _StreakCard extends StatelessWidget {
  final int streak;

  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.base),
      decoration: BoxDecoration(
        color: AppColors.streakPurple.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: AppColors.streakPurple.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.streakPurple.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: AppColors.streakPurple,
              size: 26,
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Streak $streak Hari!',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.streakPurple,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Konsisten luar biasa. Lanjutkan!',
                  style: AppTextStyles.bodySmall,
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
// 7. WEEK SCHEDULE
// ═══════════════════════════════════════════════════════════════

class _WeekSchedule extends StatelessWidget {
  final List<({String letter, bool isRest, bool isCompleted})> days;
  final int todayIndex;
  final VoidCallback onSeeAll;

  const _WeekSchedule({
    required this.days,
    required this.todayIndex,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child:
                    Text('Jadwal Minggu Ini', style: AppTextStyles.h3),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onSeeAll,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.sm,
                      vertical: AppDimensions.xs + 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Lihat Minggu', style: AppTextStyles.link),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = AppDimensions.xs + 2;
              final chipWidth =
                  (constraints.maxWidth - (spacing * (days.length - 1))) /
                      days.length;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(days.length, (i) {
                  return SizedBox(
                    width: chipWidth,
                    child: _DayChip(
                      data: days[i],
                      isToday: i == todayIndex,
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final ({String letter, bool isRest, bool isCompleted}) data;
  final bool isToday;

  const _DayChip({required this.data, required this.isToday});

  @override
  Widget build(BuildContext context) {
    final isCompleted = data.isCompleted;
    final isRest = data.isRest;

    Color bgColor;
    Color borderColor;
    Color iconColor;
    IconData iconData;

    if (isCompleted) {
      bgColor = AppColors.primaryMuted;
      borderColor = AppColors.primary;
      iconColor = AppColors.primary;
      iconData = Icons.check;
    } else if (isRest) {
      bgColor = AppColors.surfaceLight;
      borderColor = AppColors.border;
      iconColor = AppColors.textTertiary;
      iconData = Icons.bed_outlined;
    } else {
      bgColor = AppColors.surfaceLight;
      borderColor = AppColors.border;
      iconColor = AppColors.textSecondary;
      iconData = Icons.fitness_center;
    }

    if (isToday) {
      borderColor = AppColors.accent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
        border: Border.all(
          color: borderColor,
          width: isToday ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data.letter,
            style: AppTextStyles.caption.copyWith(
              color: isToday
                  ? AppColors.accent
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Icon(iconData, size: 16, color: iconColor),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 8. AI INSIGHT CARD
// ═══════════════════════════════════════════════════════════════

class _AiInsightCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AiInsightCard({required this.onTap});

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
          border: Border.all(color: AppColors.primary, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tips AI Hari Ini',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Kamu sudah konsisten 12 hari. Tingkatkan intensitas '
                    'Push Day 10% minggu depan untuk hasil optimal.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

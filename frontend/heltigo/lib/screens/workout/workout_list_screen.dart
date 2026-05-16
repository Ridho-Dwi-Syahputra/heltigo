/// S-16: Workout List / Program Latihanku — Tab 2 Latihan
/// Sumber: docs/frontend/05_SCREENS_SPEC.md §S-16
///
/// Layout (matching reference image):
/// 1. Header "Program Latihanku"
/// 2. Progress card teal — "MINGGU KE-3" + tanggal + sessions counter + ring
/// 3. Vertical list 7 hari (Sen..Min) — date pill + workout + status
/// 4. Stats grid 2x2 — Volume / Kalori / Waktu / Konsistensi
/// 5. Sticky bottom CTA "Mulai Hari Ini"
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../styles/styles.dart';
import '../../widgets/universal/primary_button.dart';

enum _DayStatus { completed, today, pending, rest }

class _DayPlan {
  final String id;
  final String dayShort;
  final String dateNumber;
  final String workoutName;
  final int? durationMinutes;
  final int? totalExercises;
  final _DayStatus status;

  const _DayPlan({
    required this.id,
    required this.dayShort,
    required this.dateNumber,
    required this.workoutName,
    required this.status,
    this.durationMinutes,
    this.totalExercises,
  });
}

class WorkoutListScreen extends StatelessWidget {
  const WorkoutListScreen({super.key});

  // ─── Mock data: minggu ke-3 (6-12 Mei 2026, hari ini = Rabu 8) ───
  // NOTE: untuk demo, hari ini di-set ke index 2 (Rabu) sesuai mockup.
  static const int _todayIndex = 2;

  static const String _weekLabel = 'MINGGU KE-3';
  static const String _weekRange = '6 - 12 Mei 2026';
  static const int _sessionsDone = 2;
  static const int _sessionsTotal = 4;

  // Stats summary mock
  static const String _totalVolume = '12.4K';
  static const String _totalCalories = '1.840';
  static const String _totalTime = '2j 18m';
  static const String _consistency = '86';

  static const List<_DayPlan> _plan = [
    _DayPlan(
      id: 'wk-mon',
      dayShort: 'Sen',
      dateNumber: '06',
      workoutName: 'Push & Core',
      durationMinutes: 30,
      totalExercises: 6,
      status: _DayStatus.completed,
    ),
    _DayPlan(
      id: 'wk-tue',
      dayShort: 'Sel',
      dateNumber: '07',
      workoutName: 'Pull & Legs',
      durationMinutes: 30,
      totalExercises: 6,
      status: _DayStatus.completed,
    ),
    _DayPlan(
      id: 'wk-wed',
      dayShort: 'Rab',
      dateNumber: '08',
      workoutName: 'Push & Core',
      durationMinutes: 28,
      totalExercises: 6,
      status: _DayStatus.today,
    ),
    _DayPlan(
      id: 'wk-thu',
      dayShort: 'Kam',
      dateNumber: '09',
      workoutName: 'Istirahat',
      status: _DayStatus.rest,
    ),
    _DayPlan(
      id: 'wk-fri',
      dayShort: 'Jum',
      dateNumber: '10',
      workoutName: 'Full Body',
      durationMinutes: 32,
      totalExercises: 6,
      status: _DayStatus.pending,
    ),
    _DayPlan(
      id: 'wk-sat',
      dayShort: 'Sab',
      dateNumber: '11',
      workoutName: 'Cardio',
      durationMinutes: 25,
      totalExercises: 6,
      status: _DayStatus.pending,
    ),
    _DayPlan(
      id: 'wk-sun',
      dayShort: 'Min',
      dateNumber: '12',
      workoutName: 'Istirahat',
      status: _DayStatus.rest,
    ),
  ];

  double get _progress => _sessionsDone / _sessionsTotal;

  void _onTapDay(BuildContext context, _DayPlan day) {
    if (day.status == _DayStatus.rest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hari istirahat — biarkan otot pulih'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    context.push('/workout/detail/${day.id}');
  }

  void _onStartToday(BuildContext context) {
    final today = _plan[_todayIndex];
    context.push('/workout/checkin/${today.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  left: AppDimensions.base,
                  right: AppDimensions.base,
                  top: AppDimensions.base,
                  bottom: AppDimensions.xxxl + 80,
                ),
                children: [
                  // ═══════════════════════════════════════
                  // 1. HEADER
                  // ═══════════════════════════════════════
                  Text(
                    'Program Latihanku',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: AppDimensions.md),

                  // ═══════════════════════════════════════
                  // 2. PROGRESS CARD (teal + ring)
                  // ═══════════════════════════════════════
                  _ProgressCard(
                    weekLabel: _weekLabel,
                    weekRange: _weekRange,
                    sessionsDone: _sessionsDone,
                    sessionsTotal: _sessionsTotal,
                    progress: _progress,
                  ),
                  const SizedBox(height: AppDimensions.lg),

                  // ═══════════════════════════════════════
                  // 3. DAILY LIST (7 days)
                  // ═══════════════════════════════════════
                  ..._plan.map((day) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppDimensions.sm,
                      ),
                      child: _DayListTile(
                        day: day,
                        onTap: () => _onTapDay(context, day),
                      ),
                    );
                  }),
                  const SizedBox(height: AppDimensions.lg),

                  // ═══════════════════════════════════════
                  // 4. STATS GRID 2x2
                  // ═══════════════════════════════════════
                  Text(
                    'RINGKASAN MINGGU',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppDimensions.sm,
                    crossAxisSpacing: AppDimensions.sm,
                    childAspectRatio: 2.2,
                    children: const [
                      _SummaryStatCard(
                        label: 'Volume',
                        value: _totalVolume,
                        unit: 'kg',
                        color: AppColors.primary,
                      ),
                      _SummaryStatCard(
                        label: 'Kalori',
                        value: _totalCalories,
                        unit: 'kkal',
                        color: AppColors.accent,
                      ),
                      _SummaryStatCard(
                        label: 'Waktu',
                        value: _totalTime,
                        unit: '',
                        color: AppColors.warning,
                      ),
                      _SummaryStatCard(
                        label: 'Konsistensi',
                        value: _consistency,
                        unit: '%',
                        color: AppColors.success,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ═══════════════════════════════════════
            // 5. STICKY BOTTOM CTA
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
              child: PrimaryButton(
                label: 'Mulai Hari Ini',
                icon: Icons.play_arrow_rounded,
                onPressed: () => _onStartToday(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PROGRESS CARD — Minggu ke-X + ring 50%
// ═══════════════════════════════════════════════════════════════

class _ProgressCard extends StatelessWidget {
  final String weekLabel;
  final String weekRange;
  final int sessionsDone;
  final int sessionsTotal;
  final double progress;

  const _ProgressCard({
    required this.weekLabel,
    required this.weekRange,
    required this.sessionsDone,
    required this.sessionsTotal,
    required this.progress,
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  weekLabel,
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  weekRange,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$sessionsDone/$sessionsTotal sesi selesai',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.2),
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
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
// DAY LIST TILE — satu baris per hari
// ═══════════════════════════════════════════════════════════════

class _DayListTile extends StatelessWidget {
  final _DayPlan day;
  final VoidCallback onTap;

  const _DayListTile({
    required this.day,
    required this.onTap,
  });

  bool get _isToday => day.status == _DayStatus.today;
  bool get _isRest => day.status == _DayStatus.rest;

  Color get _bgColor {
    if (_isToday) return AppColors.primaryMuted;
    return AppColors.surface;
  }

  Color get _borderColor {
    if (_isToday) return AppColors.primary;
    return AppColors.border;
  }

  double get _borderWidth => _isToday ? 1.5 : 1;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.sm + 2,
          vertical: AppDimensions.sm + 2,
        ),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(color: _borderColor, width: _borderWidth),
        ),
        child: Row(
          children: [
            // ─── Date pill ───
            _DatePill(
              dayShort: day.dayShort,
              dateNumber: day.dateNumber,
              isToday: _isToday,
            ),
            const SizedBox(width: AppDimensions.md),

            // ─── Name + sub ───
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    day.workoutName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (!_isRest &&
                      day.durationMinutes != null &&
                      day.totalExercises != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${day.durationMinutes} mnt · ${day.totalExercises} latihan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.sm),

            // ─── Status indicator ───
            _StatusIndicator(status: day.status),
          ],
        ),
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  final String dayShort;
  final String dateNumber;
  final bool isToday;

  const _DatePill({
    required this.dayShort,
    required this.dateNumber,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.xs + 2),
      decoration: BoxDecoration(
        color: isToday
            ? AppColors.primary.withValues(alpha: 0.2)
            : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dayShort,
            style: AppTextStyles.caption.copyWith(
              color: isToday
                  ? AppColors.primary
                  : AppColors.textTertiary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            dateNumber,
            style: AppTextStyles.h3.copyWith(
              color: isToday
                  ? AppColors.primary
                  : AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final _DayStatus status;

  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case _DayStatus.today:
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.sm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
          child: Text(
            'HARI INI',
            style: AppTextStyles.overline.copyWith(
              color: AppColors.white,
              fontSize: 9,
            ),
          ),
        );
      case _DayStatus.completed:
        return Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: AppColors.white,
            size: 14,
          ),
        );
      case _DayStatus.rest:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.bedtime_outlined,
            color: AppColors.textTertiary,
            size: 14,
          ),
        );
      case _DayStatus.pending:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
        );
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// SUMMARY STAT CARD
// ═══════════════════════════════════════════════════════════════

class _SummaryStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _SummaryStatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm + 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.h3.copyWith(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
                children: [
                  TextSpan(text: value),
                  if (unit.isNotEmpty)
                    TextSpan(
                      text: ' $unit',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

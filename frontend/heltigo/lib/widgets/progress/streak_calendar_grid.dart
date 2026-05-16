/// StreakCalendarGrid — visualisasi heatmap kalender streak
///
/// Grid `weeks × 7` cells. Cell aktif: bg streakPurple, cell tidak aktif: surfaceLight.
/// Hari pertama grid = `startDate` (paling kiri-atas).
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class StreakCalendarGrid extends StatelessWidget {
  /// Daftar tanggal yang ada streak (akan dibandingkan per hari)
  final Set<DateTime> activeDays;

  /// Tanggal awal grid (paling kiri-atas)
  final DateTime startDate;

  /// Jumlah minggu yang ditampilkan (default 4)
  final int weeks;

  const StreakCalendarGrid({
    super.key,
    required this.activeDays,
    required this.startDate,
    this.weeks = 4,
  });

  bool _isActive(DateTime d) {
    final stripped = DateTime(d.year, d.month, d.day);
    return activeDays.any((a) =>
        a.year == stripped.year &&
        a.month == stripped.month &&
        a.day == stripped.day);
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppDimensions.xs;
        final totalSpacing = spacing * 6;
        final cellSize = (constraints.maxWidth - totalSpacing) / 7;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(weeks, (week) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: week == weeks - 1 ? 0 : spacing,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (day) {
                  final dayOffset = week * 7 + day;
                  final cellDate = startDate.add(Duration(days: dayOffset));
                  final active = _isActive(cellDate);
                  final today = _isToday(cellDate);

                  return _StreakCell(
                    size: cellSize,
                    isActive: active,
                    isToday: today,
                  );
                }),
              ),
            );
          }),
        );
      },
    );
  }
}

class _StreakCell extends StatelessWidget {
  final double size;
  final bool isActive;
  final bool isToday;

  const _StreakCell({
    required this.size,
    required this.isActive,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    if (isActive) {
      bg = AppColors.streakPurple;
    } else {
      bg = AppColors.surfaceLight;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: isToday
            ? Border.all(color: AppColors.accent, width: 2)
            : null,
      ),
    );
  }
}

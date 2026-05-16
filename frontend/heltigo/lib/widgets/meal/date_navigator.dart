/// DateNavigator — row prev/next + tanggal label untuk pilih hari
///
/// Dipakai di S-22 Meal List. Format: "Hari Ini · Rabu, 8 Mei".
/// Tap label center → trigger `onTapDate` (caller bisa showDatePicker).
/// `onPrev`/`onNext` nullable — null = button disabled (semi-transparent, no ripple).
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../styles/styles.dart';

class DateNavigator extends StatelessWidget {
  /// Tanggal yang sedang ditampilkan
  final DateTime date;

  /// Callback panah kiri. Null = button disabled.
  final VoidCallback? onPrev;

  /// Callback panah kanan. Null = button disabled.
  final VoidCallback? onNext;

  /// Callback tap label center (opsional)
  final VoidCallback? onTapDate;

  const DateNavigator({
    super.key,
    required this.date,
    this.onPrev,
    this.onNext,
    this.onTapDate,
  });

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDate() {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final yesterday = now.subtract(const Duration(days: 1));
    final formatter = DateFormat('EEEE, d MMM', 'id_ID');
    final formatted = formatter.format(date);
    if (_isSameDay(date, now)) return 'Hari Ini · $formatted';
    if (_isSameDay(date, tomorrow)) return 'Besok · $formatted';
    if (_isSameDay(date, yesterday)) return 'Kemarin · $formatted';
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _NavButton(icon: Icons.chevron_left, onTap: onPrev),
        Expanded(
          child: InkWell(
            onTap: onTapDate,
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.sm + 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Flexible(
                    child: Text(
                      _formatDate(),
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _NavButton(icon: Icons.chevron_right, onTap: onNext),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    final button = Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isDisabled ? AppColors.surfaceLight : AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDisabled
              ? AppColors.border.withValues(alpha: 0.5)
              : AppColors.border,
        ),
      ),
      child: Icon(
        icon,
        color: isDisabled ? AppColors.textTertiary : AppColors.textPrimary,
        size: 20,
      ),
    );

    if (isDisabled) {
      return Opacity(opacity: 0.5, child: button);
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      child: button,
    );
  }
}

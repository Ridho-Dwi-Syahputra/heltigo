/// WaterGlassesRow — visualisasi 8 gelas hidrasi (increment-only)
///
/// User hanya bisa menambah gelas, tidak bisa membatalkan/mengurangi.
/// Hanya gelas berikutnya (index == consumed) yang tappable.
/// Gelas yang sudah filled atau yang melewati next-empty TIDAK bisa di-tap.
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class WaterGlassesRow extends StatelessWidget {
  /// Jumlah gelas yang sudah dikonsumsi (0..target)
  final int consumed;

  /// Target jumlah gelas (default 8)
  final int target;

  /// Callback dipanggil saat user tap gelas berikutnya yang masih empty.
  /// Hanya gelas pada `index == consumed` yang tappable.
  /// Null = semua gelas non-tappable (mis. target sudah tercapai).
  final VoidCallback? onIncrement;

  const WaterGlassesRow({
    super.key,
    required this.consumed,
    this.target = 8,
    this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Hitung ukuran gelas dengan spacing kecil, responsive
        const spacing = AppDimensions.xs + 2;
        final glassWidth =
            (constraints.maxWidth - (spacing * (target - 1))) / target;
        final glassSize = glassWidth.clamp(20.0, 32.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(target, (i) {
            final isFilled = i < consumed;
            final isNextEmpty = i == consumed;
            final isTappable = isNextEmpty && onIncrement != null;

            return _GlassTile(
              size: glassSize,
              isFilled: isFilled,
              isNextEmpty: isNextEmpty,
              onTap: isTappable ? onIncrement : null,
            );
          }),
        );
      },
    );
  }
}

class _GlassTile extends StatelessWidget {
  final double size;
  final bool isFilled;
  final bool isNextEmpty;
  final VoidCallback? onTap;

  const _GlassTile({
    required this.size,
    required this.isFilled,
    required this.isNextEmpty,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor;
    final IconData iconData;
    if (isFilled) {
      iconColor = AppColors.waterBlue;
      iconData = Icons.water_drop;
    } else if (isNextEmpty && onTap != null) {
      // Hint: gelas berikutnya — tinted, tappable
      iconColor = AppColors.waterBlue.withValues(alpha: 0.6);
      iconData = Icons.water_drop_outlined;
    } else {
      iconColor = AppColors.textTertiary;
      iconData = Icons.water_drop_outlined;
    }

    final glass = SizedBox(
      width: size,
      height: size + 4,
      child: Icon(iconData, size: size, color: iconColor),
    );

    // Wrap dengan InkWell hanya jika tappable (next empty)
    if (onTap == null) {
      return glass;
    }
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      splashColor: AppColors.waterBlue.withValues(alpha: 0.2),
      highlightColor: AppColors.waterBlue.withValues(alpha: 0.1),
      child: glass,
    );
  }
}

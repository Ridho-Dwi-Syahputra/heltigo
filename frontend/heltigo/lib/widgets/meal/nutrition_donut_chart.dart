/// NutritionDonutChart — donut chart 4 macro untuk S-24 Food Detail
///
/// Layout: Donut chart kiri (proporsional ke gram), center kkal+label.
/// Legend di kanan: dot warna + label + nilai gram.
/// Responsive: pakai LayoutBuilder agar wrap di layar kecil.
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class MacroSegment {
  final String label;
  final double grams;
  final Color color;

  const MacroSegment({
    required this.label,
    required this.grams,
    required this.color,
  });
}

class NutritionDonutChart extends StatelessWidget {
  final int kcal;
  final List<MacroSegment> segments;

  /// Diameter chart (default 140)
  final double size;

  const NutritionDonutChart({
    super.key,
    required this.kcal,
    required this.segments,
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Jika layar terlalu sempit, stack vertikal
        final isNarrow = constraints.maxWidth < 320;

        if (isNarrow) {
          return Column(
            children: [
              _buildDonut(),
              const SizedBox(height: AppDimensions.base),
              _buildLegend(),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildDonut(),
            const SizedBox(width: AppDimensions.base),
            Expanded(child: _buildLegend()),
          ],
        );
      },
    );
  }

  Widget _buildDonut() {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(segments: segments),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                kcal.toString(),
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
              ),
              Text(
                'kkal',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: segments.map((seg) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: seg.color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: Text(
                  seg.label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                '${seg.grams.toStringAsFixed(0)} g',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<MacroSegment> segments;

  _DonutPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    const strokeWidth = 18.0;

    // Background ring
    final bgPaint = Paint()
      ..color = AppColors.surfaceLight
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;
    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    // Total grams
    final total = segments.fold<double>(0, (sum, s) => sum + s.grams);
    if (total <= 0) return;

    var startAngle = -math.pi / 2;
    for (final seg in segments) {
      if (seg.grams <= 0) continue;
      final sweepAngle = (seg.grams / total) * 2 * math.pi;
      final paint = Paint()
        ..color = seg.color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.segments != segments;
  }
}

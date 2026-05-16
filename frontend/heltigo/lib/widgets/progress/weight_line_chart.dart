/// WeightLineChart — line chart untuk visualisasi tren berat
///
/// Custom paint dengan label X & Y axis yang proper.
/// Dipakai di S-26 Progress Dashboard dan Profile sparkline.
///
/// Features:
/// - Y axis: 4 horizontal grid lines + label nilai (auto-scaled)
/// - X axis: label per data point (e.g., "M1", "M2", ...)
/// - Optional target line (dashed horizontal)
/// - Gradient fill di bawah garis utama
/// - Dots di setiap data point
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class WeightLineChart extends StatelessWidget {
  /// Nilai data per titik (mis. berat per minggu)
  final List<double> values;

  /// Label X axis untuk tiap data point. Length harus sama dengan values.
  final List<String> xLabels;

  /// Garis target horizontal opsional (mis. 68 kg)
  final double? targetWeight;

  /// Tinggi total widget
  final double height;

  /// Unit untuk label Y (default "kg")
  final String unit;

  const WeightLineChart({
    super.key,
    required this.values,
    required this.xLabels,
    this.targetWeight,
    this.height = 180,
    this.unit = 'kg',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return CustomPaint(
            size: Size(constraints.maxWidth, height),
            painter: _WeightChartPainter(
              values: values,
              xLabels: xLabels,
              targetWeight: targetWeight,
              unit: unit,
            ),
          );
        },
      ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> xLabels;
  final double? targetWeight;
  final String unit;

  // Layout padding internal
  static const double _padLeft = 52; // ruang Y labels (lebih lebar agar tidak nabrak)
  static const double _padRight = 12;
  static const double _padTop = 12;
  static const double _padBottom = 24; // ruang X labels
  static const double _yLabelGap = 10; // jarak antara teks label dan garis chart

  _WeightChartPainter({
    required this.values,
    required this.xLabels,
    required this.targetWeight,
    required this.unit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final chartArea = Rect.fromLTRB(
      _padLeft,
      _padTop,
      size.width - _padRight,
      size.height - _padBottom,
    );

    // Compute Y range (round to nearest integer for nicer ticks)
    final minVal = values.reduce(math.min);
    final maxVal = values.reduce(math.max);
    final dataRange = maxVal - minVal;
    final headroom = dataRange < 2 ? 1.0 : dataRange * 0.15;
    final yMin = (minVal - headroom).floorToDouble();
    final yMax = (maxVal + headroom).ceilToDouble();
    final yRange = (yMax - yMin).abs() < 0.001 ? 1.0 : (yMax - yMin);

    // ─── Draw grid lines + Y labels ───
    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const yTicks = 4;
    for (int i = 0; i <= yTicks; i++) {
      final t = i / yTicks;
      final y = chartArea.top + chartArea.height * (1 - t);
      // Dashed line
      _drawDashedLine(
        canvas,
        Offset(chartArea.left, y),
        Offset(chartArea.right, y),
        gridPaint,
      );
      // Y label
      final yValue = yMin + (yMax - yMin) * t;
      final ySpan = TextSpan(
        text: yValue.toStringAsFixed(0),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
          fontSize: 10,
        ),
      );
      final yTp = TextPainter(
        text: ySpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.right,
      );
      yTp.layout(maxWidth: _padLeft - _yLabelGap);
      yTp.paint(
        canvas,
        Offset(_padLeft - yTp.width - _yLabelGap, y - yTp.height / 2),
      );
    }

    // Y axis solid line di kiri
    final axisPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(chartArea.left, chartArea.top),
      Offset(chartArea.left, chartArea.bottom),
      axisPaint,
    );
    // X axis di bawah
    canvas.drawLine(
      Offset(chartArea.left, chartArea.bottom),
      Offset(chartArea.right, chartArea.bottom),
      axisPaint,
    );

    // ─── Compute data points positions ───
    final n = values.length;
    final stepX = n <= 1 ? 0.0 : chartArea.width / (n - 1);
    final points = <Offset>[];
    for (int i = 0; i < n; i++) {
      final x = chartArea.left + i * stepX;
      final yNorm = (values[i] - yMin) / yRange;
      final y = chartArea.bottom - yNorm * chartArea.height;
      points.add(Offset(x, y));
    }

    // ─── Target line (dashed, accent color) ───
    if (targetWeight != null) {
      final t = (targetWeight! - yMin) / yRange;
      if (t >= 0 && t <= 1) {
        final yTarget = chartArea.bottom - t * chartArea.height;
        final targetPaint = Paint()
          ..color = AppColors.accent
          ..strokeWidth = 1.5;
        _drawDashedLine(
          canvas,
          Offset(chartArea.left, yTarget),
          Offset(chartArea.right, yTarget),
          targetPaint,
          dashWidth: 5,
          dashSpace: 4,
        );
        // Label "Target" kecil di kanan
        final tgSpan = TextSpan(
          text: 'Target',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.accent,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        );
        final tgTp = TextPainter(
          text: tgSpan,
          textDirection: TextDirection.ltr,
        );
        tgTp.layout();
        tgTp.paint(
          canvas,
          Offset(chartArea.right - tgTp.width - 2, yTarget - tgTp.height - 2),
        );
      }
    }

    // ─── Fill gradient di bawah garis ───
    if (points.length >= 2) {
      final fillPath = Path()..moveTo(points.first.dx, chartArea.bottom);
      for (final p in points) {
        fillPath.lineTo(p.dx, p.dy);
      }
      fillPath
        ..lineTo(points.last.dx, chartArea.bottom)
        ..close();
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.35),
            AppColors.primary.withValues(alpha: 0),
          ],
        ).createShader(chartArea);
      canvas.drawPath(fillPath, fillPaint);
    }

    // ─── Garis utama (line stroke) ───
    if (points.length >= 2) {
      final linePath = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        linePath.lineTo(points[i].dx, points[i].dy);
      }
      final linePaint = Paint()
        ..color = AppColors.primary
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(linePath, linePaint);
    }

    // ─── Dots di setiap data point ───
    final dotFill = Paint()..color = AppColors.background;
    final dotStroke = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    for (final p in points) {
      canvas.drawCircle(p, 4, dotFill);
      canvas.drawCircle(p, 4, dotStroke);
    }

    // ─── X labels ───
    for (int i = 0; i < n; i++) {
      final label = i < xLabels.length ? xLabels[i] : '';
      if (label.isEmpty) continue;
      final span = TextSpan(
        text: label,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
          fontSize: 10,
        ),
      );
      final tp = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      tp.layout();
      final x = points[i].dx - tp.width / 2;
      tp.paint(canvas, Offset(x, chartArea.bottom + 6));
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint, {
    double dashWidth = 4,
    double dashSpace = 3,
  }) {
    final totalLen = (end - start).distance;
    final dir = (end - start) / totalLen;
    double traveled = 0;
    while (traveled < totalLen) {
      final segEnd = traveled + dashWidth;
      final clampedEnd = segEnd.clamp(0, totalLen).toDouble();
      final p1 = start + dir * traveled;
      final p2 = start + dir * clampedEnd;
      canvas.drawLine(p1, p2, paint);
      traveled = clampedEnd + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter old) {
    return old.values != values ||
        old.xLabels != xLabels ||
        old.targetWeight != targetWeight ||
        old.unit != unit;
  }
}

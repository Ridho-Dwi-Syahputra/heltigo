/// ScoreRing — circular progress dengan score % di tengah
///
/// Dipakai di S-29 Weekly Report dan S-34 Replanning Evaluation.
/// Warna auto: hijau jika ≥80%, orange 50-79%, merah <50% (jika `color` null).
/// Variant `whiteText: true` untuk over-dark-gradient (replanning hero).
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class ScoreRing extends StatelessWidget {
  /// Score 0–100
  final double score;

  /// Label kecil di atas angka (mis. "SKOR MINGGU")
  final String? label;

  /// Subtitle di bawah angka (mis. "Performa Sangat Baik")
  final String? subtitle;

  /// Diameter ring (default 140)
  final double size;

  /// Override warna ring. Null = auto by score.
  final Color? color;

  /// Variant teks putih untuk over-gradient
  final bool whiteText;

  const ScoreRing({
    super.key,
    required this.score,
    this.label,
    this.subtitle,
    this.size = 140,
    this.color,
    this.whiteText = false,
  });

  Color get _resolvedColor {
    if (color != null) return color!;
    if (score >= 80) return AppColors.success;
    if (score >= 50) return AppColors.warning;
    return AppColors.error;
  }

  Color get _textColor =>
      whiteText ? AppColors.white : AppColors.textPrimary;

  Color get _labelColor => whiteText
      ? AppColors.white.withValues(alpha: 0.85)
      : AppColors.textTertiary;

  @override
  Widget build(BuildContext context) {
    // Padding internal — supaya teks tidak menyentuh garis ring
    final innerPadding = size * 0.18;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: (score / 100).clamp(0.0, 1.0),
          color: _resolvedColor,
          trackColor: whiteText
              ? AppColors.white.withValues(alpha: 0.25)
              : AppColors.surfaceLight,
          // Stroke lebih tipis supaya rongga tengah lebih luas
          strokeWidth: size * 0.07,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: innerPadding),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (label != null)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.overline.copyWith(
                        color: _labelColor,
                        fontSize: size * 0.075,
                      ),
                    ),
                  ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${score.toStringAsFixed(0)}%',
                    maxLines: 1,
                    style: AppTextStyles.display.copyWith(
                      color: _textColor,
                      fontSize: size * 0.25,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: size * 0.02),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: _textColor,
                        fontSize: size * 0.075,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = (size.width - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        progress * 2 * math.pi,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) {
    return old.progress != progress ||
        old.color != color ||
        old.trackColor != trackColor ||
        old.strokeWidth != strokeWidth;
  }
}

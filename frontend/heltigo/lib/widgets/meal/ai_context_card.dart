/// AiContextCard — green tinted card untuk "Kenapa AI Memilih Ini" / "Konteks AI"
///
/// Dipakai di S-23 Meal Detail dan S-24 Food Item Detail.
/// Style: bg primaryMuted + border primary tipis + ikon `Icons.auto_awesome`.
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class AiContextCard extends StatelessWidget {
  /// Judul section (mis. "Kenapa AI Memilih Ini?")
  final String title;

  /// Body text penjelasan
  final String body;

  /// Icon di atas (default `Icons.auto_awesome`)
  final IconData icon;

  const AiContextCard({
    super.key,
    required this.title,
    required this.body,
    this.icon = Icons.auto_awesome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.base),
      decoration: BoxDecoration(
        color: AppColors.primaryMuted,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
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

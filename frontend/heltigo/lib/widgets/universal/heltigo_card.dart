/// HeltigoCard — card komponen utama (dark mode)
/// Sumber: docs/frontend/03_DESIGN_SYSTEM.md §Components
///
/// Card dengan background surface gelap, border subtle, dan shadow.
/// Digunakan di dashboard, workout list, meal list, progress, dll.
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class HeltigoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool hasBorder;
  final Color? backgroundColor;

  const HeltigoCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.hasBorder = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ??
          const EdgeInsets.all(AppDimensions.base),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: hasBorder
            ? Border.all(color: AppColors.border, width: 1)
            : null,
        boxShadow: AppShadows.card,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }

    return card;
  }
}

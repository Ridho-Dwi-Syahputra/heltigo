/// StatusChip — chip status (badge kecil)
/// Sumber: docs/frontend/03_DESIGN_SYSTEM.md §Components
///
/// Digunakan untuk menampilkan status: "Active", "Completed", "Skipped", dll.
/// Warna otomatis berdasarkan tipe status.
import 'package:flutter/material.dart';
import '../../styles/styles.dart';

enum StatusType { active, completed, skipped, pending, error }

class StatusChip extends StatelessWidget {
  final String label;
  final StatusType type;

  const StatusChip({
    super.key,
    required this.label,
    this.type = StatusType.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusBadge),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: _textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color get _backgroundColor {
    switch (type) {
      case StatusType.active:
        return AppColors.primaryMuted;
      case StatusType.completed:
        return AppColors.successMuted;
      case StatusType.skipped:
        return AppColors.warningMuted;
      case StatusType.pending:
        return AppColors.surfaceLight;
      case StatusType.error:
        return AppColors.errorMuted;
    }
  }

  Color get _textColor {
    switch (type) {
      case StatusType.active:
        return AppColors.primary;
      case StatusType.completed:
        return AppColors.success;
      case StatusType.skipped:
        return AppColors.warning;
      case StatusType.pending:
        return AppColors.textSecondary;
      case StatusType.error:
        return AppColors.error;
    }
  }
}

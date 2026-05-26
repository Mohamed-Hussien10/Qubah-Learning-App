import 'package:flutter/material.dart';
import 'package:web_dashboard/core/constants/app_colors.dart';

/// The visual status type for the badge.
enum StatusType { active, inactive, pending, warning, custom }

/// Small badge/chip widget for showing status with a colored dot.
class StatusBadge extends StatelessWidget {
  /// Label text to display.
  final String label;

  /// Predefined status type.
  final StatusType type;

  /// Custom color (used when type is [StatusType.custom]).
  final Color? customColor;

  /// Custom background color (used when type is [StatusType.custom]).
  final Color? customBackgroundColor;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = StatusType.active,
    this.customColor,
    this.customBackgroundColor,
  });

  /// Convenience constructors.
  const StatusBadge.active({super.key, this.label = 'نشط'})
      : type = StatusType.active,
        customColor = null,
        customBackgroundColor = null;

  const StatusBadge.inactive({super.key, this.label = 'غير نشط'})
      : type = StatusType.inactive,
        customColor = null,
        customBackgroundColor = null;

  const StatusBadge.pending({super.key, this.label = 'معلق'})
      : type = StatusType.pending,
        customColor = null,
        customBackgroundColor = null;

  const StatusBadge.warning({super.key, this.label = 'تحذير'})
      : type = StatusType.warning,
        customColor = null,
        customBackgroundColor = null;

  Color _dotColor(bool isDark) {
    if (type == StatusType.custom && customColor != null) return customColor!;
    switch (type) {
      case StatusType.active:
        return AppColors.success;
      case StatusType.inactive:
        return isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;
      case StatusType.pending:
        return AppColors.warning;
      case StatusType.warning:
        return AppColors.error;
      case StatusType.custom:
        return AppColors.info;
    }
  }

  Color _bgColor(bool isDark) {
    if (type == StatusType.custom && customBackgroundColor != null) {
      return customBackgroundColor!;
    }
    switch (type) {
      case StatusType.active:
        return AppColors.success.withValues(alpha: isDark ? 0.12 : 0.08);
      case StatusType.inactive:
        return (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight)
            .withValues(alpha: isDark ? 0.12 : 0.08);
      case StatusType.pending:
        return AppColors.warning.withValues(alpha: isDark ? 0.12 : 0.08);
      case StatusType.warning:
        return AppColors.error.withValues(alpha: isDark ? 0.12 : 0.08);
      case StatusType.custom:
        return AppColors.info.withValues(alpha: isDark ? 0.12 : 0.08);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dotColor = _dotColor(isDark);
    final bgColor = _bgColor(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: dotColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

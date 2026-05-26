import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:web_dashboard/core/constants/app_colors.dart';
import 'package:web_dashboard/core/constants/app_strings.dart';

/// Card showing recent activity items with icons, descriptions, and timestamps.
class RecentActivityCard extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const RecentActivityCard({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      color: AppColors.warning,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppStrings.recentActivity,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'عرض الكل',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Activity list ─────────────────────────────────────────────
          ...activities.asMap().entries.map((entry) {
            final i = entry.key;
            final activity = entry.value;
            final isLast = i == activities.length - 1;
            return _buildActivityItem(
              context,
              activity: activity,
              isLast: isLast,
              isDark: isDark,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required Map<String, dynamic> activity,
    required bool isLast,
    required bool isDark,
  }) {
    final iconData = _getIconData(activity['icon'] as String? ?? 'info');
    final color = _getColor(activity['color'] as String? ?? 'primary');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(iconData, color: color, size: 20),
              ),
              const SizedBox(width: 14),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['title'] as String? ?? '',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activity['description'] as String? ?? '',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Timestamp
              Text(
                activity['time'] as String? ?? '',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: (isDark ? AppColors.borderDark : AppColors.borderLight)
                .withValues(alpha: 0.5),
          ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'person_add':
        return Icons.person_add_rounded;
      case 'payment':
        return Icons.payment_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'star':
        return Icons.star_rounded;
      case 'notifications':
        return Icons.notifications_rounded;
      case 'edit':
        return Icons.edit_rounded;
      case 'delete':
        return Icons.delete_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Color _getColor(String colorName) {
    switch (colorName) {
      case 'success':
        return AppColors.success;
      case 'primary':
        return AppColors.primary;
      case 'info':
        return AppColors.info;
      case 'warning':
        return AppColors.warning;
      case 'error':
        return AppColors.error;
      case 'accent':
        return AppColors.accent;
      default:
        return AppColors.primary;
    }
  }
}

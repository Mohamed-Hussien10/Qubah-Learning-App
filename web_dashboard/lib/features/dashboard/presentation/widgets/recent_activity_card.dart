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
                onPressed: () => _showAllActivitiesDialog(context),
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
          if (activities.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'لا توجد أنشطة حديثة',
                  style: GoogleFonts.cairo(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            )
          else
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

  void _showAllActivitiesDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setState) {
            final filtered = activities.where((act) {
              final title = (act['title'] as String? ?? '').toLowerCase();
              final desc = (act['description'] as String? ?? '').toLowerCase();
              return title.contains(query.toLowerCase()) ||
                  desc.contains(query.toLowerCase());
            }).toList();

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor:
                    isDark ? AppColors.cardDark : AppColors.cardLight,
                child: Container(
                  width: 600,
                  height: 520,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
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
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'سجل النشاطات الكامل',
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Search field
                      TextField(
                        onChanged: (val) => setState(() => query = val),
                        style: GoogleFonts.cairo(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                        decoration: InputDecoration(
                          hintText: 'البحث في النشاطات...',
                          hintStyle: GoogleFonts.cairo(
                            color: isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textTertiaryLight,
                          ),
                          prefixIcon: const Icon(Icons.search, size: 20),
                          filled: true,
                          fillColor: isDark
                              ? AppColors.surfaceDark
                              : AppColors.backgroundLight,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // List
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(
                                child: Text(
                                  'لا توجد نتائج تطابق بحثك',
                                  style: GoogleFonts.cairo(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, _) => Divider(
                                  height: 1,
                                  color: (isDark
                                          ? AppColors.borderDark
                                          : AppColors.borderLight)
                                      .withValues(alpha: 0.5),
                                ),
                                itemBuilder: (context, i) {
                                  return _buildActivityItem(
                                    context,
                                    activity: filtered[i],
                                    isLast: i == filtered.length - 1,
                                    isDark: isDark,
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 12),

                      // Close button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'إغلاق',
                            style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
    final rawTime = activity['time'];
    final arabicTime = _formatArabicTime(rawTime);

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

              // Timestamp (pure Arabic)
              Text(
                arabicTime,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
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

  String _formatArabicTime(dynamic rawTime) {
    if (rawTime == null) return '';
    String text = rawTime.toString().trim();
    if (text.isEmpty) return '';

    // If it's already pure Arabic, return it
    if (text.startsWith('منذ') || text == 'الآن' || text == 'مؤخراً') {
      return text;
    }

    final lower = text.toLowerCase();

    // Just now
    if (lower.contains('just now') || lower.contains('second')) {
      return 'الآن';
    }

    // Extract any integer
    final numberMatch = RegExp(r'\d+').firstMatch(lower);
    final count = numberMatch != null ? int.tryParse(numberMatch.group(0)!) ?? 1 : 1;

    // Month
    if (lower.contains('month')) {
      if (count == 1) return 'منذ شهر';
      if (count == 2) return 'منذ شهرين';
      if (count >= 3 && count <= 10) return 'منذ $count أشهر';
      return 'منذ $count شهراً';
    }

    // Day
    if (lower.contains('day')) {
      if (count == 1) return 'منذ يوم';
      if (count == 2) return 'منذ يومين';
      if (count >= 3 && count <= 10) return 'منذ $count أيام';
      return 'منذ $count يوماً';
    }

    // Week
    if (lower.contains('week')) {
      if (count == 1) return 'منذ أسبوع';
      if (count == 2) return 'منذ أسبوعين';
      if (count >= 3 && count <= 10) return 'منذ $count أسابيع';
      return 'منذ $count أسبوعاً';
    }

    // Hour
    if (lower.contains('hour')) {
      if (count == 1) return 'منذ ساعة';
      if (count == 2) return 'منذ ساعتين';
      if (count >= 3 && count <= 10) return 'منذ $count ساعات';
      return 'منذ $count ساعة';
    }

    // Minute
    if (lower.contains('minute') || lower.contains('min')) {
      if (count == 1) return 'منذ دقيقة';
      if (count == 2) return 'منذ دقيقتين';
      if (count >= 3 && count <= 10) return 'منذ $count دقائق';
      return 'منذ $count دقيقة';
    }

    // Year
    if (lower.contains('year')) {
      if (count == 1) return 'منذ سنة';
      if (count == 2) return 'منذ سنتين';
      if (count >= 3 && count <= 10) return 'منذ $count سنوات';
      return 'منذ $count سنة';
    }

    return text;
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

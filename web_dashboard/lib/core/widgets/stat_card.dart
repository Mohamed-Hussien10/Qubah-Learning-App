import 'package:flutter/material.dart';
import 'package:web_dashboard/core/constants/app_colors.dart';

/// Reusable statistics card with icon, value, trend indicator, and hover animation.
class StatCard extends StatefulWidget {
  /// Card title (e.g. "إجمالي المستخدمين").
  final String title;

  /// Primary value to display (e.g. "1,245").
  final String value;

  /// Icon displayed in the card.
  final IconData icon;

  /// Background color for the icon container.
  final Color? iconColor;

  /// Background tint for the icon circle.
  final Color? iconBackgroundColor;

  /// Percentage change text (e.g. "+12.5%").
  final String? changeText;

  /// Whether the trend is positive (up) or negative (down).
  final bool? isPositiveTrend;

  /// Subtitle text below the value.
  final String? subtitle;

  /// Optional callback when card is tapped.
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    this.changeText,
    this.isPositiveTrend,
    this.subtitle,
    this.onTap,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveIconColor = widget.iconColor ?? AppColors.primary;
    final effectiveIconBg = widget.iconBackgroundColor ??
        effectiveIconColor.withValues(alpha: isDark ? 0.15 : 0.1);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: _isHovered
              ? (Matrix4.identity()..translate(0, -2, 0))
              : Matrix4.identity(),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? effectiveIconColor.withValues(alpha: 0.3)
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: effectiveIconColor.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ── Top Row: Icon + Trend ────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon container
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: effectiveIconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.icon,
                      color: effectiveIconColor,
                      size: 24,
                    ),
                  ),

                  // Trend badge
                  if (widget.changeText != null &&
                      widget.isPositiveTrend != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.isPositiveTrend!
                            ? AppColors.success.withValues(alpha: isDark ? 0.15 : 0.1)
                            : AppColors.error.withValues(alpha: isDark ? 0.15 : 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.isPositiveTrend!
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            size: 14,
                            color: widget.isPositiveTrend!
                                ? AppColors.success
                                : AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.changeText!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: widget.isPositiveTrend!
                                  ? AppColors.success
                                  : AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Title ───────────────────────────────────────────────
              Text(
                widget.title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // ── Value ───────────────────────────────────────────────
              Text(
                widget.value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // ── Subtitle ────────────────────────────────────────────
              if (widget.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.subtitle!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

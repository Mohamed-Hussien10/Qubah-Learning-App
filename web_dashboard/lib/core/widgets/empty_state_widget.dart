import 'package:flutter/material.dart';
import 'package:web_dashboard/core/constants/app_colors.dart';
import 'package:web_dashboard/core/constants/app_strings.dart';

/// Empty state placeholder with icon, title, subtitle, and optional action button.
class EmptyStateWidget extends StatelessWidget {
  /// Main icon to display.
  final IconData icon;

  /// Title text.
  final String title;

  /// Subtitle / description text.
  final String? subtitle;

  /// Label for the action button.
  final String? actionLabel;

  /// Callback when the action button is pressed.
  final VoidCallback? onAction;

  /// Icon for the action button.
  final IconData? actionIcon;

  /// Optional custom icon size.
  final double iconSize;

  const EmptyStateWidget({
    super.key,
    this.icon = Icons.inbox_rounded,
    this.title = AppStrings.noData,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
    this.iconSize = 80,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon ────────────────────────────────────────────────
            Container(
              width: iconSize + 40,
              height: iconSize + 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? AppColors.borderDark : AppColors.borderLight)
                    .withValues(alpha: 0.3),
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),

            const SizedBox(height: 24),

            // ── Title ───────────────────────────────────────────────
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),

            // ── Subtitle ────────────────────────────────────────────
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // ── Action Button ───────────────────────────────────────
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: Icon(actionIcon ?? Icons.add_rounded, size: 20),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

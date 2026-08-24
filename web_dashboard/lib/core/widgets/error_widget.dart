import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web_dashboard/core/constants/app_colors.dart';
import 'package:web_dashboard/core/constants/app_strings.dart';

/// Error state widget with icon, message, and retry button.
class AppErrorWidget extends StatelessWidget {
  /// Error message to display.
  final String message;

  /// Callback when retry button is pressed.
  final VoidCallback? onRetry;

  /// Icon to display.
  final IconData icon;

  /// Optional title above the message.
  final String? title;

  const AppErrorWidget({
    super.key,
    this.message = AppStrings.generalError,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
    this.title,
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
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error.withValues(alpha: isDark ? 0.12 : 0.08),
              ),
              child: Icon(
                icon,
                size: 50,
                color: AppColors.error,
              ),
            ),

            const SizedBox(height: 24),

            // ── Title ───────────────────────────────────────────────
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],

            // ── Message ─────────────────────────────────────────────
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),

            // ── Actions ─────────────────────────────────────────────
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.icon(
                  onPressed: () => context.go('/login'),
                  icon: const Icon(Icons.login_rounded, size: 20),
                  label: const Text(AppStrings.login),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: const Text(AppStrings.refresh),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

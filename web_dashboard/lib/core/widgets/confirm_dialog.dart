import 'package:flutter/material.dart';
import 'package:web_dashboard/core/constants/app_colors.dart';
import 'package:web_dashboard/core/constants/app_strings.dart';

/// Confirmation dialog for destructive actions like delete.
class ConfirmDialog extends StatelessWidget {
  /// Dialog title.
  final String title;

  /// Dialog message / description.
  final String message;

  /// Confirm button label.
  final String confirmLabel;

  /// Cancel button label.
  final String cancelLabel;

  /// Confirm button color.
  final Color? confirmColor;

  /// Icon to display.
  final IconData icon;

  /// Icon color.
  final Color? iconColor;

  /// Whether the dialog is in a loading state.
  final bool isLoading;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = AppStrings.confirm,
    this.cancelLabel = AppStrings.cancel,
    this.confirmColor,
    this.icon = Icons.warning_amber_rounded,
    this.iconColor,
    this.isLoading = false,
  });

  /// Shows the dialog and returns `true` if confirmed, `false` if cancelled.
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = AppStrings.confirm,
    String cancelLabel = AppStrings.cancel,
    Color? confirmColor,
    IconData icon = Icons.warning_amber_rounded,
    Color? iconColor,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        confirmColor: confirmColor,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  /// Shows a delete confirmation dialog.
  static Future<bool?> showDelete(
    BuildContext context, {
    String? itemName,
  }) {
    final message = itemName != null
        ? 'هل أنت متأكد من حذف "$itemName"؟ لا يمكن التراجع عن هذا الإجراء.'
        : 'هل أنت متأكد من الحذف؟ لا يمكن التراجع عن هذا الإجراء.';

    return show(
      context,
      title: AppStrings.delete,
      message: message,
      confirmLabel: AppStrings.delete,
      confirmColor: AppColors.error,
      icon: Icons.delete_outline_rounded,
      iconColor: AppColors.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveConfirmColor = confirmColor ?? AppColors.error;
    final effectiveIconColor = iconColor ?? AppColors.warning;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icon ──────────────────────────────────────────────
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: effectiveIconColor.withValues(alpha: isDark ? 0.15 : 0.1),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: effectiveIconColor,
                ),
              ),

              const SizedBox(height: 20),

              // ── Title ─────────────────────────────────────────────
              Text(
                title,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // ── Message ───────────────────────────────────────────
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              // ── Actions ───────────────────────────────────────────
              Row(
                children: [
                  // Cancel
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.of(context).pop(false),
                      child: Text(cancelLabel),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Confirm
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: effectiveConfirmColor,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(confirmLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

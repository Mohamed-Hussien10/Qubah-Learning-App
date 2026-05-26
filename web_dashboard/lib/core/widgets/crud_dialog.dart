import 'package:flutter/material.dart';
import 'package:web_dashboard/core/constants/app_colors.dart';
import 'package:web_dashboard/core/constants/app_strings.dart';
import 'package:web_dashboard/core/widgets/responsive_layout.dart';

/// Reusable CRUD dialog for create/edit forms.
///
/// Displays a responsive dialog with a title, a list of form fields,
/// and save/cancel action buttons.
class CrudDialog extends StatefulWidget {
  /// Dialog title.
  final String title;

  /// Icon shown next to the title.
  final IconData? titleIcon;

  /// Whether this dialog is for editing an existing item.
  final bool isEditMode;

  /// Builder for the form fields. Receives the [GlobalKey<FormState>].
  final Widget Function(GlobalKey<FormState> formKey) formBuilder;

  /// Called when the save button is pressed and form is valid.
  /// Return `true` to close the dialog, `false` to keep it open.
  final Future<bool> Function() onSave;

  /// Label for the save button.
  final String? saveLabel;

  /// Label for the cancel button.
  final String? cancelLabel;

  /// Whether the dialog is currently saving.
  final bool isLoading;

  const CrudDialog({
    super.key,
    required this.title,
    this.titleIcon,
    this.isEditMode = false,
    required this.formBuilder,
    required this.onSave,
    this.saveLabel,
    this.cancelLabel,
    this.isLoading = false,
  });

  /// Shows a CRUD dialog and returns `true` if saved successfully.
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    IconData? titleIcon,
    bool isEditMode = false,
    required Widget Function(GlobalKey<FormState> formKey) formBuilder,
    required Future<bool> Function() onSave,
    String? saveLabel,
    String? cancelLabel,
    bool isLoading = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CrudDialog(
        title: title,
        titleIcon: titleIcon,
        isEditMode: isEditMode,
        formBuilder: formBuilder,
        onSave: onSave,
        saveLabel: saveLabel,
        cancelLabel: cancelLabel,
        isLoading: isLoading,
      ),
    );
  }

  @override
  State<CrudDialog> createState() => _CrudDialogState();
}

class _CrudDialogState extends State<CrudDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSaving = true);
    try {
      final success = await widget.onSave();
      if (success && mounted) {
        Navigator.of(context).pop(true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isLoading = widget.isLoading || _isSaving;

    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 560 : 480,
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (widget.titleIcon != null) ...[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        widget.titleIcon,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    onPressed:
                        isLoading ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),

            // ── Form ────────────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: widget.formBuilder(_formKey),
                ),
              ),
            ),

            // ── Actions ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.of(context).pop(false),
                      child: Text(widget.cancelLabel ?? AppStrings.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleSave,
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.saveLabel ??
                                  (widget.isEditMode
                                      ? AppStrings.edit
                                      : AppStrings.save),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

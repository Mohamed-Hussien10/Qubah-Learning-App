import 'package:flutter/material.dart';
import 'package:web_dashboard/core/constants/app_colors.dart';
import 'package:web_dashboard/features/educational_stages/data/models/stage_model.dart';

/// A dialog for creating or editing an educational stage.
class StageFormDialog extends StatefulWidget {
  /// If non-null, the dialog is in "edit" mode.
  final StageModel? stage;

  /// Called when the user taps Save with valid data.
  final Future<void> Function(StageModel stage) onSave;

  const StageFormDialog({super.key, this.stage, required this.onSave});

  /// Convenience helper to show the dialog.
  static Future<void> show(
    BuildContext context, {
    StageModel? stage,
    required Future<void> Function(StageModel stage) onSave,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StageFormDialog(stage: stage, onSave: onSave),
    );
  }

  @override
  State<StageFormDialog> createState() => _StageFormDialogState();
}

class _StageFormDialogState extends State<StageFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _thumbCtrl;
  late final TextEditingController _orderCtrl;
  late bool _isActive;
  bool _isSaving = false;

  bool get _isEditing => widget.stage != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.stage?.title ?? '');
    _descCtrl = TextEditingController(text: widget.stage?.description ?? '');
    _thumbCtrl = TextEditingController(text: widget.stage?.thumbnailUrl ?? '');
    _orderCtrl = TextEditingController(
      text: widget.stage?.order.toString() ?? '0',
    );
    _isActive = widget.stage?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _thumbCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final stage = StageModel(
      id: widget.stage?.id ?? '',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      thumbnailUrl:
          _thumbCtrl.text.trim().isEmpty ? null : _thumbCtrl.text.trim(),
      isActive: _isActive,
      order: int.tryParse(_orderCtrl.text) ?? 0,
      gradesCount: widget.stage?.gradesCount ?? 0,
      createdAt: widget.stage?.createdAt,
    );

    try {
      await widget.onSave(stage);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ──────────────────────────────────────────
                Row(
                  children: [
                    Icon(
                      _isEditing ? Icons.edit_rounded : Icons.add_rounded,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isEditing
                          ? 'تعديل المرحلة التعليمية'
                          : 'إضافة مرحلة تعليمية جديدة',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed:
                          _isSaving ? null : () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Title ───────────────────────────────────────────
                TextFormField(
                  controller: _titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'العنوان *',
                    hintText: 'مثال: المرحلة الابتدائية',
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'العنوان مطلوب';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Description ─────────────────────────────────────
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'الوصف',
                    hintText: 'وصف اختياري للمرحلة',
                    prefixIcon: const Icon(Icons.description_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Thumbnail URL ───────────────────────────────────
                TextFormField(
                  controller: _thumbCtrl,
                  decoration: InputDecoration(
                    labelText: 'رابط الصورة المصغرة',
                    hintText: 'https://...',
                    prefixIcon: const Icon(Icons.image_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Order & Active ──────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _orderCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'الترتيب',
                          prefixIcon: const Icon(Icons.reorder),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) {
                          if (v != null &&
                              v.isNotEmpty &&
                              int.tryParse(v) == null) {
                            return 'أدخل رقمًا صحيحًا';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      children: [
                        const Text('نشط'),
                        Switch.adaptive(
                          value: _isActive,
                          activeColor: AppColors.success,
                          onChanged:
                              _isSaving
                                  ? null
                                  : (v) => setState(() => _isActive = v),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Actions ─────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed:
                          _isSaving ? null : () => Navigator.of(context).pop(),
                      child: const Text('إلغاء'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _isSaving ? null : _handleSave,
                      icon:
                          _isSaving
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.save_rounded),
                      label: Text(_isSaving ? 'جاري الحفظ...' : 'حفظ'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

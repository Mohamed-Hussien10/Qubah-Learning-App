import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:web_dashboard/core/constants/app_colors.dart';
import 'package:web_dashboard/features/educational_stages/data/models/stage_model.dart';

/// A dialog for creating or editing an educational stage.
class StageFormDialog extends StatefulWidget {
  /// If non-null, the dialog is in "edit" mode.
  final StageModel? stage;

  /// Called when the user taps Save with valid data.
  final Future<void> Function(StageModel stage, {List<int>? imageBytes, String? imageName, List<int>? bgImageBytes, String? bgImageName}) onSave;

  const StageFormDialog({super.key, this.stage, required this.onSave});

  /// Convenience helper to show the dialog.
  static Future<void> show(
    BuildContext context, {
    StageModel? stage,
    required Future<void> Function(StageModel stage, {List<int>? imageBytes, String? imageName, List<int>? bgImageBytes, String? bgImageName}) onSave,
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
  late final TextEditingController _bgCtrl;
  late final TextEditingController _orderCtrl;
  late bool _isActive;
  bool _isSaving = false;
  String? _selectedFileName;
  List<int>? _selectedFileBytes;
  String? _selectedBgFileName;
  List<int>? _selectedBgFileBytes;

  bool get _isEditing => widget.stage != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.stage?.title ?? '');
    _descCtrl = TextEditingController(text: widget.stage?.description ?? '');
    _thumbCtrl = TextEditingController(text: widget.stage?.thumbnailUrl ?? '');
    _bgCtrl = TextEditingController(text: widget.stage?.backgroundImageUrl ?? '');
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
    _bgCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true, // Need bytes for web
    );
    if (result != null) {
      setState(() {
        _selectedFileName = result.files.single.name;
        _selectedFileBytes = result.files.single.bytes;
        _thumbCtrl.text = _selectedFileName!;
      });
    }
  }

  Future<void> _pickBgImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null) {
      setState(() {
        _selectedBgFileName = result.files.single.name;
        _selectedBgFileBytes = result.files.single.bytes;
        _bgCtrl.text = _selectedBgFileName!;
      });
    }
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
      backgroundImageUrl:
          _bgCtrl.text.trim().isEmpty ? null : _bgCtrl.text.trim(),
      isActive: _isActive,
      order: int.tryParse(_orderCtrl.text) ?? 0,
      gradesCount: widget.stage?.gradesCount ?? 0,
      createdAt: widget.stage?.createdAt,
    );

    try {
      await widget.onSave(stage, imageBytes: _selectedFileBytes, imageName: _selectedFileName, bgImageBytes: _selectedBgFileBytes, bgImageName: _selectedBgFileName);
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
        child: SingleChildScrollView(
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

                // ── Thumbnail Picker ───────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الصورة المصغرة',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickImage,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.surfaceDark
                              : AppColors.backgroundLight,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.image_outlined,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.textTertiaryDark
                                    : AppColors.textTertiaryLight),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedFileName ??
                                    (_thumbCtrl.text.isEmpty
                                        ? 'اختر صورة مصغرة'
                                        : _thumbCtrl.text),
                                style: TextStyle(
                                  color: (_selectedFileName == null &&
                                          _thumbCtrl.text.isEmpty)
                                      ? (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? AppColors.textTertiaryDark
                                          : AppColors.textTertiaryLight)
                                      : (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimaryLight),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.upload_file_rounded),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Background Image Picker ──────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'صورة الخلفية للمرحلة',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickBgImage,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.surfaceDark
                              : AppColors.backgroundLight,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.wallpaper_rounded,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.textTertiaryDark
                                    : AppColors.textTertiaryLight),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedBgFileName ??
                                    (_bgCtrl.text.isEmpty
                                        ? 'اختر صورة للخلفية'
                                        : _bgCtrl.text),
                                style: TextStyle(
                                  color: (_selectedBgFileName == null &&
                                          _bgCtrl.text.isEmpty)
                                      ? (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? AppColors.textTertiaryDark
                                          : AppColors.textTertiaryLight)
                                      : (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimaryLight),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.upload_file_rounded),
                          ],
                        ),
                      ),
                    ),
                  ],
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

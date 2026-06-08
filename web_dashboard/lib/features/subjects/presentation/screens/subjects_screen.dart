import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import 'package:web_dashboard/core/constants/app_colors.dart';
import 'package:web_dashboard/core/constants/app_strings.dart';
import 'package:web_dashboard/features/subjects/data/models/subject_model.dart';
import 'package:web_dashboard/features/subjects/presentation/manager/subjects_cubit.dart';
import 'package:web_dashboard/core/services/dependency_injection.dart';
import 'package:web_dashboard/features/subjects/presentation/manager/subjects_state.dart';

/// Subjects management screen – filtered by sectionId.
class SubjectsScreen extends StatelessWidget {
  final String sectionId;
  const SubjectsScreen({super.key, required this.sectionId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<SubjectsCubit>()..loadSubjects(sectionId),
      child: _SubjectsView(sectionId: sectionId),
    );
  }
}

class _SubjectsView extends StatelessWidget {
  final String sectionId;
  const _SubjectsView({required this.sectionId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Breadcrumb
            BlocBuilder<SubjectsCubit, SubjectsState>(
              builder: (context, state) {
                final sectionName =
                    state is SubjectsLoaded ? state.sectionName : '';
                return _buildBreadcrumb(context, isDark, sectionName);
              },
            ),
            const SizedBox(height: 16),
            _buildHeader(context, isDark),
            const SizedBox(height: 20),
            _buildSearchBar(context, isDark),
            const SizedBox(height: 20),
            Expanded(child: _buildBody(context, isDark)),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.02, end: 0),
    );
  }

  Widget _buildBreadcrumb(
      BuildContext context, bool isDark, String sectionName) {
    return Row(
      children: [
        InkWell(
          onTap: () => context.go('/stages'),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.category_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                const Text('الأقسام',
                    style:
                        TextStyle(color: AppColors.primary, fontSize: 14)),
              ],
            ),
          ),
        ),
        Icon(Icons.chevron_left,
            size: 18,
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight),
        Text(sectionName,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight)),
        Icon(Icons.chevron_left,
            size: 18,
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight),
        Text(AppStrings.subjects,
            style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight)),
      ],
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        Icon(Icons.menu_book_rounded,
            color: AppColors.primary, size: 28),
        const SizedBox(width: 12),
        Text(AppStrings.subjects,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight)),
        const Spacer(),
        FilledButton.icon(
          onPressed: () => _showForm(context),
          icon: const Icon(Icons.add_rounded),
          label: Text('${AppStrings.add} مادة'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: AppStrings.search,
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (q) => context.read<SubjectsCubit>().search(q),
      ),
    );
  }

  Widget _buildBody(BuildContext context, bool isDark) {
    return BlocBuilder<SubjectsCubit, SubjectsState>(
      builder: (context, state) {
        if (state is SubjectsLoading) return _buildShimmer(isDark);
        if (state is SubjectsError) {
          return _buildError(context, state.message);
        }
        if (state is SubjectsLoaded) {
          if (state.filteredSubjects.isEmpty) return _buildEmpty(isDark);
          return _buildTable(context, state.filteredSubjects, isDark);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTable(
      BuildContext context, List<SubjectModel> subjects, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: DataTable2(
          columnSpacing: 16,
          horizontalMargin: 20,
          minWidth: 600,
          headingRowColor: WidgetStateProperty.all(
              isDark ? AppColors.surfaceDark : AppColors.backgroundLight),
          headingTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight),
          columns: const [
            DataColumn2(label: Text(AppStrings.order), fixedWidth: 70),
            DataColumn2(label: Text(AppStrings.title), size: ColumnSize.L),
            DataColumn2(
                label: Text(AppStrings.description), size: ColumnSize.L),
            DataColumn2(label: Text(AppStrings.status), fixedWidth: 100),
            DataColumn2(label: Text('الوحدات'), fixedWidth: 90),
            DataColumn2(label: Text(AppStrings.actions), fixedWidth: 200),
          ],
          rows: subjects.map((subject) {
            return DataRow2(
              onTap: () => _navigateToUnits(context, subject),
              cells: [
                DataCell(Text('${subject.order}')),
                DataCell(Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                      backgroundImage: (subject.thumbnailUrl != null && subject.thumbnailUrl!.isNotEmpty)
                          ? NetworkImage(resolveImageUrl(subject.thumbnailUrl!))
                          : null,
                      onBackgroundImageError: (subject.thumbnailUrl != null && subject.thumbnailUrl!.isNotEmpty)
                          ? (_, __) {}
                          : null,
                      child: (subject.thumbnailUrl == null || subject.thumbnailUrl!.isEmpty)
                          ? const Icon(Icons.book, size: 18, color: AppColors.primary)
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(subject.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis)),
                  ],
                )),
                DataCell(Text(subject.description ?? '—',
                    overflow: TextOverflow.ellipsis)),
                DataCell(_StatusBadge(isActive: subject.isActive)),
                DataCell(Text('${subject.unitsCount}')),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionIcon(
                        icon: Icons.edit_rounded,
                        tooltip: AppStrings.edit,
                        color: AppColors.warning,
                        onTap: () =>
                            _showForm(context, subject: subject)),
                    _ActionIcon(
                        icon: Icons.delete_outline_rounded,
                        tooltip: AppStrings.delete,
                        color: AppColors.error,
                        onTap: () =>
                            _confirmDelete(context, subject)),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_outlined,
              size: 80,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight),
          const SizedBox(height: 16),
          Text(AppStrings.noData,
              style: TextStyle(
                  fontSize: 18,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight)),
          const SizedBox(height: 8),
          Text('لا توجد مواد في هذا القسم',
              style: TextStyle(
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight)),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 80, color: AppColors.error),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: AppColors.error)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () =>
                context.read<SubjectsCubit>().loadSubjects(sectionId),
            icon: const Icon(Icons.refresh),
            label: const Text(AppStrings.refresh),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Shimmer.fromColors(
        baseColor: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
        highlightColor: isDark ? AppColors.cardDark : Colors.grey.shade50,
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: 4,
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
                height: 48,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8))),
          ),
        ),
      ),
    );
  }

  void _showForm(BuildContext context, {SubjectModel? subject}) {
    final cubit = context.read<SubjectsCubit>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SubjectFormDialog(
        subject: subject,
        sectionId: sectionId,
        onSave: (s, {imageBytes, imageName}) async {
          if (subject != null) {
            await cubit.updateSubject(s, imageBytes: imageBytes, imageName: imageName);
          } else {
            await cubit.createSubject(s, imageBytes: imageBytes, imageName: imageName);
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, SubjectModel subject) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.error),
          SizedBox(width: 8),
          Text('تأكيد الحذف'),
        ]),
        content: Text('هل أنت متأكد من حذف "${subject.title}"؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(AppStrings.cancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<SubjectsCubit>().deleteSubject(subject.id);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  void _navigateToUnits(BuildContext context, SubjectModel subject) {
    context.go('/units/${subject.id}');
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppColors.successBg : AppColors.errorBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? AppStrings.active : AppStrings.inactive,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.success : AppColors.error),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;
  const _ActionIcon(
      {required this.icon,
      required this.tooltip,
      required this.color,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child:
            Padding(padding: const EdgeInsets.all(6), child: Icon(icon, size: 20, color: color)),
      ),
    );
  }
}

class _SubjectFormDialog extends StatefulWidget {
  final SubjectModel? subject;
  final String sectionId;
  final Future<void> Function(SubjectModel, {List<int>? imageBytes, String? imageName}) onSave;
  const _SubjectFormDialog(
      {this.subject, required this.sectionId, required this.onSave});
  @override
  State<_SubjectFormDialog> createState() => _SubjectFormDialogState();
}

class _SubjectFormDialogState extends State<_SubjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _orderCtrl;
  late bool _isActive;
  bool _isSaving = false;
  String? _selectedFileName;
  List<int>? _selectedFileBytes;
  late TextEditingController _thumbCtrl;
  bool get _isEditing => widget.subject != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.subject?.title ?? '');
    _descCtrl = TextEditingController(text: widget.subject?.description ?? '');
    _thumbCtrl = TextEditingController(text: widget.subject?.thumbnailUrl ?? '');
    _orderCtrl =
        TextEditingController(text: widget.subject?.order.toString() ?? '0');
    _isActive = widget.subject?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _thumbCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  
  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null) {
      setState(() {
        _selectedFileName = result.files.single.name;
        _selectedFileBytes = result.files.single.bytes;
        _thumbCtrl.text = _selectedFileName!;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final subject = SubjectModel(
      id: widget.subject?.id ?? '',
      sectionId: widget.sectionId,
      title: _titleCtrl.text.trim(),
      description:
          _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      isActive: _isActive,
      thumbnailUrl: _thumbCtrl.text,
      order: int.tryParse(_orderCtrl.text) ?? 0,
      unitsCount: widget.subject?.unitsCount ?? 0,
      createdAt: widget.subject?.createdAt,
    );
    try {
      await widget.onSave(subject, imageBytes: _selectedFileBytes, imageName: _selectedFileName);
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
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  Icon(_isEditing ? Icons.edit : Icons.add,
                      color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(_isEditing ? 'تعديل المادة' : 'إضافة مادة جديدة',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.of(context).pop()),
                ]),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'العنوان *',
                    hintText: 'مثال: الرياضيات',
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'العنوان مطلوب' : null,
                ),
                const SizedBox(height: 16),
                
                  const Text('صورة الغلاف (اختياري)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _thumbCtrl,
                          decoration: const InputDecoration(
                            hintText: 'لم يتم اختيار صورة',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('اختيار'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'الوصف',
                    prefixIcon: const Icon(Icons.description_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _orderCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'الترتيب',
                        prefixIcon: const Icon(Icons.reorder),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(children: [
                    const Text('نشط'),
                    Switch.adaptive(
                        value: _isActive,
                        activeColor: AppColors.success,
                        onChanged: _isSaving
                            ? null
                            : (v) => setState(() => _isActive = v)),
                  ]),
                ]),
                const SizedBox(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text(AppStrings.cancel)),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _handleSave,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save_rounded),
                    label: Text(_isSaving ? 'جاري الحفظ...' : 'حفظ'),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String resolveImageUrl(String path) {
  if (path.isEmpty) return '';
  if (path.contains('thumbnails/')) {
    final fileName = path.split('thumbnails/').last;
    return 'http://127.0.0.1:8000/api/v1/thumbnails/' + fileName;
  }
  if (path.startsWith('http')) return path;
  const baseUrl = 'http://127.0.0.1:8000';
  if (path.startsWith('/')) return '$baseUrl$path';
  if (path.startsWith('storage/')) return '$baseUrl/$path';
  return '$baseUrl/storage/$path';
}

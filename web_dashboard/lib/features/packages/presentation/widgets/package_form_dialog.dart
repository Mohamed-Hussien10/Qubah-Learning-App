import 'package:flutter/material.dart';
import 'package:web_dashboard/core/constants/app_colors.dart';
import 'package:web_dashboard/core/constants/app_strings.dart';
import 'package:web_dashboard/core/services/dependency_injection.dart';
import 'package:web_dashboard/features/educational_stages/data/models/stage_model.dart';
import 'package:web_dashboard/features/educational_stages/data/repositories/stages_repository.dart';
import 'package:web_dashboard/features/grades/data/models/grade_model.dart';
import 'package:web_dashboard/features/grades/data/repositories/grades_repository.dart';
import 'package:web_dashboard/features/packages/data/models/package_model.dart';
import 'package:web_dashboard/features/sections/data/models/section_model.dart';
import 'package:web_dashboard/features/sections/data/repositories/sections_repository.dart';
import 'package:web_dashboard/features/subjects/data/models/subject_model.dart';
import 'package:web_dashboard/features/subjects/data/repositories/subjects_repository.dart';

class PackageFormDialog extends StatefulWidget {
  final PackageModel? package;
  final Function(PackageModel package) onSubmit;

  const PackageFormDialog({
    super.key,
    this.package,
    required this.onSubmit,
  });

  @override
  State<PackageFormDialog> createState() => _PackageFormDialogState();
}

class _PackageFormDialogState extends State<PackageFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  bool _isActive = true;
  bool _isLoadingInitial = true;
  bool _isLoadingGrades = false;
  bool _isLoadingSections = false;
  bool _isLoadingSubjects = false;

  List<StageModel> _stages = [];
  List<GradeModel> _grades = [];
  List<SectionModel> _sections = [];
  List<SubjectModel> _subjects = [];

  // Multi-Subset selection state
  bool _isAllStages = false;
  final Set<String> _selectedStageIds = {};

  bool _isAllGrades = false;
  final Set<String> _selectedGradeIds = {};

  bool _isAllSections = false;
  final Set<String> _selectedSectionIds = {};

  bool _isAllSubjects = false;
  final Set<String> _selectedSubjectIds = {};

  DateTime? _expiryDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.package?.name ?? '');
    _priceController = TextEditingController(
      text: widget.package != null ? widget.package!.price.toStringAsFixed(2) : '',
    );
    _descriptionController = TextEditingController(
      text: widget.package?.description ?? '',
    );
    _isActive = widget.package?.isActive ?? true;
    _expiryDate = widget.package?.expiryDate;

    if (widget.package != null) {
      final pkg = widget.package!;
      _isAllStages = pkg.isAllStages;
      _selectedStageIds.addAll(pkg.stageIds);
      if (_selectedStageIds.isEmpty && pkg.educationalStageId.isNotEmpty) {
        _selectedStageIds.add(pkg.educationalStageId);
      }

      _isAllGrades = pkg.isAllGrades;
      _selectedGradeIds.addAll(pkg.gradeIds);
      if (_selectedGradeIds.isEmpty && pkg.gradeId != null && pkg.gradeId!.isNotEmpty) {
        _selectedGradeIds.add(pkg.gradeId!);
      }

      _isAllSections = pkg.isAllSections;
      _selectedSectionIds.addAll(pkg.sectionIds);
      if (_selectedSectionIds.isEmpty && pkg.sectionId != null && pkg.sectionId!.isNotEmpty) {
        _selectedSectionIds.add(pkg.sectionId!);
      }

      _isAllSubjects = pkg.isAllSubjects;
      _selectedSubjectIds.addAll(pkg.subjectIds);
      if (_selectedSubjectIds.isEmpty && pkg.subjectId != null && pkg.subjectId!.isNotEmpty) {
        _selectedSubjectIds.add(pkg.subjectId!);
      }
    }

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoadingInitial = true);
    try {
      final stagesRepo = sl<StagesRepository>();
      _stages = await stagesRepo.getAll();

      // If initial stage is empty and not edit, select first stage by default
      if (_selectedStageIds.isEmpty && !_isAllStages && _stages.isNotEmpty) {
        _selectedStageIds.add(_stages.first.id);
      }

      await _updateGradesForSelectedStages();
      await _updateSectionsForSelectedGrades();
      await _updateSubjectsForSelectedSections();
    } catch (e) {
      debugPrint('Error loading initial dialog data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingInitial = false);
      }
    }
  }

  Future<void> _updateGradesForSelectedStages() async {
    setState(() => _isLoadingGrades = true);
    try {
      final gradesRepo = sl<GradesRepository>();
      final List<GradeModel> allFetched = [];

      final targetStageIds = _isAllStages
          ? _stages.map((e) => e.id).toList()
          : _selectedStageIds.toList();

      for (final sId in targetStageIds) {
        final gList = await gradesRepo.getByStageId(sId);
        allFetched.addAll(gList);
      }

      // Remove duplicates by ID
      final Map<String, GradeModel> uniqueMap = {};
      for (final g in allFetched) {
        uniqueMap[g.id] = g;
      }
      _grades = uniqueMap.values.toList();

      // Clean invalid selected grade IDs
      final validIds = _grades.map((e) => e.id).toSet();
      _selectedGradeIds.removeWhere((id) => !validIds.contains(id));
    } catch (e) {
      _grades = [];
      debugPrint('Error fetching grades: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingGrades = false);
      }
    }
  }

  Future<void> _updateSectionsForSelectedGrades() async {
    setState(() => _isLoadingSections = true);
    try {
      final sectionsRepo = sl<SectionsRepository>();
      final List<SectionModel> allFetched = [];

      final targetGradeIds = _isAllGrades
          ? _grades.map((e) => e.id).toList()
          : _selectedGradeIds.toList();

      for (final gId in targetGradeIds) {
        final secList = await sectionsRepo.getByGradeId(gId);
        allFetched.addAll(secList);
      }

      final Map<String, SectionModel> uniqueMap = {};
      for (final s in allFetched) {
        uniqueMap[s.id] = s;
      }
      _sections = uniqueMap.values.toList();

      final validIds = _sections.map((e) => e.id).toSet();
      _selectedSectionIds.removeWhere((id) => !validIds.contains(id));
    } catch (e) {
      _sections = [];
      debugPrint('Error fetching sections: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingSections = false);
      }
    }
  }

  Future<void> _updateSubjectsForSelectedSections() async {
    setState(() => _isLoadingSubjects = true);
    try {
      final subjectsRepo = sl<SubjectsRepository>();
      final List<SubjectModel> allFetched = [];

      final targetSectionIds = _isAllSections
          ? _sections.map((e) => e.id).toList()
          : _selectedSectionIds.toList();

      for (final secId in targetSectionIds) {
        final subList = await subjectsRepo.getBySectionId(secId);
        allFetched.addAll(subList);
      }

      final Map<String, SubjectModel> uniqueMap = {};
      for (final sub in allFetched) {
        uniqueMap[sub.id] = sub;
      }
      _subjects = uniqueMap.values.toList();

      final validIds = _subjects.map((e) => e.id).toSet();
      _selectedSubjectIds.removeWhere((id) => !validIds.contains(id));
    } catch (e) {
      _subjects = [];
      debugPrint('Error fetching subjects: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingSubjects = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    if (!_isAllStages && _selectedStageIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار مرحلة تعليمية واحدة على الأقل أو تفعيل "كل المراحل"')),
      );
      return;
    }

    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    final effectiveStageIds = _isAllStages
        ? _stages.map((e) => e.id).toList()
        : _selectedStageIds.toList();

    final effectiveGradeIds = _isAllGrades
        ? _grades.map((e) => e.id).toList()
        : _selectedGradeIds.toList();

    final effectiveSectionIds = _isAllSections
        ? _sections.map((e) => e.id).toList()
        : _selectedSectionIds.toList();

    final effectiveSubjectIds = _isAllSubjects
        ? _subjects.map((e) => e.id).toList()
        : _selectedSubjectIds.toList();

    final stageTitles = _isAllStages
        ? ['كل المراحل']
        : _stages.where((e) => _selectedStageIds.contains(e.id)).map((e) => e.title).toList();

    final gradeTitles = _isAllGrades
        ? ['كل الصفوف']
        : _grades.where((e) => _selectedGradeIds.contains(e.id)).map((e) => e.title).toList();

    final sectionTitles = _isAllSections
        ? ['كل الفصول']
        : _sections.where((e) => _selectedSectionIds.contains(e.id)).map((e) => e.title).toList();

    final subjectTitles = _isAllSubjects
        ? ['كل المواد']
        : _subjects.where((e) => _selectedSubjectIds.contains(e.id)).map((e) => e.title).toList();

    final updatedPackage = PackageModel(
      id: widget.package?.id ?? '',
      name: _nameController.text.trim(),
      price: price,
      educationalStageId: effectiveStageIds.isNotEmpty
          ? effectiveStageIds.first
          : (_stages.isNotEmpty ? _stages.first.id : ''),
      gradeId: !_isAllGrades && effectiveGradeIds.length == 1 ? effectiveGradeIds.first : null,
      sectionId: !_isAllSections && effectiveSectionIds.length == 1 ? effectiveSectionIds.first : null,
      subjectId: !_isAllSubjects && effectiveSubjectIds.length == 1 ? effectiveSubjectIds.first : null,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      expiryDate: _expiryDate,
      isActive: _isActive,
      isAllStages: _isAllStages,
      stageIds: effectiveStageIds,
      isAllGrades: _isAllGrades,
      gradeIds: effectiveGradeIds,
      isAllSections: _isAllSections,
      sectionIds: effectiveSectionIds,
      isAllSubjects: _isAllSubjects,
      subjectIds: effectiveSubjectIds,
      stageTitles: stageTitles,
      gradeTitles: gradeTitles,
      sectionTitles: sectionTitles,
      subjectTitles: subjectTitles,
    );

    widget.onSubmit(updatedPackage);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.package != null;
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 720,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.card_membership_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    isEdit ? AppStrings.editPackage : AppStrings.addPackage,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(height: 32),

            // Form Body
            Expanded(
              child: _isLoadingInitial
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Package Name & Price Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: '${AppStrings.packageName} *',
                                      hintText: 'مثال: باقة الترم الأول الشاملة',
                                      prefixIcon: Icon(Icons.card_giftcard),
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'الرجاء إدخال اسم الباقة';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 1,
                                  child: TextFormField(
                                    controller: _priceController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: const InputDecoration(
                                      labelText: '${AppStrings.packagePrice} *',
                                      hintText: '0.00',
                                      suffixText: AppStrings.currency,
                                      prefixIcon: Icon(Icons.attach_money),
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'إدخال السعر';
                                      }
                                      if (double.tryParse(val.trim()) == null) {
                                        return 'سعر غير صالح';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Scope Banner Info
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.info.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.info.withValues(alpha: 0.2),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      color: AppColors.info, size: 20),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'يمكنك تخصيص الباقة لتشمل مرحلة واحدة أو عدة مراحل، صفوف متعددة، فصول متعددة، أو مواد محددة.',
                                      style: TextStyle(
                                          fontSize: 12, color: AppColors.info),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 1. Stages Selection (Multi-Select)
                            _buildMultiSelectSection<StageModel>(
                              title: '1. المراحل التعليمية *',
                              icon: Icons.account_balance_outlined,
                              isAllSelected: _isAllStages,
                              allLabel: 'كل المراحل التعليمية',
                              items: _stages,
                              selectedIds: _selectedStageIds,
                              getItemTitle: (s) => s.title,
                              getItemId: (s) => s.id,
                              onToggleAll: (val) async {
                                setState(() {
                                  _isAllStages = val;
                                  if (val) {
                                    _selectedStageIds.clear();
                                  }
                                });
                                await _updateGradesForSelectedStages();
                                await _updateSectionsForSelectedGrades();
                                await _updateSubjectsForSelectedSections();
                              },
                              onItemToggled: (id, selected) async {
                                setState(() {
                                  if (selected) {
                                    _selectedStageIds.add(id);
                                  } else {
                                    _selectedStageIds.remove(id);
                                  }
                                });
                                await _updateGradesForSelectedStages();
                                await _updateSectionsForSelectedGrades();
                                await _updateSubjectsForSelectedSections();
                              },
                            ),
                            const SizedBox(height: 20),

                            // 2. Grades Selection (Multi-Select)
                            _buildMultiSelectSection<GradeModel>(
                              title: '2. الصفوف الدراسية (اختياري)',
                              icon: Icons.layers_outlined,
                              isLoading: _isLoadingGrades,
                              isAllSelected: _isAllGrades,
                              allLabel: 'كل الصفوف (ضمن المراحل المختارة)',
                              items: _grades,
                              selectedIds: _selectedGradeIds,
                              getItemTitle: (g) => g.title,
                              getItemId: (g) => g.id,
                              onToggleAll: (val) async {
                                setState(() {
                                  _isAllGrades = val;
                                  if (val) {
                                    _selectedGradeIds.clear();
                                  }
                                });
                                await _updateSectionsForSelectedGrades();
                                await _updateSubjectsForSelectedSections();
                              },
                              onItemToggled: (id, selected) async {
                                setState(() {
                                  if (selected) {
                                    _selectedGradeIds.add(id);
                                  } else {
                                    _selectedGradeIds.remove(id);
                                  }
                                });
                                await _updateSectionsForSelectedGrades();
                                await _updateSubjectsForSelectedSections();
                              },
                            ),
                            const SizedBox(height: 20),

                            // 3. Sections Selection (Multi-Select)
                            _buildMultiSelectSection<SectionModel>(
                              title: '3. الفصول والقطاعات (اختياري)',
                              icon: Icons.grid_view_outlined,
                              isLoading: _isLoadingSections,
                              isAllSelected: _isAllSections,
                              allLabel: 'كل الفصول (ضمن الصفوف المختارة)',
                              items: _sections,
                              selectedIds: _selectedSectionIds,
                              getItemTitle: (sec) => sec.title,
                              getItemId: (sec) => sec.id,
                              onToggleAll: (val) async {
                                setState(() {
                                  _isAllSections = val;
                                  if (val) {
                                    _selectedSectionIds.clear();
                                  }
                                });
                                await _updateSubjectsForSelectedSections();
                              },
                              onItemToggled: (id, selected) async {
                                setState(() {
                                  if (selected) {
                                    _selectedSectionIds.add(id);
                                  } else {
                                    _selectedSectionIds.remove(id);
                                  }
                                });
                                await _updateSubjectsForSelectedSections();
                              },
                            ),
                            const SizedBox(height: 20),

                            // 4. Subjects Selection (Multi-Select)
                            _buildMultiSelectSection<SubjectModel>(
                              title: '4. المواد الدراسية (اختياري)',
                              icon: Icons.library_books_outlined,
                              isLoading: _isLoadingSubjects,
                              isAllSelected: _isAllSubjects,
                              allLabel: 'كل المواد (ضمن الفصول المختارة)',
                              items: _subjects,
                              selectedIds: _selectedSubjectIds,
                              getItemTitle: (sub) => sub.title,
                              getItemId: (sub) => sub.id,
                              onToggleAll: (val) {
                                setState(() {
                                  _isAllSubjects = val;
                                  if (val) {
                                    _selectedSubjectIds.clear();
                                  }
                                });
                              },
                              onItemToggled: (id, selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedSubjectIds.add(id);
                                  } else {
                                    _selectedSubjectIds.remove(id);
                                  }
                                });
                              },
                            ),
                            const SizedBox(height: 20),

                            // Description Text Field
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'وصف الباقة (اختياري)',
                                hintText: 'اكتب وصفاً مختصراً لمزايا الباقة...',
                                prefixIcon: Icon(Icons.description_outlined),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Expiry Date Field
                            InkWell(
                              onTap: () async {
                                final selected = await showDatePicker(
                                  context: context,
                                  initialDate: _expiryDate ??
                                      DateTime.now().add(const Duration(days: 365)),
                                  firstDate: DateTime.now()
                                      .subtract(const Duration(days: 30)),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 3650)),
                                );
                                if (selected != null) {
                                  setState(() => _expiryDate = selected);
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'تاريخ انتهاء الباقة (اختياري)',
                                  prefixIcon:
                                      const Icon(Icons.event_outlined),
                                  border: const OutlineInputBorder(),
                                  suffixIcon: _expiryDate != null
                                      ? IconButton(
                                          icon: const Icon(Icons.clear,
                                              size: 20),
                                          onPressed: () {
                                            setState(() => _expiryDate = null);
                                          },
                                        )
                                      : null,
                                ),
                                child: Text(
                                  _expiryDate != null
                                      ? "${_expiryDate!.year}-${_expiryDate!.month.toString().padLeft(2, '0')}-${_expiryDate!.day.toString().padLeft(2, '0')}"
                                      : 'اضغط لاختيار تاريخ الانتهاء...',
                                  style: TextStyle(
                                    color: _expiryDate != null
                                        ? theme.textTheme.bodyMedium?.color
                                        : theme.hintColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Active Switch
                            SwitchListTile(
                              title: const Text('حالة تفعيل الباقة'),
                              subtitle: Text(
                                _isActive
                                    ? 'الباقة مفعّلة وتظهر للطلاب'
                                    : 'الباقة معطلة ومخفية',
                              ),
                              value: _isActive,
                              activeThumbColor: AppColors.success,
                              onChanged: (val) {
                                setState(() => _isActive = val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // Actions Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(AppStrings.cancel),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isLoadingInitial ? null : _submitForm,
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(isEdit ? AppStrings.save : AppStrings.add),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiSelectSection<T>({
    required String title,
    required IconData icon,
    bool isLoading = false,
    required bool isAllSelected,
    required String allLabel,
    required List<T> items,
    required Set<String> selectedIds,
    required String Function(T item) getItemTitle,
    required String Function(T item) getItemId,
    required Function(bool val) onToggleAll,
    required Function(String id, bool selected) onItemToggled,
  }) {
    final theme = Theme.of(context);

    String selectionSummaryText = '';
    if (isAllSelected) {
      selectionSummaryText = 'محدد: الكل (${items.length})';
    } else if (selectedIds.isEmpty) {
      selectionSummaryText = 'غير محدد (الكل مجاني/تلقائي)';
    } else {
      selectionSummaryText = 'محدد: ${selectedIds.length} من ${items.length}';
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAllSelected || selectedIds.isNotEmpty
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    selectionSummaryText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isAllSelected || selectedIds.isNotEmpty
                          ? AppColors.primary
                          : Colors.grey[700],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Toggle "All" option
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(
              allLabel,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            value: isAllSelected,
            activeColor: AppColors.primary,
            onChanged: (val) {
              if (val != null) onToggleAll(val);
            },
          ),

          // Items Chips Wrap
          if (!isAllSelected) ...[
            const SizedBox(height: 6),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'لا توجد عناصر متاحة للاختيار (يرجى اختيار المستوى الأعلى أولاً)',
                  style: TextStyle(fontSize: 12, color: theme.hintColor),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items.map((item) {
                  final id = getItemId(item);
                  final itemTitle = getItemTitle(item);
                  final isSelected = selectedIds.contains(id);

                  return FilterChip(
                    label: Text(itemTitle),
                    selected: isSelected,
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.primary : theme.textTheme.bodyMedium?.color,
                    ),
                    onSelected: (selected) {
                      onItemToggled(id, selected);
                    },
                  );
                }).toList(),
              ),
          ],
        ],
      ),
    );
  }
}

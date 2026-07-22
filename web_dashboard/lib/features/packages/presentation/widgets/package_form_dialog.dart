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

  String? _selectedStageId;
  String? _selectedGradeId;
  String? _selectedSectionId;
  String? _selectedSubjectId;
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

    _selectedStageId = widget.package?.educationalStageId;
    _selectedGradeId = widget.package?.gradeId;
    _selectedSectionId = widget.package?.sectionId;
    _selectedSubjectId = widget.package?.subjectId;

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoadingInitial = true);
    try {
      final stagesRepo = sl<StagesRepository>();
      _stages = await stagesRepo.getAll();

      if (_selectedStageId != null && _selectedStageId!.isNotEmpty) {
        await _fetchGradesForStage(_selectedStageId!);
        if (_selectedGradeId != null && _selectedGradeId!.isNotEmpty) {
          await _fetchSectionsForGrade(_selectedGradeId!);
          if (_selectedSectionId != null && _selectedSectionId!.isNotEmpty) {
            await _fetchSubjectsForSection(_selectedSectionId!);
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading initial dialog data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingInitial = false);
      }
    }
  }

  Future<void> _fetchGradesForStage(String stageId) async {
    setState(() => _isLoadingGrades = true);
    try {
      final gradesRepo = sl<GradesRepository>();
      _grades = await gradesRepo.getByStageId(stageId);
    } catch (e) {
      _grades = [];
      debugPrint('Error loading grades: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingGrades = false);
      }
    }
  }

  Future<void> _fetchSectionsForGrade(String gradeId) async {
    setState(() => _isLoadingSections = true);
    try {
      final sectionsRepo = sl<SectionsRepository>();
      _sections = await sectionsRepo.getByGradeId(gradeId);
    } catch (e) {
      _sections = [];
      debugPrint('Error loading sections: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingSections = false);
      }
    }
  }

  Future<void> _fetchSubjectsForSection(String sectionId) async {
    setState(() => _isLoadingSubjects = true);
    try {
      final subjectsRepo = sl<SubjectsRepository>();
      _subjects = await subjectsRepo.getBySectionId(sectionId);
    } catch (e) {
      _subjects = [];
      debugPrint('Error loading subjects: $e');
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
    if (_selectedStageId == null || _selectedStageId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار المرحلة التعليمية')),
      );
      return;
    }

    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

    final updatedPackage = PackageModel(
      id: widget.package?.id ?? '',
      name: _nameController.text.trim(),
      price: price,
      educationalStageId: _selectedStageId!,
      gradeId: _selectedGradeId,
      sectionId: _selectedSectionId,
      subjectId: _selectedSubjectId,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      expiryDate: _expiryDate,
      isActive: _isActive,
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
        width: 620,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
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
                                      'حدد نطاق الباقة بشكل متدرج. يمكنك التوقف عند المرحلة أو الصف أو الفصل أو المادة.',
                                      style: TextStyle(
                                          fontSize: 12, color: AppColors.info),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 1. Stage Dropdown (Required)
                            DropdownButtonFormField<String>(
                              initialValue: _selectedStageId,
                              decoration: const InputDecoration(
                                labelText: AppStrings.selectStageRequired,
                                prefixIcon:
                                    Icon(Icons.account_balance_outlined),
                                border: OutlineInputBorder(),
                              ),
                              items: _stages.map((stage) {
                                return DropdownMenuItem<String>(
                                  value: stage.id,
                                  child: Text(stage.title),
                                );
                              }).toList(),
                              onChanged: (stageId) async {
                                if (stageId == _selectedStageId) return;
                                setState(() {
                                  _selectedStageId = stageId;
                                  _selectedGradeId = null;
                                  _selectedSectionId = null;
                                  _selectedSubjectId = null;
                                  _grades = [];
                                  _sections = [];
                                  _subjects = [];
                                });
                                if (stageId != null) {
                                  await _fetchGradesForStage(stageId);
                                }
                              },
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'المرحلة التعليمية مطلوبة';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // 2. Grade Dropdown (Optional)
                            Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                DropdownButtonFormField<String?>(
                                  initialValue: _selectedGradeId,
                                  decoration: InputDecoration(
                                    labelText: AppStrings.selectGradeOptional,
                                    prefixIcon: const Icon(Icons.layers_outlined),
                                    border: const OutlineInputBorder(),
                                    enabled: _selectedStageId != null &&
                                        !_isLoadingGrades,
                                  ),
                                  items: [
                                    const DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text(
                                        '-- ${AppStrings.allGradesInStage} (توقف عند المرحلة) --',
                                        style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    ..._grades.map((grade) {
                                      return DropdownMenuItem<String?>(
                                        value: grade.id,
                                        child: Text(grade.title),
                                      );
                                    }),
                                  ],
                                  onChanged: _selectedStageId == null
                                      ? null
                                      : (gradeId) async {
                                          if (gradeId == _selectedGradeId) return;
                                          setState(() {
                                            _selectedGradeId = gradeId;
                                            _selectedSectionId = null;
                                            _selectedSubjectId = null;
                                            _sections = [];
                                            _subjects = [];
                                          });
                                          if (gradeId != null) {
                                            await _fetchSectionsForGrade(gradeId);
                                          }
                                        },
                                ),
                                if (_isLoadingGrades)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 12),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // 3. Section Dropdown (Optional)
                            Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                DropdownButtonFormField<String?>(
                                  initialValue: _selectedSectionId,
                                  decoration: InputDecoration(
                                    labelText: AppStrings.selectSectionOptional,
                                    prefixIcon:
                                        const Icon(Icons.grid_view_outlined),
                                    border: const OutlineInputBorder(),
                                    enabled: _selectedGradeId != null &&
                                        !_isLoadingSections,
                                  ),
                                  items: [
                                    const DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text(
                                        '-- ${AppStrings.allSectionsInGrade} (توقف عند الصف) --',
                                        style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    ..._sections.map((sec) {
                                      return DropdownMenuItem<String?>(
                                        value: sec.id,
                                        child: Text(sec.title),
                                      );
                                    }),
                                  ],
                                  onChanged: _selectedGradeId == null
                                      ? null
                                      : (sectionId) async {
                                          if (sectionId == _selectedSectionId) {
                                            return;
                                          }
                                          setState(() {
                                            _selectedSectionId = sectionId;
                                            _selectedSubjectId = null;
                                            _subjects = [];
                                          });
                                          if (sectionId != null) {
                                            await _fetchSubjectsForSection(
                                                sectionId);
                                          }
                                        },
                                ),
                                if (_isLoadingSections)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 12),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // 4. Subject Dropdown (Optional)
                            Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                DropdownButtonFormField<String?>(
                                  initialValue: _selectedSubjectId,
                                  decoration: InputDecoration(
                                    labelText: AppStrings.selectSubjectOptional,
                                    prefixIcon:
                                        const Icon(Icons.library_books_outlined),
                                    border: const OutlineInputBorder(),
                                    enabled: _selectedSectionId != null &&
                                        !_isLoadingSubjects,
                                  ),
                                  items: [
                                    const DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text(
                                        '-- ${AppStrings.allSubjectsInSection} (توقف عند الفصل) --',
                                        style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    ..._subjects.map((sub) {
                                      return DropdownMenuItem<String?>(
                                        value: sub.id,
                                        child: Text(sub.title),
                                      );
                                    }),
                                  ],
                                  onChanged: _selectedSectionId == null
                                      ? null
                                      : (subjectId) {
                                          setState(() {
                                            _selectedSubjectId = subjectId;
                                          });
                                        },
                                ),
                                if (_isLoadingSubjects)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 12),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),

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
}

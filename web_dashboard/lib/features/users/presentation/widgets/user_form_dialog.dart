import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_dashboard/core/constants/app_colors.dart';
import 'package:web_dashboard/core/constants/app_strings.dart';
import 'package:web_dashboard/core/services/dependency_injection.dart';
import 'package:web_dashboard/features/users/data/models/user_model.dart';
import 'package:web_dashboard/features/users/presentation/manager/users_cubit.dart';
import 'package:web_dashboard/features/educational_stages/data/models/stage_model.dart';
import 'package:web_dashboard/features/educational_stages/data/repositories/stages_repository.dart';
import 'package:web_dashboard/features/grades/data/models/grade_model.dart';
import 'package:web_dashboard/features/grades/data/repositories/grades_repository.dart';

class UserFormDialog extends StatefulWidget {
  final UserModel? user;
  final List<StageModel> initialStages;
  final List<GradeModel> initialGrades;

  const UserFormDialog({
    super.key,
    this.user,
    this.initialStages = const [],
    this.initialGrades = const [],
  });

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late UserRole _selectedRole;
  late bool _isActive;
  String? _selectedStageId;
  String? _selectedGradeId;
  DateTime? _subscriptionExpiry;
  
  List<StageModel> _stages = [];
  List<GradeModel> _grades = [];
  bool _isLoadingStages = true;
  bool _isLoadingGrades = false;

  bool get isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController();
    _selectedRole = widget.user?.role ?? UserRole.student;
    _isActive = widget.user?.isActive ?? true;
    _selectedStageId = widget.user?.stageId?.toString();
    _selectedGradeId = widget.user?.gradeId?.toString();
    _subscriptionExpiry = widget.user?.subscriptionExpiry;

    _stages = widget.initialStages;
    _grades = widget.initialGrades;
    _isLoadingStages = _stages.isEmpty;
    _isLoadingGrades = _selectedStageId != null && _grades.isEmpty;

    if (_isLoadingStages) {
      _loadStages();
    } else if (_isLoadingGrades) {
      _loadGrades(_selectedStageId!);
    }
  }

  Future<void> _loadStages() async {
    try {
      final stages = await sl<StagesRepository>().getAll();
      if (mounted) {
        setState(() {
          _stages = stages;
          _isLoadingStages = false;
        });
        if (_selectedStageId != null && _grades.isEmpty) {
          setState(() => _isLoadingGrades = true);
          _loadGrades(_selectedStageId!);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStages = false);
      }
    }
  }

  Future<void> _loadGrades(String stageId) async {
    setState(() => _isLoadingGrades = true);
    try {
      final grades = await sl<GradesRepository>().getByStageId(stageId);
      if (mounted) {
        setState(() {
          _grades = grades;
          _isLoadingGrades = false;
          // Validate selected grade id exists
          if (_selectedGradeId != null && !grades.any((g) => g.id == _selectedGradeId)) {
            _selectedGradeId = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingGrades = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title ─────────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isEditing ? Icons.edit : Icons.person_add,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEditing ? '${AppStrings.edit} مستخدم' : '${AppStrings.add} مستخدم جديد',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Name ──────────────────────────────────
                Text(
                  'الاسم الكامل',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  style: GoogleFonts.cairo(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                  decoration: _inputDecoration('أدخل الاسم الكامل', isDark),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'الاسم مطلوب';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Email ─────────────────────────────────
                Text(
                  AppStrings.email,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  style: GoogleFonts.cairo(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                  decoration: _inputDecoration('example@email.com', isDark),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'البريد الإلكتروني مطلوب';
                    if (!v.contains('@')) return 'بريد إلكتروني غير صالح';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Password ──────────────────────────────
                if (!isEditing) ...[
                  Text(
                    'كلمة المرور',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: GoogleFonts.cairo(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                    decoration: _inputDecoration('أدخل كلمة المرور', isDark),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'كلمة المرور مطلوبة';
                      if (v.length < 6) return 'يجب أن تكون 6 أحرف على الأقل';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Role ──────────────────────────────────
                Text(
                  'الدور',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<UserRole>(
                  value: _selectedRole,
                  style: GoogleFonts.cairo(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                  decoration: _inputDecoration(null, isDark),
                  dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                  items: const [
                    DropdownMenuItem(value: UserRole.student, child: Text('طالب')),
                    DropdownMenuItem(value: UserRole.admin, child: Text('مدير')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedRole = v);
                  },
                ),
                const SizedBox(height: 16),

                // ── Student Only Fields ───────────────────
                if (_selectedRole == UserRole.student) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'المرحلة',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _isLoadingStages
                                ? const CircularProgressIndicator()
                                : DropdownButtonFormField<String>(
                                    value: _selectedStageId,
                                    style: GoogleFonts.cairo(
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                    ),
                                    decoration: _inputDecoration('اختر المرحلة', isDark),
                                    dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                                    items: _stages.map((s) {
                                      return DropdownMenuItem(
                                        value: s.id,
                                        child: Text(s.title),
                                      );
                                    }).toList(),
                                    onChanged: (v) {
                                      if (v != null) {
                                        setState(() {
                                          _selectedStageId = v;
                                          _selectedGradeId = null; // reset grade
                                        });
                                        _loadGrades(v);
                                      }
                                    },
                                    validator: (v) => v == null ? 'مطلوب' : null,
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الصف',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _isLoadingGrades
                                ? const CircularProgressIndicator()
                                : DropdownButtonFormField<String>(
                                    value: _selectedGradeId,
                                    style: GoogleFonts.cairo(
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                    ),
                                    decoration: _inputDecoration('اختر الصف', isDark),
                                    dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                                    items: _grades.map((g) {
                                      return DropdownMenuItem(
                                        value: g.id,
                                        child: Text(g.title),
                                      );
                                    }).toList(),
                                    onChanged: (v) {
                                      if (v != null) setState(() => _selectedGradeId = v);
                                    },
                                    validator: (v) => v == null ? 'مطلوب' : null,
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'تاريخ انتهاء الاشتراك',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _subscriptionExpiry ?? DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (picked != null) {
                        setState(() => _subscriptionExpiry = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _subscriptionExpiry != null
                                ? '${_subscriptionExpiry!.year}-${_subscriptionExpiry!.month.toString().padLeft(2, '0')}-${_subscriptionExpiry!.day.toString().padLeft(2, '0')}'
                                : 'اختر التاريخ',
                            style: GoogleFonts.cairo(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          Icon(
                            Icons.calendar_today,
                            color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Status ────────────────────────────────
                Row(
                  children: [
                    Text(
                      AppStrings.status,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                      activeColor: AppColors.success,
                    ),
                    Text(
                      _isActive ? AppStrings.active : AppStrings.inactive,
                      style: GoogleFonts.cairo(
                        color: _isActive ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // ── Actions ───────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          AppStrings.cancel,
                          style: GoogleFonts.cairo(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          AppStrings.save,
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String? hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.cairo(
        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
      ),
      filled: true,
      fillColor: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<UsersCubit>();

    if (isEditing) {
      cubit.updateUser(widget.user!.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        role: _selectedRole,
        isActive: _isActive,
        stageId: _selectedRole == UserRole.student && _selectedStageId != null ? int.tryParse(_selectedStageId!) : null,
        gradeId: _selectedRole == UserRole.student && _selectedGradeId != null ? int.tryParse(_selectedGradeId!) : null,
        subscriptionExpiry: _selectedRole == UserRole.student ? _subscriptionExpiry : null,
      ));
    } else {
      cubit.createUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: _selectedRole,
        isActive: _isActive,
        stageId: _selectedRole == UserRole.student && _selectedStageId != null ? int.tryParse(_selectedStageId!) : null,
        gradeId: _selectedRole == UserRole.student && _selectedGradeId != null ? int.tryParse(_selectedGradeId!) : null,
        subscriptionExpiry: _selectedRole == UserRole.student ? _subscriptionExpiry : null,
      );
    }

    Navigator.pop(context);
  }
}

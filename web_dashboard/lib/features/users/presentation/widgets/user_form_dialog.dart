import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_dashboard/core/constants/app_colors.dart';
import 'package:web_dashboard/core/constants/app_strings.dart';
import 'package:web_dashboard/core/services/dependency_injection.dart';
import 'package:web_dashboard/features/packages/data/models/package_model.dart';
import 'package:web_dashboard/features/packages/data/repositories/packages_repository.dart';
import 'package:web_dashboard/features/users/data/models/user_model.dart';
import 'package:web_dashboard/features/users/presentation/manager/users_cubit.dart';

class UserFormDialog extends StatefulWidget {
  final UserModel? user;

  const UserFormDialog({
    super.key,
    this.user,
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
  String? _selectedPackageId;
  PackageModel? _selectedPackage;
  DateTime? _subscriptionExpiry;

  List<PackageModel> _packages = [];
  bool _isLoadingPackages = true;

  bool get isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController();
    _selectedRole = widget.user?.role ?? UserRole.student;
    _isActive = widget.user?.isActive ?? true;
    _selectedPackageId = widget.user?.packageId?.toString();
    _subscriptionExpiry = widget.user?.subscriptionExpiry;

    _loadPackages();
  }

  Future<void> _loadPackages() async {
    try {
      final packages = await sl<PackagesRepository>().getPackages(isActive: true);
      if (mounted) {
        setState(() {
          _packages = packages;
          _isLoadingPackages = false;
          if (_selectedPackageId != null) {
            try {
              _selectedPackage = packages.firstWhere(
                (p) => p.id == _selectedPackageId,
              );
            } catch (_) {}
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPackages = false);
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
          width: 520,
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
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isEditing ? Icons.edit : Icons.person_add,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEditing
                            ? '${AppStrings.edit} مستخدم'
                            : '${AppStrings.add} مستخدم جديد',
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
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
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    style: GoogleFonts.cairo(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
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
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    style: GoogleFonts.cairo(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    decoration: _inputDecoration('example@email.com', isDark),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'البريد الإلكتروني مطلوب';
                      }
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
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: GoogleFonts.cairo(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                      decoration: _inputDecoration('أدخل كلمة المرور', isDark),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'كلمة المرور مطلوبة';
                        }
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
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<UserRole>(
                    initialValue: _selectedRole,
                    style: GoogleFonts.cairo(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    decoration: _inputDecoration(null, isDark),
                    dropdownColor:
                        isDark ? AppColors.cardDark : AppColors.cardLight,
                    items: const [
                      DropdownMenuItem(
                          value: UserRole.student, child: Text('طالب')),
                      DropdownMenuItem(
                          value: UserRole.admin, child: Text('مدير')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedRole = v);
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Student Package Assignment ───────────
                  if (_selectedRole == UserRole.student) ...[
                    Text(
                      'تعيين باقة الاشتراك',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isLoadingPackages
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : DropdownButtonFormField<String?>(
                            initialValue: _selectedPackageId,
                            style: GoogleFonts.cairo(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                            decoration: _inputDecoration(
                              'اختر باقة الاشتراك للسيشن الحالي',
                              isDark,
                            ),
                            dropdownColor: isDark
                                ? AppColors.cardDark
                                : AppColors.cardLight,
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('بدون باقة (حساب مجاني)'),
                              ),
                              ..._packages.map((pkg) {
                                return DropdownMenuItem<String?>(
                                  value: pkg.id,
                                  child: Text(
                                      '${pkg.name} (${pkg.price} ${AppStrings.currency}) - ${pkg.scopeText}'),
                                );
                              }),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _selectedPackageId = val;
                                if (val != null) {
                                  try {
                                    _selectedPackage = _packages.firstWhere(
                                      (p) => p.id == val,
                                    );
                                    if (_selectedPackage?.expiryDate != null) {
                                      _subscriptionExpiry =
                                          _selectedPackage!.expiryDate;
                                    }
                                  } catch (_) {}
                                } else {
                                  _selectedPackage = null;
                                }
                              });
                            },
                          ),
                    if (_selectedPackage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.card_membership,
                                    size: 18, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedPackage!.name,
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _selectedPackage!.price
                                          .toStringAsFixed(2),
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'ر.ع.',
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'نطاق الباقة: ${_selectedPackage!.scopeText}',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      'تاريخ انتهاء الاشتراك',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final selected = await showDatePicker(
                          context: context,
                          initialDate: _subscriptionExpiry ??
                              DateTime.now().add(const Duration(days: 30)),
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 365)),
                          lastDate: DateTime.now()
                              .add(const Duration(days: 3650)),
                        );
                        if (selected != null) {
                          setState(() => _subscriptionExpiry = selected);
                        }
                      },
                      child: InputDecorator(
                        decoration: _inputDecoration(
                          'اضغط لاختيار تاريخ الانتهاء',
                          isDark,
                        ).copyWith(
                          prefixIcon: const Icon(Icons.event_outlined, color: AppColors.primary),
                          suffixIcon: _subscriptionExpiry != null
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  onPressed: () {
                                    setState(() => _subscriptionExpiry = null);
                                  },
                                )
                              : null,
                        ),
                        child: Text(
                          _subscriptionExpiry != null
                              ? "${_subscriptionExpiry!.year}-${_subscriptionExpiry!.month.toString().padLeft(2, '0')}-${_subscriptionExpiry!.day.toString().padLeft(2, '0')}"
                              : 'بدون تاريخ انتهاء (مستمر)',
                          style: GoogleFonts.cairo(
                            color: _subscriptionExpiry != null
                                ? (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight)
                                : (isDark
                                    ? AppColors.textTertiaryDark
                                    : AppColors.textTertiaryLight),
                          ),
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
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: _isActive,
                        onChanged: (v) => setState(() => _isActive = v),
                        activeThumbColor: AppColors.success,
                      ),
                      Text(
                        _isActive ? AppStrings.active : AppStrings.inactive,
                        style: GoogleFonts.cairo(
                          color:
                              _isActive ? AppColors.success : AppColors.error,
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
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            AppStrings.cancel,
                            style: GoogleFonts.cairo(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
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
                            style:
                                GoogleFonts.cairo(fontWeight: FontWeight.bold),
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
        color:
            isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
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

    final pkgId = _selectedRole == UserRole.student && _selectedPackageId != null
        ? int.tryParse(_selectedPackageId!)
        : null;

    if (isEditing) {
      cubit.updateUser(widget.user!.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        role: _selectedRole,
        isActive: _isActive,
        packageId: pkgId,
        package: _selectedPackage,
        subscriptionExpiry: _subscriptionExpiry,
      ));
    } else {
      cubit.createUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: _selectedRole,
        isActive: _isActive,
        packageId: pkgId,
        subscriptionExpiry: _subscriptionExpiry,
      );
    }

    Navigator.pop(context);
  }
}

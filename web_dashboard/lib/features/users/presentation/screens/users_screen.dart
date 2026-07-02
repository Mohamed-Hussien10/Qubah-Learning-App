import 'dart:html' as html;
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:web_dashboard/core/constants/app_colors.dart';
import 'package:web_dashboard/core/constants/app_strings.dart';
import 'package:web_dashboard/features/users/data/models/user_model.dart';
import 'package:web_dashboard/features/users/presentation/manager/users_cubit.dart';
import 'package:web_dashboard/features/users/presentation/manager/users_state.dart';
import 'package:web_dashboard/core/services/dependency_injection.dart';
import 'package:web_dashboard/features/educational_stages/data/models/stage_model.dart';
import 'package:web_dashboard/features/educational_stages/data/repositories/stages_repository.dart';
import 'package:web_dashboard/features/users/presentation/widgets/user_form_dialog.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<UsersCubit>()..loadUsers(),
      child: const _UsersScreenBody(),
    );
  }
}

class _UsersScreenBody extends StatefulWidget {
  const _UsersScreenBody();

  @override
  State<_UsersScreenBody> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<_UsersScreenBody> {
  List<StageModel> _stages = [];

  @override
  void initState() {
    super.initState();
    _loadStages();
  }

  Future<void> _loadStages() async {
    try {
      final stages = await sl<StagesRepository>().getAll();
      if (mounted) {
        setState(() {
          _stages = stages;
        });
      }
    } catch (_) {
      // Ignored
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────
              _buildHeader(context, isDark),
              const SizedBox(height: 24),

              // ── Filter Tabs ───────────────────────────────────
              _buildFilterTabs(context, isDark),
              const SizedBox(height: 16),

              // ── Search & Actions ──────────────────────────────
              _buildSearchAndActions(context, isDark),
              const SizedBox(height: 16),

              // ── Data Table ────────────────────────────────────
              Expanded(child: _buildDataTable(context, isDark)),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.02, end: 0),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.users,
              style: GoogleFonts.cairo(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 4),
            BlocBuilder<UsersCubit, UsersState>(
              builder: (context, state) {
                return Text(
                  'إجمالي ${state.totalCount} مستخدم',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                );
              },
            ),
          ],
        ),
        const Spacer(),
        _buildExportButton(context, isDark),
        const SizedBox(width: 12),
        _buildAddButton(context),
      ],
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }

  Future<void> _exportToExcel(List<UserModel> users) async {
    final excel = Excel.createExcel();
    final sheet = excel['المستخدمين'];
    excel.setDefaultSheet('المستخدمين');

    // Headers
    sheet.appendRow([
      TextCellValue('المعرف'),
      TextCellValue('الاسم'),
      TextCellValue('البريد الإلكتروني'),
      TextCellValue('الدور'),
      TextCellValue('الحالة'),
      TextCellValue('تاريخ الانضمام'),
      TextCellValue('تاريخ انتهاء الاشتراك'),
    ]);

    // Data rows
    for (final user in users) {
      sheet.appendRow([
        TextCellValue(user.id.toString()),
        TextCellValue(user.name),
        TextCellValue(user.email),
        TextCellValue(user.roleLabel),
        TextCellValue(user.statusLabel),
        TextCellValue('${user.createdAt.year}-${user.createdAt.month}-${user.createdAt.day}'),
        TextCellValue(user.subscriptionExpiry != null 
            ? '${user.subscriptionExpiry!.year}-${user.subscriptionExpiry!.month}-${user.subscriptionExpiry!.day}' 
            : 'غير محدد'),
      ]);
    }

    final bytes = excel.encode();
    if (bytes != null) {
      final blob = html.Blob([bytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = 'users_export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      html.document.body!.children.add(anchor);
      anchor.click();
      html.document.body!.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    }
  }

  Widget _buildExportButton(BuildContext context, bool isDark) {
    return BlocBuilder<UsersCubit, UsersState>(
      builder: (context, state) {
        return OutlinedButton.icon(
          onPressed: () {
            if (state.status == UsersStatus.loaded || state.filteredUsers.isNotEmpty) {
              _exportToExcel(state.filteredUsers);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم تصدير البيانات بنجاح', style: GoogleFonts.cairo()),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
          icon: const Icon(Icons.file_download_outlined, size: 18),
          label: Text(AppStrings.exportData, style: GoogleFonts.cairo()),
          style: OutlinedButton.styleFrom(
            foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => _showUserDialog(context),
      icon: const Icon(Icons.add, size: 18),
      label: Text('${AppStrings.add} مستخدم', style: GoogleFonts.cairo()),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context, bool isDark) {
    return BlocBuilder<UsersCubit, UsersState>(
      builder: (context, state) {
        final tabs = [
          _FilterTab('الكل', state.totalCount, null),
          _FilterTab('طلاب', state.studentsCount, UserRole.student),
          _FilterTab('مدراء', state.adminsCount, UserRole.admin),
        ];

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: tabs.map((tab) {
              final isSelected = state.selectedRole == tab.role;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: FilterChip(
                  selected: isSelected,
                  onSelected: (_) {
                    context.read<UsersCubit>().filterByRole(
                      isSelected ? null : tab.role,
                    );
                  },
                  label: Text(
                    '${tab.label} (${tab.count})',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    ),
                  ),
                  selectedColor: AppColors.primary,
                  backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              );
            }).toList(),
          ),
        );
      },
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildSearchAndActions(BuildContext context, bool isDark) {
    return BlocBuilder<UsersCubit, UsersState>(
      builder: (context, state) {
        return Row(
          children: [
            // Search
            Expanded(
              flex: 3,
              child: TextField(
                onChanged: (v) => context.read<UsersCubit>().search(v),
                style: GoogleFonts.cairo(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  hintText: AppStrings.search,
                  hintStyle: GoogleFonts.cairo(
                    color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Bulk delete
            if (state.selectedIds.isNotEmpty) ...[
              FilledButton.icon(
                onPressed: () => _confirmBulkDelete(context, state.selectedIds.length),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: Text(
                  '${AppStrings.deleteSelected} (${state.selectedIds.length})',
                  style: GoogleFonts.cairo(),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 12),
            ],

            // Refresh
            IconButton(
              onPressed: () => context.read<UsersCubit>().loadUsers(),
              icon: const Icon(Icons.refresh),
              tooltip: AppStrings.refresh,
              style: IconButton.styleFrom(
                backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
              ),
            ),
          ],
        );
      },
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildDataTable(BuildContext context, bool isDark) {
    return BlocBuilder<UsersCubit, UsersState>(
      builder: (context, state) {
        if (state.status == UsersStatus.loading) {
          return _buildLoadingShimmer(isDark);
        }

        if (state.status == UsersStatus.error) {
          return _buildErrorState(context, isDark, state.errorMessage ?? AppStrings.generalError);
        }

        if (state.filteredUsers.isEmpty) {
          return _buildEmptyState(isDark);
        }

        return Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: DataTable2(
                    columnSpacing: 12,
                    horizontalMargin: 16,
                    dataRowHeight: 64,
                    headingRowHeight: 56,
                    headingRowColor: WidgetStateProperty.all(
                      isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                    ),
                    headingTextStyle: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    dataTextStyle: GoogleFonts.cairo(
                      fontSize: 13,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                    columns: [
                      DataColumn2(
                        label: Checkbox(
                          value: state.selectedIds.length == state.filteredUsers.length &&
                              state.filteredUsers.isNotEmpty,
                          onChanged: (_) => context.read<UsersCubit>().selectAll(),
                          activeColor: AppColors.primary,
                        ),
                        fixedWidth: 56,
                      ),
                      DataColumn2(
                        label: Text('الاسم', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                        size: ColumnSize.L,
                      ),
                      DataColumn2(
                        label: Text(AppStrings.email, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                        size: ColumnSize.L,
                      ),
                      DataColumn2(
                        label: Text('الدور', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                        size: ColumnSize.S,
                      ),
                      DataColumn2(
                        label: Text(AppStrings.status, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                        size: ColumnSize.S,
                      ),

                      DataColumn2(
                        label: Text('انتهاء الاشتراك', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                        size: ColumnSize.M,
                      ),
                      DataColumn2(
                        label: Text(AppStrings.actions, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                        fixedWidth: 120,
                      ),
                    ],
                    rows: state.paginatedUsers.map((user) {
                      final isSelected = state.selectedIds.contains(user.id);
                      return DataRow2(
                        selected: isSelected,
                        onSelectChanged: (_) => context.read<UsersCubit>().toggleSelection(user.id),
                        color: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return AppColors.primary.withOpacity(0.05);
                          }
                          return null;
                        }),
                        cells: [
                          DataCell(
                            Checkbox(
                              value: isSelected,
                              onChanged: (_) => context.read<UsersCubit>().toggleSelection(user.id),
                              activeColor: AppColors.primary,
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.primary.withOpacity(0.1),
                                  child: Text(
                                    user.name.isNotEmpty ? user.name[0] : '?',
                                    style: GoogleFonts.cairo(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    user.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(Text(user.email, overflow: TextOverflow.ellipsis)),
                          DataCell(_buildRoleChip(user.role)),
                          DataCell(_buildStatusBadge(user.isActive)),

                          DataCell(
                            Text(
                              user.subscriptionExpiry != null
                                  ? intl.DateFormat('yyyy/MM/dd').format(user.subscriptionExpiry!)
                                  : 'غير محدد',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _showUserDialog(context, user: user),
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  tooltip: AppStrings.edit,
                                  style: IconButton.styleFrom(
                                    foregroundColor: AppColors.info,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _confirmDelete(context, user),
                                  icon: const Icon(Icons.delete_outline, size: 18),
                                  tooltip: AppStrings.delete,
                                  style: IconButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
            ),
            const SizedBox(height: 16),

            // ── Pagination ──────────────────────────────────
            _buildPagination(context, state, isDark),
          ],
        );
      },
    );
  }

  Widget _buildRoleChip(UserRole role) {
    Color color;
    String label;
    switch (role) {
      case UserRole.admin:
        color = AppColors.error;
        label = 'مدير';
        break;
      case UserRole.student:
        color = AppColors.success;
        label = 'طالب';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.successBg : AppColors.errorBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? AppStrings.active : AppStrings.inactive,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildPagination(BuildContext context, UsersState state, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: state.currentPage > 1
              ? () => context.read<UsersCubit>().changePage(state.currentPage - 1)
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
        ...List.generate(state.totalPages, (index) {
          final page = index + 1;
          final isSelected = page == state.currentPage;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => context.read<UsersCubit>().changePage(page),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? null
                      : Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$page',
                  style: GoogleFonts.cairo(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
        IconButton(
          onPressed: state.currentPage < state.totalPages
              ? () => context.read<UsersCubit>().changePage(state.currentPage + 1)
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms);
  }

  Widget _buildLoadingShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.cardDark : Colors.grey[300]!,
      highlightColor: isDark ? AppColors.surfaceDark : Colors.grey[100]!,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.noData,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لا يوجد مستخدمون مطابقون للبحث',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildErrorState(BuildContext context, bool isDark, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: AppColors.error.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.read<UsersCubit>().loadUsers(),
            icon: const Icon(Icons.refresh),
            label: Text(AppStrings.refresh, style: GoogleFonts.cairo()),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }

  void _showUserDialog(BuildContext context, {UserModel? user}) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<UsersCubit>(),
        child: UserFormDialog(
          user: user,
          initialStages: _stages,
          initialGrades: const [],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(AppStrings.confirm, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: Text(
            'هل أنت متأكد من حذف المستخدم "${user.name}"؟',
            style: GoogleFonts.cairo(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppStrings.cancel, style: GoogleFonts.cairo()),
            ),
            FilledButton(
              onPressed: () {
                context.read<UsersCubit>().deleteUser(user.id);
                Navigator.pop(dialogContext);
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: Text(AppStrings.delete, style: GoogleFonts.cairo()),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmBulkDelete(BuildContext context, int count) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(AppStrings.confirm, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: Text(
            'هل أنت متأكد من حذف $count مستخدم؟',
            style: GoogleFonts.cairo(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppStrings.cancel, style: GoogleFonts.cairo()),
            ),
            FilledButton(
              onPressed: () {
                context.read<UsersCubit>().deleteSelected();
                Navigator.pop(dialogContext);
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: Text(AppStrings.deleteSelected, style: GoogleFonts.cairo()),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTab {
  final String label;
  final int count;
  final UserRole? role;
  _FilterTab(this.label, this.count, this.role);
}

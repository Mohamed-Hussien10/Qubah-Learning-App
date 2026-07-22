import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:web_dashboard/core/constants/app_colors.dart';
import 'package:web_dashboard/core/constants/app_strings.dart';
import 'package:web_dashboard/core/services/dependency_injection.dart';
import 'package:web_dashboard/features/packages/data/models/package_model.dart';
import 'package:web_dashboard/features/packages/presentation/manager/packages_cubit.dart';
import 'package:web_dashboard/features/packages/presentation/manager/packages_state.dart';
import 'package:web_dashboard/features/packages/presentation/widgets/package_form_dialog.dart';

class PackagesScreen extends StatelessWidget {
  const PackagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PackagesCubit>()..loadPackages(),
      child: const _PackagesScreenBody(),
    );
  }
}

class _PackagesScreenBody extends StatefulWidget {
  const _PackagesScreenBody();

  @override
  State<_PackagesScreenBody> createState() => _PackagesScreenBodyState();
}

class _PackagesScreenBodyState extends State<_PackagesScreenBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFormDialog(BuildContext context, [PackageModel? package]) {
    final cubit = context.read<PackagesCubit>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PackageFormDialog(
        package: package,
        onSubmit: (updatedPackage) {
          if (package == null) {
            cubit.createPackage(updatedPackage);
          } else {
            cubit.updatePackage(updatedPackage);
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, PackageModel package) {
    final cubit = context.read<PackagesCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text(AppStrings.deletePackage),
          ],
        ),
        content: Text('هل أنت تأكد من حذف باقة "${package.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              cubit.deletePackage(package.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<PackagesCubit, PackagesState>(
      listener: (context, state) {
        if (state is PackagesActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is PackagesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.packages,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'إدارة بااقات الاشتراك والتسعير للمراحل والصفوف والدروس',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _openFormDialog(context),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text(AppStrings.addPackage),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Content Area
            Expanded(
              child: BlocBuilder<PackagesCubit, PackagesState>(
                builder: (context, state) {
                  if (state is PackagesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is PackagesError && state is! PackagesLoaded) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: AppColors.error),
                          const SizedBox(height: 16),
                          Text(state.message),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                context.read<PackagesCubit>().loadPackages(),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is PackagesLoaded) {
                    final packages = state.filteredPackages;
                    final totalCount = state.packages.length;
                    final activeCount = state.packages
                        .where((p) => p.isActive)
                        .length;
                    final inactiveCount = totalCount - activeCount;

                    return Column(
                      children: [
                        // KPI Stat Cards
                        Row(
                          children: [
                            _buildStatCard(
                              title: 'إجمالي الباقات',
                              value: '$totalCount',
                              icon: Icons.card_membership_rounded,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 16),
                            _buildStatCard(
                              title: 'الباقات المفعّلة',
                              value: '$activeCount',
                              icon: Icons.check_circle_outline_rounded,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 16),
                            _buildStatCard(
                              title: 'الباقات المعطلة',
                              value: '$inactiveCount',
                              icon: Icons.pause_circle_outline_rounded,
                              color: AppColors.warning,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Search Bar Card
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: theme.dividerColor.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search, color: Colors.grey),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: const InputDecoration(
                                      hintText: 'ابحث عن اسم الباقة أو النطاق...',
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (q) => context
                                        .read<PackagesCubit>()
                                        .filterPackages(q),
                                  ),
                                ),
                                if (_searchController.text.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
                                    onPressed: () {
                                      _searchController.clear();
                                      context
                                          .read<PackagesCubit>()
                                          .filterPackages('');
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Main Data Table Card
                        Expanded(
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: theme.dividerColor.withValues(alpha: 0.1),
                              ),
                            ),
                            child: packages.isEmpty
                                ? const Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.inbox_rounded,
                                            size: 48, color: Colors.grey),
                                        SizedBox(height: 12),
                                        Text(
                                          'لا توجد باقات اشتراك مضافة حتى الآن',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : DataTable2(
                                    columnSpacing: 16,
                                    horizontalMargin: 16,
                                    minWidth: 900,
                                    columns: const [
                                      DataColumn2(
                                        label: Text('اسم الباقة',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        size: ColumnSize.L,
                                      ),
                                      DataColumn2(
                                        label: Text('السعر',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        size: ColumnSize.S,
                                      ),
                                      DataColumn2(
                                        label: Text('نطاق التغطية',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        size: ColumnSize.L,
                                      ),
                                      DataColumn2(
                                        label: Text('مستوى التوقف',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        size: ColumnSize.M,
                                      ),
                                      DataColumn2(
                                        label: Text('تاريخ الانتهاء',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        size: ColumnSize.S,
                                      ),
                                      DataColumn2(
                                        label: Text('الحالة',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        size: ColumnSize.S,
                                      ),
                                      DataColumn2(
                                        label: Text('الإجراءات',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        size: ColumnSize.S,
                                      ),
                                    ],
                                    rows: packages.map((pkg) {
                                      final expiryStr = pkg.expiryDate != null
                                          ? "${pkg.expiryDate!.year}-${pkg.expiryDate!.month.toString().padLeft(2, '0')}-${pkg.expiryDate!.day.toString().padLeft(2, '0')}"
                                          : 'دائم';

                                      return DataRow2(
                                        cells: [
                                          // Package Name & Description
                                          DataCell(
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  pkg.name,
                                                  style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                if (pkg.description != null &&
                                                    pkg.description!
                                                        .isNotEmpty)
                                                  Text(
                                                    pkg.description!,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          // Price
                                          DataCell(
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  pkg.price.toStringAsFixed(2),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                const Text(
                                                  'ر.ع.',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Scope Hierarchy
                                          DataCell(
                                            Text(
                                              pkg.scopeText,
                                              style: const TextStyle(
                                                  fontSize: 13),
                                            ),
                                          ),
                                          // Scope Level Badge
                                          DataCell(
                                            _buildLevelBadge(pkg.scopeLevelLabel),
                                          ),
                                          // Expiry Date
                                          DataCell(
                                            Text(
                                              expiryStr,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: pkg.expiryDate != null &&
                                                        pkg.expiryDate!.isBefore(
                                                            DateTime.now())
                                                    ? AppColors.error
                                                    : Colors.black87,
                                                fontWeight: pkg.expiryDate != null &&
                                                        pkg.expiryDate!.isBefore(
                                                            DateTime.now())
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                          // Status
                                          DataCell(
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: (pkg.isActive
                                                        ? AppColors.success
                                                        : AppColors.error)
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                pkg.isActive
                                                    ? AppStrings.active
                                                    : AppStrings.inactive,
                                                style: TextStyle(
                                                  color: pkg.isActive
                                                      ? AppColors.success
                                                      : AppColors.error,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Actions
                                          DataCell(
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.edit_outlined,
                                                      size: 18,
                                                      color: AppColors.primary),
                                                  onPressed: () =>
                                                      _openFormDialog(
                                                          context, pkg),
                                                  tooltip: AppStrings.edit,
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.delete_outline,
                                                      size: 18,
                                                      color: AppColors.error),
                                                  onPressed: () =>
                                                      _confirmDelete(
                                                          context, pkg),
                                                  tooltip: AppStrings.delete,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                          ),
                        ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelBadge(String label) {
    Color bg = AppColors.primary.withValues(alpha: 0.1);
    Color text = AppColors.primary;

    if (label == 'مرحلة كاملة') {
      bg = Colors.purple.withValues(alpha: 0.1);
      text = Colors.purple;
    } else if (label == 'صف محدد') {
      bg = Colors.blue.withValues(alpha: 0.1);
      text = Colors.blue;
    } else if (label == 'فصل محدد') {
      bg = Colors.teal.withValues(alpha: 0.1);
      text = Colors.teal;
    } else if (label == 'مادة محددة') {
      bg = Colors.orange.withValues(alpha: 0.1);
      text = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

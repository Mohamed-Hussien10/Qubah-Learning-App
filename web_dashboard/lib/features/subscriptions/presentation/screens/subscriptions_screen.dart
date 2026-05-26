import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:web_dashboard/core/constants/app_colors.dart';
import 'package:web_dashboard/core/constants/app_strings.dart';
import 'package:web_dashboard/features/subscriptions/data/models/subscription_model.dart';
import 'package:web_dashboard/features/subscriptions/data/models/plan_model.dart';
import 'package:web_dashboard/features/subscriptions/presentation/manager/subscriptions_cubit.dart';
import 'package:web_dashboard/core/services/dependency_injection.dart';
import 'package:web_dashboard/features/subscriptions/presentation/manager/subscriptions_state.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SubscriptionsCubit>()..loadAll(),
      child: const _SubscriptionsScreenBody(),
    );
  }
}

class _SubscriptionsScreenBody extends StatelessWidget {
  const _SubscriptionsScreenBody();

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
              _buildHeader(context, isDark),
              const SizedBox(height: 24),
              _buildTabs(context, isDark),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<SubscriptionsCubit, SubscriptionsState>(
                  builder: (context, state) {
                    if (state.status == SubscriptionsStatus.loading) {
                      return _buildLoadingShimmer(isDark);
                    }
                    if (state.status == SubscriptionsStatus.error) {
                      return _buildErrorState(context, isDark, state.errorMessage ?? AppStrings.generalError);
                    }
                    return state.selectedTabIndex == 0
                        ? _buildPlansTab(context, state, isDark)
                        : _buildSubscriptionsTab(context, state, isDark);
                  },
                ),
              ),
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
              AppStrings.subscriptions,
              style: GoogleFonts.cairo(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 4),
            BlocBuilder<SubscriptionsCubit, SubscriptionsState>(
              builder: (context, state) {
                return Text(
                  '${state.activeSubscriptionsCount} اشتراك نشط • إيرادات: ${state.totalRevenue.toStringAsFixed(0)} ر.س',
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
        BlocBuilder<SubscriptionsCubit, SubscriptionsState>(
          builder: (context, state) {
            return FilledButton.icon(
              onPressed: () {
                if (state.selectedTabIndex == 0) {
                  _showPlanDialog(context, isDark);
                } else {
                  _showAssignDialog(context, isDark);
                }
              },
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                state.selectedTabIndex == 0 ? 'إضافة باقة' : 'تعيين اشتراك',
                style: GoogleFonts.cairo(),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
        ),
      ],
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }

  Widget _buildTabs(BuildContext context, bool isDark) {
    return BlocBuilder<SubscriptionsCubit, SubscriptionsState>(
      builder: (context, state) {
        return Row(
          children: [
            _buildTab(context, 'الباقات', 0, state.selectedTabIndex, isDark),
            const SizedBox(width: 8),
            _buildTab(context, 'اشتراكات المستخدمين', 1, state.selectedTabIndex, isDark),
          ],
        );
      },
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildTab(BuildContext context, String label, int index, int selected, bool isDark) {
    final isSelected = index == selected;
    return InkWell(
      onTap: () => context.read<SubscriptionsCubit>().changeTab(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : (isDark ? AppColors.cardDark : AppColors.cardLight),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? null
              : Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          ),
        ),
      ),
    );
  }

  Widget _buildPlansTab(BuildContext context, SubscriptionsState state, bool isDark) {
    if (state.plans.isEmpty) {
      return _buildEmptyState(isDark, 'لا توجد باقات');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.85,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: state.plans.length,
          itemBuilder: (context, index) {
            return _buildPlanCard(context, state.plans[index], isDark, index);
          },
        );
      },
    );
  }

  Widget _buildPlanCard(BuildContext context, PlanModel plan, bool isDark, int index) {
    final colors = [AppColors.primary, AppColors.accent, AppColors.warning, AppColors.info];
    final color = colors[index % colors.length];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(19),
                topLeft: Radius.circular(19),
              ),
            ),
            child: Column(
              children: [
                Text(
                  plan.name,
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  plan.priceLabel,
                  style: GoogleFonts.cairo(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '/ ${plan.durationLabel}',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // Features
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...plan.features.take(5).map((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 18, color: color),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                feature,
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )),
                  if (plan.features.length > 5)
                    Text(
                      '+${plan.features.length - 5} ميزات أخرى',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                      ),
                    ),
                  const Spacer(),
                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showPlanDialog(context, isDark, plan: plan),
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: Text(AppStrings.edit, style: GoogleFonts.cairo(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.info,
                            side: const BorderSide(color: AppColors.info),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmDeletePlan(context, plan),
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: Text(AppStrings.delete, style: GoogleFonts.cairo(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (300 + index * 100).ms, duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildSubscriptionsTab(BuildContext context, SubscriptionsState state, bool isDark) {
    if (state.subscriptions.isEmpty) {
      return _buildEmptyState(isDark, 'لا توجد اشتراكات');
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 16,
          dataRowHeight: 60,
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
              label: Text('المستخدم', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              size: ColumnSize.L,
            ),
            DataColumn2(
              label: Text('الباقة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            ),
            DataColumn2(
              label: Text(AppStrings.status, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              size: ColumnSize.S,
            ),
            DataColumn2(
              label: Text('تاريخ البداية', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            ),
            DataColumn2(
              label: Text('تاريخ الانتهاء', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            ),
            DataColumn2(
              label: Text('المبلغ', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              size: ColumnSize.S,
            ),
            DataColumn2(
              label: Text(AppStrings.actions, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              fixedWidth: 100,
            ),
          ],
          rows: state.subscriptions.map((sub) {
            return DataRow2(
              cells: [
                DataCell(
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          sub.userName.isNotEmpty ? sub.userName[0] : '?',
                          style: GoogleFonts.cairo(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(sub.userName, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
                DataCell(Text(sub.planName)),
                DataCell(_buildSubStatusBadge(sub.status)),
                DataCell(Text(intl.DateFormat('yyyy/MM/dd').format(sub.startDate))),
                DataCell(Text(intl.DateFormat('yyyy/MM/dd').format(sub.endDate))),
                DataCell(Text('${sub.amount.toStringAsFixed(0)} ر.س')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (sub.status == SubscriptionStatus.active)
                        IconButton(
                          onPressed: () => context.read<SubscriptionsCubit>().cancelSubscription(sub.id),
                          icon: const Icon(Icons.cancel_outlined, size: 18),
                          tooltip: 'إلغاء',
                          style: IconButton.styleFrom(foregroundColor: AppColors.warning),
                        ),
                      IconButton(
                        onPressed: () => _confirmDeleteSub(context, sub),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        tooltip: AppStrings.delete,
                        style: IconButton.styleFrom(foregroundColor: AppColors.error),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildSubStatusBadge(SubscriptionStatus status) {
    Color color;
    String label;
    switch (status) {
      case SubscriptionStatus.active:
        color = AppColors.success;
        label = 'نشط';
        break;
      case SubscriptionStatus.expired:
        color = AppColors.warning;
        label = 'منتهي';
        break;
      case SubscriptionStatus.cancelled:
        color = AppColors.error;
        label = 'ملغي';
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
        style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Widget _buildLoadingShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.cardDark : Colors.grey[300]!,
      highlightColor: isDark ? AppColors.surfaceDark : Colors.grey[100]!,
      child: Column(
        children: List.generate(5, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        )),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.subscriptions_outlined, size: 80,
            color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.cairo(
            fontSize: 18, fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          )),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildErrorState(BuildContext context, bool isDark, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: AppColors.error.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.cairo(
            fontSize: 16, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          )),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.read<SubscriptionsCubit>().loadAll(),
            icon: const Icon(Icons.refresh),
            label: Text(AppStrings.refresh, style: GoogleFonts.cairo()),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }

  void _showPlanDialog(BuildContext context, bool isDark, {PlanModel? plan}) {
    final nameCtrl = TextEditingController(text: plan?.name ?? '');
    final priceCtrl = TextEditingController(text: plan?.price.toString() ?? '');
    final durationCtrl = TextEditingController(text: plan?.durationMonths.toString() ?? '');
    final featuresCtrl = TextEditingController(text: plan?.features.join('\n') ?? '');

    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            plan != null ? 'تعديل الباقة' : 'إضافة باقة جديدة',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          ),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    style: GoogleFonts.cairo(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    decoration: InputDecoration(
                      labelText: 'اسم الباقة',
                      labelStyle: GoogleFonts.cairo(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.cairo(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    decoration: InputDecoration(
                      labelText: 'السعر (ر.س)',
                      labelStyle: GoogleFonts.cairo(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: durationCtrl,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.cairo(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    decoration: InputDecoration(
                      labelText: 'المدة (أشهر)',
                      labelStyle: GoogleFonts.cairo(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: featuresCtrl,
                    maxLines: 4,
                    style: GoogleFonts.cairo(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    decoration: InputDecoration(
                      labelText: 'الميزات (سطر لكل ميزة)',
                      labelStyle: GoogleFonts.cairo(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.cancel, style: GoogleFonts.cairo()),
            ),
            FilledButton(
              onPressed: () {
                final newPlan = PlanModel(
                  id: plan?.id ?? 0,
                  name: nameCtrl.text,
                  price: double.tryParse(priceCtrl.text) ?? 0,
                  durationMonths: int.tryParse(durationCtrl.text) ?? 1,
                  features: featuresCtrl.text.split('\n').where((f) => f.trim().isNotEmpty).toList(),
                  isActive: true,
                );
                if (plan != null) {
                  context.read<SubscriptionsCubit>().updatePlan(newPlan);
                } else {
                  context.read<SubscriptionsCubit>().createPlan(newPlan);
                }
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text(AppStrings.save, style: GoogleFonts.cairo()),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignDialog(BuildContext context, bool isDark) {
    final userIdCtrl = TextEditingController();
    final userNameCtrl = TextEditingController();
    String selectedPlan = '';
    double amount = 0;

    showDialog(
      context: context,
      builder: (_) => BlocBuilder<SubscriptionsCubit, SubscriptionsState>(
        builder: (context, state) {
          if (selectedPlan.isEmpty && state.plans.isNotEmpty) {
            selectedPlan = state.plans.first.name;
            amount = state.plans.first.price;
          }
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('تعيين اشتراك',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: userIdCtrl,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.cairo(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                      decoration: InputDecoration(
                        labelText: 'رقم المستخدم',
                        labelStyle: GoogleFonts.cairo(),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: userNameCtrl,
                      style: GoogleFonts.cairo(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                      decoration: InputDecoration(
                        labelText: 'اسم المستخدم',
                        labelStyle: GoogleFonts.cairo(),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedPlan.isEmpty ? null : selectedPlan,
                      style: GoogleFonts.cairo(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                      decoration: InputDecoration(
                        labelText: 'الباقة',
                        labelStyle: GoogleFonts.cairo(),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                      items: state.plans.map((p) => DropdownMenuItem(
                        value: p.name,
                        child: Text(p.name, style: GoogleFonts.cairo()),
                      )).toList(),
                      onChanged: (v) {
                        selectedPlan = v ?? '';
                        final plan = state.plans.firstWhere((p) => p.name == v);
                        amount = plan.price;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppStrings.cancel, style: GoogleFonts.cairo()),
                ),
                FilledButton(
                  onPressed: () {
                    context.read<SubscriptionsCubit>().assignSubscription(
                      userId: int.tryParse(userIdCtrl.text) ?? 0,
                      userName: userNameCtrl.text,
                      planName: selectedPlan,
                      startDate: DateTime.now(),
                      endDate: DateTime.now().add(const Duration(days: 365)),
                      amount: amount,
                    );
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  child: Text('تعيين', style: GoogleFonts.cairo()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmDeletePlan(BuildContext context, PlanModel plan) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(AppStrings.confirm, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: Text('هل أنت متأكد من حذف باقة "${plan.name}"؟', style: GoogleFonts.cairo()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.cancel, style: GoogleFonts.cairo()),
            ),
            FilledButton(
              onPressed: () {
                context.read<SubscriptionsCubit>().deletePlan(plan.id);
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: Text(AppStrings.delete, style: GoogleFonts.cairo()),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteSub(BuildContext context, SubscriptionModel sub) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(AppStrings.confirm, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: Text('هل أنت متأكد من حذف اشتراك "${sub.userName}"؟', style: GoogleFonts.cairo()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.cancel, style: GoogleFonts.cairo()),
            ),
            FilledButton(
              onPressed: () {
                context.read<SubscriptionsCubit>().cancelSubscription(sub.id);
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: Text(AppStrings.delete, style: GoogleFonts.cairo()),
            ),
          ],
        ),
      ),
    );
  }
}

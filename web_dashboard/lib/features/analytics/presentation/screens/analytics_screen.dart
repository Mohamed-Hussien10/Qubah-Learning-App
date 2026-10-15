import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:web_dashboard/core/constants/app_colors.dart';
import 'package:web_dashboard/core/constants/app_strings.dart';
import 'package:web_dashboard/core/widgets/stat_card.dart';
import 'package:web_dashboard/features/analytics/presentation/manager/analytics_cubit.dart';
import 'package:web_dashboard/features/analytics/presentation/manager/analytics_state.dart';
import 'package:web_dashboard/features/analytics/presentation/widgets/bar_chart_widget.dart';
import 'package:web_dashboard/features/analytics/presentation/widgets/pie_chart_widget.dart';
import 'package:web_dashboard/core/services/dependency_injection.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AnalyticsCubit>()..loadAnalytics(),
      child: const _AnalyticsView(),
    );
  }
}

class _AnalyticsView extends StatelessWidget {
  const _AnalyticsView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<AnalyticsCubit, AnalyticsState>(
        builder: (context, state) {
          if (state.status == AnalyticsStatus.loading ||
              state.status == AnalyticsStatus.initial) {
            return _buildShimmer(isDark);
          }

          if (state.status == AnalyticsStatus.error) {
            return _buildError(context, state.errorMessage ?? '');
          }

          return RefreshIndicator(
            onRefresh: () => context.read<AnalyticsCubit>().refreshAnalytics(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context, isDark),
                  const SizedBox(height: 24),
                  _buildStatCards(state),
                  const SizedBox(height: 24),
                  _buildChartsRow(state),
                  const SizedBox(height: 24),
                  _buildPieChartsRow(state),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.02, end: 0);
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.analytics_rounded, color: AppColors.primary, size: 28),
            const SizedBox(width: 12),
            Text(
              AppStrings.analytics,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: AppStrings.refresh,
          onPressed: () => context.read<AnalyticsCubit>().refreshAnalytics(),
          style: IconButton.styleFrom(
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCards(AnalyticsState state) {
    final user = state.userAnalytics!;
    final content = state.contentAnalytics!;
    final revenue = state.revenueAnalytics!;

    final cards = [
      StatCard(
        title: 'إجمالي المستخدمين',
        value: '${user.totalUsers}',
        icon: Icons.people_rounded,
        iconColor: AppColors.primary,
        iconBackgroundColor: AppColors.primary.withValues(alpha: 0.15),
        changeText: '+${user.newUsersThisMonth} هذا الشهر',
        isPositiveTrend: true,
      ),
      StatCard(
        title: 'المستخدمون النشطون',
        value: '${user.activeUsers}',
        icon: Icons.offline_bolt_rounded,
        iconColor: AppColors.accent,
        iconBackgroundColor: AppColors.accent.withValues(alpha: 0.15),
        changeText: '${user.activePercentage.toStringAsFixed(1)}% نسبة النشاط',
        isPositiveTrend: true,
      ),
      StatCard(
        title: 'الدروس التعليمية',
        value: '${content.totalLessons}',
        icon: Icons.menu_book_rounded,
        iconColor: AppColors.info,
        iconBackgroundColor: AppColors.info.withValues(alpha: 0.15),
        subtitle: 'موزعة على كافة المراحل',
      ),
      StatCard(
        title: 'إجمالي الإيرادات',
        value: '${revenue.totalRevenue.toInt()} ر.س',
        icon: Icons.account_balance_wallet_rounded,
        iconColor: AppColors.success,
        iconBackgroundColor: AppColors.success.withValues(alpha: 0.15),
        changeText: '+12% النمو',
        isPositiveTrend: true,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 840) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 14),
                Expanded(child: cards[1]),
                const SizedBox(width: 14),
                Expanded(child: cards[2]),
                const SizedBox(width: 14),
                Expanded(child: cards[3]),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 220, child: cards[0]),
                const SizedBox(width: 14),
                SizedBox(width: 220, child: cards[1]),
                const SizedBox(width: 14),
                SizedBox(width: 220, child: cards[2]),
                const SizedBox(width: 14),
                SizedBox(width: 220, child: cards[3]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChartsRow(AnalyticsState state) {
    final userGrowth = state.userAnalytics!.monthlyGrowth;
    final revenue = state.revenueAnalytics!.monthlyRevenue;

    final userLabels = userGrowth.map((d) => d.month).toList();
    final userValues = userGrowth.map((d) => d.value).toList();

    final revLabels = revenue.map((d) => d.month).toList();
    final revValues = revenue.map((d) => d.value).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        if (width >= 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  height: 350,
                  child: BarChartWidget(
                    title: 'نمو المستخدمين (شهرياً)',
                    labels: userLabels,
                    values: userValues,
                    tooltipSuffix: 'مستخدم جديد',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 350,
                  child: BarChartWidget(
                    title: 'الإيرادات الشهرية',
                    labels: revLabels,
                    values: revValues,
                    tooltipSuffix: 'ر.س',
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            SizedBox(
              height: 350,
              child: BarChartWidget(
                title: 'نمو المستخدمين (شهرياً)',
                labels: userLabels,
                values: userValues,
                tooltipSuffix: 'مستخدم جديد',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 350,
              child: BarChartWidget(
                title: 'الإيرادات الشهرية',
                labels: revLabels,
                values: revValues,
                tooltipSuffix: 'ر.س',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPieChartsRow(AnalyticsState state) {
    final rawUserRoles = state.userAnalytics!.usersByRole;
    final subscriptions = state.revenueAnalytics!.subscriptionBreakdown;

    // The system has only two roles: students and admins
    final Map<String, double> userRolesDouble = {};
    if (rawUserRoles.containsKey('طلاب')) {
      userRolesDouble['طلاب'] = rawUserRoles['طلاب']!.toDouble();
    }
    if (rawUserRoles.containsKey('مدراء')) {
      userRolesDouble['مدراء'] = rawUserRoles['مدراء']!.toDouble();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        if (width >= 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  height: 310,
                  child: PieChartWidget(
                    title: 'المستخدمون حسب الدور',
                    data: userRolesDouble,
                    isDonut: false,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 310,
                  child: PieChartWidget(
                    title: 'توزيع مبيعات الباقات',
                    data: subscriptions,
                    isDonut: true,
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            SizedBox(
              height: 310,
              child: PieChartWidget(
                title: 'المستخدمون حسب الدور',
                data: userRolesDouble,
                isDonut: false,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 310,
              child: PieChartWidget(
                title: 'توزيع مبيعات الباقات',
                data: subscriptions,
                isDonut: true,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 80, color: AppColors.error),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: AppColors.error)),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => context.go('/force-logout'),
            icon: const Icon(Icons.login_rounded),
            label: const Text(AppStrings.login),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Shimmer.fromColors(
        baseColor: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
        highlightColor: isDark ? AppColors.cardDark : Colors.grey.shade50,
        child: Column(
          children: [
            Container(height: 30, width: 200, color: Colors.white),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: List.generate(4, (_) => Container(height: 100, color: Colors.white)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: Container(height: 300, color: Colors.white)),
                const SizedBox(width: 16),
                Expanded(child: Container(height: 300, color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

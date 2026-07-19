import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                  const SizedBox(height: 24),
                  _buildMostViewedLessons(state, isDark),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 4;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 1000) {
          crossAxisCount = 2;
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: crossAxisCount == 1 ? 2.5 : 1.6,
          children: [
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
          ],
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
                  height: 320,
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
                  height: 320,
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
              height: 320,
              child: BarChartWidget(
                title: 'نمو المستخدمين (شهرياً)',
                labels: userLabels,
                values: userValues,
                tooltipSuffix: 'مستخدم جديد',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 320,
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
    final userRoles = state.userAnalytics!.usersByRole;
    final subscriptions = state.revenueAnalytics!.subscriptionBreakdown;

    final Map<String, double> userRolesDouble =
        userRoles.map((k, v) => MapEntry(k, v.toDouble()));

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        if (width >= 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  height: 250,
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
                  height: 250,
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
              height: 250,
              child: PieChartWidget(
                title: 'المستخدمون حسب الدور',
                data: userRolesDouble,
                isDonut: false,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
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

  Widget _buildMostViewedLessons(AnalyticsState state, bool isDark) {
    final lessons = state.contentAnalytics!.mostViewedLessons;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الدروس الأكثر مشاهدة ومتابعة',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lessons.length,
              separatorBuilder: (_, _) => Divider(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        radius: 18,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          lesson.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.remove_red_eye_rounded, size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            '${lesson.views} مشاهدة',
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
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
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.read<AnalyticsCubit>().loadAnalytics(),
            icon: const Icon(Icons.refresh),
            label: const Text(AppStrings.refresh),
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

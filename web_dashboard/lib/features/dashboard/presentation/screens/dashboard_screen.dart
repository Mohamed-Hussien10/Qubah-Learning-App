import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import 'package:web_dashboard/core/constants/app_colors.dart';
import 'package:web_dashboard/core/constants/app_strings.dart';
import 'package:web_dashboard/core/widgets/stat_card.dart';
import 'package:web_dashboard/features/dashboard/presentation/manager/dashboard_cubit.dart';
import 'package:web_dashboard/features/dashboard/presentation/manager/dashboard_state.dart';
import 'package:web_dashboard/features/dashboard/presentation/widgets/quick_actions_card.dart';
import 'package:web_dashboard/features/dashboard/presentation/widgets/recent_activity_card.dart';
import 'package:web_dashboard/features/dashboard/presentation/widgets/revenue_chart.dart';
import 'package:web_dashboard/features/dashboard/presentation/widgets/user_growth_chart.dart';
import 'package:web_dashboard/core/services/dependency_injection.dart';

/// The main dashboard home screen.
///
/// Shows stat cards, revenue & user-growth charts, recent activity,
/// and quick-action buttons. Fully responsive across desktop / tablet / mobile.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardCubit>(
      create: (_) => sl<DashboardCubit>()..loadDashboard(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading || state is DashboardInitial) {
          return _buildShimmerLoading(context);
        }

        if (state is DashboardError) {
          return _buildError(context, state.message);
        }

        if (state is DashboardLoaded) {
          return _buildContent(context, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Loaded content
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildContent(BuildContext context, DashboardLoaded state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;

    return RefreshIndicator(
      onRefresh: () => context.read<DashboardCubit>().refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(width > 600 ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Page header ───────────────────────────────────────────
            _buildHeader(isDark),
            const SizedBox(height: 24),

            // ── Stat cards row ────────────────────────────────────────
            _buildStatCards(state, width),
            const SizedBox(height: 24),

            // ── Charts row ────────────────────────────────────────────
            _buildChartsRow(state, width),
            const SizedBox(height: 24),

            // ── Activity + quick actions ──────────────────────────────
            _buildBottomRow(state, width),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Header
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.dashboard,
              style: GoogleFonts.cairo(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'نظرة عامة على أداء المنصة',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildHeaderAction(
              icon: Icons.refresh_rounded,
              tooltip: AppStrings.refresh,
              onTap: () => context.read<DashboardCubit>().refresh(),
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _buildHeaderAction(
              icon: Icons.file_download_outlined,
              tooltip: AppStrings.exportData,
              onTap: () {},
              isDark: isDark,
            ),
          ],
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: -0.1, end: 0, duration: 500.ms);
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Stat cards – responsive grid
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildStatCards(DashboardLoaded state, double width) {
    final stats = state.stats;

    final cards = [
      StatCard(
        title: AppStrings.totalUsers,
        value: _formatNumber(stats.totalUsers),
        icon: Icons.people_rounded,
        iconColor: AppColors.primary,
        iconBackgroundColor: const Color(0xFFEDE9FE),
        changeText: '${stats.userGrowthPercent >= 0 ? "+" : ""}${stats.userGrowthPercent.toStringAsFixed(1)}%',
        isPositiveTrend: stats.userGrowthPercent >= 0,
      ),

      StatCard(
        title: AppStrings.totalLessons,
        value: _formatNumber(stats.totalLessons),
        icon: Icons.menu_book_rounded,
        iconColor: AppColors.info,
        iconBackgroundColor: AppColors.infoBg,
        changeText: '+3.8%',
        isPositiveTrend: true,
      ),
      StatCard(
        title: AppStrings.totalRevenue,
        value: '${_formatNumber(stats.totalRevenue.toInt())} ر.س',
        icon: Icons.account_balance_wallet_rounded,
        iconColor: AppColors.success,
        iconBackgroundColor: AppColors.successBg,
        changeText: '${stats.revenueGrowthPercent >= 0 ? "+" : ""}${stats.revenueGrowthPercent.toStringAsFixed(1)}%',
        isPositiveTrend: stats.revenueGrowthPercent >= 0,
      ),
    ];

    // Responsive: 4 cols desktop, 2 tablet, 1 mobile
    int crossAxisCount;
    if (width >= 1200) {
      crossAxisCount = 4;
    } else if (width >= 700) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: crossAxisCount == 1 ? 2.5 : 1.6,
      ),
      itemCount: cards.length,
      itemBuilder: (_, i) => cards[i],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Charts row
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildChartsRow(DashboardLoaded state, double width) {
    final revenueChart = RevenueChart(data: state.revenueData)
        .animate()
        .fadeIn(duration: 600.ms, delay: 300.ms)
        .slideY(begin: 0.1, end: 0, duration: 600.ms, delay: 300.ms);

    final userChart = UserGrowthChart(data: state.userGrowthData)
        .animate()
        .fadeIn(duration: 600.ms, delay: 450.ms)
        .slideY(begin: 0.1, end: 0, duration: 600.ms, delay: 450.ms);

    if (width >= 900) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: revenueChart),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: userChart),
        ],
      );
    }

    return Column(
      children: [
        revenueChart,
        const SizedBox(height: 16),
        userChart,
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Bottom row – recent activity + quick actions
  // ─────────────────────────────────────────────────────────────────────
  Widget _buildBottomRow(DashboardLoaded state, double width) {
    final activityCard = RecentActivityCard(activities: state.recentActivity)
        .animate()
        .fadeIn(duration: 600.ms, delay: 500.ms)
        .slideY(begin: 0.1, end: 0, duration: 600.ms, delay: 500.ms);

    final actionsCard = QuickActionsCard(
      onActionTap: (action) => _handleQuickAction(action),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 600.ms)
        .slideY(begin: 0.1, end: 0, duration: 600.ms, delay: 600.ms);

    if (width >= 900) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: activityCard),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: actionsCard),
        ],
      );
    }

    return Column(
      children: [
        activityCard,
        const SizedBox(height: 16),
        actionsCard,
      ],
    );
  }

  void _handleQuickAction(String action) {
    // TODO: Navigate to the appropriate route
    debugPrint('Quick action tapped: $action');
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Shimmer loading
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildShimmerLoading(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? AppColors.surfaceDark : const Color(0xFFE8E8E8);
    final highlightColor =
        isDark ? AppColors.cardDark : const Color(0xFFF5F5F5);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title shimmer
            Container(
              width: 200,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 300,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 24),

            // Stat cards shimmer
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: _responsiveColumns(context),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.6,
              children: List.generate(
                3,
                (_) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Chart shimmer
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 340,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 340,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Bottom row shimmer
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _responsiveColumns(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1200) return 4;
    if (w >= 700) return 2;
    return 1;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Error state
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildError(BuildContext context, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.generalError,
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<DashboardCubit>().refresh(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                AppStrings.refresh,
                style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(number % 1000 == 0 ? 0 : 1)}K';
    }
    return number.toString();
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:web_dashboard/core/constants/app_colors.dart';
import 'package:web_dashboard/core/constants/app_strings.dart';
import 'package:web_dashboard/features/dashboard/data/models/chart_data.dart';

/// Revenue bar/line chart widget using fl_chart.
///
/// Displays monthly revenue with a gradient-filled bar chart, tooltips,
/// and responsive sizing.
class RevenueChart extends StatelessWidget {
  final List<RevenueData> data;

  const RevenueChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.chartPalette[0].withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.bar_chart_rounded,
                      color: AppColors.chartPalette[0],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppStrings.revenueChart,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '٢٠٢٦',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Chart ─────────────────────────────────────────────────────
          SizedBox(
            height: 260,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => isDark
                        ? AppColors.surfaceDark
                        : AppColors.textPrimaryLight,
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${data[group.x].month}\n',
                        GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text:
                                '${data[group.x].amount.toStringAsFixed(0)} ر.س',
                            style: GoogleFonts.cairo(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= data.length) {
                          return const SizedBox.shrink();
                        }
                        // Show abbreviated month (first 3 chars)
                        final label = data[index].month.length > 3
                            ? data[index].month.substring(0, 3)
                            : data[index].month;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            label,
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              color: isDark
                                  ? AppColors.textTertiaryDark
                                  : AppColors.textTertiaryLight,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      interval: _maxY / 5,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value / 1000).toStringAsFixed(0)}K',
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            color: isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textTertiaryLight,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _maxY / 5,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: (isDark ? AppColors.borderDark : AppColors.borderLight)
                        .withValues(alpha: 0.5),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _buildBarGroups(),
              ),
              duration: const Duration(milliseconds: 500),
            ),
          ),
        ],
      ),
    );
  }

  double get _maxY {
    if (data.isEmpty) return 15000;
    final maxAmount =
        data.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
    final calculatedMax = (maxAmount * 1.2).ceilToDouble();
    return calculatedMax <= 0 ? 15000 : calculatedMax;
  }

  List<BarChartGroupData> _buildBarGroups() {
    return data.asMap().entries.map((entry) {
      final i = entry.key;
      final d = entry.value;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: d.amount,
            width: 16,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6),
            ),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                AppColors.chartPalette[0].withValues(alpha: 0.7),
                AppColors.chartPalette[0],
              ],
            ),
          ),
        ],
      );
    }).toList();
  }
}

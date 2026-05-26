import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:web_dashboard/core/constants/app_colors.dart';

class PieChartWidget extends StatefulWidget {
  final String title;
  final Map<String, double> data;
  final bool isDonut;

  const PieChartWidget({
    super.key,
    required this.title,
    required this.data,
    this.isDonut = true,
  });

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final entries = widget.data.entries.toList();
    final double total = widget.data.values.fold(0, (sum, val) => sum + val);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 4,
                        centerSpaceRadius: widget.isDonut ? 40 : 0,
                        sections: List.generate(entries.length, (i) {
                          final entry = entries[i];
                          final isTouched = i == touchedIndex;
                          final fontSize = isTouched ? 16.0 : 12.0;
                          final radius = isTouched ? 60.0 : 50.0;
                          final color = AppColors.chartPalette[i % AppColors.chartPalette.length];
                          final percent = total > 0 ? (entry.value / total) * 100 : 0;

                          return PieChartSectionData(
                            color: color,
                            value: entry.value,
                            title: '${percent.toStringAsFixed(0)}%',
                            radius: radius,
                            titleStyle: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Legend
                  Expanded(
                    flex: 2,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: entries.length,
                      itemBuilder: (context, i) {
                        final entry = entries[i];
                        final color = AppColors.chartPalette[i % AppColors.chartPalette.length];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

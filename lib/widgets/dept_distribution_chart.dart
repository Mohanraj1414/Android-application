import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Donut chart for department-wise employee distribution with legend.
class DeptDistributionChart extends StatefulWidget {
  final Map<String, int> departmentCounts;
  final int totalEmployees;

  const DeptDistributionChart({
    super.key,
    required this.departmentCounts,
    required this.totalEmployees,
  });

  @override
  State<DeptDistributionChart> createState() => _DeptDistributionChartState();
}

class _DeptDistributionChartState extends State<DeptDistributionChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.departmentCounts.isEmpty || widget.totalEmployees == 0) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: Text(
            'No department distribution data available',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ),
      );
    }

    final entries = widget.departmentCounts.entries.toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 420;

        final chartWidget = SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
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
                        touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 3,
                  centerSpaceRadius: 55,
                  sections: List.generate(entries.length, (i) {
                    final isTouched = i == touchedIndex;
                    final radius = isTouched ? 28.0 : 22.0;
                    final color = AppColors.departmentPalette[i % AppColors.departmentPalette.length];
                    final count = entries[i].value;

                    return PieChartSectionData(
                      color: color,
                      value: count.toDouble(),
                      title: '',
                      radius: radius,
                    );
                  }),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.totalEmployees.toString(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'Workforce',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

        final legendWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(entries.length, (i) {
            final entry = entries[i];
            final color = AppColors.departmentPalette[i % AppColors.departmentPalette.length];
            final percentage = (entry.value / widget.totalEmployees) * 100;
            final isSelected = i == touchedIndex;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '(${entry.value} • ${percentage.toStringAsFixed(0)}%)',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            );
          }),
        );

        if (isNarrow) {
          return Column(
            children: [
              chartWidget,
              const SizedBox(height: 16),
              legendWidget,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            chartWidget,
            const SizedBox(width: 16),
            Expanded(child: legendWidget),
          ],
        );
      },
    );
  }
}

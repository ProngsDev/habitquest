import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';

import '../../../core/utils/chart_data_processor.dart';
import '../../../domain/entities/habit_completion.dart';
import '../common/custom_card.dart';

/// Widget for displaying progress charts and analytics
class ProgressChartsWidget extends StatefulWidget {
  final List<HabitCompletion> completions;

  const ProgressChartsWidget({
    super.key,
    required this.completions,
  });

  @override
  State<ProgressChartsWidget> createState() => _ProgressChartsWidgetState();
}

class _ProgressChartsWidgetState extends State<ProgressChartsWidget> {
  int _selectedChartIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with chart selector
          Row(
            children: [
              const Icon(
                CupertinoIcons.chart_bar_fill,
                size: 24,
                color: CupertinoColors.systemBlue,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Progress Charts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
              ),
              CupertinoSlidingSegmentedControl<int>(
                groupValue: _selectedChartIndex,
                onValueChanged: (value) {
                  setState(() {
                    _selectedChartIndex = value ?? 0;
                  });
                },
                children: const {
                  0: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Week'),
                  ),
                  1: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Month'),
                  ),
                  2: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('XP'),
                  ),
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Chart content
          SizedBox(
            height: 250,
            child: _buildSelectedChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedChart() {
    switch (_selectedChartIndex) {
      case 0:
        return _buildWeeklyChart();
      case 1:
        return _buildMonthlyChart();
      case 2:
        return _buildXpChart();
      default:
        return _buildWeeklyChart();
    }
  }

  Widget _buildWeeklyChart() {
    final weeklyData = ChartDataProcessor.generateWeeklyCompletionData(
      widget.completions,
    );

    if (weeklyData.isEmpty) {
      return _buildEmptyChart('No weekly data available');
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) => ChartDataProcessor.getChartGridLine(),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final labels = ChartDataProcessor.getWeekDayLabels();
                if (value.toInt() >= 0 && value.toInt() < labels.length) {
                  return Text(
                    labels[value.toInt()],
                    style: ChartDataProcessor.getChartAxisLabelStyle(),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  ChartDataProcessor.formatChartValue(value),
                  style: ChartDataProcessor.getChartAxisLabelStyle(),
                );
              },
            ),
          ),
        ),
        borderData: ChartDataProcessor.getChartBorder(),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: weeklyData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) + 1,
        lineBarsData: [
          LineChartBarData(
            spots: weeklyData,
            isCurved: true,
            gradient: ChartDataProcessor.getChartGradient(CupertinoColors.systemBlue),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: ChartDataProcessor.getChartGradient(CupertinoColors.systemBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart() {
    final monthlyData = ChartDataProcessor.generateMonthlyCompletionData(
      widget.completions,
    );

    if (monthlyData.isEmpty) {
      return _buildEmptyChart('No monthly data available');
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) => ChartDataProcessor.getChartGridLine(),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 5,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: ChartDataProcessor.getChartAxisLabelStyle(),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  ChartDataProcessor.formatChartValue(value),
                  style: ChartDataProcessor.getChartAxisLabelStyle(),
                );
              },
            ),
          ),
        ),
        borderData: ChartDataProcessor.getChartBorder(),
        minX: 1,
        maxX: monthlyData.length.toDouble(),
        minY: 0,
        maxY: monthlyData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) + 1,
        lineBarsData: [
          LineChartBarData(
            spots: monthlyData,
            isCurved: true,
            gradient: ChartDataProcessor.getChartGradient(CupertinoColors.systemGreen),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: ChartDataProcessor.getChartGradient(CupertinoColors.systemGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXpChart() {
    final xpData = ChartDataProcessor.generateXpProgressData(
      widget.completions,
      30, // Last 30 days
    );

    if (xpData.isEmpty) {
      return _buildEmptyChart('No XP data available');
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 100,
          getDrawingHorizontalLine: (value) => ChartDataProcessor.getChartGridLine(),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 5,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}d',
                  style: ChartDataProcessor.getChartAxisLabelStyle(),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 100,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  ChartDataProcessor.formatChartValue(value),
                  style: ChartDataProcessor.getChartAxisLabelStyle(),
                );
              },
            ),
          ),
        ),
        borderData: ChartDataProcessor.getChartBorder(),
        minX: 0,
        maxX: 29,
        minY: 0,
        maxY: xpData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) + 100,
        lineBarsData: [
          LineChartBarData(
            spots: xpData,
            isCurved: true,
            gradient: ChartDataProcessor.getChartGradient(CupertinoColors.systemPurple),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: ChartDataProcessor.getChartGradient(CupertinoColors.systemPurple),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.chart_bar,
            size: 48,
            color: CupertinoColors.systemGrey3,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

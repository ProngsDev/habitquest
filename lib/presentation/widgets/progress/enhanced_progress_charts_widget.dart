import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';

import '../../../core/utils/chart_data_processor.dart';
import '../../../core/utils/enhanced_animation_utils.dart';
import '../../../domain/entities/habit_completion.dart';
import '../common/custom_card.dart';
import '../common/modern_header.dart';

/// Enhanced widget for displaying progress charts with animations
class EnhancedProgressChartsWidget extends StatefulWidget {
  final List<HabitCompletion> completions;

  const EnhancedProgressChartsWidget({super.key, required this.completions});

  @override
  State<EnhancedProgressChartsWidget> createState() =>
      _EnhancedProgressChartsWidgetState();
}

class _EnhancedProgressChartsWidgetState
    extends State<EnhancedProgressChartsWidget>
    with TickerProviderStateMixin {
  int _selectedChartIndex = 0;
  late AnimationController _chartAnimationController;
  late AnimationController _fadeController;
  late Animation<double> _chartAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _chartAnimationController = AnimationController(
      duration: EnhancedAnimationUtils.normalDuration,
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: EnhancedAnimationUtils.fastDuration,
      vsync: this,
    );

    _chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _chartAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _chartAnimationController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _chartAnimationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ModernSectionHeader(
          title: 'Progress Charts',
          subtitle: 'Visualize your habit completion trends',
        ),
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chart selector with animation
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Center(
                      child: CupertinoSlidingSegmentedControl<int>(
                        groupValue: _selectedChartIndex,
                        onValueChanged: (value) {
                          if (value != null) {
                            _animateChartChange(value);
                          }
                        },
                        children: const {
                          0: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text('Week'),
                          ),
                          1: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text('Month'),
                          ),
                          2: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text('XP'),
                          ),
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Chart content with animation
              AnimatedBuilder(
                animation: _chartAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _chartAnimation.value,
                    child: Opacity(
                      opacity: _chartAnimation.value,
                      child: SizedBox(
                        height: 300,
                        child: _buildSelectedChart(),
                      ),
                    ),
                  );
                },
              ),

              // Chart legend
              const SizedBox(height: 16),
              _buildChartLegend(),
            ],
          ),
        ),
      ],
    );
  }

  void _animateChartChange(int newIndex) {
    _fadeController.reverse().then((_) {
      setState(() {
        _selectedChartIndex = newIndex;
      });
      _chartAnimationController.reset();
      _chartAnimationController.forward();
      _fadeController.forward();
    });
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
          getDrawingHorizontalLine: (value) =>
              ChartDataProcessor.getChartGridLine(),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
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
        maxY:
            weeklyData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) +
            1,
        lineBarsData: [
          LineChartBarData(
            spots: weeklyData,
            isCurved: true,
            gradient: ChartDataProcessor.getChartGradient(
              CupertinoColors.systemBlue,
            ),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 6,
                  color: CupertinoColors.systemBlue,
                  strokeWidth: 2,
                  strokeColor: CupertinoColors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  CupertinoColors.systemBlue.withOpacity(0.3),
                  CupertinoColors.systemBlue.withOpacity(0.1),
                ],
              ),
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
          getDrawingHorizontalLine: (value) =>
              ChartDataProcessor.getChartGridLine(),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
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
        maxY:
            monthlyData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) +
            1,
        lineBarsData: [
          LineChartBarData(
            spots: monthlyData,
            isCurved: true,
            gradient: ChartDataProcessor.getChartGradient(
              CupertinoColors.systemGreen,
            ),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  CupertinoColors.systemGreen.withOpacity(0.3),
                  CupertinoColors.systemGreen.withOpacity(0.1),
                ],
              ),
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
          getDrawingHorizontalLine: (value) =>
              ChartDataProcessor.getChartGridLine(),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
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
        maxY:
            xpData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) + 100,
        lineBarsData: [
          LineChartBarData(
            spots: xpData,
            isCurved: true,
            gradient: ChartDataProcessor.getChartGradient(
              CupertinoColors.systemPurple,
            ),
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  CupertinoColors.systemPurple.withOpacity(0.3),
                  CupertinoColors.systemPurple.withOpacity(0.1),
                ],
              ),
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CupertinoColors.systemGrey6,
              border: Border.all(color: CupertinoColors.systemGrey4, width: 2),
            ),
            child: const Icon(
              CupertinoIcons.chart_bar,
              size: 32,
              color: CupertinoColors.systemGrey3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.systemGrey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete some habits to see your progress!',
            style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey2),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend() {
    final legendItems = _getLegendItems();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: legendItems
            .map(
              (item) => _buildLegendItem(
                color: item['color'] as Color,
                label: item['label'] as String,
                value: item['value'] as String,
              ),
            )
            .toList(),
      ),
    );
  }

  List<Map<String, dynamic>> _getLegendItems() {
    switch (_selectedChartIndex) {
      case 0:
        final weeklyTotal = widget.completions
            .where((c) => DateTime.now().difference(c.completedAt).inDays < 7)
            .length;
        return [
          {
            'color': CupertinoColors.systemBlue,
            'label': 'This Week',
            'value': '$weeklyTotal habits',
          },
        ];
      case 1:
        final monthlyTotal = widget.completions
            .where((c) => DateTime.now().difference(c.completedAt).inDays < 30)
            .length;
        return [
          {
            'color': CupertinoColors.systemGreen,
            'label': 'This Month',
            'value': '$monthlyTotal habits',
          },
        ];
      case 2:
        final totalXp = widget.completions.fold<int>(
          0,
          (sum, completion) => sum + (completion.xpEarned ?? 0),
        );
        return [
          {
            'color': CupertinoColors.systemPurple,
            'label': 'Total XP',
            'value': '$totalXp points',
          },
        ];
      default:
        return [];
    }
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

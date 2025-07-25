import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';

import '../../domain/entities/habit_completion.dart';

/// Utility class for processing data for charts and analytics
class ChartDataProcessor {
  /// Generate weekly completion data for line chart
  static List<FlSpot> generateWeeklyCompletionData(
    List<HabitCompletion> completions,
  ) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final spots = <FlSpot>[];

    for (var i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final dayCompletions = completions.where((completion) {
        final completionDate = completion.completedAt;
        return completionDate.year == day.year &&
            completionDate.month == day.month &&
            completionDate.day == day.day;
      }).length;

      spots.add(FlSpot(i.toDouble(), dayCompletions.toDouble()));
    }

    return spots;
  }

  /// Generate monthly completion data for line chart
  static List<FlSpot> generateMonthlyCompletionData(
    List<HabitCompletion> completions,
  ) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final spots = <FlSpot>[];

    for (var i = 1; i <= daysInMonth; i++) {
      final day = DateTime(now.year, now.month, i);
      final dayCompletions = completions.where((completion) {
        final completionDate = completion.completedAt;
        return completionDate.year == day.year &&
            completionDate.month == day.month &&
            completionDate.day == day.day;
      }).length;

      spots.add(FlSpot(i.toDouble(), dayCompletions.toDouble()));
    }

    return spots;
  }

  /// Generate XP progress data over time
  static List<FlSpot> generateXpProgressData(
    List<HabitCompletion> completions,
    int days,
  ) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final spots = <FlSpot>[];
    var cumulativeXp = 0;

    for (var i = 0; i < days; i++) {
      final day = startDate.add(Duration(days: i));
      final dayXp = completions
          .where((completion) {
            final completionDate = completion.completedAt;
            return completionDate.year == day.year &&
                completionDate.month == day.month &&
                completionDate.day == day.day;
          })
          .fold<int>(0, (sum, completion) => sum + completion.xpEarned);

      cumulativeXp += dayXp;
      spots.add(FlSpot(i.toDouble(), cumulativeXp.toDouble()));
    }

    return spots;
  }

  /// Generate streak data for visualization
  static List<FlSpot> generateStreakData(
    List<HabitCompletion> completions,
    int days,
  ) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final spots = <FlSpot>[];
    var currentStreak = 0;

    for (var i = 0; i < days; i++) {
      final day = startDate.add(Duration(days: i));
      final hasCompletion = completions.any((completion) {
        final completionDate = completion.completedAt;
        return completionDate.year == day.year &&
            completionDate.month == day.month &&
            completionDate.day == day.day;
      });

      if (hasCompletion) {
        currentStreak++;
      } else {
        currentStreak = 0;
      }

      spots.add(FlSpot(i.toDouble(), currentStreak.toDouble()));
    }

    return spots;
  }

  /// Generate pie chart data for habit categories
  static List<PieChartSectionData> generateCategoryPieData(
    Map<String, int> categoryCompletions,
    Map<String, Color> categoryColors,
  ) {
    final total = categoryCompletions.values.fold<int>(
      0,
      (sum, count) => sum + count,
    );
    if (total == 0) return [];

    return categoryCompletions.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      return PieChartSectionData(
        color: categoryColors[entry.key] ?? CupertinoColors.systemGrey,
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: CupertinoColors.white,
        ),
      );
    }).toList();
  }

  /// Generate bar chart data for weekly comparison
  static List<BarChartGroupData> generateWeeklyBarData(
    List<HabitCompletion> completions,
  ) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final barGroups = <BarChartGroupData>[];

    for (var i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final dayCompletions = completions.where((completion) {
        final completionDate = completion.completedAt;
        return completionDate.year == day.year &&
            completionDate.month == day.month &&
            completionDate.day == day.day;
      }).length;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: dayCompletions.toDouble(),
              color: CupertinoColors.systemBlue,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return barGroups;
  }

  /// Generate heatmap data for calendar view
  static Map<DateTime, int> generateHeatmapData(
    List<HabitCompletion> completions,
    DateTime startDate,
    DateTime endDate,
  ) {
    final heatmapData = <DateTime, int>{};
    final current = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      final dayCompletions = completions.where((completion) {
        final completionDate = completion.completedAt;
        return completionDate.year == current.year &&
            completionDate.month == current.month &&
            completionDate.day == current.day;
      }).length;

      heatmapData[DateTime(current.year, current.month, current.day)] =
          dayCompletions;
      current.add(const Duration(days: 1));
    }

    return heatmapData;
  }

  /// Get week day labels
  static List<String> getWeekDayLabels() => [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  /// Get month labels
  static List<String> getMonthLabels() => [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Calculate completion rate for a period
  static double calculateCompletionRate(
    List<HabitCompletion> completions,
    int totalPossibleCompletions,
  ) {
    if (totalPossibleCompletions == 0) return 0;
    return (completions.length / totalPossibleCompletions).clamp(0.0, 1.0);
  }

  /// Get color for completion rate
  static Color getCompletionRateColor(double rate) {
    if (rate >= 0.8) return CupertinoColors.systemGreen;
    if (rate >= 0.6) return CupertinoColors.systemYellow;
    if (rate >= 0.4) return CupertinoColors.systemOrange;
    return CupertinoColors.systemRed;
  }

  /// Generate gradient for charts
  static LinearGradient getChartGradient(Color color) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [color.withValues(alpha: 0.8), color.withValues(alpha: 0.1)],
  );

  /// Format chart values for display
  static String formatChartValue(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toInt().toString();
  }

  /// Get chart title style
  static TextStyle getChartTitleStyle() => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: CupertinoColors.label,
  );

  /// Get chart axis label style
  static TextStyle getChartAxisLabelStyle() => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: CupertinoColors.secondaryLabel,
  );

  /// Get chart grid line style
  static FlLine getChartGridLine() =>
      const FlLine(color: CupertinoColors.separator, strokeWidth: 0.5);

  /// Get chart border style
  static FlBorderData getChartBorder() => FlBorderData(
    show: true,
    border: const Border(
      bottom: BorderSide(color: CupertinoColors.separator, width: 0.5),
      left: BorderSide(color: CupertinoColors.separator, width: 0.5),
    ),
  );
}

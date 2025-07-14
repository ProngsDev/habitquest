import 'package:flutter/cupertino.dart';

import '../../../core/utils/chart_data_processor.dart';
import '../../../domain/entities/habit_completion.dart';
import '../common/custom_card.dart';

/// Widget for displaying streak calendar heatmap
class StreakCalendarWidget extends StatelessWidget {
  final List<HabitCompletion> completions;

  const StreakCalendarWidget({
    super.key,
    required this.completions,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Icon(
                CupertinoIcons.calendar,
                size: 24,
                color: CupertinoColors.systemGreen,
              ),
              SizedBox(width: 12),
              Text(
                'Streak Calendar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Calendar heatmap
          _buildCalendarHeatmap(),
          const SizedBox(height: 16),

          // Legend
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildCalendarHeatmap() {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - 2, 1); // Last 3 months
    final endDate = DateTime(now.year, now.month + 1, 0);

    final heatmapData = ChartDataProcessor.generateHeatmapData(
      completions,
      startDate,
      endDate,
    );

    return SizedBox(
      height: 200,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Week day labels
              Row(
                children: [
                  const SizedBox(width: 30), // Space for month labels
                  ...List.generate(7, (index) {
                    final weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                    return Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.all(1),
                      alignment: Alignment.center,
                      child: Text(
                        weekDays[index],
                        style: const TextStyle(
                          fontSize: 10,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 4),

              // Calendar grid
              Expanded(
                child: _buildCalendarGrid(heatmapData, startDate, endDate),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(
    Map<DateTime, int> heatmapData,
    DateTime startDate,
    DateTime endDate,
  ) {
    final weeks = <List<DateTime>>[];
    var currentWeek = <DateTime>[];
    var current = DateTime(startDate.year, startDate.month, startDate.day);

    // Pad the start of the first week
    final firstWeekday = current.weekday % 7;
    for (int i = 0; i < firstWeekday; i++) {
      currentWeek.add(current.subtract(Duration(days: firstWeekday - i)));
    }

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      currentWeek.add(current);
      
      if (currentWeek.length == 7) {
        weeks.add(List.from(currentWeek));
        currentWeek.clear();
      }
      
      current = current.add(const Duration(days: 1));
    }

    // Add remaining days to the last week
    if (currentWeek.isNotEmpty) {
      while (currentWeek.length < 7) {
        currentWeek.add(current);
        current = current.add(const Duration(days: 1));
      }
      weeks.add(currentWeek);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: weeks.map((week) => _buildWeekColumn(week, heatmapData)).toList(),
    );
  }

  Widget _buildWeekColumn(List<DateTime> week, Map<DateTime, int> heatmapData) {
    return Column(
      children: week.map((date) {
        final completionCount = heatmapData[DateTime(date.year, date.month, date.day)] ?? 0;
        return _buildDayCell(date, completionCount);
      }).toList(),
    );
  }

  Widget _buildDayCell(DateTime date, int completionCount) {
    final isToday = _isSameDay(date, DateTime.now());
    final intensity = _getIntensity(completionCount);
    
    return Container(
      width: 16,
      height: 16,
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: _getIntensityColor(intensity),
        borderRadius: BorderRadius.circular(2),
        border: isToday
            ? Border.all(color: CupertinoColors.systemBlue, width: 1)
            : null,
      ),
      child: completionCount > 0
          ? Center(
              child: Text(
                completionCount > 9 ? '9+' : completionCount.toString(),
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: intensity > 0.5 
                      ? CupertinoColors.white 
                      : CupertinoColors.label,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        const Text(
          'Less',
          style: TextStyle(
            fontSize: 12,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
        const SizedBox(width: 8),
        ...List.generate(5, (index) {
          final intensity = index / 4.0;
          return Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: _getIntensityColor(intensity),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
        const SizedBox(width: 8),
        const Text(
          'More',
          style: TextStyle(
            fontSize: 12,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
        const Spacer(),
        const Text(
          'Habit completions per day',
          style: TextStyle(
            fontSize: 12,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
      ],
    );
  }

  double _getIntensity(int completionCount) {
    if (completionCount == 0) return 0.0;
    if (completionCount == 1) return 0.25;
    if (completionCount == 2) return 0.5;
    if (completionCount <= 4) return 0.75;
    return 1.0;
  }

  Color _getIntensityColor(double intensity) {
    if (intensity == 0.0) return CupertinoColors.systemGrey6;
    
    final baseColor = CupertinoColors.systemGreen;
    return Color.lerp(
      baseColor.withOpacity(0.2),
      baseColor,
      intensity,
    )!;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

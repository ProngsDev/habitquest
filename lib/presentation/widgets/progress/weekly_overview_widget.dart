import 'package:flutter/cupertino.dart';

import '../../../core/utils/responsive_utils.dart';
import '../common/custom_card.dart';
import '../layout/responsive_grid.dart';

/// Widget for displaying weekly overview statistics
class WeeklyOverviewWidget extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final int totalHabitsCompleted;
  final int coins;

  const WeeklyOverviewWidget({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalHabitsCompleted,
    required this.coins,
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
                CupertinoIcons.chart_bar_alt_fill,
                size: 24,
                color: CupertinoColors.systemBlue,
              ),
              SizedBox(width: 12),
              Text(
                'Weekly Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stats Grid
          ResponsiveGrid(
            forceColumns: ResponsiveUtils.isMobile(context) ? 2 : null,
            children: [
              _buildStatCard(
                'Current Streak',
                '$currentStreak',
                'days',
                CupertinoIcons.flame_fill,
                CupertinoColors.systemOrange,
              ),
              _buildStatCard(
                'Longest Streak',
                '$longestStreak',
                'days',
                CupertinoIcons.star_fill,
                CupertinoColors.systemYellow,
              ),
              _buildStatCard(
                'Total Completed',
                '$totalHabitsCompleted',
                'habits',
                CupertinoIcons.checkmark_circle_fill,
                CupertinoColors.systemGreen,
              ),
              _buildStatCard(
                'Coins Earned',
                '$coins',
                'coins',
                CupertinoIcons.money_dollar_circle_fill,
                CupertinoColors.systemPurple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }
}

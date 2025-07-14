import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/responsive_utils.dart';
import '../common/custom_card.dart';
import '../layout/responsive_grid.dart';

/// Widget for displaying user profile statistics
class ProfileStatsWidget extends StatelessWidget {
  final int totalHabitsCompleted;
  final int currentStreak;
  final int longestStreak;
  final int coins;
  final int unlockedAchievements;
  final DateTime memberSince;

  const ProfileStatsWidget({
    super.key,
    required this.totalHabitsCompleted,
    required this.currentStreak,
    required this.longestStreak,
    required this.coins,
    required this.unlockedAchievements,
    required this.memberSince,
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
                'Statistics',
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
                'Habits Completed',
                totalHabitsCompleted.toString(),
                CupertinoIcons.checkmark_circle_fill,
                CupertinoColors.systemGreen,
              ),
              _buildStatCard(
                'Current Streak',
                '$currentStreak days',
                CupertinoIcons.flame_fill,
                CupertinoColors.systemOrange,
              ),
              _buildStatCard(
                'Longest Streak',
                '$longestStreak days',
                CupertinoIcons.star_fill,
                CupertinoColors.systemYellow,
              ),
              _buildStatCard(
                'Coins Earned',
                coins.toString(),
                CupertinoIcons.money_dollar_circle_fill,
                CupertinoColors.systemPurple,
              ),
              _buildStatCard(
                'Achievements',
                unlockedAchievements.toString(),
                CupertinoIcons.rosette,
                CupertinoColors.systemPink,
              ),
              _buildStatCard(
                'Member Since',
                _formatMemberSince(memberSince),
                CupertinoIcons.calendar,
                CupertinoColors.systemTeal,
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMemberSince(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      return DateFormat('MMM yyyy').format(date);
    }
  }
}

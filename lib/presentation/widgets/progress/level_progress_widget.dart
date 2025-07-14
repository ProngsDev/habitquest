import 'package:flutter/cupertino.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/xp_calculator.dart';
import '../common/custom_card.dart';
import '../common/progress_widgets.dart';

/// Widget for displaying user level and XP progress
class LevelProgressWidget extends StatelessWidget {
  final int currentLevel;
  final int totalXp;
  final int xpInCurrentLevel;
  final int xpRequiredForNextLevel;
  final double progressPercentage;

  const LevelProgressWidget({
    super.key,
    required this.currentLevel,
    required this.totalXp,
    required this.xpInCurrentLevel,
    required this.xpRequiredForNextLevel,
    required this.progressPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                XpCalculator.getLevelIcon(currentLevel),
                size: 24,
                color: AppTheme.getLevelColor(currentLevel),
              ),
              const SizedBox(width: 12),
              const Text(
                'Level Progress',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Level and XP Display
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level $currentLevel',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getLevelColor(currentLevel),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalXp Total XP',
                      style: const TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
              CircularProgressWidget(
                progress: progressPercentage,
                size: 80,
                progressColor: AppTheme.getLevelColor(currentLevel),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(progressPercentage * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const Text(
                      'to next',
                      style: TextStyle(
                        fontSize: 10,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$xpInCurrentLevel XP',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.label,
                    ),
                  ),
                  Text(
                    '$xpRequiredForNextLevel XP to Level ${currentLevel + 1}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressWidget(
                progress: progressPercentage,
                height: 8,
                progressColor: AppTheme.getLevelColor(currentLevel),
                backgroundColor: CupertinoColors.systemGrey5,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Level Benefits or Next Level Preview
          _buildLevelInfo(context),
        ],
      ),
    );
  }

  Widget _buildLevelInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.getLevelColor(currentLevel).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.getLevelColor(currentLevel).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.star_fill,
            size: 16,
            color: AppTheme.getLevelColor(currentLevel),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getLevelDescription(currentLevel),
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.getLevelColor(currentLevel),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLevelDescription(int level) {
    if (level >= 50) return 'Master Level - You\'ve achieved greatness!';
    if (level >= 30) return 'Expert Level - Habits are second nature';
    if (level >= 20) return 'Advanced Level - Consistency is your strength';
    if (level >= 10) return 'Intermediate Level - Building momentum';
    if (level >= 5) return 'Developing Level - Great progress!';
    return 'Beginner Level - Every journey starts here';
  }
}

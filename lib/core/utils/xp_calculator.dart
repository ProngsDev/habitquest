import 'package:flutter/cupertino.dart';

import '../constants/app_constants.dart';
import '../enums/habit_enums.dart';

/// Utility class for calculating XP and levels
class XpCalculator {
  /// Calculate XP earned for completing a habit
  static int calculateHabitXp(
    HabitDifficulty difficulty, {
    int streakCount = 0,
  }) {
    final baseXp = AppConstants.baseXpPerHabit * difficulty.xpMultiplier;

    // Apply streak bonus if applicable
    if (streakCount >= AppConstants.minStreakForBonus) {
      return (baseXp * AppConstants.streakBonusMultiplier).round();
    }

    return baseXp;
  }

  /// Calculate level from total XP
  static int calculateLevel(int totalXp) {
    if (totalXp <= 0) return 1;

    final level = (totalXp / AppConstants.xpPerLevel).floor() + 1;
    return level > AppConstants.maxLevel ? AppConstants.maxLevel : level;
  }

  /// Calculate XP required for next level
  static int xpRequiredForNextLevel(int currentLevel) {
    if (currentLevel >= AppConstants.maxLevel) return 0;
    return AppConstants.xpPerLevel * currentLevel;
  }

  /// Calculate XP progress towards next level
  static int xpProgressInCurrentLevel(int totalXp) =>
      totalXp % AppConstants.xpPerLevel;

  /// Calculate percentage progress towards next level
  static double levelProgressPercentage(int totalXp) {
    final currentLevel = calculateLevel(totalXp);
    if (currentLevel >= AppConstants.maxLevel) return 1;

    final progressInLevel = xpProgressInCurrentLevel(totalXp);
    return progressInLevel / AppConstants.xpPerLevel;
  }

  /// Calculate total XP required to reach a specific level
  static int totalXpForLevel(int level) {
    if (level <= 1) return 0;
    return AppConstants.xpPerLevel * (level - 1);
  }

  /// Check if user leveled up after gaining XP
  static bool didLevelUp(int previousXp, int newXp) {
    final previousLevel = calculateLevel(previousXp);
    final newLevel = calculateLevel(newXp);
    return newLevel > previousLevel;
  }

  /// Get the new level after gaining XP (if leveled up)
  static int? getNewLevel(int previousXp, int newXp) {
    if (didLevelUp(previousXp, newXp)) {
      return calculateLevel(newXp);
    }
    return null;
  }

  /// Calculate streak bonus multiplier
  static double getStreakBonusMultiplier(int streakCount) {
    if (streakCount >= AppConstants.minStreakForBonus) {
      return AppConstants.streakBonusMultiplier;
    }
    return 1;
  }

  /// Calculate weekly XP goal based on user level
  static int calculateWeeklyXpGoal(int userLevel) {
    // Base weekly goal increases with level
    const baseWeeklyGoal = 200;
    return baseWeeklyGoal + (userLevel * 10);
  }

  /// Calculate monthly XP goal based on user level
  static int calculateMonthlyXpGoal(int userLevel) {
    // Base monthly goal increases with level
    const baseMonthlyGoal = 800;
    return baseMonthlyGoal + (userLevel * 40);
  }

  /// Get level title/rank based on level
  static String getLevelTitle(int level) {
    if (level >= 90) return 'Grandmaster';
    if (level >= 80) return 'Master';
    if (level >= 70) return 'Expert';
    if (level >= 60) return 'Advanced';
    if (level >= 50) return 'Skilled';
    if (level >= 40) return 'Experienced';
    if (level >= 30) return 'Competent';
    if (level >= 20) return 'Intermediate';
    if (level >= 10) return 'Apprentice';
    return 'Novice';
  }

  /// Get professional Cupertino icon for level range
  static IconData getLevelIcon(int level) {
    if (level >= 90) return CupertinoIcons.star_circle_fill; // Master level
    if (level >= 80) return CupertinoIcons.star_fill; // Expert level
    if (level >= 70) return CupertinoIcons.star; // Advanced level
    if (level >= 60) return CupertinoIcons.circle_fill; // Proficient level
    if (level >= 50) return CupertinoIcons.circle; // Intermediate level
    if (level >= 40) return CupertinoIcons.bolt_fill; // Experienced level
    if (level >= 30) return CupertinoIcons.bolt; // Developing level
    if (level >= 20) return CupertinoIcons.flame; // Growing level
    if (level >= 10)
      return CupertinoIcons.leaf_arrow_circlepath; // Learning level
    return CupertinoIcons.circle; // Beginner level
  }

  /// Legacy emoji support (deprecated - use getLevelIcon instead)
  @Deprecated('Use getLevelIcon instead for better visual consistency')
  static String getLevelEmoji(int level) {
    if (level >= 90) return '👑';
    if (level >= 80) return '🏆';
    if (level >= 70) return '🥇';
    if (level >= 60) return '🥈';
    if (level >= 50) return '🥉';
    if (level >= 40) return '⭐';
    if (level >= 30) return '🌟';
    if (level >= 20) return '✨';
    if (level >= 10) return '🔥';
    return '🌱';
  }
}

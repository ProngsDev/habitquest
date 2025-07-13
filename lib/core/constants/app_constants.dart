/// Application-wide constants for HabitQuest
class AppConstants {
  // App Information
  static const String appName = 'HabitQuest';
  static const String appVersion = '1.0.0';

  // Database
  static const String hiveBoxName = 'habitquest_box';
  static const String userBoxName = 'user_box';
  static const String habitsBoxName = 'habits_box';
  static const String achievementsBoxName = 'achievements_box';

  // Gamification
  static const int baseXpPerHabit = 10;
  static const int xpMultiplierEasy = 1;
  static const int xpMultiplierMedium = 2;
  static const int xpMultiplierHard = 3;
  static const int xpPerLevel = 100;
  static const int maxLevel = 100;

  // Streaks
  static const int minStreakForBonus = 7;
  static const double streakBonusMultiplier = 1.5;

  // Notifications
  static const String notificationChannelId = 'habit_reminders';
  static const String notificationChannelName = 'Habit Reminders';
  static const String notificationChannelDescription =
      'Notifications for habit reminders';

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);

  // UI Constants
  static const double defaultPadding = 16;
  static const double smallPadding = 8;
  static const double largePadding = 24;
  static const double borderRadius = 12;
  static const double cardElevation = 2;
}

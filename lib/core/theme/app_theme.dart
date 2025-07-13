import 'package:flutter/cupertino.dart';

/// iOS-style theme configuration for HabitQuest
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Light theme colors
  static const CupertinoThemeData lightTheme = CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: CupertinoColors.systemBlue,
    primaryContrastingColor: CupertinoColors.white,
    scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
    barBackgroundColor: CupertinoColors.systemBackground,
    textTheme: CupertinoTextThemeData(
      primaryColor: CupertinoColors.label,
      textStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 17,
        color: CupertinoColors.label,
      ),
      actionTextStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 17,
        color: CupertinoColors.systemBlue,
      ),
      tabLabelTextStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 10,
        color: CupertinoColors.inactiveGray,
      ),
      navTitleTextStyle: TextStyle(
        fontFamily: '.SF Pro Display',
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: CupertinoColors.label,
      ),
      navLargeTitleTextStyle: TextStyle(
        fontFamily: '.SF Pro Display',
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: CupertinoColors.label,
      ),
      navActionTextStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 17,
        color: CupertinoColors.systemBlue,
      ),
      pickerTextStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 21,
        color: CupertinoColors.label,
      ),
      dateTimePickerTextStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 21,
        color: CupertinoColors.label,
      ),
    ),
  );

  // Dark theme colors
  static const CupertinoThemeData darkTheme = CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: CupertinoColors.systemBlue,
    primaryContrastingColor: CupertinoColors.black,
    scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
    barBackgroundColor: CupertinoColors.systemBackground,
    textTheme: CupertinoTextThemeData(
      primaryColor: CupertinoColors.label,
      textStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 17,
        color: CupertinoColors.label,
      ),
      actionTextStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 17,
        color: CupertinoColors.systemBlue,
      ),
      tabLabelTextStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 10,
        color: CupertinoColors.inactiveGray,
      ),
      navTitleTextStyle: TextStyle(
        fontFamily: '.SF Pro Display',
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: CupertinoColors.label,
      ),
      navLargeTitleTextStyle: TextStyle(
        fontFamily: '.SF Pro Display',
        fontSize: 34,
        fontWeight: FontWeight.bold,
        color: CupertinoColors.label,
      ),
      navActionTextStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 17,
        color: CupertinoColors.systemBlue,
      ),
      pickerTextStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 21,
        color: CupertinoColors.label,
      ),
      dateTimePickerTextStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 21,
        color: CupertinoColors.label,
      ),
    ),
  );

  // Custom colors for the app
  static const Color primaryBlue = CupertinoColors.systemBlue;
  static const Color primaryGreen = CupertinoColors.systemGreen;
  static const Color primaryOrange = CupertinoColors.systemOrange;
  static const Color primaryRed = CupertinoColors.systemRed;
  static const Color primaryPurple = CupertinoColors.systemPurple;
  static const Color primaryYellow = CupertinoColors.systemYellow;
  static const Color primaryPink = CupertinoColors.systemPink;
  static const Color primaryTeal = CupertinoColors.systemTeal;
  static const Color primaryIndigo = CupertinoColors.systemIndigo;

  // Semantic colors
  static const Color successColor = CupertinoColors.systemGreen;
  static const Color warningColor = CupertinoColors.systemOrange;
  static const Color errorColor = CupertinoColors.systemRed;
  static const Color infoColor = CupertinoColors.systemBlue;

  // Habit category colors
  static const Map<String, Color> categoryColors = {
    'health': CupertinoColors.systemRed,
    'fitness': CupertinoColors.systemOrange,
    'learning': CupertinoColors.systemBlue,
    'productivity': CupertinoColors.systemPurple,
    'social': CupertinoColors.systemPink,
    'creativity': CupertinoColors.systemYellow,
    'mindfulness': CupertinoColors.systemGreen,
    'other': CupertinoColors.systemGray,
  };

  // Difficulty colors
  static const Map<String, Color> difficultyColors = {
    'easy': CupertinoColors.systemGreen,
    'medium': CupertinoColors.systemOrange,
    'hard': CupertinoColors.systemRed,
  };

  // Level colors
  static const List<Color> levelColors = [
    CupertinoColors.systemGray,    // Novice
    CupertinoColors.systemBlue,    // Apprentice
    CupertinoColors.systemGreen,   // Intermediate
    CupertinoColors.systemOrange,  // Competent
    CupertinoColors.systemPurple,  // Experienced
    CupertinoColors.systemPink,    // Skilled
    CupertinoColors.systemRed,     // Advanced
    CupertinoColors.systemYellow,  // Expert
    CupertinoColors.systemTeal,    // Master
    CupertinoColors.systemIndigo,  // Grandmaster
  ];

  // Text styles
  static const TextStyle headingLarge = TextStyle(
    fontFamily: '.SF Pro Display',
    fontSize: 34,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: '.SF Pro Display',
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: '.SF Pro Display',
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 17,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle button = TextStyle(
    fontFamily: '.SF Pro Text',
    fontSize: 17,
    fontWeight: FontWeight.w600,
  );

  // Helper methods
  static Color getCategoryColor(String category) => 
      categoryColors[category.toLowerCase()] ?? CupertinoColors.systemGray;

  static Color getDifficultyColor(String difficulty) => 
      difficultyColors[difficulty.toLowerCase()] ?? CupertinoColors.systemGray;

  static Color getLevelColor(int level) {
    final index = ((level - 1) / 10).floor().clamp(0, levelColors.length - 1);
    return levelColors[index];
  }
}

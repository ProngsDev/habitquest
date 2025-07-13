import 'package:hive/hive.dart';

part 'habit_enums.g.dart';

/// Enums for habit-related functionality

/// Difficulty levels for habits
@HiveType(typeId: 10)
enum HabitDifficulty {
  @HiveField(0)
  easy,
  @HiveField(1)
  medium,
  @HiveField(2)
  hard;

  String get displayName {
    switch (this) {
      case HabitDifficulty.easy:
        return 'Easy';
      case HabitDifficulty.medium:
        return 'Medium';
      case HabitDifficulty.hard:
        return 'Hard';
    }
  }

  int get xpMultiplier {
    switch (this) {
      case HabitDifficulty.easy:
        return 1;
      case HabitDifficulty.medium:
        return 2;
      case HabitDifficulty.hard:
        return 3;
    }
  }
}

/// Categories for organizing habits
@HiveType(typeId: 11)
enum HabitCategory {
  @HiveField(0)
  health,
  @HiveField(1)
  fitness,
  @HiveField(2)
  learning,
  @HiveField(3)
  productivity,
  @HiveField(4)
  social,
  @HiveField(5)
  creativity,
  @HiveField(6)
  mindfulness,
  @HiveField(7)
  other;

  String get displayName {
    switch (this) {
      case HabitCategory.health:
        return 'Health';
      case HabitCategory.fitness:
        return 'Fitness';
      case HabitCategory.learning:
        return 'Learning';
      case HabitCategory.productivity:
        return 'Productivity';
      case HabitCategory.social:
        return 'Social';
      case HabitCategory.creativity:
        return 'Creativity';
      case HabitCategory.mindfulness:
        return 'Mindfulness';
      case HabitCategory.other:
        return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case HabitCategory.health:
        return '🏥';
      case HabitCategory.fitness:
        return '💪';
      case HabitCategory.learning:
        return '📚';
      case HabitCategory.productivity:
        return '⚡';
      case HabitCategory.social:
        return '👥';
      case HabitCategory.creativity:
        return '🎨';
      case HabitCategory.mindfulness:
        return '🧘';
      case HabitCategory.other:
        return '📝';
    }
  }
}

/// Frequency options for habits
@HiveType(typeId: 12)
enum HabitFrequency {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly;

  String get displayName {
    switch (this) {
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.weekly:
        return 'Weekly';
      case HabitFrequency.monthly:
        return 'Monthly';
    }
  }
}

/// Status of a habit completion
@HiveType(typeId: 13)
enum CompletionStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  completed,
  @HiveField(2)
  skipped,
  @HiveField(3)
  failed;

  String get displayName {
    switch (this) {
      case CompletionStatus.pending:
        return 'Pending';
      case CompletionStatus.completed:
        return 'Completed';
      case CompletionStatus.skipped:
        return 'Skipped';
      case CompletionStatus.failed:
        return 'Failed';
    }
  }
}

/// Enums for habit-related functionality

/// Difficulty levels for habits
enum HabitDifficulty {
  easy,
  medium,
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
enum HabitCategory {
  health,
  fitness,
  learning,
  productivity,
  social,
  creativity,
  mindfulness,
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
enum HabitFrequency {
  daily,
  weekly,
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
enum CompletionStatus {
  pending,
  completed,
  skipped,
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

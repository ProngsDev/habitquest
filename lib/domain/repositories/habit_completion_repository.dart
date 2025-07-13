import '../entities/habit_completion.dart';

/// Abstract repository interface for habit completion operations
abstract class HabitCompletionRepository {
  /// Record a habit completion
  Future<void> recordCompletion(HabitCompletion completion);

  /// Get all completions for a specific habit
  Future<List<HabitCompletion>> getCompletionsForHabit(String habitId);

  /// Get completions for a habit within a date range
  Future<List<HabitCompletion>> getCompletionsInRange(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get completion for a habit on a specific date
  Future<HabitCompletion?> getCompletionForDate(
    String habitId,
    DateTime date,
  );

  /// Get today's completion for a habit
  Future<HabitCompletion?> getTodaysCompletion(String habitId);

  /// Update an existing completion
  Future<void> updateCompletion(HabitCompletion completion);

  /// Delete a completion
  Future<void> deleteCompletion(String completionId);

  /// Get habit statistics
  Future<HabitStats> getHabitStats(String habitId);

  /// Get completion statistics for multiple habits
  Future<Map<String, HabitStats>> getMultipleHabitStats(List<String> habitIds);

  /// Calculate current streak for a habit
  Future<int> calculateCurrentStreak(String habitId);

  /// Calculate longest streak for a habit
  Future<int> calculateLongestStreak(String habitId);

  /// Calculate completion rate for a habit (last 30 days)
  Future<double> calculateCompletionRate(String habitId, {int days = 30});

  /// Get all completions for today across all habits
  Future<List<HabitCompletion>> getTodaysCompletions();

  /// Get completion history for calendar view
  Future<Map<DateTime, List<HabitCompletion>>> getCompletionCalendar(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Check if a habit can be completed today (based on frequency)
  Future<bool> canCompleteToday(String habitId);

  /// Get total XP earned from all completions
  Future<int> getTotalXpEarned();

  /// Get XP earned in a specific time period
  Future<int> getXpEarnedInPeriod(DateTime startDate, DateTime endDate);
}

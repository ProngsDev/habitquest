import '../../core/enums/habit_enums.dart';
import '../../core/result/result.dart';
import '../entities/habit.dart';

/// Abstract repository interface for habit operations
abstract class HabitRepository {
  /// Get all habits
  Future<Result<List<Habit>>> getAllHabits();

  /// Get active habits only
  Future<Result<List<Habit>>> getActiveHabits();

  /// Get habits by category
  Future<Result<List<Habit>>> getHabitsByCategory(HabitCategory category);

  /// Get habit by ID
  Future<Result<Habit?>> getHabitById(String id);

  /// Create a new habit
  Future<Result<void>> createHabit(Habit habit);

  /// Update an existing habit
  Future<Result<void>> updateHabit(Habit habit);

  /// Delete a habit
  Future<Result<void>> deleteHabit(String id);

  /// Archive/deactivate a habit
  Future<Result<void>> archiveHabit(String id);

  /// Restore an archived habit
  Future<Result<void>> restoreHabit(String id);

  /// Search habits by name or description
  Future<Result<List<Habit>>> searchHabits(String query);

  /// Get habits with reminders
  Future<Result<List<Habit>>> getHabitsWithReminders();

  /// Get habits count by category
  Future<Result<Map<HabitCategory, int>>> getHabitsCountByCategory();

  /// Get habits created in date range
  Future<Result<List<Habit>>> getHabitsCreatedInRange(
    DateTime start,
    DateTime end,
  );
}

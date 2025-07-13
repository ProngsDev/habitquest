import '../entities/habit.dart';
import '../../core/enums/habit_enums.dart';

/// Abstract repository interface for habit operations
abstract class HabitRepository {
  /// Get all habits
  Future<List<Habit>> getAllHabits();

  /// Get active habits only
  Future<List<Habit>> getActiveHabits();

  /// Get habits by category
  Future<List<Habit>> getHabitsByCategory(HabitCategory category);

  /// Get habit by ID
  Future<Habit?> getHabitById(String id);

  /// Create a new habit
  Future<void> createHabit(Habit habit);

  /// Update an existing habit
  Future<void> updateHabit(Habit habit);

  /// Delete a habit
  Future<void> deleteHabit(String id);

  /// Archive/deactivate a habit
  Future<void> archiveHabit(String id);

  /// Restore an archived habit
  Future<void> restoreHabit(String id);

  /// Search habits by name or description
  Future<List<Habit>> searchHabits(String query);

  /// Get habits with reminders
  Future<List<Habit>> getHabitsWithReminders();

  /// Get habits count by category
  Future<Map<HabitCategory, int>> getHabitsCountByCategory();

  /// Get habits created in date range
  Future<List<Habit>> getHabitsCreatedInRange(DateTime start, DateTime end);
}

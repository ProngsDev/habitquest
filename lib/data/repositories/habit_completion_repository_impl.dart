import '../../domain/entities/habit_completion.dart';
import '../../domain/repositories/habit_completion_repository.dart';
import '../datasources/local/hive_datasource.dart';
import '../models/habit_completion_model.dart';

/// Implementation of HabitCompletionRepository using Hive local storage
class HabitCompletionRepositoryImpl implements HabitCompletionRepository {
  final HiveDataSource _dataSource;

  const HabitCompletionRepositoryImpl(this._dataSource);

  @override
  Future<void> recordCompletion(HabitCompletion completion) async {
    final model = _mapToModel(completion);
    await _dataSource.saveCompletion(model);
  }

  @override
  Future<List<HabitCompletion>> getCompletionsForHabit(String habitId) async {
    final models = await _dataSource.getCompletionsForHabit(habitId);
    return models.map(_mapToEntity).toList();
  }

  @override
  Future<List<HabitCompletion>> getCompletionsInRange(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final models = await _dataSource.getCompletionsInDateRange(habitId, startDate, endDate);
    return models.map(_mapToEntity).toList();
  }

  @override
  Future<HabitCompletion?> getCompletionForDate(String habitId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final completions = await getCompletionsInRange(habitId, startOfDay, endOfDay);
    return completions.isNotEmpty ? completions.first : null;
  }

  @override
  Future<HabitCompletion?> getTodaysCompletion(String habitId) async {
    final model = await _dataSource.getTodaysCompletion(habitId);
    return model != null ? _mapToEntity(model) : null;
  }

  @override
  Future<void> updateCompletion(HabitCompletion completion) async {
    final model = _mapToModel(completion);
    await _dataSource.updateCompletion(model);
  }

  @override
  Future<void> deleteCompletion(String completionId) async {
    await _dataSource.deleteCompletion(completionId);
  }

  @override
  Future<HabitStats> getHabitStats(String habitId) async {
    final completions = await getCompletionsForHabit(habitId);
    final completedCompletions = completions.where((c) => c.status == CompletionStatus.completed).toList();
    
    return HabitStats(
      habitId: habitId,
      totalCompletions: completedCompletions.length,
      currentStreak: await calculateCurrentStreak(habitId),
      longestStreak: await calculateLongestStreak(habitId),
      completionRate: await calculateCompletionRate(habitId),
      totalXpEarned: completedCompletions.fold(0, (sum, c) => sum + c.xpEarned),
      lastCompletedAt: completedCompletions.isNotEmpty 
          ? completedCompletions.map((c) => c.completedAt).reduce((a, b) => a.isAfter(b) ? a : b)
          : null,
      recentCompletions: completedCompletions.take(10).toList(),
    );
  }

  @override
  Future<Map<String, HabitStats>> getMultipleHabitStats(List<String> habitIds) async {
    final Map<String, HabitStats> stats = {};
    for (final habitId in habitIds) {
      stats[habitId] = await getHabitStats(habitId);
    }
    return stats;
  }

  @override
  Future<int> calculateCurrentStreak(String habitId) async {
    final completions = await getCompletionsForHabit(habitId);
    final completedCompletions = completions
        .where((c) => c.status == CompletionStatus.completed)
        .toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    if (completedCompletions.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();
    
    for (final completion in completedCompletions) {
      final completionDate = DateTime(
        completion.completedAt.year,
        completion.completedAt.month,
        completion.completedAt.day,
      );
      final checkDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
      
      if (completionDate == checkDate || completionDate == checkDate.subtract(const Duration(days: 1))) {
        streak++;
        currentDate = completionDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    return streak;
  }

  @override
  Future<int> calculateLongestStreak(String habitId) async {
    final completions = await getCompletionsForHabit(habitId);
    final completedCompletions = completions
        .where((c) => c.status == CompletionStatus.completed)
        .toList()
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

    if (completedCompletions.isEmpty) return 0;

    int longestStreak = 0;
    int currentStreak = 1;
    DateTime? lastDate;

    for (final completion in completedCompletions) {
      final completionDate = DateTime(
        completion.completedAt.year,
        completion.completedAt.month,
        completion.completedAt.day,
      );

      if (lastDate != null) {
        final daysDifference = completionDate.difference(lastDate).inDays;
        if (daysDifference == 1) {
          currentStreak++;
        } else {
          longestStreak = longestStreak > currentStreak ? longestStreak : currentStreak;
          currentStreak = 1;
        }
      }

      lastDate = completionDate;
    }

    return longestStreak > currentStreak ? longestStreak : currentStreak;
  }

  @override
  Future<double> calculateCompletionRate(String habitId, {int days = 30}) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    
    final completions = await getCompletionsInRange(habitId, startDate, endDate);
    final completedDays = completions
        .where((c) => c.status == CompletionStatus.completed)
        .map((c) => DateTime(c.completedAt.year, c.completedAt.month, c.completedAt.day))
        .toSet()
        .length;
    
    return days > 0 ? completedDays / days : 0.0;
  }

  @override
  Future<List<HabitCompletion>> getTodaysCompletions() async {
    final models = await _dataSource.getAllCompletions();
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return models
        .where((model) => 
            model.completedAt.isAfter(startOfDay.subtract(const Duration(milliseconds: 1))) &&
            model.completedAt.isBefore(endOfDay))
        .map(_mapToEntity)
        .toList();
  }

  @override
  Future<Map<DateTime, List<HabitCompletion>>> getCompletionCalendar(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final completions = await getCompletionsInRange(habitId, startDate, endDate);
    final Map<DateTime, List<HabitCompletion>> calendar = {};
    
    for (final completion in completions) {
      final date = DateTime(
        completion.completedAt.year,
        completion.completedAt.month,
        completion.completedAt.day,
      );
      calendar[date] = calendar[date] ?? [];
      calendar[date]!.add(completion);
    }
    
    return calendar;
  }

  @override
  Future<bool> canCompleteToday(String habitId) async {
    final todaysCompletion = await getTodaysCompletion(habitId);
    return todaysCompletion == null || todaysCompletion.status != CompletionStatus.completed;
  }

  @override
  Future<int> getTotalXpEarned() async {
    final models = await _dataSource.getAllCompletions();
    return models
        .where((model) => model.status == CompletionStatus.completed)
        .fold(0, (sum, model) => sum + model.xpEarned);
  }

  @override
  Future<int> getXpEarnedInPeriod(DateTime startDate, DateTime endDate) async {
    final models = await _dataSource.getAllCompletions();
    return models
        .where((model) => 
            model.status == CompletionStatus.completed &&
            model.completedAt.isAfter(startDate.subtract(const Duration(milliseconds: 1))) &&
            model.completedAt.isBefore(endDate.add(const Duration(milliseconds: 1))))
        .fold(0, (sum, model) => sum + model.xpEarned);
  }

  // Helper methods for mapping between domain entities and data models
  HabitCompletion _mapToEntity(HabitCompletionModel model) {
    return HabitCompletion(
      id: model.id,
      habitId: model.habitId,
      completedAt: model.completedAt,
      status: model.status,
      xpEarned: model.xpEarned,
      notes: model.notes,
      actualCount: model.completedCount,
    );
  }

  HabitCompletionModel _mapToModel(HabitCompletion entity) {
    return HabitCompletionModel(
      id: entity.id,
      habitId: entity.habitId,
      completedAt: entity.completedAt,
      status: entity.status,
      xpEarned: entity.xpEarned,
      streakCount: 0, // Will be calculated separately
      notes: entity.notes,
      completedCount: entity.actualCount ?? 1,
      targetCount: 1, // Default target
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/enums/habit_enums.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_completion.dart';
import '../../domain/repositories/habit_completion_repository.dart';
import 'app_providers.dart';

/// Provider for habit statistics by habit ID
final habitStatsProvider = FutureProvider.family<HabitStats, String>((ref, habitId) async {
  final repository = ref.watch(habitCompletionRepositoryProvider);
  return repository.getHabitStats(habitId);
});

/// Provider for checking if a habit is completed today
final isHabitCompletedTodayProvider = FutureProvider.family<bool, String>((ref, habitId) async {
  final repository = ref.watch(habitCompletionRepositoryProvider);
  final completion = await repository.getTodaysCompletion(habitId);
  return completion?.status == CompletionStatus.completed;
});

/// Provider for today's completion for a specific habit
final todaysCompletionProvider = FutureProvider.family<HabitCompletion?, String>((ref, habitId) async {
  final repository = ref.watch(habitCompletionRepositoryProvider);
  return repository.getTodaysCompletion(habitId);
});

/// Provider for all completions of a specific habit
final habitCompletionsProvider = FutureProvider.family<List<HabitCompletion>, String>((ref, habitId) async {
  final repository = ref.watch(habitCompletionRepositoryProvider);
  return repository.getCompletionsForHabit(habitId);
});

/// Provider for today's completions across all habits
final todaysCompletionsProvider = FutureProvider<List<HabitCompletion>>((ref) async {
  final repository = ref.watch(habitCompletionRepositoryProvider);
  return repository.getTodaysCompletions();
});

/// Provider for total XP earned
final totalXpProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(habitCompletionRepositoryProvider);
  return repository.getTotalXpEarned();
});

/// State notifier for managing habit completion actions
class HabitCompletionNotifier extends StateNotifier<AsyncValue<void>> {
  final HabitCompletionRepository _repository;
  final Ref _ref;

  HabitCompletionNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  /// Complete a habit for today
  Future<void> completeHabit(Habit habit) async {
    state = const AsyncValue.loading();
    
    try {
      // Check if already completed today
      final todaysCompletion = await _repository.getTodaysCompletion(habit.id);
      if (todaysCompletion?.status == CompletionStatus.completed) {
        state = AsyncValue.error('Habit already completed today', StackTrace.current);
        return;
      }

      // Calculate XP based on difficulty
      final xpEarned = _calculateXP(habit);

      // Create completion record
      final completion = HabitCompletion(
        id: const Uuid().v4(),
        habitId: habit.id,
        completedAt: DateTime.now(),
        status: CompletionStatus.completed,
        xpEarned: xpEarned,
        actualCount: habit.targetCount,
      );

      await _repository.recordCompletion(completion);

      // Invalidate related providers to refresh UI
      _ref.invalidate(habitStatsProvider(habit.id));
      _ref.invalidate(isHabitCompletedTodayProvider(habit.id));
      _ref.invalidate(todaysCompletionProvider(habit.id));
      _ref.invalidate(todaysCompletionsProvider);
      _ref.invalidate(totalXpProvider);

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Undo today's completion for a habit
  Future<void> undoCompletion(String habitId) async {
    state = const AsyncValue.loading();
    
    try {
      final todaysCompletion = await _repository.getTodaysCompletion(habitId);
      if (todaysCompletion == null) {
        state = AsyncValue.error('No completion found for today', StackTrace.current);
        return;
      }

      await _repository.deleteCompletion(todaysCompletion.id);

      // Invalidate related providers
      _ref.invalidate(habitStatsProvider(habitId));
      _ref.invalidate(isHabitCompletedTodayProvider(habitId));
      _ref.invalidate(todaysCompletionProvider(habitId));
      _ref.invalidate(todaysCompletionsProvider);
      _ref.invalidate(totalXpProvider);

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Mark a habit as skipped for today
  Future<void> skipHabit(String habitId, {String? reason}) async {
    state = const AsyncValue.loading();
    
    try {
      final completion = HabitCompletion(
        id: const Uuid().v4(),
        habitId: habitId,
        completedAt: DateTime.now(),
        status: CompletionStatus.skipped,
        xpEarned: 0,
        notes: reason,
      );

      await _repository.recordCompletion(completion);

      // Invalidate related providers
      _ref.invalidate(habitStatsProvider(habitId));
      _ref.invalidate(isHabitCompletedTodayProvider(habitId));
      _ref.invalidate(todaysCompletionProvider(habitId));
      _ref.invalidate(todaysCompletionsProvider);

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Calculate XP earned for completing a habit
  int _calculateXP(Habit habit) {
    const baseXP = 10;
    final difficultyMultiplier = habit.difficulty.xpMultiplier;
    return (baseXP * difficultyMultiplier).round();
  }
}

/// Provider for habit completion actions
final habitCompletionNotifierProvider = StateNotifierProvider<HabitCompletionNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(habitCompletionRepositoryProvider);
  return HabitCompletionNotifier(repository, ref);
});

/// Provider for completion calendar data
final completionCalendarProvider = FutureProvider.family<Map<DateTime, List<HabitCompletion>>, ({String habitId, DateTime startDate, DateTime endDate})>((ref, params) async {
  final repository = ref.watch(habitCompletionRepositoryProvider);
  return repository.getCompletionCalendar(params.habitId, params.startDate, params.endDate);
});

/// Provider for checking if a habit can be completed today
final canCompleteHabitTodayProvider = FutureProvider.family<bool, String>((ref, habitId) async {
  final repository = ref.watch(habitCompletionRepositoryProvider);
  return repository.canCompleteToday(habitId);
});

/// Provider for XP earned in a specific period
final xpEarnedInPeriodProvider = FutureProvider.family<int, ({DateTime startDate, DateTime endDate})>((ref, params) async {
  final repository = ref.watch(habitCompletionRepositoryProvider);
  return repository.getXpEarnedInPeriod(params.startDate, params.endDate);
});

/// Provider for multiple habit stats (for dashboard)
final multipleHabitStatsProvider = FutureProvider.family<Map<String, HabitStats>, List<String>>((ref, habitIds) async {
  final repository = ref.watch(habitCompletionRepositoryProvider);
  return repository.getMultipleHabitStats(habitIds);
});

/// Provider for current streak of a specific habit
final currentStreakProvider = FutureProvider.family<int, String>((ref, habitId) async {
  final repository = ref.watch(habitCompletionRepositoryProvider);
  return repository.calculateCurrentStreak(habitId);
});

/// Provider for longest streak of a specific habit
final longestStreakProvider = FutureProvider.family<int, String>((ref, habitId) async {
  final repository = ref.watch(habitCompletionRepositoryProvider);
  return repository.calculateLongestStreak(habitId);
});

/// Provider for completion rate of a specific habit
final completionRateProvider = FutureProvider.family<double, ({String habitId, int days})>((ref, params) async {
  final repository = ref.watch(habitCompletionRepositoryProvider);
  return repository.calculateCompletionRate(params.habitId, days: params.days);
});

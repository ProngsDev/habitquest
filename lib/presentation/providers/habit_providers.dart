import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import 'app_providers.dart';

/// Provider for all habits
final habitsProvider = FutureProvider<List<Habit>>((ref) async {
  final repository = ref.watch(habitRepositoryProvider);
  final result = await repository.getAllHabits();
  return result.getOrThrow();
});

/// Provider for active habits only
final activeHabitsProvider = FutureProvider<List<Habit>>((ref) async {
  final repository = ref.watch(habitRepositoryProvider);
  final result = await repository.getActiveHabits();
  return result.getOrThrow();
});

/// Provider for a specific habit by ID
final habitByIdProvider = FutureProvider.family<Habit?, String>((
  ref,
  id,
) async {
  final repository = ref.watch(habitRepositoryProvider);
  final result = await repository.getHabitById(id);
  return result.getOrThrow();
});

/// Provider for habits with reminders
final habitsWithRemindersProvider = FutureProvider<List<Habit>>((ref) async {
  final repository = ref.watch(habitRepositoryProvider);
  final result = await repository.getHabitsWithReminders();
  return result.getOrThrow();
});

/// Provider for habit search
final habitSearchProvider = FutureProvider.family<List<Habit>, String>((
  ref,
  query,
) async {
  if (query.isEmpty) return [];
  final repository = ref.watch(habitRepositoryProvider);
  final result = await repository.searchHabits(query);
  return result.getOrThrow();
});

/// Provider for habit statistics
final habitStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final dataSource = ref.watch(hiveDataSourceProvider);
  return dataSource.getStatistics();
});

/// State provider for habit creation/editing
final habitFormProvider =
    StateNotifierProvider<HabitFormNotifier, HabitFormState>((ref) {
      final repository = ref.watch(habitRepositoryProvider);
      return HabitFormNotifier(repository);
    });

/// State for habit form
class HabitFormState {

  const HabitFormState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  HabitFormState copyWith({bool? isLoading, String? error, bool? isSuccess}) =>
      HabitFormState(
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
        isSuccess: isSuccess ?? this.isSuccess,
      );
}

/// Notifier for habit form operations
class HabitFormNotifier extends StateNotifier<HabitFormState> {

  HabitFormNotifier(this._repository) : super(const HabitFormState());
  final HabitRepository _repository;

  Future<void> createHabit(Habit habit) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.createHabit(habit);
    result.fold(
      (error) =>
          state = state.copyWith(isLoading: false, error: error.userMessage),
      (_) => state = state.copyWith(isLoading: false, isSuccess: true),
    );
  }

  Future<void> updateHabit(Habit habit) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.updateHabit(habit);
    result.fold(
      (error) =>
          state = state.copyWith(isLoading: false, error: error.userMessage),
      (_) => state = state.copyWith(isLoading: false, isSuccess: true),
    );
  }

  Future<void> deleteHabit(String id) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.deleteHabit(id);
    result.fold(
      (error) =>
          state = state.copyWith(isLoading: false, error: error.userMessage),
      (_) => state = state.copyWith(isLoading: false, isSuccess: true),
    );
  }

  void resetState() {
    state = const HabitFormState();
  }
}

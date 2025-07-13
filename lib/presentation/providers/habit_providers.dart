import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import 'app_providers.dart';

/// Provider for all habits
final habitsProvider = FutureProvider<List<Habit>>((ref) async {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.getAllHabits();
});

/// Provider for active habits only
final activeHabitsProvider = FutureProvider<List<Habit>>((ref) async {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.getActiveHabits();
});

/// Provider for a specific habit by ID
final habitByIdProvider = FutureProvider.family<Habit?, String>((ref, id) async {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.getHabitById(id);
});

/// Provider for habits with reminders
final habitsWithRemindersProvider = FutureProvider<List<Habit>>((ref) async {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.getHabitsWithReminders();
});

/// Provider for habit search
final habitSearchProvider = FutureProvider.family<List<Habit>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final repository = ref.watch(habitRepositoryProvider);
  return repository.searchHabits(query);
});

/// Provider for habit statistics
final habitStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final dataSource = ref.watch(hiveDataSourceProvider);
  return dataSource.getStatistics();
});

/// State provider for habit creation/editing
final habitFormProvider = StateNotifierProvider<HabitFormNotifier, HabitFormState>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return HabitFormNotifier(repository);
});

/// State for habit form
class HabitFormState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const HabitFormState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  HabitFormState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) => HabitFormState(
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
        isSuccess: isSuccess ?? this.isSuccess,
      );
}

/// Notifier for habit form operations
class HabitFormNotifier extends StateNotifier<HabitFormState> {
  final HabitRepository _repository;

  HabitFormNotifier(this._repository) : super(const HabitFormState());

  Future<void> createHabit(Habit habit) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _repository.createHabit(habit);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateHabit(Habit habit) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _repository.updateHabit(habit);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteHabit(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _repository.deleteHabit(id);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void resetState() {
    state = const HabitFormState();
  }
}

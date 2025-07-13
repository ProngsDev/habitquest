import '../../core/enums/habit_enums.dart';
import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/local/hive_datasource.dart';
import '../models/habit_model.dart';

/// Implementation of HabitRepository using Hive local storage
class HabitRepositoryImpl implements HabitRepository {
  final HiveDataSource _dataSource;

  const HabitRepositoryImpl(this._dataSource);

  @override
  Future<List<Habit>> getAllHabits() async {
    final habitModels = await _dataSource.getAllHabits();
    return habitModels.map(_mapToEntity).toList();
  }

  @override
  Future<List<Habit>> getActiveHabits() async {
    final habitModels = await _dataSource.getActiveHabits();
    return habitModels.map(_mapToEntity).toList();
  }

  @override
  Future<List<Habit>> getHabitsByCategory(HabitCategory category) async {
    final allHabits = await getAllHabits();
    return allHabits.where((habit) => habit.category == category).toList();
  }

  @override
  Future<Habit?> getHabitById(String id) async {
    final habitModel = await _dataSource.getHabitById(id);
    return habitModel != null ? _mapToEntity(habitModel) : null;
  }

  @override
  Future<void> createHabit(Habit habit) async {
    final habitModel = _mapToModel(habit);
    await _dataSource.saveHabit(habitModel);
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    final habitModel = _mapToModel(habit);
    await _dataSource.updateHabit(habitModel);
  }

  @override
  Future<void> deleteHabit(String id) async {
    await _dataSource.deleteHabit(id);
  }

  @override
  Future<void> archiveHabit(String id) async {
    final habit = await getHabitById(id);
    if (habit != null) {
      final archivedHabit = habit.copyWith(isActive: false);
      await updateHabit(archivedHabit);
    }
  }

  @override
  Future<void> restoreHabit(String id) async {
    final habit = await getHabitById(id);
    if (habit != null) {
      final restoredHabit = habit.copyWith(isActive: true);
      await updateHabit(restoredHabit);
    }
  }

  @override
  Future<List<Habit>> searchHabits(String query) async {
    final allHabits = await getAllHabits();
    final lowercaseQuery = query.toLowerCase();
    
    return allHabits.where((habit) =>
        habit.name.toLowerCase().contains(lowercaseQuery) ||
        habit.description.toLowerCase().contains(lowercaseQuery)).toList();
  }

  @override
  Future<List<Habit>> getHabitsWithReminders() async {
    final allHabits = await getAllHabits();
    return allHabits.where((habit) => habit.reminderTime != null).toList();
  }

  @override
  Future<Map<HabitCategory, int>> getHabitsCountByCategory() async {
    final allHabits = await getAllHabits();
    final countMap = <HabitCategory, int>{};
    
    for (final category in HabitCategory.values) {
      countMap[category] = allHabits.where((habit) => habit.category == category).length;
    }
    
    return countMap;
  }

  @override
  Future<List<Habit>> getHabitsCreatedInRange(DateTime start, DateTime end) async {
    final allHabits = await getAllHabits();
    return allHabits.where((habit) =>
        habit.createdAt.isAfter(start) && habit.createdAt.isBefore(end)).toList();
  }

  // Helper methods for mapping between domain entities and data models
  Habit _mapToEntity(HabitModel model) => Habit(
        id: model.id,
        name: model.name,
        description: model.description,
        category: model.category,
        difficulty: model.difficulty,
        frequency: model.frequency,
        createdAt: model.createdAt,
        reminderTime: model.reminderTime,
        isActive: model.isActive,
        iconName: model.iconName,
        colorValue: model.colorValue,
        targetCount: model.targetCount,
        unit: model.unit,
      );

  HabitModel _mapToModel(Habit entity) => HabitModel(
        id: entity.id,
        name: entity.name,
        description: entity.description,
        category: entity.category,
        difficulty: entity.difficulty,
        frequency: entity.frequency,
        createdAt: entity.createdAt,
        reminderTime: entity.reminderTime,
        isActive: entity.isActive,
        iconName: entity.iconName,
        colorValue: entity.colorValue,
        targetCount: entity.targetCount,
        unit: entity.unit,
      );
}

import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../../models/achievement_model.dart';
import '../../models/habit_completion_model.dart';
import '../../models/habit_model.dart';
import '../../models/user_model.dart';

/// Local data source using Hive for offline storage
class HiveDataSource {
  // Lazy getters for Hive boxes
  Box<UserModel> get _userBox => Hive.box<UserModel>(AppConstants.userBoxName);
  Box<HabitModel> get _habitsBox =>
      Hive.box<HabitModel>(AppConstants.habitsBoxName);
  Box<HabitCompletionModel> get _completionsBox =>
      Hive.box<HabitCompletionModel>(AppConstants.completionsBoxName);
  Box<AchievementModel> get _achievementsBox =>
      Hive.box<AchievementModel>(AppConstants.achievementsBoxName);

  // User operations
  Future<UserModel?> getCurrentUser() async {
    if (_userBox.isEmpty) return null;
    return _userBox.getAt(0);
  }

  Future<void> saveUser(UserModel user) async {
    await _userBox.clear();
    await _userBox.add(user);
  }

  Future<void> updateUser(UserModel user) async {
    if (_userBox.isNotEmpty) {
      await _userBox.putAt(0, user);
    } else {
      await _userBox.add(user);
    }
  }

  // Habit operations
  Future<List<HabitModel>> getAllHabits() async => _habitsBox.values.toList();

  Future<List<HabitModel>> getActiveHabits() async =>
      _habitsBox.values.where((habit) => habit.isActive).toList();

  Future<HabitModel?> getHabitById(String id) async => _habitsBox.values
      .cast<HabitModel?>()
      .firstWhere((habit) => habit?.id == id, orElse: () => null);

  Future<void> saveHabit(HabitModel habit) async {
    await _habitsBox.put(habit.id, habit);
  }

  Future<void> updateHabit(HabitModel habit) async {
    await _habitsBox.put(habit.id, habit);
  }

  Future<void> deleteHabit(String id) async {
    await _habitsBox.delete(id);
  }

  // Habit completion operations
  Future<List<HabitCompletionModel>> getAllCompletions() async =>
      _completionsBox.values.toList();

  Future<List<HabitCompletionModel>> getCompletionsForHabit(
    String habitId,
  ) async => _completionsBox.values
      .where((completion) => completion.habitId == habitId)
      .toList();

  Future<HabitCompletionModel?> getCompletionById(String id) async =>
      _completionsBox.values.cast<HabitCompletionModel?>().firstWhere(
        (completion) => completion?.id == id,
        orElse: () => null,
      );

  Future<void> saveCompletion(HabitCompletionModel completion) async {
    await _completionsBox.put(completion.id, completion);
  }

  Future<void> updateCompletion(HabitCompletionModel completion) async {
    await _completionsBox.put(completion.id, completion);
  }

  Future<void> deleteCompletion(String id) async {
    await _completionsBox.delete(id);
  }

  Future<List<HabitCompletionModel>> getCompletionsInDateRange(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final completions = await getCompletionsForHabit(habitId);
    return completions.where((completion) {
      final completionDate = completion.completedAt;
      return completionDate.isAfter(
            startDate.subtract(const Duration(days: 1)),
          ) &&
          completionDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  Future<HabitCompletionModel?> getTodaysCompletion(String habitId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final completions = await getCompletionsForHabit(habitId);
    return completions.cast<HabitCompletionModel?>().firstWhere(
      (completion) =>
          completion != null &&
          completion.completedAt.isAfter(
            today.subtract(const Duration(milliseconds: 1)),
          ) &&
          completion.completedAt.isBefore(tomorrow),
      orElse: () => null,
    );
  }

  // Achievement operations
  Future<List<AchievementModel>> getAllAchievements() async =>
      _achievementsBox.values.toList();

  Future<List<AchievementModel>> getUnlockedAchievements() async =>
      _achievementsBox.values
          .where((achievement) => achievement.isUnlocked)
          .toList();

  Future<void> saveAchievement(AchievementModel achievement) async {
    await _achievementsBox.put(achievement.id, achievement);
  }

  Future<void> updateAchievement(AchievementModel achievement) async {
    await _achievementsBox.put(achievement.id, achievement);
  }

  Future<AchievementModel?> getAchievementById(String id) async => _achievementsBox.get(id);

  Future<void> deleteAchievement(String id) async {
    await _achievementsBox.delete(id);
  }

  // Utility methods
  Future<void> clearAllData() async {
    await _userBox.clear();
    await _habitsBox.clear();
    await _achievementsBox.clear();
  }

  Future<bool> hasData() async =>
      _userBox.isNotEmpty ||
      _habitsBox.isNotEmpty ||
      _achievementsBox.isNotEmpty;

  // Statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final user = await getCurrentUser();
    final habits = await getAllHabits();
    final achievements = await getAllAchievements();

    return {
      'totalHabits': habits.length,
      'activeHabits': habits.where((h) => h.isActive).length,
      'totalAchievements': achievements.length,
      'unlockedAchievements': achievements.where((a) => a.isUnlocked).length,
      'userLevel': user?.level ?? 1,
      'userXp': user?.totalXp ?? 0,
      'currentStreak': user?.currentStreak ?? 0,
      'longestStreak': user?.longestStreak ?? 0,
    };
  }
}

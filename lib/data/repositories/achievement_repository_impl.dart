import '../../domain/entities/achievement.dart';
import '../../domain/repositories/achievement_repository.dart';
import '../datasources/local/hive_datasource.dart';
import '../models/achievement_model.dart' as model;

/// Implementation of AchievementRepository using Hive local storage
class AchievementRepositoryImpl implements AchievementRepository {

  const AchievementRepositoryImpl(this._dataSource);
  final HiveDataSource _dataSource;

  @override
  Future<List<Achievement>> getAllAchievements() async {
    final achievementModels = await _dataSource.getAllAchievements();
    return achievementModels.map(_mapToEntity).toList();
  }

  @override
  Future<List<Achievement>> getUnlockedAchievements() async {
    final allAchievements = await getAllAchievements();
    return allAchievements
        .where((achievement) => achievement.isUnlocked)
        .toList();
  }

  @override
  Future<List<Achievement>> getLockedAchievements() async {
    final allAchievements = await getAllAchievements();
    return allAchievements
        .where((achievement) => !achievement.isUnlocked)
        .toList();
  }

  @override
  Future<List<Achievement>> getAchievementsByType(AchievementType type) async {
    final allAchievements = await getAllAchievements();
    return allAchievements
        .where((achievement) => achievement.type == type)
        .toList();
  }

  @override
  Future<Achievement?> getAchievementById(String id) async {
    final achievementModel = await _dataSource.getAchievementById(id);
    return achievementModel != null ? _mapToEntity(achievementModel) : null;
  }

  @override
  Future<void> createAchievement(Achievement achievement) async {
    final achievementModel = _mapToModel(achievement);
    await _dataSource.saveAchievement(achievementModel);
  }

  @override
  Future<void> updateAchievement(Achievement achievement) async {
    final achievementModel = _mapToModel(achievement);
    await _dataSource.updateAchievement(achievementModel);
  }

  @override
  Future<void> deleteAchievement(String id) async {
    await _dataSource.deleteAchievement(id);
  }

  @override
  Future<Achievement> unlockAchievement(String id) async {
    final achievement = await getAchievementById(id);
    if (achievement == null) {
      throw Exception('Achievement not found');
    }

    if (achievement.isUnlocked) {
      return achievement; // Already unlocked
    }

    final unlockedAchievement = achievement.copyWith(
      isUnlocked: true,
      unlockedAt: DateTime.now(),
    );

    await updateAchievement(unlockedAchievement);
    return unlockedAchievement;
  }

  @override
  Future<Achievement> updateProgress(String id, int newProgress) async {
    final achievement = await getAchievementById(id);
    if (achievement == null) {
      throw Exception('Achievement not found');
    }

    final updatedAchievement = achievement.copyWith(
      currentProgress: newProgress,
    );

    await updateAchievement(updatedAchievement);
    return updatedAchievement;
  }

  @override
  Future<List<Achievement>> checkForUnlockableAchievements() async {
    final lockedAchievements = await getLockedAchievements();
    return lockedAchievements
        .where((achievement) => achievement.isCompleted)
        .toList();
  }

  @override
  Future<List<Achievement>> getNearCompletionAchievements() async {
    final lockedAchievements = await getLockedAchievements();
    return lockedAchievements
        .where(
          (achievement) =>
              achievement.progressPercentage >= 0.8 && !achievement.isCompleted,
        )
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getAchievementStatistics() async {
    final allAchievements = await getAllAchievements();
    final unlockedAchievements = allAchievements
        .where((a) => a.isUnlocked)
        .toList();

    return {
      'totalAchievements': allAchievements.length,
      'unlockedAchievements': unlockedAchievements.length,
      'lockedAchievements':
          allAchievements.length - unlockedAchievements.length,
      'completionPercentage': allAchievements.isEmpty
          ? 0.0
          : unlockedAchievements.length / allAchievements.length,
      'totalCoinsEarned': unlockedAchievements.fold<int>(
        0,
        (sum, a) => sum + a.coinsReward,
      ),
      'totalXpEarned': unlockedAchievements.fold<int>(
        0,
        (sum, a) => sum + a.xpReward,
      ),
    };
  }

  @override
  Future<void> initializeDefaultAchievements() async {
    final existingAchievements = await getAllAchievements();
    if (existingAchievements.isNotEmpty) {
      return; // Already initialized
    }

    final defaultAchievements = _getDefaultAchievements();
    for (final achievement in defaultAchievements) {
      await createAchievement(achievement);
    }
  }

  @override
  Future<List<Achievement>> getAchievementsByRarity(
    AchievementRarity rarity,
  ) async {
    final allAchievements = await getAllAchievements();
    return allAchievements
        .where((achievement) => achievement.rarity == rarity)
        .toList();
  }

  @override
  Future<List<Achievement>> searchAchievements(String query) async {
    if (query.isEmpty) return [];

    final allAchievements = await getAllAchievements();
    final lowercaseQuery = query.toLowerCase();

    return allAchievements
        .where(
          (achievement) =>
              achievement.name.toLowerCase().contains(lowercaseQuery) ||
              achievement.description.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }

  @override
  Future<int> getTotalCoinsFromAchievements() async {
    final unlockedAchievements = await getUnlockedAchievements();
    return unlockedAchievements.fold<int>(
      0,
      (sum, achievement) => sum + achievement.coinsReward,
    );
  }

  @override
  Future<int> getTotalXpFromAchievements() async {
    final unlockedAchievements = await getUnlockedAchievements();
    return unlockedAchievements.fold<int>(
      0,
      (sum, achievement) => sum + achievement.xpReward,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getUnlockHistory() async {
    final unlockedAchievements = await getUnlockedAchievements();
    return unlockedAchievements
        .where((achievement) => achievement.unlockedAt != null)
        .map(
          (achievement) => {
            'id': achievement.id,
            'name': achievement.name,
            'unlockedAt': achievement.unlockedAt!,
            'coinsReward': achievement.coinsReward,
            'xpReward': achievement.xpReward,
          },
        )
        .toList()
      ..sort(
        (a, b) => (b['unlockedAt']! as DateTime).compareTo(
          a['unlockedAt']! as DateTime,
        ),
      );
  }

  @override
  Future<List<Achievement>> updateAllAchievementProgress(
    Map<String, dynamic> userStats,
  ) async {
    final allAchievements = await getAllAchievements();
    final updatedAchievements = <Achievement>[];

    for (final achievement in allAchievements) {
      if (achievement.isUnlocked) continue;

      final newProgress = _calculateProgressForAchievement(
        achievement,
        userStats,
      );
      if (newProgress != achievement.currentProgress) {
        final updatedAchievement = achievement.copyWith(
          currentProgress: newProgress,
        );
        await updateAchievement(updatedAchievement);
        updatedAchievements.add(updatedAchievement);
      }
    }

    return updatedAchievements;
  }

  /// Calculate progress for an achievement based on user stats
  int _calculateProgressForAchievement(
    Achievement achievement,
    Map<String, dynamic> userStats,
  ) {
    switch (achievement.type) {
      case AchievementType.streak:
        return (userStats['longestStreak'] as int?) ?? 0;
      case AchievementType.totalHabits:
        return (userStats['totalHabitsCompleted'] as int?) ?? 0;
      case AchievementType.totalXp:
        return (userStats['totalXp'] as int?) ?? 0;
      case AchievementType.level:
        return (userStats['level'] as int?) ?? 1;
      case AchievementType.consistency:
      case AchievementType.category:
      case AchievementType.special:
        // These would require more complex calculations
        return achievement.currentProgress;
    }
  }

  /// Map AchievementModel to Achievement entity
  Achievement _mapToEntity(model.AchievementModel achievementModel) => Achievement(
      id: achievementModel.id,
      name: achievementModel.name,
      description: achievementModel.description,
      iconName: achievementModel.iconName,
      coinsReward: achievementModel.coinsReward,
      xpReward: achievementModel.xpReward,
      type: _mapAchievementTypeToEntity(achievementModel.type),
      targetValue: achievementModel.targetValue,
      isUnlocked: achievementModel.isUnlocked,
      unlockedAt: achievementModel.unlockedAt,
      currentProgress: achievementModel.currentProgress,
    );

  /// Map Achievement entity to AchievementModel
  model.AchievementModel _mapToModel(Achievement entity) => model.AchievementModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      iconName: entity.iconName,
      coinsReward: entity.coinsReward,
      xpReward: entity.xpReward,
      type: _mapAchievementTypeToModel(entity.type),
      targetValue: entity.targetValue,
      isUnlocked: entity.isUnlocked,
      unlockedAt: entity.unlockedAt,
      currentProgress: entity.currentProgress,
    );

  /// Map model AchievementType to entity AchievementType
  AchievementType _mapAchievementTypeToEntity(model.AchievementType modelType) {
    switch (modelType) {
      case model.AchievementType.streak:
        return AchievementType.streak;
      case model.AchievementType.totalHabits:
        return AchievementType.totalHabits;
      case model.AchievementType.totalXp:
        return AchievementType.totalXp;
      case model.AchievementType.level:
        return AchievementType.level;
      case model.AchievementType.consistency:
        return AchievementType.consistency;
      case model.AchievementType.category:
        return AchievementType.category;
      case model.AchievementType.special:
        return AchievementType.special;
    }
  }

  /// Map entity AchievementType to model AchievementType
  model.AchievementType _mapAchievementTypeToModel(AchievementType entityType) {
    switch (entityType) {
      case AchievementType.streak:
        return model.AchievementType.streak;
      case AchievementType.totalHabits:
        return model.AchievementType.totalHabits;
      case AchievementType.totalXp:
        return model.AchievementType.totalXp;
      case AchievementType.level:
        return model.AchievementType.level;
      case AchievementType.consistency:
        return model.AchievementType.consistency;
      case AchievementType.category:
        return model.AchievementType.category;
      case AchievementType.special:
        return model.AchievementType.special;
    }
  }

  /// Get default achievements to initialize the app
  List<Achievement> _getDefaultAchievements() => [
      // Streak achievements
      const Achievement(
        id: 'streak_3',
        name: 'Getting Started',
        description: 'Complete habits for 3 days in a row',
        iconName: 'flame',
        coinsReward: 10,
        xpReward: 50,
        type: AchievementType.streak,
        targetValue: 3,
      ),
      const Achievement(
        id: 'streak_7',
        name: 'Week Warrior',
        description: 'Complete habits for 7 days in a row',
        iconName: 'flame_fill',
        coinsReward: 25,
        xpReward: 100,
        type: AchievementType.streak,
        targetValue: 7,
      ),
      const Achievement(
        id: 'streak_30',
        name: 'Monthly Master',
        description: 'Complete habits for 30 days in a row',
        iconName: 'star_fill',
        coinsReward: 100,
        xpReward: 500,
        type: AchievementType.streak,
        targetValue: 30,
      ),

      // Level achievements
      const Achievement(
        id: 'level_5',
        name: 'Rising Star',
        description: 'Reach level 5',
        iconName: 'star',
        coinsReward: 20,
        type: AchievementType.level,
        targetValue: 5,
      ),
      const Achievement(
        id: 'level_10',
        name: 'Habit Hero',
        description: 'Reach level 10',
        iconName: 'star_circle',
        coinsReward: 50,
        type: AchievementType.level,
        targetValue: 10,
      ),

      // Total habits achievements
      const Achievement(
        id: 'habits_10',
        name: 'Habit Collector',
        description: 'Complete 10 habits',
        iconName: 'checkmark_circle',
        coinsReward: 15,
        xpReward: 75,
        type: AchievementType.totalHabits,
        targetValue: 10,
      ),
      const Achievement(
        id: 'habits_50',
        name: 'Habit Master',
        description: 'Complete 50 habits',
        iconName: 'checkmark_circle_fill',
        coinsReward: 75,
        xpReward: 250,
        type: AchievementType.totalHabits,
        targetValue: 50,
      ),

      // XP achievements
      const Achievement(
        id: 'xp_500',
        name: 'XP Collector',
        description: 'Earn 500 XP',
        iconName: 'bolt',
        coinsReward: 30,
        type: AchievementType.totalXp,
        targetValue: 500,
      ),
      const Achievement(
        id: 'xp_2000',
        name: 'XP Master',
        description: 'Earn 2000 XP',
        iconName: 'bolt_fill',
        coinsReward: 100,
        type: AchievementType.totalXp,
        targetValue: 2000,
      ),
    ];
}

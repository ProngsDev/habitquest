import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local/hive_datasource.dart';
import '../models/user_model.dart';

/// Implementation of UserRepository using Hive local storage
class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl(this._dataSource);
  final HiveDataSource _dataSource;

  @override
  Future<User?> getCurrentUser() async {
    final userModel = await _dataSource.getCurrentUser();
    return userModel != null ? _mapToEntity(userModel) : null;
  }

  @override
  Future<void> createUser(User user) async {
    final userModel = _mapToModel(user);
    await _dataSource.saveUser(userModel);
  }

  @override
  Future<void> updateUser(User user) async {
    final userModel = _mapToModel(user);
    await _dataSource.updateUser(userModel);
  }

  @override
  Future<void> deleteUser(String id) async {
    // For now, we'll clear the user box since we only support one user
    final userModel = await _dataSource.getCurrentUser();
    if (userModel?.id == id) {
      // Implementation would depend on HiveDataSource having a deleteUser method
      // For now, we'll throw an exception to indicate this needs implementation
      throw UnimplementedError('Delete user not implemented in HiveDataSource');
    }
  }

  @override
  Future<User> addXpToUser(String userId, int xp) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null || currentUser.id != userId) {
      throw Exception('User not found');
    }

    final updatedUser = currentUser.copyWith(
      totalXp: currentUser.totalXp + xp,
      level: _calculateLevel(currentUser.totalXp + xp),
      lastActiveAt: DateTime.now(),
    );

    await updateUser(updatedUser);
    return updatedUser;
  }

  @override
  Future<User> updateUserStreak(String userId, int newStreak) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null || currentUser.id != userId) {
      throw Exception('User not found');
    }

    final updatedUser = currentUser.copyWith(
      currentStreak: newStreak,
      longestStreak: newStreak > currentUser.longestStreak
          ? newStreak
          : currentUser.longestStreak,
      lastActiveAt: DateTime.now(),
    );

    await updateUser(updatedUser);
    return updatedUser;
  }

  @override
  Future<User> unlockAchievement(String userId, String achievementId) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null || currentUser.id != userId) {
      throw Exception('User not found');
    }

    if (currentUser.unlockedAchievements.contains(achievementId)) {
      return currentUser; // Already unlocked
    }

    final newAchievements = List<String>.from(currentUser.unlockedAchievements)
      ..add(achievementId);

    final updatedUser = currentUser.copyWith(
      unlockedAchievements: newAchievements,
      coins: currentUser.coins + 50, // Bonus coins for achievement
      lastActiveAt: DateTime.now(),
    );

    await updateUser(updatedUser);
    return updatedUser;
  }

  @override
  Future<User> spendCoins(String userId, int amount) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null || currentUser.id != userId) {
      throw Exception('User not found');
    }

    if (currentUser.coins < amount) {
      throw Exception('Insufficient coins');
    }

    final updatedUser = currentUser.copyWith(
      coins: currentUser.coins - amount,
      lastActiveAt: DateTime.now(),
    );

    await updateUser(updatedUser);
    return updatedUser;
  }

  @override
  Future<User> updatePreference(
    String userId,
    String key,
    dynamic value,
  ) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null || currentUser.id != userId) {
      throw Exception('User not found');
    }

    final newPreferences = Map<String, dynamic>.from(currentUser.preferences);
    newPreferences[key] = value;

    final updatedUser = currentUser.copyWith(
      preferences: newPreferences,
      lastActiveAt: DateTime.now(),
    );

    await updateUser(updatedUser);
    return updatedUser;
  }

  @override
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    final user = await getCurrentUser();
    if (user == null || user.id != userId) {
      throw Exception('User not found');
    }

    return {
      'totalXp': user.totalXp,
      'level': user.level,
      'currentStreak': user.currentStreak,
      'longestStreak': user.longestStreak,
      'totalHabitsCompleted': user.totalHabitsCompleted,
      'coins': user.coins,
      'unlockedAchievements': user.unlockedAchievements.length,
      'xpProgressInLevel': user.xpProgressInLevel,
      'xpRequiredForNextLevel': user.xpRequiredForNextLevel,
      'levelProgressPercentage': user.levelProgressPercentage,
      'memberSince': user.createdAt,
      'lastActive': user.lastActiveAt,
    };
  }

  @override
  Future<bool> userExists(String id) async {
    final user = await getCurrentUser();
    return user?.id == id;
  }

  @override
  Future<List<Map<String, dynamic>>> getUserLevelHistory(String userId) async =>
      // This would require storing level history data
      // For now, return empty list as this feature isn't implemented yet
      [];

  @override
  Future<List<Map<String, dynamic>>> getUserXpHistory(String userId) async =>
      // This would require storing XP history data
      // For now, return empty list as this feature isn't implemented yet
      [];

  /// Map UserModel to User entity
  User _mapToEntity(UserModel model) => User(
    id: model.id,
    name: model.name,
    email: model.email,
    totalXp: model.totalXp,
    level: model.level,
    createdAt: model.createdAt,
    lastActiveAt: model.lastActiveAt,
    avatarPath: model.avatarPath,
    coins: model.coins,
    preferences: model.preferences,
    unlockedAchievements: model.unlockedAchievements,
    longestStreak: model.longestStreak,
    currentStreak: model.currentStreak,
    totalHabitsCompleted: model.totalHabitsCompleted,
  );

  /// Map User entity to UserModel
  UserModel _mapToModel(User entity) => UserModel(
    id: entity.id,
    name: entity.name,
    email: entity.email,
    totalXp: entity.totalXp,
    level: entity.level,
    createdAt: entity.createdAt,
    lastActiveAt: entity.lastActiveAt,
    avatarPath: entity.avatarPath,
    coins: entity.coins,
    preferences: entity.preferences,
    unlockedAchievements: entity.unlockedAchievements,
    longestStreak: entity.longestStreak,
    currentStreak: entity.currentStreak,
    totalHabitsCompleted: entity.totalHabitsCompleted,
  );

  /// Calculate level from total XP
  int _calculateLevel(int totalXp) {
    if (totalXp <= 0) return 1;
    return (totalXp / 100).floor() + 1;
  }
}

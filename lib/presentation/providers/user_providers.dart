import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import 'app_providers.dart';

/// Provider for current user
final currentUserProvider = FutureProvider<User?>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getCurrentUser();
});

/// Provider for user statistics
final userStatisticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) {
    // Return default stats for new user
    return {
      'totalXp': 0,
      'level': 1,
      'currentStreak': 0,
      'longestStreak': 0,
      'totalHabitsCompleted': 0,
      'coins': 0,
      'unlockedAchievements': 0,
      'xpProgressInLevel': 0,
      'xpRequiredForNextLevel': 100,
      'levelProgressPercentage': 0.0,
      'memberSince': DateTime.now(),
      'lastActive': DateTime.now(),
    };
  }

  final repository = ref.watch(userRepositoryProvider);
  return repository.getUserStatistics(user.id);
});

/// Provider for user level progress
final userLevelProgressProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) {
    return {
      'currentLevel': 1,
      'totalXp': 0,
      'xpInCurrentLevel': 0,
      'xpRequiredForNextLevel': 100,
      'progressPercentage': 0.0,
    };
  }

  return {
    'currentLevel': user.level,
    'totalXp': user.totalXp,
    'xpInCurrentLevel': user.xpProgressInLevel,
    'xpRequiredForNextLevel': user.xpRequiredForNextLevel,
    'progressPercentage': user.levelProgressPercentage,
  };
});

/// Provider for user achievements
final userAchievementsProvider = FutureProvider<List<String>>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  return user?.unlockedAchievements ?? [];
});

/// State notifier for user operations
final userNotifierProvider =
    StateNotifierProvider<UserNotifier, AsyncValue<User?>>((ref) {
      final repository = ref.watch(userRepositoryProvider);
      return UserNotifier(repository);
    });

/// User state notifier for managing user operations
class UserNotifier extends StateNotifier<AsyncValue<User?>> {
  final UserRepository _repository;

  UserNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadUser();
  }

  /// Load current user
  Future<void> _loadUser() async {
    try {
      final user = await _repository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Create a new user
  Future<void> createUser({
    required String name,
    String? email,
    String? avatarPath,
  }) async {
    try {
      state = const AsyncValue.loading();

      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        avatarPath: avatarPath,
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
      );

      await _repository.createUser(user);
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update user information
  Future<void> updateUser(User user) async {
    try {
      await _repository.updateUser(user);
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Add XP to user
  Future<void> addXp(int xp) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    try {
      final updatedUser = await _repository.addXpToUser(currentUser.id, xp);
      state = AsyncValue.data(updatedUser);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update user streak
  Future<void> updateStreak(int newStreak) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    try {
      final updatedUser = await _repository.updateUserStreak(
        currentUser.id,
        newStreak,
      );
      state = AsyncValue.data(updatedUser);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Unlock achievement
  Future<void> unlockAchievement(String achievementId) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    try {
      final updatedUser = await _repository.unlockAchievement(
        currentUser.id,
        achievementId,
      );
      state = AsyncValue.data(updatedUser);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Spend coins
  Future<void> spendCoins(int amount) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    try {
      final updatedUser = await _repository.spendCoins(currentUser.id, amount);
      state = AsyncValue.data(updatedUser);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update user preference
  Future<void> updatePreference(String key, dynamic value) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    try {
      final updatedUser = await _repository.updatePreference(
        currentUser.id,
        key,
        value,
      );
      state = AsyncValue.data(updatedUser);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh user data
  Future<void> refresh() async {
    await _loadUser();
  }
}

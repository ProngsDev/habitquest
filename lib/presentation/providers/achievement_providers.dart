import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/achievement.dart';
import '../../domain/repositories/achievement_repository.dart';
import 'app_providers.dart';
import 'user_providers.dart';

/// Provider for all achievements
final achievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final repository = ref.watch(achievementRepositoryProvider);
  return repository.getAllAchievements();
});

/// Provider for unlocked achievements
final unlockedAchievementsProvider = FutureProvider<List<Achievement>>((
  ref,
) async {
  final repository = ref.watch(achievementRepositoryProvider);
  return repository.getUnlockedAchievements();
});

/// Provider for locked achievements
final lockedAchievementsProvider = FutureProvider<List<Achievement>>((
  ref,
) async {
  final repository = ref.watch(achievementRepositoryProvider);
  return repository.getLockedAchievements();
});

/// Provider for achievements by type
final achievementsByTypeProvider =
    FutureProvider.family<List<Achievement>, AchievementType>((
      ref,
      type,
    ) async {
      final repository = ref.watch(achievementRepositoryProvider);
      return repository.getAchievementsByType(type);
    });

/// Provider for achievement by ID
final achievementByIdProvider = FutureProvider.family<Achievement?, String>((
  ref,
  id,
) async {
  final repository = ref.watch(achievementRepositoryProvider);
  return repository.getAchievementById(id);
});

/// Provider for achievements near completion
final nearCompletionAchievementsProvider = FutureProvider<List<Achievement>>((
  ref,
) async {
  final repository = ref.watch(achievementRepositoryProvider);
  return repository.getNearCompletionAchievements();
});

/// Provider for achievement statistics
final achievementStatisticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final repository = ref.watch(achievementRepositoryProvider);
  return repository.getAchievementStatistics();
});

/// Provider for achievements by rarity
final achievementsByRarityProvider =
    FutureProvider.family<List<Achievement>, AchievementRarity>((
      ref,
      rarity,
    ) async {
      final repository = ref.watch(achievementRepositoryProvider);
      return repository.getAchievementsByRarity(rarity);
    });

/// Provider for achievement search
final achievementSearchProvider =
    FutureProvider.family<List<Achievement>, String>((ref, query) async {
      if (query.isEmpty) return [];
      final repository = ref.watch(achievementRepositoryProvider);
      return repository.searchAchievements(query);
    });

/// Provider for achievement unlock history
final achievementUnlockHistoryProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
      final repository = ref.watch(achievementRepositoryProvider);
      return repository.getUnlockHistory();
    });

/// State notifier for achievement operations
final achievementNotifierProvider =
    StateNotifierProvider<AchievementNotifier, AsyncValue<List<Achievement>>>((
      ref,
    ) {
      final repository = ref.watch(achievementRepositoryProvider);
      return AchievementNotifier(repository);
    });

/// Achievement state notifier for managing achievement operations
class AchievementNotifier extends StateNotifier<AsyncValue<List<Achievement>>> {
  AchievementNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadAchievements();
  }
  final AchievementRepository _repository;

  /// Load all achievements
  Future<void> _loadAchievements() async {
    try {
      final achievements = await _repository.getAllAchievements();
      state = AsyncValue.data(achievements);
    } on Exception catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Initialize default achievements
  Future<void> initializeDefaultAchievements() async {
    try {
      await _repository.initializeDefaultAchievements();
      await _loadAchievements();
    } on Exception catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Unlock an achievement
  Future<Achievement?> unlockAchievement(String id) async {
    try {
      final unlockedAchievement = await _repository.unlockAchievement(id);

      // Award coins and XP to user
      if (unlockedAchievement.coinsReward > 0) {
        // Add coins to user (this would be handled by user repository)
        // For now, we'll just refresh the achievements
      }

      await _loadAchievements();
      return unlockedAchievement;
    } on Exception catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  /// Update achievement progress
  Future<Achievement?> updateProgress(String id, int newProgress) async {
    try {
      final updatedAchievement = await _repository.updateProgress(
        id,
        newProgress,
      );

      // Check if achievement should be unlocked
      if (updatedAchievement.isCompleted && !updatedAchievement.isUnlocked) {
        return await unlockAchievement(id);
      }

      await _loadAchievements();
      return updatedAchievement;
    } on Exception catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  /// Check for unlockable achievements based on user stats
  Future<List<Achievement>> checkForUnlockableAchievements(
    Map<String, dynamic> userStats,
  ) async {
    try {
      // Update all achievement progress
      await _repository.updateAllAchievementProgress(userStats);

      // Get achievements that can be unlocked
      final unlockableAchievements = await _repository
          .checkForUnlockableAchievements();

      // Auto-unlock achievements that meet criteria
      final newlyUnlocked = <Achievement>[];
      for (final achievement in unlockableAchievements) {
        final unlocked = await unlockAchievement(achievement.id);
        if (unlocked != null) {
          newlyUnlocked.add(unlocked);
        }
      }

      return newlyUnlocked;
    } on Exception catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return [];
    }
  }

  /// Create a new achievement
  Future<void> createAchievement(Achievement achievement) async {
    try {
      await _repository.createAchievement(achievement);
      await _loadAchievements();
    } on Exception catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update an existing achievement
  Future<void> updateAchievement(Achievement achievement) async {
    try {
      await _repository.updateAchievement(achievement);
      await _loadAchievements();
    } on Exception catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Delete an achievement
  Future<void> deleteAchievement(String id) async {
    try {
      await _repository.deleteAchievement(id);
      await _loadAchievements();
    } on Exception catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh achievements
  Future<void> refresh() async {
    await _loadAchievements();
  }
}

/// Provider for checking if achievements should be updated based on user stats
final achievementUpdateProvider = FutureProvider<List<Achievement>>((
  ref,
) async {
  final userStats = await ref.watch(userStatisticsProvider.future);
  final achievementNotifier = ref.watch(achievementNotifierProvider.notifier);
  return achievementNotifier.checkForUnlockableAchievements(userStats);
});

/// Provider for achievement progress tracking
final achievementProgressProvider = FutureProvider.family<double, String>((
  ref,
  achievementId,
) async {
  final achievement = await ref.watch(
    achievementByIdProvider(achievementId).future,
  );
  return achievement?.progressPercentage ?? 0.0;
});

/// Provider for total rewards from achievements
final achievementRewardsProvider = FutureProvider<Map<String, int>>((
  ref,
) async {
  final repository = ref.watch(achievementRepositoryProvider);
  final totalCoins = await repository.getTotalCoinsFromAchievements();
  final totalXp = await repository.getTotalXpFromAchievements();

  return {'coins': totalCoins, 'xp': totalXp};
});

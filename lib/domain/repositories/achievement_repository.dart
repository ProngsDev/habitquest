import '../entities/achievement.dart';

/// Abstract repository interface for achievement operations
abstract class AchievementRepository {
  /// Get all achievements
  Future<List<Achievement>> getAllAchievements();

  /// Get unlocked achievements only
  Future<List<Achievement>> getUnlockedAchievements();

  /// Get locked achievements only
  Future<List<Achievement>> getLockedAchievements();

  /// Get achievements by type
  Future<List<Achievement>> getAchievementsByType(AchievementType type);

  /// Get achievement by ID
  Future<Achievement?> getAchievementById(String id);

  /// Create a new achievement
  Future<void> createAchievement(Achievement achievement);

  /// Update an existing achievement
  Future<void> updateAchievement(Achievement achievement);

  /// Delete an achievement
  Future<void> deleteAchievement(String id);

  /// Unlock an achievement
  Future<Achievement> unlockAchievement(String id);

  /// Update achievement progress
  Future<Achievement> updateProgress(String id, int newProgress);

  /// Check if achievement should be unlocked based on current progress
  Future<List<Achievement>> checkForUnlockableAchievements();

  /// Get achievements that are close to being unlocked (within 80% of target)
  Future<List<Achievement>> getNearCompletionAchievements();

  /// Get achievement statistics
  Future<Map<String, dynamic>> getAchievementStatistics();

  /// Initialize default achievements
  Future<void> initializeDefaultAchievements();

  /// Get achievements by rarity
  Future<List<Achievement>> getAchievementsByRarity(AchievementRarity rarity);

  /// Search achievements by name or description
  Future<List<Achievement>> searchAchievements(String query);

  /// Get total coins earned from achievements
  Future<int> getTotalCoinsFromAchievements();

  /// Get total XP earned from achievements
  Future<int> getTotalXpFromAchievements();

  /// Get achievement unlock history
  Future<List<Map<String, dynamic>>> getUnlockHistory();

  /// Check and update all achievement progress based on user stats
  Future<List<Achievement>> updateAllAchievementProgress(Map<String, dynamic> userStats);
}

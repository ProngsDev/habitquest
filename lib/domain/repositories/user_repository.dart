import '../entities/user.dart';

/// Abstract repository interface for user operations
abstract class UserRepository {
  /// Get the current user
  Future<User?> getCurrentUser();

  /// Create a new user
  Future<void> createUser(User user);

  /// Update user information
  Future<void> updateUser(User user);

  /// Delete user data
  Future<void> deleteUser(String id);

  /// Add XP to user
  Future<User> addXpToUser(String userId, int xp);

  /// Update user streak
  Future<User> updateUserStreak(String userId, int newStreak);

  /// Unlock achievement for user
  Future<User> unlockAchievement(String userId, String achievementId);

  /// Spend user coins
  Future<User> spendCoins(String userId, int amount);

  /// Update user preference
  Future<User> updatePreference(String userId, String key, dynamic value);

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStatistics(String userId);

  /// Check if user exists
  Future<bool> userExists(String id);

  /// Get user level history
  Future<List<Map<String, dynamic>>> getUserLevelHistory(String userId);

  /// Get user XP history
  Future<List<Map<String, dynamic>>> getUserXpHistory(String userId);
}

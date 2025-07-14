import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/achievement_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../presentation/providers/app_providers.dart';

/// Service for initializing app data on first launch
class AppInitializationService {
  final UserRepository _userRepository;
  final AchievementRepository _achievementRepository;

  const AppInitializationService(
    this._userRepository,
    this._achievementRepository,
  );

  /// Initialize app with default user and achievements if needed
  Future<void> initializeApp() async {
    await _initializeUser();
    await _initializeAchievements();
  }

  /// Create default user if none exists
  Future<void> _initializeUser() async {
    final existingUser = await _userRepository.getCurrentUser();
    if (existingUser == null) {
      final defaultUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'HabitQuest User',
        email: null,
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
        totalXp: 0,
        level: 1,
        coins: 0,
        currentStreak: 0,
        longestStreak: 0,
        totalHabitsCompleted: 0,
        unlockedAchievements: [],
        preferences: {},
      );

      await _userRepository.createUser(defaultUser);
    }
  }

  /// Initialize default achievements
  Future<void> _initializeAchievements() async {
    await _achievementRepository.initializeDefaultAchievements();
  }

  /// Check if app needs initialization
  Future<bool> needsInitialization() async {
    final user = await _userRepository.getCurrentUser();
    return user == null;
  }
}

/// Provider for app initialization service
final appInitializationServiceProvider = Provider<AppInitializationService>((
  ref,
) {
  final userRepository = ref.watch(userRepositoryProvider);
  final achievementRepository = ref.watch(achievementRepositoryProvider);
  return AppInitializationService(userRepository, achievementRepository);
});

/// Provider for app initialization state
final appInitializationProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(appInitializationServiceProvider);
  await service.initializeApp();
});

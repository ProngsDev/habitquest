import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'user_model.g.dart';

@HiveType(typeId: 2)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? email;

  @HiveField(3)
  final int totalXp;

  @HiveField(4)
  final int level;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime lastActiveAt;

  @HiveField(7)
  final String? avatarPath;

  @HiveField(8)
  final int coins;

  @HiveField(9)
  final Map<String, dynamic> preferences;

  @HiveField(10)
  final List<String> unlockedAchievements;

  @HiveField(11)
  final int longestStreak;

  @HiveField(12)
  final int currentStreak;

  @HiveField(13)
  final int totalHabitsCompleted;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.totalXp = 0,
    this.level = 1,
    required this.createdAt,
    required this.lastActiveAt,
    this.avatarPath,
    this.coins = 0,
    this.preferences = const {},
    this.unlockedAchievements = const [],
    this.longestStreak = 0,
    this.currentStreak = 0,
    this.totalHabitsCompleted = 0,
  });

  factory UserModel.create({
    required String name,
    String? email,
    String? avatarPath,
  }) {
    final now = DateTime.now();
    return UserModel(
      id: const Uuid().v4(),
      name: name,
      email: email,
      createdAt: now,
      lastActiveAt: now,
      avatarPath: avatarPath,
    );
  }

  UserModel copyWith({
    String? name,
    String? email,
    int? totalXp,
    int? level,
    DateTime? lastActiveAt,
    String? avatarPath,
    int? coins,
    Map<String, dynamic>? preferences,
    List<String>? unlockedAchievements,
    int? longestStreak,
    int? currentStreak,
    int? totalHabitsCompleted,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      createdAt: createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      avatarPath: avatarPath ?? this.avatarPath,
      coins: coins ?? this.coins,
      preferences: preferences ?? this.preferences,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      longestStreak: longestStreak ?? this.longestStreak,
      currentStreak: currentStreak ?? this.currentStreak,
      totalHabitsCompleted: totalHabitsCompleted ?? this.totalHabitsCompleted,
    );
  }

  /// Add XP and update level if necessary
  UserModel addXp(int xp) {
    final newTotalXp = totalXp + xp;
    final newLevel = _calculateLevel(newTotalXp);
    final coinsEarned = newLevel > level ? (newLevel - level) * 10 : 0;
    
    return copyWith(
      totalXp: newTotalXp,
      level: newLevel,
      coins: coins + coinsEarned,
      lastActiveAt: DateTime.now(),
    );
  }

  /// Update streak information
  UserModel updateStreak(int newStreak) {
    return copyWith(
      currentStreak: newStreak,
      longestStreak: newStreak > longestStreak ? newStreak : longestStreak,
      lastActiveAt: DateTime.now(),
    );
  }

  /// Add completed habit
  UserModel addCompletedHabit() {
    return copyWith(
      totalHabitsCompleted: totalHabitsCompleted + 1,
      lastActiveAt: DateTime.now(),
    );
  }

  /// Unlock achievement
  UserModel unlockAchievement(String achievementId) {
    if (unlockedAchievements.contains(achievementId)) {
      return this;
    }
    
    final newAchievements = List<String>.from(unlockedAchievements)
      ..add(achievementId);
    
    return copyWith(
      unlockedAchievements: newAchievements,
      coins: coins + 50, // Bonus coins for achievement
      lastActiveAt: DateTime.now(),
    );
  }

  /// Spend coins
  UserModel spendCoins(int amount) {
    if (coins < amount) {
      throw Exception('Insufficient coins');
    }
    
    return copyWith(
      coins: coins - amount,
      lastActiveAt: DateTime.now(),
    );
  }

  /// Update preference
  UserModel updatePreference(String key, dynamic value) {
    final newPreferences = Map<String, dynamic>.from(preferences);
    newPreferences[key] = value;
    
    return copyWith(
      preferences: newPreferences,
      lastActiveAt: DateTime.now(),
    );
  }

  /// Calculate level from total XP
  int _calculateLevel(int xp) {
    if (xp <= 0) return 1;
    return (xp / 100).floor() + 1;
  }

  /// Get XP progress in current level
  int get xpProgressInLevel => totalXp % 100;

  /// Get XP required for next level
  int get xpRequiredForNextLevel => 100 - xpProgressInLevel;

  /// Get level progress percentage
  double get levelProgressPercentage => xpProgressInLevel / 100.0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, level: $level, totalXp: $totalXp)';
  }
}

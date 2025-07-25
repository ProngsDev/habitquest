import 'package:flutter/foundation.dart';

/// Domain entity representing a user
@immutable
class User {

  const User({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.lastActiveAt,
    this.email,
    this.totalXp = 0,
    this.level = 1,
    this.avatarPath,
    this.coins = 0,
    this.preferences = const {},
    this.unlockedAchievements = const [],
    this.longestStreak = 0,
    this.currentStreak = 0,
    this.totalHabitsCompleted = 0,
  });
  final String id;
  final String name;
  final String? email;
  final int totalXp;
  final int level;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final String? avatarPath;
  final int coins;
  final Map<String, dynamic> preferences;
  final List<String> unlockedAchievements;
  final int longestStreak;
  final int currentStreak;
  final int totalHabitsCompleted;

  User copyWith({
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
  }) => User(
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

  /// Get XP progress in current level
  int get xpProgressInLevel => totalXp % 100;

  /// Get XP required for next level
  int get xpRequiredForNextLevel => 100 - xpProgressInLevel;

  /// Get level progress percentage
  double get levelProgressPercentage => xpProgressInLevel / 100.0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'User(id: $id, name: $name, level: $level, totalXp: $totalXp)';
}

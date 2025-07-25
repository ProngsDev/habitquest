import 'package:flutter/foundation.dart';


/// Achievement types
enum AchievementType {
  streak,
  totalHabits,
  totalXp,
  level,
  consistency,
  category,
  special;

  String get displayName {
    switch (this) {
      case AchievementType.streak:
        return 'Streak';
      case AchievementType.totalHabits:
        return 'Total Habits';
      case AchievementType.totalXp:
        return 'Total XP';
      case AchievementType.level:
        return 'Level';
      case AchievementType.consistency:
        return 'Consistency';
      case AchievementType.category:
        return 'Category';
      case AchievementType.special:
        return 'Special';
    }
  }
}

/// Domain entity representing an achievement
@immutable
class Achievement {

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.type, required this.targetValue, this.coinsReward = 0,
    this.xpReward = 0,
    this.isUnlocked = false,
    this.unlockedAt,
    this.currentProgress = 0,
  });
  final String id;
  final String name;
  final String description;
  final String iconName;
  final int coinsReward;
  final int xpReward;
  final AchievementType type;
  final int targetValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int currentProgress;

  /// Create a copy with updated values
  Achievement copyWith({
    String? name,
    String? description,
    String? iconName,
    int? coinsReward,
    int? xpReward,
    AchievementType? type,
    int? targetValue,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? currentProgress,
  }) => Achievement(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      coinsReward: coinsReward ?? this.coinsReward,
      xpReward: xpReward ?? this.xpReward,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      currentProgress: currentProgress ?? this.currentProgress,
    );

  /// Get progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (targetValue <= 0) return 0;
    return (currentProgress / targetValue).clamp(0.0, 1.0);
  }

  /// Check if achievement is completed but not yet unlocked
  bool get isCompleted => currentProgress >= targetValue;

  /// Get display text for progress
  String get progressText => '$currentProgress / $targetValue';

  /// Get rarity based on target value and type
  AchievementRarity get rarity {
    switch (type) {
      case AchievementType.streak:
        if (targetValue >= 100) return AchievementRarity.legendary;
        if (targetValue >= 50) return AchievementRarity.epic;
        if (targetValue >= 20) return AchievementRarity.rare;
        if (targetValue >= 7) return AchievementRarity.uncommon;
        return AchievementRarity.common;
      
      case AchievementType.totalHabits:
        if (targetValue >= 100) return AchievementRarity.legendary;
        if (targetValue >= 50) return AchievementRarity.epic;
        if (targetValue >= 20) return AchievementRarity.rare;
        if (targetValue >= 10) return AchievementRarity.uncommon;
        return AchievementRarity.common;
      
      case AchievementType.totalXp:
        if (targetValue >= 10000) return AchievementRarity.legendary;
        if (targetValue >= 5000) return AchievementRarity.epic;
        if (targetValue >= 2000) return AchievementRarity.rare;
        if (targetValue >= 500) return AchievementRarity.uncommon;
        return AchievementRarity.common;
      
      case AchievementType.level:
        if (targetValue >= 50) return AchievementRarity.legendary;
        if (targetValue >= 30) return AchievementRarity.epic;
        if (targetValue >= 20) return AchievementRarity.rare;
        if (targetValue >= 10) return AchievementRarity.uncommon;
        return AchievementRarity.common;
      
      case AchievementType.consistency:
      case AchievementType.category:
      case AchievementType.special:
        return AchievementRarity.rare; // Default for special achievements
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Achievement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Achievement(id: $id, name: $name, type: $type, progress: $currentProgress/$targetValue)';
}

/// Achievement rarity levels
enum AchievementRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary;

  String get displayName {
    switch (this) {
      case AchievementRarity.common:
        return 'Common';
      case AchievementRarity.uncommon:
        return 'Uncommon';
      case AchievementRarity.rare:
        return 'Rare';
      case AchievementRarity.epic:
        return 'Epic';
      case AchievementRarity.legendary:
        return 'Legendary';
    }
  }

  /// Get color associated with rarity
  int get colorValue {
    switch (this) {
      case AchievementRarity.common:
        return 0xFF8E8E93; // System gray
      case AchievementRarity.uncommon:
        return 0xFF34C759; // System green
      case AchievementRarity.rare:
        return 0xFF007AFF; // System blue
      case AchievementRarity.epic:
        return 0xFFAF52DE; // System purple
      case AchievementRarity.legendary:
        return 0xFFFF9500; // System orange
    }
  }
}

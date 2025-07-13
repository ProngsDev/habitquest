import 'package:hive/hive.dart';

part 'achievement_model.g.dart';

@HiveType(typeId: 3)
class AchievementModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String iconName;

  @HiveField(4)
  final int coinsReward;

  @HiveField(5)
  final int xpReward;

  @HiveField(6)
  final AchievementType type;

  @HiveField(7)
  final int targetValue;

  @HiveField(8)
  final bool isUnlocked;

  @HiveField(9)
  final DateTime? unlockedAt;

  @HiveField(10)
  final int currentProgress;

  AchievementModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    this.coinsReward = 0,
    this.xpReward = 0,
    required this.type,
    required this.targetValue,
    this.isUnlocked = false,
    this.unlockedAt,
    this.currentProgress = 0,
  });

  AchievementModel copyWith({
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
  }) {
    return AchievementModel(
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
  }

  /// Update progress towards achievement
  AchievementModel updateProgress(int newProgress) {
    final shouldUnlock = !isUnlocked && newProgress >= targetValue;
    
    return copyWith(
      currentProgress: newProgress,
      isUnlocked: shouldUnlock ? true : isUnlocked,
      unlockedAt: shouldUnlock ? DateTime.now() : unlockedAt,
    );
  }

  /// Get progress percentage
  double get progressPercentage {
    if (targetValue <= 0) return 0.0;
    return (currentProgress / targetValue).clamp(0.0, 1.0);
  }

  /// Check if achievement is completed
  bool get isCompleted => currentProgress >= targetValue;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AchievementModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AchievementModel(id: $id, name: $name, isUnlocked: $isUnlocked, progress: $currentProgress/$targetValue)';
  }
}

@HiveType(typeId: 4)
enum AchievementType {
  @HiveField(0)
  streak,
  
  @HiveField(1)
  totalHabits,
  
  @HiveField(2)
  totalXp,
  
  @HiveField(3)
  level,
  
  @HiveField(4)
  consistency,
  
  @HiveField(5)
  category,
  
  @HiveField(6)
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

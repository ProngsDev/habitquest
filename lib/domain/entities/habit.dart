import 'package:flutter/foundation.dart';

import '../../core/enums/habit_enums.dart';

/// Domain entity representing a habit
@immutable
class Habit {
  final String id;
  final String name;
  final String description;
  final HabitCategory category;
  final HabitDifficulty difficulty;
  final HabitFrequency frequency;
  final DateTime createdAt;
  final DateTime? reminderTime;
  final bool isActive;
  final String? iconName;
  final int colorValue;
  final int targetCount;
  final String? unit;

  const Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.frequency,
    required this.createdAt,
    required this.colorValue,
    this.reminderTime,
    this.isActive = true,
    this.iconName,
    this.targetCount = 1,
    this.unit,
  });

  Habit copyWith({
    String? name,
    String? description,
    HabitCategory? category,
    HabitDifficulty? difficulty,
    HabitFrequency? frequency,
    DateTime? reminderTime,
    bool? isActive,
    String? iconName,
    int? colorValue,
    int? targetCount,
    String? unit,
  }) => Habit(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    category: category ?? this.category,
    difficulty: difficulty ?? this.difficulty,
    frequency: frequency ?? this.frequency,
    createdAt: createdAt,
    reminderTime: reminderTime ?? this.reminderTime,
    isActive: isActive ?? this.isActive,
    iconName: iconName ?? this.iconName,
    colorValue: colorValue ?? this.colorValue,
    targetCount: targetCount ?? this.targetCount,
    unit: unit ?? this.unit,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Habit && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Habit(id: $id, name: $name, category: $category, difficulty: $difficulty)';
}

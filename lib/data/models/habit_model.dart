import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../core/enums/habit_enums.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 0)
class HabitModel extends HiveObject {
  HabitModel({
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

  factory HabitModel.create({
    required String name,
    required String description,
    required HabitCategory category,
    required HabitDifficulty difficulty,
    required HabitFrequency frequency,
    required int colorValue,
    DateTime? reminderTime,
    String? iconName,
    int targetCount = 1,
    String? unit,
  }) => HabitModel(
    id: const Uuid().v4(),
    name: name,
    description: description,
    category: category,
    difficulty: difficulty,
    frequency: frequency,
    createdAt: DateTime.now(),
    reminderTime: reminderTime,
    iconName: iconName,
    colorValue: colorValue,
    targetCount: targetCount,
    unit: unit,
  );
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final HabitCategory category;

  @HiveField(4)
  final HabitDifficulty difficulty;

  @HiveField(5)
  final HabitFrequency frequency;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime? reminderTime;

  @HiveField(8)
  final bool isActive;

  @HiveField(9)
  final String? iconName;

  @HiveField(10)
  final int colorValue;

  @HiveField(11)
  final int targetCount;

  @HiveField(12)
  final String? unit;

  HabitModel copyWith({
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
  }) => HabitModel(
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
  String toString() =>
      'HabitModel(id: $id, name: $name, category: $category, difficulty: $difficulty)';
}

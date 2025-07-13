import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../core/enums/habit_enums.dart';

part 'habit_completion_model.g.dart';

@HiveType(typeId: 1)
class HabitCompletionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String habitId;

  @HiveField(2)
  final DateTime completedAt;

  @HiveField(3)
  final CompletionStatus status;

  @HiveField(4)
  final int xpEarned;

  @HiveField(5)
  final int streakCount;

  @HiveField(6)
  final String? notes;

  @HiveField(7)
  final int completedCount;

  @HiveField(8)
  final int targetCount;

  HabitCompletionModel({
    required this.id,
    required this.habitId,
    required this.completedAt,
    required this.status,
    required this.xpEarned,
    required this.streakCount,
    this.notes,
    this.completedCount = 1,
    this.targetCount = 1,
  });

  factory HabitCompletionModel.create({
    required String habitId,
    required CompletionStatus status,
    required int xpEarned,
    required int streakCount,
    String? notes,
    int completedCount = 1,
    int targetCount = 1,
  }) {
    return HabitCompletionModel(
      id: const Uuid().v4(),
      habitId: habitId,
      completedAt: DateTime.now(),
      status: status,
      xpEarned: xpEarned,
      streakCount: streakCount,
      notes: notes,
      completedCount: completedCount,
      targetCount: targetCount,
    );
  }

  HabitCompletionModel copyWith({
    String? habitId,
    DateTime? completedAt,
    CompletionStatus? status,
    int? xpEarned,
    int? streakCount,
    String? notes,
    int? completedCount,
    int? targetCount,
  }) {
    return HabitCompletionModel(
      id: id,
      habitId: habitId ?? this.habitId,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      xpEarned: xpEarned ?? this.xpEarned,
      streakCount: streakCount ?? this.streakCount,
      notes: notes ?? this.notes,
      completedCount: completedCount ?? this.completedCount,
      targetCount: targetCount ?? this.targetCount,
    );
  }

  /// Check if the completion is fully completed (completed count meets target)
  bool get isFullyCompleted => 
      status == CompletionStatus.completed && completedCount >= targetCount;

  /// Get completion percentage
  double get completionPercentage => 
      targetCount > 0 ? (completedCount / targetCount).clamp(0.0, 1.0) : 0.0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitCompletionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'HabitCompletionModel(id: $id, habitId: $habitId, status: $status, xpEarned: $xpEarned)';
  }
}

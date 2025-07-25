import 'package:flutter/foundation.dart';

import '../../core/enums/habit_enums.dart';

/// Domain entity representing a habit completion record
@immutable
class HabitCompletion { // For time-based habits

  const HabitCompletion({
    required this.id,
    required this.habitId,
    required this.completedAt,
    required this.status,
    this.xpEarned = 0,
    this.notes,
    this.actualCount,
    this.duration,
  });
  final String id;
  final String habitId;
  final DateTime completedAt;
  final CompletionStatus status;
  final int xpEarned;
  final String? notes;
  final int? actualCount; // For habits with target counts
  final Duration? duration;

  HabitCompletion copyWith({
    String? id,
    String? habitId,
    DateTime? completedAt,
    CompletionStatus? status,
    int? xpEarned,
    String? notes,
    int? actualCount,
    Duration? duration,
  }) => HabitCompletion(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    completedAt: completedAt ?? this.completedAt,
    status: status ?? this.status,
    xpEarned: xpEarned ?? this.xpEarned,
    notes: notes ?? this.notes,
    actualCount: actualCount ?? this.actualCount,
    duration: duration ?? this.duration,
  );

  /// Check if this completion was made today
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final completionDate = DateTime(
      completedAt.year,
      completedAt.month,
      completedAt.day,
    );
    return completionDate == today;
  }

  /// Check if this completion was made on a specific date
  bool isOnDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    final completionDate = DateTime(
      completedAt.year,
      completedAt.month,
      completedAt.day,
    );
    return completionDate == targetDate;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitCompletion && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'HabitCompletion(id: $id, habitId: $habitId, status: $status)';
}

/// Statistics for a habit's completion history
@immutable
class HabitStats {

  const HabitStats({
    required this.habitId,
    this.totalCompletions = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.completionRate = 0.0,
    this.totalXpEarned = 0,
    this.lastCompletedAt,
    this.recentCompletions = const [],
  });
  final String habitId;
  final int totalCompletions;
  final int currentStreak;
  final int longestStreak;
  final double completionRate;
  final int totalXpEarned;
  final DateTime? lastCompletedAt;
  final List<HabitCompletion> recentCompletions;

  HabitStats copyWith({
    String? habitId,
    int? totalCompletions,
    int? currentStreak,
    int? longestStreak,
    double? completionRate,
    int? totalXpEarned,
    DateTime? lastCompletedAt,
    List<HabitCompletion>? recentCompletions,
  }) => HabitStats(
    habitId: habitId ?? this.habitId,
    totalCompletions: totalCompletions ?? this.totalCompletions,
    currentStreak: currentStreak ?? this.currentStreak,
    longestStreak: longestStreak ?? this.longestStreak,
    completionRate: completionRate ?? this.completionRate,
    totalXpEarned: totalXpEarned ?? this.totalXpEarned,
    lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
    recentCompletions: recentCompletions ?? this.recentCompletions,
  );

  /// Check if the habit was completed today
  bool get isCompletedToday {
    if (lastCompletedAt == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCompleted = DateTime(
      lastCompletedAt!.year,
      lastCompletedAt!.month,
      lastCompletedAt!.day,
    );
    return lastCompleted == today;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitStats && other.habitId == habitId;
  }

  @override
  int get hashCode => habitId.hashCode;

  @override
  String toString() => 'HabitStats(habitId: $habitId, completions: $totalCompletions, streak: $currentStreak)';
}

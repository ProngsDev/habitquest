// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitDifficultyAdapter extends TypeAdapter<HabitDifficulty> {
  @override
  final int typeId = 10;

  @override
  HabitDifficulty read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitDifficulty.easy;
      case 1:
        return HabitDifficulty.medium;
      case 2:
        return HabitDifficulty.hard;
      default:
        return HabitDifficulty.easy;
    }
  }

  @override
  void write(BinaryWriter writer, HabitDifficulty obj) {
    switch (obj) {
      case HabitDifficulty.easy:
        writer.writeByte(0);
        break;
      case HabitDifficulty.medium:
        writer.writeByte(1);
        break;
      case HabitDifficulty.hard:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitDifficultyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HabitCategoryAdapter extends TypeAdapter<HabitCategory> {
  @override
  final int typeId = 11;

  @override
  HabitCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitCategory.health;
      case 1:
        return HabitCategory.fitness;
      case 2:
        return HabitCategory.learning;
      case 3:
        return HabitCategory.productivity;
      case 4:
        return HabitCategory.social;
      case 5:
        return HabitCategory.creativity;
      case 6:
        return HabitCategory.mindfulness;
      case 7:
        return HabitCategory.other;
      default:
        return HabitCategory.health;
    }
  }

  @override
  void write(BinaryWriter writer, HabitCategory obj) {
    switch (obj) {
      case HabitCategory.health:
        writer.writeByte(0);
        break;
      case HabitCategory.fitness:
        writer.writeByte(1);
        break;
      case HabitCategory.learning:
        writer.writeByte(2);
        break;
      case HabitCategory.productivity:
        writer.writeByte(3);
        break;
      case HabitCategory.social:
        writer.writeByte(4);
        break;
      case HabitCategory.creativity:
        writer.writeByte(5);
        break;
      case HabitCategory.mindfulness:
        writer.writeByte(6);
        break;
      case HabitCategory.other:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HabitFrequencyAdapter extends TypeAdapter<HabitFrequency> {
  @override
  final int typeId = 12;

  @override
  HabitFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitFrequency.daily;
      case 1:
        return HabitFrequency.weekly;
      case 2:
        return HabitFrequency.monthly;
      default:
        return HabitFrequency.daily;
    }
  }

  @override
  void write(BinaryWriter writer, HabitFrequency obj) {
    switch (obj) {
      case HabitFrequency.daily:
        writer.writeByte(0);
        break;
      case HabitFrequency.weekly:
        writer.writeByte(1);
        break;
      case HabitFrequency.monthly:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CompletionStatusAdapter extends TypeAdapter<CompletionStatus> {
  @override
  final int typeId = 13;

  @override
  CompletionStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CompletionStatus.pending;
      case 1:
        return CompletionStatus.completed;
      case 2:
        return CompletionStatus.skipped;
      case 3:
        return CompletionStatus.failed;
      default:
        return CompletionStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, CompletionStatus obj) {
    switch (obj) {
      case CompletionStatus.pending:
        writer.writeByte(0);
        break;
      case CompletionStatus.completed:
        writer.writeByte(1);
        break;
      case CompletionStatus.skipped:
        writer.writeByte(2);
        break;
      case CompletionStatus.failed:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletionStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

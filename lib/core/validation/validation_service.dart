import '../../domain/entities/habit.dart';
import '../../domain/entities/user.dart';
import '../enums/habit_enums.dart';
import '../services/logging_service.dart';
import 'validators.dart';

/// Service for validating domain entities at trust boundaries
class ValidationService {
  ValidationService._internal();
  static final ValidationService _instance = ValidationService._internal();

  /// Singleton instance
  static ValidationService get instance => _instance;

  /// Validate a habit entity
  ValidationResult validateHabit(Habit habit) {
    final results = <ValidationResult>[];

    // Validate habit name
    results
      ..add(ValidationHelper.habitNameValidator().validate(habit.name))
      // Validate habit description
      ..add(
        ValidationHelper.habitDescriptionValidator().validate(
          habit.description,
        ),
      )
      // Validate target count
      ..add(
        const NumericValidator(
          fieldName: 'Target count',
          min: 1,
          allowNegative: false,
          allowZero: false,
        ).validate(habit.targetCount),
      )
      // Validate created date is not in the future
      ..add(
        DateValidator(
          fieldName: 'Created date',
          maxDate: DateTime.now(),
        ).validate(habit.createdAt),
      );

    // Validate reminder time if set
    if (habit.reminderTime != null) {
      results.add(
        const DateValidator(
          fieldName: 'Reminder time',
          required: false,
        ).validate(habit.reminderTime),
      );
    }

    final combinedResult = ValidationResult.combine(results);

    if (!combinedResult.isValid) {
      LoggingService.instance.warning(
        'Habit validation failed',
        context: {
          'habitId': habit.id,
          'habitName': habit.name,
          'errors': combinedResult.errors,
        },
      );
    }

    return combinedResult;
  }

  /// Validate a user entity
  ValidationResult validateUser(User user) {
    final results = <ValidationResult>[];

    // Validate user name
    results
      ..add(ValidationHelper.userNameValidator().validate(user.name))
      // Validate XP
      ..add(ValidationHelper.xpValidator().validate(user.totalXp))
      // Validate level
      ..add(ValidationHelper.levelValidator().validate(user.level));

    // Validate email if provided
    if (user.email != null && user.email!.isNotEmpty) {
      results.add(EmailValidator(required: false).validate(user.email));
    }

    // Validate streaks
    results
      ..add(ValidationHelper.streakValidator().validate(user.currentStreak))
      ..add(ValidationHelper.streakValidator().validate(user.longestStreak))
      // Validate coins
      ..add(
        const NumericValidator(
          fieldName: 'Coins',
          min: 0,
          allowNegative: false,
        ).validate(user.coins),
      );

    // Validate total habits completed and dates
    results
      ..add(
        const NumericValidator(
          fieldName: 'Total habits completed',
          min: 0,
          allowNegative: false,
        ).validate(user.totalHabitsCompleted),
      )
      ..add(
        DateValidator(
          fieldName: 'Created date',
          maxDate: DateTime.now(),
        ).validate(user.createdAt),
      )
      ..add(
        DateValidator(
          fieldName: 'Last active date',
          maxDate: DateTime.now(),
        ).validate(user.lastActiveAt),
      );

    // Validate that last active is not before created
    if (user.lastActiveAt.isBefore(user.createdAt)) {
      results.add(
        const ValidationResult.failure([
          'Last active date cannot be before created date',
        ]),
      );
    }

    // Validate that current streak is not greater than longest streak
    if (user.currentStreak > user.longestStreak) {
      results.add(
        const ValidationResult.failure([
          'Current streak cannot be greater than longest streak',
        ]),
      );
    }

    final combinedResult = ValidationResult.combine(results);

    if (!combinedResult.isValid) {
      LoggingService.instance.warning(
        'User validation failed',
        context: {
          'userId': user.id,
          'userName': user.name,
          'errors': combinedResult.errors,
        },
      );
    }

    return combinedResult;
  }

  /// Validate habit creation parameters
  ValidationResult validateHabitCreation({
    required String name,
    required String description,
    required HabitCategory category,
    required HabitDifficulty difficulty,
    required HabitFrequency frequency,
    DateTime? reminderTime,
    int targetCount = 1,
    String? unit,
  }) {
    final results = <ValidationResult>[];

    // Validate name, description, and target count
    results
      ..add(ValidationHelper.habitNameValidator().validate(name))
      ..add(ValidationHelper.habitDescriptionValidator().validate(description))
      ..add(
        const NumericValidator(
          fieldName: 'Target count',
          min: 1,
          max: 1000,
          allowNegative: false,
          allowZero: false,
        ).validate(targetCount),
      );

    // Validate unit if provided
    if (unit != null && unit.isNotEmpty) {
      results.add(
        const StringValidator(
          fieldName: 'Unit',
          maxLength: 20,
          required: false,
        ).validate(unit),
      );
    }

    // Validate reminder time if provided
    if (reminderTime != null) {
      results.add(
        DateValidator(
          fieldName: 'Reminder time',
          minDate: DateTime.now(),
          required: false,
        ).validate(reminderTime),
      );
    }

    return ValidationResult.combine(results);
  }

  /// Validate user creation parameters
  ValidationResult validateUserCreation({
    required String name,
    String? email,
    String? avatarPath,
  }) {
    final results = <ValidationResult>[];

    // Validate name
    results.add(ValidationHelper.userNameValidator().validate(name));

    // Validate email if provided
    if (email != null && email.isNotEmpty) {
      results.add(EmailValidator(required: false).validate(email));
    }

    // Validate avatar path if provided
    if (avatarPath != null && avatarPath.isNotEmpty) {
      results.add(
        const StringValidator(
          fieldName: 'Avatar path',
          maxLength: 500,
          required: false,
        ).validate(avatarPath),
      );
    }

    return ValidationResult.combine(results);
  }

  /// Validate XP addition
  ValidationResult validateXpAddition(int currentXp, int xpToAdd) {
    final results = <ValidationResult>[];

    // Validate current XP and XP to add
    results
      ..add(ValidationHelper.xpValidator().validate(currentXp))
      ..add(
        const NumericValidator(
          fieldName: 'XP to add',
          min: 1,
          max: 10000,
          allowNegative: false,
          allowZero: false,
        ).validate(xpToAdd),
      );

    // Validate total doesn't exceed reasonable limits
    final totalXp = currentXp + xpToAdd;
    if (totalXp > 1000000) {
      results.add(
        const ValidationResult.failure([
          'Total XP would exceed maximum allowed (1,000,000)',
        ]),
      );
    }

    return ValidationResult.combine(results);
  }

  /// Validate ID string
  ValidationResult validateId(String? id) {
    const validator = StringValidator(
      fieldName: 'ID',
      minLength: 1,
      maxLength: 100,
    );
    return validator.validate(id);
  }

  /// Validate and throw if validation fails
  void validateAndThrow(ValidationResult result, String operation) {
    if (!result.isValid) {
      LoggingService.instance.error(
        'Validation failed for operation: $operation',
        context: {'errors': result.errors},
      );
      ValidationHelper.validateAndThrow(result);
    }
  }
}

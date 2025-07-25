import '../../core/enums/habit_enums.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/resilience/resilience_service.dart';
import '../../core/resilience/retry_policy.dart';
import '../../core/result/result.dart';
import '../../core/services/logging_service.dart';
import '../../core/services/performance_wrapper.dart';
import '../../core/validation/validation_service.dart';
import '../../core/validation/validators.dart';
import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/local/hive_datasource.dart';
import '../models/habit_model.dart';

/// Implementation of HabitRepository using Hive local storage
class HabitRepositoryImpl
    with PerformanceMonitoringMixin
    implements HabitRepository {
  HabitRepositoryImpl(this._dataSource);

  final HiveDataSource _dataSource;
  final ResilienceService _resilience = ResilienceService.instance;
  final ValidationService _validation = ValidationService.instance;
  final LoggingService _logger = LoggingService.instance;
  final HabitPerformanceWrapper _performanceWrapper = HabitPerformanceWrapper();

  @override
  Future<Result<List<Habit>>> getAllHabits() async => _performanceWrapper.trackHabitListLoad(
      () async {
        final result = await _resilience.executeWithRetry(
          () async {
            final habitModels = await _dataSource.getAllHabits();
            return habitModels.map(_mapToEntity).toList();
          },
          operationName: 'getAllHabits',
          retryPolicy: RetryPolicy.database,
        );
        return result;
      },
    );

  @override
  Future<Result<List<Habit>>> getActiveHabits() async => _resilience.executeWithRetry(
      () async {
        final habitModels = await _dataSource.getActiveHabits();
        return habitModels.map(_mapToEntity).toList();
      },
      operationName: 'getActiveHabits',
      retryPolicy: RetryPolicy.database,
    );

  @override
  Future<Result<List<Habit>>> getHabitsByCategory(
    HabitCategory category,
  ) async => _resilience.executeWithRetry(
      () async {
        final allHabitsResult = await getAllHabits();
        final allHabits = allHabitsResult.getOrThrow();
        return allHabits.where((habit) => habit.category == category).toList();
      },
      operationName: 'getHabitsByCategory',
      retryPolicy: RetryPolicy.database,
    );

  @override
  Future<Result<Habit?>> getHabitById(String id) async {
    // Validate input
    final validation = _validation.validateId(id);
    if (!validation.isValid) {
      return Result.failure(
        DataValidationException(
          validationErrors: validation.errors,
          context: {'habitId': id},
        ),
      );
    }

    return _resilience.executeWithRetry(
      () async {
        final habitModel = await _dataSource.getHabitById(id);
        return habitModel != null ? _mapToEntity(habitModel) : null;
      },
      operationName: 'getHabitById',
      retryPolicy: RetryPolicy.database,
    );
  }

  @override
  Future<Result<void>> createHabit(Habit habit) async => _performanceWrapper.trackHabitCreation(
      () async {
        // Validate input
        final validation = _validation.validateHabit(habit);
        if (!validation.isValid) {
          return Result.failure(
            DataValidationException(
              validationErrors: validation.errors,
              context: {'habitName': habit.name},
            ),
          );
        }

        _logger.info(
          'Creating new habit',
          context: {
            'habitId': habit.id,
            'habitName': habit.name,
            'category': habit.category.name,
          },
        );

        return _resilience.executeWithRetry(
          () async {
            final habitModel = _mapToModel(habit);
            await _dataSource.saveHabit(habitModel);
          },
          operationName: 'createHabit',
          retryPolicy: RetryPolicy.database,
        );
      },
      habitCategory: habit.category.name,
      habitDifficulty: habit.difficulty.name,
    );

  @override
  Future<Result<void>> updateHabit(Habit habit) async {
    // Validate input
    final validation = _validation.validateHabit(habit);
    if (!validation.isValid) {
      return Result.failure(
        DataValidationException(
          validationErrors: validation.errors,
          context: {'habitId': habit.id, 'habitName': habit.name},
        ),
      );
    }

    _logger.info(
      'Updating habit',
      context: {'habitId': habit.id, 'habitName': habit.name},
    );

    return _resilience.executeWithRetry(
      () async {
        final habitModel = _mapToModel(habit);
        await _dataSource.updateHabit(habitModel);
      },
      operationName: 'updateHabit',
      retryPolicy: RetryPolicy.database,
    );
  }

  @override
  Future<Result<void>> deleteHabit(String id) async {
    // Validate input
    final validation = _validation.validateId(id);
    if (!validation.isValid) {
      return Result.failure(
        DataValidationException(
          validationErrors: validation.errors,
          context: {'habitId': id},
        ),
      );
    }

    _logger.info('Deleting habit', context: {'habitId': id});

    return _resilience.executeWithRetry(
      () async {
        await _dataSource.deleteHabit(id);
      },
      operationName: 'deleteHabit',
      retryPolicy: RetryPolicy.database,
    );
  }

  @override
  Future<Result<void>> archiveHabit(String id) async {
    // Validate input
    final validation = _validation.validateId(id);
    if (!validation.isValid) {
      return Result.failure(
        DataValidationException(
          validationErrors: validation.errors,
          context: {'habitId': id},
        ),
      );
    }

    _logger.info('Archiving habit', context: {'habitId': id});

    return _resilience.executeWithRetry(
      () async {
        final habitResult = await getHabitById(id);
        final habit = habitResult.getOrThrow();
        if (habit != null) {
          final archivedHabit = habit.copyWith(isActive: false);
          final updateResult = await updateHabit(archivedHabit);
          updateResult.getOrThrow(); // Propagate any errors
        }
      },
      operationName: 'archiveHabit',
      retryPolicy: RetryPolicy.database,
    );
  }

  @override
  Future<Result<void>> restoreHabit(String id) async {
    // Validate input
    final validation = _validation.validateId(id);
    if (!validation.isValid) {
      return Result.failure(
        DataValidationException(
          validationErrors: validation.errors,
          context: {'habitId': id},
        ),
      );
    }

    _logger.info('Restoring habit', context: {'habitId': id});

    return _resilience.executeWithRetry(
      () async {
        final habitResult = await getHabitById(id);
        final habit = habitResult.getOrThrow();
        if (habit != null) {
          final restoredHabit = habit.copyWith(isActive: true);
          final updateResult = await updateHabit(restoredHabit);
          updateResult.getOrThrow(); // Propagate any errors
        }
      },
      operationName: 'restoreHabit',
      retryPolicy: RetryPolicy.database,
    );
  }

  @override
  Future<Result<List<Habit>>> searchHabits(String query) async {
    // Validate input
    final validation = ValidationHelper.habitSearchQueryValidator().validate(
      query,
    );
    if (!validation.isValid) {
      return Result.failure(
        DataValidationException(
          validationErrors: validation.errors,
          context: {'query': query},
        ),
      );
    }

    return _resilience.executeWithRetry(
      () async {
        final allHabitsResult = await getAllHabits();
        final allHabits = allHabitsResult.getOrThrow();
        final lowercaseQuery = query.toLowerCase();

        return allHabits
            .where(
              (habit) =>
                  habit.name.toLowerCase().contains(lowercaseQuery) ||
                  habit.description.toLowerCase().contains(lowercaseQuery),
            )
            .toList();
      },
      operationName: 'searchHabits',
      retryPolicy: RetryPolicy.database,
    );
  }

  @override
  Future<Result<List<Habit>>> getHabitsWithReminders() async => _resilience.executeWithRetry(
      () async {
        final allHabitsResult = await getAllHabits();
        final allHabits = allHabitsResult.getOrThrow();
        return allHabits.where((habit) => habit.reminderTime != null).toList();
      },
      operationName: 'getHabitsWithReminders',
      retryPolicy: RetryPolicy.database,
    );

  @override
  Future<Result<Map<HabitCategory, int>>> getHabitsCountByCategory() async => _resilience.executeWithRetry(
      () async {
        final allHabitsResult = await getAllHabits();
        final allHabits = allHabitsResult.getOrThrow();
        final countMap = <HabitCategory, int>{};

        for (final category in HabitCategory.values) {
          countMap[category] = allHabits
              .where((habit) => habit.category == category)
              .length;
        }

        return countMap;
      },
      operationName: 'getHabitsCountByCategory',
      retryPolicy: RetryPolicy.database,
    );

  @override
  Future<Result<List<Habit>>> getHabitsCreatedInRange(
    DateTime start,
    DateTime end,
  ) async {
    // Validate input
    final startValidation = const DateValidator(
      fieldName: 'Start date',
    ).validate(start);
    final endValidation = const DateValidator(fieldName: 'End date').validate(end);
    final rangeValidation = start.isBefore(end)
        ? const ValidationResult.success()
        : const ValidationResult.failure([
            'Start date must be before end date',
          ]);

    final validation = ValidationResult.combine([
      startValidation,
      endValidation,
      rangeValidation,
    ]);
    if (!validation.isValid) {
      return Result.failure(
        DataValidationException(
          validationErrors: validation.errors,
          context: {
            'startDate': start.toIso8601String(),
            'endDate': end.toIso8601String(),
          },
        ),
      );
    }

    return _resilience.executeWithRetry(
      () async {
        final allHabitsResult = await getAllHabits();
        final allHabits = allHabitsResult.getOrThrow();
        return allHabits
            .where(
              (habit) =>
                  habit.createdAt.isAfter(start) &&
                  habit.createdAt.isBefore(end),
            )
            .toList();
      },
      operationName: 'getHabitsCreatedInRange',
      retryPolicy: RetryPolicy.database,
    );
  }

  // Helper methods for mapping between domain entities and data models
  Habit _mapToEntity(HabitModel model) => Habit(
    id: model.id,
    name: model.name,
    description: model.description,
    category: model.category,
    difficulty: model.difficulty,
    frequency: model.frequency,
    createdAt: model.createdAt,
    reminderTime: model.reminderTime,
    isActive: model.isActive,
    iconName: model.iconName,
    colorValue: model.colorValue,
    targetCount: model.targetCount,
    unit: model.unit,
  );

  HabitModel _mapToModel(Habit entity) => HabitModel(
    id: entity.id,
    name: entity.name,
    description: entity.description,
    category: entity.category,
    difficulty: entity.difficulty,
    frequency: entity.frequency,
    createdAt: entity.createdAt,
    reminderTime: entity.reminderTime,
    isActive: entity.isActive,
    iconName: entity.iconName,
    colorValue: entity.colorValue,
    targetCount: entity.targetCount,
    unit: entity.unit,
  );
}

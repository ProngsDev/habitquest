import 'package:flutter_test/flutter_test.dart';
import 'package:habitquest/core/enums/habit_enums.dart';
import 'package:habitquest/core/errors/app_exceptions.dart';
import 'package:habitquest/data/datasources/local/hive_datasource.dart';
import 'package:habitquest/data/models/habit_model.dart';
import 'package:habitquest/data/repositories/habit_repository_impl.dart';
import 'package:habitquest/domain/entities/habit.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'habit_repository_impl_test.mocks.dart';

@GenerateMocks([HiveDataSource])
void main() {
  late HabitRepositoryImpl repository;
  late MockHiveDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockHiveDataSource();
    repository = HabitRepositoryImpl(mockDataSource);
  });

  group('HabitRepositoryImpl', () {
    final testHabitModel = HabitModel(
      id: 'test-id',
      name: 'Test Habit',
      description: 'Test Description',
      category: HabitCategory.health,
      difficulty: HabitDifficulty.medium,
      frequency: HabitFrequency.daily,
      createdAt: DateTime(2024),
      iconName: 'test_icon',
      colorValue: 0xFF000000,
      unit: 'times',
    );

    final testHabit = Habit(
      id: 'test-id',
      name: 'Test Habit',
      description: 'Test Description',
      category: HabitCategory.health,
      difficulty: HabitDifficulty.medium,
      frequency: HabitFrequency.daily,
      createdAt: DateTime(2024),
      iconName: 'test_icon',
      colorValue: 0xFF000000,
      unit: 'times',
    );

    group('getAllHabits', () {
      test('should return success result with habits list', () async {
        // Arrange
        when(
          mockDataSource.getAllHabits(),
        ).thenAnswer((_) async => [testHabitModel]);

        // Act
        final result = await repository.getAllHabits();

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, isA<List<Habit>>());
        expect(result.data!.length, 1);
        expect(result.data!.first.id, testHabit.id);
        verify(mockDataSource.getAllHabits()).called(1);
      });

      test('should return failure result when data source throws', () async {
        // Arrange
        when(
          mockDataSource.getAllHabits(),
        ).thenThrow(Exception('Database error'));

        // Act
        final result = await repository.getAllHabits();

        // Assert
        expect(result.isFailure, true);
        expect(result.error, isA<UnknownException>());
      });
    });

    group('getHabitById', () {
      test('should return success result with habit when found', () async {
        // Arrange
        when(
          mockDataSource.getHabitById('test-id'),
        ).thenAnswer((_) async => testHabitModel);

        // Act
        final result = await repository.getHabitById('test-id');

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, isNotNull);
        expect(result.data!.id, testHabit.id);
        verify(mockDataSource.getHabitById('test-id')).called(1);
      });

      test('should return success result with null when not found', () async {
        // Arrange
        when(
          mockDataSource.getHabitById('non-existent'),
        ).thenAnswer((_) async => null);

        // Act
        final result = await repository.getHabitById('non-existent');

        // Assert
        expect(result.isSuccess, true);
        expect(result.data, isNull);
        verify(mockDataSource.getHabitById('non-existent')).called(1);
      });

      test('should return failure result for invalid ID', () async {
        // Act
        final result = await repository.getHabitById('');

        // Assert
        expect(result.isFailure, true);
        expect(result.error, isA<DataValidationException>());
        verifyNever(mockDataSource.getHabitById(any));
      });
    });

    group('createHabit', () {
      test('should return success result when habit is created', () async {
        // Arrange
        when(mockDataSource.saveHabit(any)).thenAnswer((_) async {});

        // Act
        final result = await repository.createHabit(testHabit);

        // Assert
        expect(result.isSuccess, true);
        verify(mockDataSource.saveHabit(any)).called(1);
      });

      test('should return failure result for invalid habit', () async {
        // Arrange
        final invalidHabit = testHabit.copyWith(name: '');

        // Act
        final result = await repository.createHabit(invalidHabit);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, isA<DataValidationException>());
        verifyNever(mockDataSource.saveHabit(any));
      });

      test('should return failure result when data source throws', () async {
        // Arrange
        when(
          mockDataSource.saveHabit(any),
        ).thenThrow(Exception('Database error'));

        // Act
        final result = await repository.createHabit(testHabit);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, isA<UnknownException>());
      });
    });

    group('updateHabit', () {
      test('should return success result when habit is updated', () async {
        // Arrange
        when(mockDataSource.updateHabit(any)).thenAnswer((_) async {});

        // Act
        final result = await repository.updateHabit(testHabit);

        // Assert
        expect(result.isSuccess, true);
        verify(mockDataSource.updateHabit(any)).called(1);
      });

      test('should return failure result for invalid habit', () async {
        // Arrange
        final invalidHabit = testHabit.copyWith(name: '');

        // Act
        final result = await repository.updateHabit(invalidHabit);

        // Assert
        expect(result.isFailure, true);
        expect(result.error, isA<DataValidationException>());
        verifyNever(mockDataSource.updateHabit(any));
      });
    });

    group('deleteHabit', () {
      test('should return success result when habit is deleted', () async {
        // Arrange
        when(mockDataSource.deleteHabit('test-id')).thenAnswer((_) async {});

        // Act
        final result = await repository.deleteHabit('test-id');

        // Assert
        expect(result.isSuccess, true);
        verify(mockDataSource.deleteHabit('test-id')).called(1);
      });

      test('should return failure result for invalid ID', () async {
        // Act
        final result = await repository.deleteHabit('');

        // Assert
        expect(result.isFailure, true);
        expect(result.error, isA<DataValidationException>());
        verifyNever(mockDataSource.deleteHabit(any));
      });
    });
  });
}

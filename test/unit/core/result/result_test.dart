import 'package:flutter_test/flutter_test.dart';
import 'package:habitquest/core/errors/app_exceptions.dart';
import 'package:habitquest/core/result/result.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('should create successful result', () {
        const result = Result.success('test data');

        expect(result.isSuccess, true);
        expect(result.isFailure, false);
        expect(result.data, 'test data');
        expect(result.error, null);
      });

      test('should support getOrThrow', () {
        const result = Result.success(42);

        expect(result.getOrThrow(), 42);
      });

      test('should support getOrElse', () {
        const result = Result.success('success');

        expect(result.getOrElse('default'), 'success');
      });

      test('should support getOrElseGet', () {
        const result = Result.success('success');

        expect(result.getOrElseGet(() => 'default'), 'success');
      });
    });

    group('Failure', () {
      test('should create failed result', () {
        final error = UnknownException(message: 'Test error');
        final result = Result<String>.failure(error);

        expect(result.isSuccess, false);
        expect(result.isFailure, true);
        expect(result.data, null);
        expect(result.error, error);
      });

      test('should throw on getOrThrow', () {
        final error = UnknownException(message: 'Test error');
        final result = Result<String>.failure(error);

        expect(result.getOrThrow, throwsA(error));
      });

      test('should return default on getOrElse', () {
        final error = UnknownException(message: 'Test error');
        final result = Result<String>.failure(error);

        expect(result.getOrElse('default'), 'default');
      });

      test('should compute default on getOrElseGet', () {
        final error = UnknownException(message: 'Test error');
        final result = Result<String>.failure(error);

        expect(result.getOrElseGet(() => 'computed'), 'computed');
      });
    });

    group('map', () {
      test('should transform success data', () {
        const result = Result.success(5);
        final mapped = result.map((value) => value * 2);

        expect(mapped.isSuccess, true);
        expect(mapped.data, 10);
      });

      test('should preserve failure', () {
        final error = UnknownException(message: 'Test error');
        final result = Result<int>.failure(error);
        final mapped = result.map((value) => value * 2);

        expect(mapped.isFailure, true);
        expect(mapped.error, error);
      });
    });

    group('flatMap', () {
      test('should chain successful operations', () {
        const result = Result.success(5);
        final chained = result.flatMap((value) => Result.success(value * 2));

        expect(chained.isSuccess, true);
        expect(chained.data, 10);
      });

      test('should handle failure in chain', () {
        const result = Result.success(5);
        final error = UnknownException(message: 'Chain error');
        final chained = result.flatMap((value) => Result<int>.failure(error));

        expect(chained.isFailure, true);
        expect(chained.error, error);
      });

      test('should preserve original failure', () {
        final error = UnknownException(message: 'Original error');
        final result = Result<int>.failure(error);
        final chained = result.flatMap((value) => Result.success(value * 2));

        expect(chained.isFailure, true);
        expect(chained.error, error);
      });
    });

    group('fold', () {
      test('should handle success case', () {
        const result = Result.success('test');
        final folded = result.fold(
          (error) => 'error: ${error.message}',
          (data) => 'success: $data',
        );

        expect(folded, 'success: test');
      });

      test('should handle failure case', () {
        final error = UnknownException(message: 'Test error');
        final result = Result<String>.failure(error);
        final folded = result.fold(
          (error) => 'error: ${error.message}',
          (data) => 'success: $data',
        );

        expect(folded, 'error: Test error');
      });
    });

    group('onSuccess', () {
      test('should execute action on success', () {
        var executed = false;
        const result = Result.success('test');

        result.onSuccess((data) => executed = true);

        expect(executed, true);
      });

      test('should not execute action on failure', () {
        var executed = false;
        final error = UnknownException(message: 'Test error');
        final result = Result<String>.failure(error);

        result.onSuccess((data) => executed = true);

        expect(executed, false);
      });
    });

    group('onFailure', () {
      test('should execute action on failure', () {
        var executed = false;
        final error = UnknownException(message: 'Test error');
        final result = Result<String>.failure(error);

        result.onFailure((error) => executed = true);

        expect(executed, true);
      });

      test('should not execute action on success', () {
        var executed = false;
        const result = Result.success('test');

        result.onFailure((error) => executed = true);

        expect(executed, false);
      });
    });

    group('recover', () {
      test('should recover from failure', () {
        final error = UnknownException(message: 'Test error');
        final result = Result<String>.failure(error);
        final recovered = result.recover((error) => 'recovered');

        expect(recovered.isSuccess, true);
        expect(recovered.data, 'recovered');
      });

      test('should preserve success', () {
        const result = Result.success('original');
        final recovered = result.recover((error) => 'recovered');

        expect(recovered.isSuccess, true);
        expect(recovered.data, 'original');
      });
    });

    group('recoverWith', () {
      test('should recover with new result', () {
        final error = UnknownException(message: 'Test error');
        final result = Result<String>.failure(error);
        final recovered = result.recoverWith(
          (error) => const Result.success('recovered'),
        );

        expect(recovered.isSuccess, true);
        expect(recovered.data, 'recovered');
      });

      test('should preserve success', () {
        const result = Result.success('original');
        final recovered = result.recoverWith(
          (error) => const Result.success('recovered'),
        );

        expect(recovered.isSuccess, true);
        expect(recovered.data, 'original');
      });
    });

    group('equality', () {
      test('should compare success results', () {
        const result1 = Result.success('test');
        const result2 = Result.success('test');
        const result3 = Result.success('different');

        expect(result1, equals(result2));
        expect(result1, isNot(equals(result3)));
      });

      test('should compare failure results', () {
        final error1 = UnknownException(message: 'Test error');
        final error2 = UnknownException(message: 'Test error');
        final error3 = UnknownException(message: 'Different error');

        final result1 = Result<String>.failure(error1);
        final result2 = Result<String>.failure(error2);
        final result3 = Result<String>.failure(error3);

        expect(result1, equals(result2));
        expect(result1, isNot(equals(result3)));
      });
    });
  });

  group('ResultUtils', () {
    group('combine', () {
      test('should combine successful results', () {
        final results = [
          const Result.success(1),
          const Result.success(2),
          const Result.success(3),
        ];

        final combined = ResultUtils.combine(results);

        expect(combined.isSuccess, true);
        expect(combined.data, [1, 2, 3]);
      });

      test('should fail on first failure', () {
        final error = UnknownException(message: 'Test error');
        final results = [
          const Result.success(1),
          Result<int>.failure(error),
          const Result.success(3),
        ];

        final combined = ResultUtils.combine(results);

        expect(combined.isFailure, true);
        expect(combined.error, error);
      });
    });

    group('tryExecute', () {
      test('should wrap successful function', () {
        final result = ResultUtils.tryExecute(() => 42);

        expect(result.isSuccess, true);
        expect(result.data, 42);
      });

      test('should catch and wrap exceptions', () {
        final result = ResultUtils.tryExecute(
          () => throw Exception('Test error'),
        );

        expect(result.isFailure, true);
        expect(result.error, isA<UnknownException>());
      });
    });

    group('tryExecuteAsync', () {
      test('should wrap successful async function', () async {
        final result = await ResultUtils.tryExecuteAsync(() async => 42);

        expect(result.isSuccess, true);
        expect(result.data, 42);
      });

      test('should catch and wrap async exceptions', () async {
        final result = await ResultUtils.tryExecuteAsync(
          () async => throw Exception('Test error'),
        );

        expect(result.isFailure, true);
        expect(result.error, isA<UnknownException>());
      });
    });

    group('fromNullable', () {
      test('should create success from non-null value', () {
        final result = ResultUtils.fromNullable(
          'test',
          () => UnknownException(message: 'Null value'),
        );

        expect(result.isSuccess, true);
        expect(result.data, 'test');
      });

      test('should create failure from null value', () {
        final error = UnknownException(message: 'Null value');
        final result = ResultUtils.fromNullable<String>(null, () => error);

        expect(result.isFailure, true);
        expect(result.error, error);
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:habitquest/core/errors/app_exceptions.dart';

void main() {
  group('AppException', () {
    test('should create exception with required fields', () {
      final exception = DatabaseException(
        message: 'Database connection failed',
        context: const {'table': 'habits'},
      );

      expect(exception.code, 'DATABASE_ERROR');
      expect(exception.message, 'Database connection failed');
      expect(exception.context, {'table': 'habits'});
      expect(exception.severity, ErrorSeverity.error);
      expect(exception.isRetryable, true);
      expect(exception.shouldReport, true);
      expect(
        exception.userMessage,
        'A database error occurred. Please try again.',
      );
    });

    test('should have proper timestamp', () {
      final before = DateTime.now();
      final exception = DatabaseException(message: 'Test error');
      final after = DateTime.now();

      expect(
        exception.timestamp.isAfter(before) ||
            exception.timestamp.isAtSameMomentAs(before),
        true,
      );
      expect(
        exception.timestamp.isBefore(after) ||
            exception.timestamp.isAtSameMomentAs(after),
        true,
      );
    });

    test('should support equality comparison', () {
      final exception1 = DataNotFoundException(
        entityType: 'Habit',
        identifier: '123',
      );
      final exception2 = DataNotFoundException(
        entityType: 'Habit',
        identifier: '123',
      );
      final exception3 = DataNotFoundException(
        entityType: 'User',
        identifier: '123',
      );

      expect(exception1, equals(exception2));
      expect(exception1, isNot(equals(exception3)));
    });
  });

  group('ErrorSeverity', () {
    test('should have correct display names', () {
      expect(ErrorSeverity.info.displayName, 'Info');
      expect(ErrorSeverity.warning.displayName, 'Warning');
      expect(ErrorSeverity.error.displayName, 'Error');
      expect(ErrorSeverity.critical.displayName, 'Critical');
      expect(ErrorSeverity.fatal.displayName, 'Fatal');
    });
  });

  group('DataException', () {
    test('DatabaseException should be retryable', () {
      final exception = DatabaseException(message: 'Connection failed');

      expect(exception.isRetryable, true);
      expect(exception.severity, ErrorSeverity.error);
      expect(exception.shouldReport, true);
    });

    test('DataNotFoundException should not be retryable', () {
      final exception = DataNotFoundException(
        entityType: 'Habit',
        identifier: '123',
      );

      expect(exception.isRetryable, false);
      expect(exception.severity, ErrorSeverity.warning);
      expect(exception.shouldReport, false);
    });

    test('DataValidationException should not be retryable', () {
      final exception = DataValidationException(
        validationErrors: const ['Name is required', 'Invalid email'],
      );

      expect(exception.isRetryable, false);
      expect(exception.shouldReport, false);
      expect(exception.userMessage, 'Please check your input and try again.');
    });

    test('StorageQuotaExceededException should have warning severity', () {
      final exception = StorageQuotaExceededException();

      expect(exception.severity, ErrorSeverity.warning);
      expect(
        exception.userMessage,
        'Storage space is full. Please free up some space.',
      );
    });
  });

  group('BusinessException', () {
    test('should not be reported by default', () {
      final exception = InvalidOperationException(message: 'Invalid state');

      expect(exception.shouldReport, false);
      expect(exception.severity, ErrorSeverity.error);
    });

    test('InsufficientPermissionsException should have proper message', () {
      final exception = InsufficientPermissionsException(
        operation: 'delete_habit',
      );

      expect(
        exception.message,
        'Insufficient permissions for operation: delete_habit',
      );
      expect(
        exception.userMessage,
        'You don\'t have permission to perform this action.',
      );
    });

    test('ResourceLimitExceededException should include counts', () {
      final exception = ResourceLimitExceededException(
        resourceType: 'habits',
        currentCount: 10,
        maxAllowed: 5,
      );

      expect(exception.message, 'habits limit exceeded: 10/5');
      expect(
        exception.userMessage,
        'You have reached the maximum number of habits allowed.',
      );
    });
  });

  group('NetworkException', () {
    test('should be retryable by default', () {
      final exception = NoInternetConnectionException();

      expect(exception.isRetryable, true);
      expect(exception.severity, ErrorSeverity.warning);
    });

    test('NetworkTimeoutException should have proper message', () {
      final exception = NetworkTimeoutException();

      expect(exception.code, 'NETWORK_TIMEOUT');
      expect(
        exception.userMessage,
        'The request took too long. Please try again.',
      );
    });

    test(
      'ServerException should have different severity based on status code',
      () {
        final serverError = ServerException(
          statusCode: 500,
          message: 'Internal server error',
        );
        final clientError = ServerException(
          statusCode: 400,
          message: 'Bad request',
        );

        expect(serverError.severity, ErrorSeverity.error);
        expect(clientError.severity, ErrorSeverity.warning);
      },
    );
  });

  group('PresentationException', () {
    test('should not be reported', () {
      final exception = NavigationException(message: 'Route not found');

      expect(exception.shouldReport, false);
      expect(exception.severity, ErrorSeverity.warning);
    });

    test('WidgetRenderException should have proper user message', () {
      final exception = WidgetRenderException(
        message: 'Widget failed to render',
      );

      expect(
        exception.userMessage,
        'Display error occurred. Please refresh the screen.',
      );
    });
  });

  group('SystemException', () {
    test('should have critical severity', () {
      final exception = PlatformException(message: 'Platform error');

      expect(exception.severity, ErrorSeverity.critical);
    });

    test('SystemPermissionDeniedException should have warning severity', () {
      final exception = SystemPermissionDeniedException(permission: 'camera');

      expect(exception.severity, ErrorSeverity.warning);
      expect(
        exception.userMessage,
        'Permission required. Please grant access in settings.',
      );
    });
  });

  group('UnknownException', () {
    test('should handle unknown errors', () {
      final exception = UnknownException(
        message: 'Something went wrong',
        context: const {'originalError': 'FormatException'},
      );

      expect(exception.code, 'UNKNOWN_ERROR');
      expect(exception.severity, ErrorSeverity.error);
      expect(
        exception.userMessage,
        'An unexpected error occurred. Please try again.',
      );
    });
  });
}

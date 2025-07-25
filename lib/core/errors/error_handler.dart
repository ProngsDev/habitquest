import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' as services;
import 'package:hive/hive.dart';

import '../services/logging_service.dart';
import 'app_exceptions.dart';

/// Central error handler following JP_GE Präzision principles
class ErrorHandler {
  /// Convert generic exceptions to typed AppExceptions
  static AppException handleError(Object error, [StackTrace? stackTrace]) {
    if (error is AppException) {
      return error;
    }

    // Handle Hive-specific errors
    if (error is HiveError) {
      return _handleHiveError(error);
    }

    // Handle platform-specific errors
    if (error is services.PlatformException) {
      return _handlePlatformError(error);
    }

    // Handle argument errors (validation)
    if (error is ArgumentError) {
      return DataValidationException(
        validationErrors: [(error.message ?? 'Invalid argument').toString()],
        context: {'argument': error.name, 'value': error.invalidValue},
      );
    }

    // Handle state errors
    if (error is StateError) {
      return InvalidOperationException(
        message: error.message,
        context: {'stackTrace': stackTrace?.toString()},
      );
    }

    // Handle format exceptions
    if (error is FormatException) {
      return DataValidationException(
        validationErrors: ['Invalid format: ${error.message}'],
        context: {'source': error.source, 'offset': error.offset},
      );
    }

    // Handle timeout errors
    if (error is TimeoutException) {
      return NetworkTimeoutException(
        context: {'timeout': error.duration?.toString()},
      );
    }

    // Default to unknown exception
    return UnknownException(
      message: error.toString(),
      context: {
        'originalType': error.runtimeType.toString(),
        'stackTrace': stackTrace?.toString(),
      },
      cause: error is Exception ? error : null,
    );
  }

  /// Handle Hive database errors
  static AppException _handleHiveError(HiveError error) {
    switch (error.message) {
      case 'Box not found':
        return DatabaseException(
          message: 'Database not initialized',
          context: {'hiveError': error.message},
        );
      case 'Box is already open':
        return InvalidOperationException(
          message: 'Database already initialized',
          context: {'hiveError': error.message},
        );
      default:
        return DatabaseException(
          message: 'Database operation failed: ${error.message}',
          context: {'hiveError': error.message},
        );
    }
  }

  /// Handle platform-specific errors
  static AppException _handlePlatformError(services.PlatformException error) {
    switch (error.code) {
      case 'PERMISSION_DENIED':
        return SystemPermissionDeniedException(
          permission: error.details?.toString() ?? 'Unknown permission',
          context: {'platformCode': error.code, 'details': error.details},
        );
      case 'UNAVAILABLE':
        return PlatformException(
          message:
              'Platform service unavailable: ${error.message ?? 'Unknown'}',
          context: {'platformCode': error.code, 'details': error.details},
        );
      case 'NOT_FOUND':
        return DataNotFoundException(
          entityType: 'Platform Resource',
          identifier: error.details?.toString() ?? 'Unknown',
          context: {'platformCode': error.code},
        );
      default:
        return PlatformException(
          message: error.message ?? 'Platform error occurred',
          context: {
            'platformCode': error.code,
            'details': error.details,
            'stackTrace': error.stacktrace,
          },
        );
    }
  }

  /// Log error with appropriate level
  static void logError(AppException error) {
    // Use the structured logging service
    LoggingService.instance.logException(error);

    // In production, you would send to crash analytics here
    if (error.shouldReport && !kDebugMode) {
      _reportToCrashlytics(error);
    }
  }

  /// Report error to crash analytics (placeholder)
  static void _reportToCrashlytics(AppException error) {
    // TODO(crashlytics): Implement crash analytics reporting
    // Example: FirebaseCrashlytics.instance.recordError(error, null);
    LoggingService.instance.debug('Would report to crashlytics: ${error.code}');
  }

  /// Check if error should trigger retry logic
  static bool shouldRetry(
    AppException error,
    int attemptCount,
    int maxRetries,
  ) {
    if (!error.isRetryable || attemptCount >= maxRetries) {
      return false;
    }

    // Don't retry validation errors or business logic errors
    if (error is DataValidationException || error is BusinessException) {
      return false;
    }

    // Retry network and database errors
    return error is NetworkException || error is DatabaseException;
  }

  /// Get retry delay based on attempt count (exponential backoff)
  static Duration getRetryDelay(int attemptCount) {
    const baseDelay = Duration(milliseconds: 500);
    final multiplier = math.pow(2, attemptCount).toInt();
    const maxDelay = Duration(seconds: 30);

    final delay = Duration(milliseconds: baseDelay.inMilliseconds * multiplier);
    return delay > maxDelay ? maxDelay : delay;
  }
}

import 'dart:async';
import 'dart:math' as math;

import '../errors/app_exceptions.dart';
import '../result/result.dart';
import '../services/logging_service.dart';

/// Retry policy configuration following JP_GE resilience principles
class RetryPolicy {
  const RetryPolicy({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffMultiplier = 2.0,
    this.shouldRetry = _defaultShouldRetry,
    this.timeout,
  });
  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;
  final double backoffMultiplier;
  final bool Function(AppException) shouldRetry;
  final Duration? timeout;

  /// Default retry policy for network operations
  static const RetryPolicy network = RetryPolicy(
    initialDelay: Duration(milliseconds: 1000),
    maxDelay: Duration(seconds: 10),
    shouldRetry: _networkShouldRetry,
    timeout: Duration(seconds: 30),
  );

  /// Default retry policy for database operations
  static const RetryPolicy database = RetryPolicy(
    maxAttempts: 5,
    initialDelay: Duration(milliseconds: 100),
    maxDelay: Duration(seconds: 5),
    backoffMultiplier: 1.5,
    shouldRetry: _databaseShouldRetry,
    timeout: Duration(seconds: 10),
  );

  /// No retry policy
  static const RetryPolicy none = RetryPolicy(maxAttempts: 1);

  /// Calculate delay for given attempt
  Duration calculateDelay(int attempt) {
    if (attempt <= 0) return Duration.zero;

    final delay = Duration(
      milliseconds:
          (initialDelay.inMilliseconds *
                  math.pow(backoffMultiplier, attempt - 1))
              .round(),
    );

    return delay > maxDelay ? maxDelay : delay;
  }

  /// Default should retry logic
  static bool _defaultShouldRetry(AppException error) => error.isRetryable;

  /// Network-specific retry logic
  static bool _networkShouldRetry(AppException error) {
    if (!error.isRetryable) return false;

    // Retry network timeouts and server errors
    if (error is NetworkTimeoutException) return true;
    if (error is ServerException && error.statusCode >= 500) return true;
    if (error is NoInternetConnectionException) return true;

    return false;
  }

  /// Database-specific retry logic
  static bool _databaseShouldRetry(AppException error) {
    if (!error.isRetryable) return false;

    // Retry database connection issues
    if (error is DatabaseException) return true;

    return false;
  }
}

/// Retry executor for implementing retry logic
class RetryExecutor {
  static final LoggingService _logger = LoggingService.instance;

  /// Execute function with retry policy
  static Future<Result<T>> execute<T>(
    Future<T> Function() operation,
    RetryPolicy policy, {
    String? operationName,
  }) async {
    final name = operationName ?? 'operation';
    var attempt = 0;
    AppException? lastError;

    while (attempt < policy.maxAttempts) {
      attempt++;

      try {
        _logger.debug(
          'Executing $name (attempt $attempt/${policy.maxAttempts})',
          context: {'attempt': attempt, 'maxAttempts': policy.maxAttempts},
        );

        final operationFuture = operation();
        final result = policy.timeout != null
            ? await operationFuture.timeout(policy.timeout!)
            : await operationFuture;

        if (attempt > 1) {
          _logger.info(
            '$name succeeded after $attempt attempts',
            context: {'attempt': attempt, 'totalAttempts': attempt},
          );
        }

        return Result.success(result);
      } on Exception catch (error, stackTrace) {
        final appException = _handleError(error, stackTrace);
        lastError = appException;

        _logger.warning(
          '$name failed on attempt $attempt',
          context: {
            'attempt': attempt,
            'maxAttempts': policy.maxAttempts,
            'error': appException.code,
            'message': appException.message,
          },
          error: appException,
        );

        // Check if we should retry
        if (attempt >= policy.maxAttempts ||
            !policy.shouldRetry(appException)) {
          _logger.error(
            '$name failed permanently after $attempt attempts',
            context: {
              'totalAttempts': attempt,
              'finalError': appException.code,
            },
            error: appException,
          );
          return Result.failure(appException);
        }

        // Calculate delay and wait
        if (attempt < policy.maxAttempts) {
          final delay = policy.calculateDelay(attempt);
          _logger.debug(
            'Retrying $name in ${delay.inMilliseconds}ms',
            context: {
              'delay': delay.inMilliseconds,
              'nextAttempt': attempt + 1,
            },
          );
          await Future<void>.delayed(delay);
        }
      }
    }

    // This should never be reached, but just in case
    return Result.failure(
      lastError ?? UnknownException(message: 'Retry failed'),
    );
  }

  /// Execute function with retry policy (synchronous)
  static Result<T> executeSync<T>(
    T Function() operation,
    RetryPolicy policy, {
    String? operationName,
  }) {
    final name = operationName ?? 'operation';
    var attempt = 0;
    AppException? lastError;

    while (attempt < policy.maxAttempts) {
      attempt++;

      try {
        _logger.debug(
          'Executing $name (attempt $attempt/${policy.maxAttempts})',
          context: {'attempt': attempt, 'maxAttempts': policy.maxAttempts},
        );

        final result = operation();

        if (attempt > 1) {
          _logger.info(
            '$name succeeded after $attempt attempts',
            context: {'attempt': attempt, 'totalAttempts': attempt},
          );
        }

        return Result.success(result);
      } on Exception catch (error, stackTrace) {
        final appException = _handleError(error, stackTrace);
        lastError = appException;

        _logger.warning(
          '$name failed on attempt $attempt',
          context: {
            'attempt': attempt,
            'maxAttempts': policy.maxAttempts,
            'error': appException.code,
            'message': appException.message,
          },
          error: appException,
        );

        // Check if we should retry
        if (attempt >= policy.maxAttempts ||
            !policy.shouldRetry(appException)) {
          _logger.error(
            '$name failed permanently after $attempt attempts',
            context: {
              'totalAttempts': attempt,
              'finalError': appException.code,
            },
            error: appException,
          );
          return Result.failure(appException);
        }

        // For synchronous operations, we can't delay, so just continue
      }
    }

    // This should never be reached, but just in case
    return Result.failure(
      lastError ?? UnknownException(message: 'Retry failed'),
    );
  }

  /// Handle errors and convert to AppException
  static AppException _handleError(Object error, StackTrace stackTrace) {
    if (error is AppException) {
      return error;
    }

    if (error is TimeoutException) {
      return NetworkTimeoutException(
        context: {'timeout': error.duration?.toString()},
      );
    }

    return UnknownException(
      message: error.toString(),
      context: {'stackTrace': stackTrace.toString()},
    );
  }
}

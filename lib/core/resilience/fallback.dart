import 'dart:async';

import '../errors/app_exceptions.dart';
import '../result/result.dart';
import '../services/logging_service.dart';

/// Fallback strategy for handling failures gracefully
abstract class FallbackStrategy<T> {
  /// Execute fallback strategy
  Future<Result<T>> execute(AppException error);

  /// Name of the fallback strategy
  String get name;
}

/// Return a default value as fallback
class DefaultValueFallback<T> extends FallbackStrategy<T> {
  DefaultValueFallback(this.defaultValue);

  final T defaultValue;

  @override
  Future<Result<T>> execute(AppException error) async {
    LoggingService.instance.info(
      'Using default value fallback',
      context: {
        'fallback': name,
        'error': error.code,
        'defaultValue': defaultValue.toString(),
      },
    );
    return Result.success(defaultValue);
  }

  @override
  String get name => 'DefaultValue';
}

/// Return an empty result as fallback
class EmptyFallback<T> extends FallbackStrategy<List<T>> {
  EmptyFallback();

  @override
  Future<Result<List<T>>> execute(AppException error) async {
    LoggingService.instance.info(
      'Using empty list fallback',
      context: {'fallback': name, 'error': error.code},
    );
    return Result.success(<T>[]);
  }

  @override
  String get name => 'Empty';
}

/// Execute an alternative operation as fallback
class AlternativeFallback<T> extends FallbackStrategy<T> {
  AlternativeFallback(this.alternative, {this.alternativeName});

  final Future<T> Function() alternative;
  final String? alternativeName;

  @override
  Future<Result<T>> execute(AppException error) async {
    try {
      LoggingService.instance.info(
        'Executing alternative operation fallback',
        context: {
          'fallback': name,
          'alternative': alternativeName ?? 'unnamed',
          'error': error.code,
        },
      );

      final result = await alternative();
      return Result.success(result);
    } on Exception catch (fallbackError, stackTrace) {
      LoggingService.instance.error(
        'Alternative fallback failed',
        context: {
          'fallback': name,
          'originalError': error.code,
          'fallbackError': fallbackError.toString(),
        },
        error: fallbackError,
        stackTrace: stackTrace,
      );

      // Return the original error if fallback fails
      return Result.failure(error);
    }
  }

  @override
  String get name => 'Alternative(${alternativeName ?? 'unnamed'})';
}

/// Cache-based fallback strategy
class CacheFallback<T> extends FallbackStrategy<T> {
  CacheFallback(this.getCachedValue, {required this.cacheName});

  final Future<T?> Function() getCachedValue;
  final String cacheName;

  @override
  Future<Result<T>> execute(AppException error) async {
    try {
      LoggingService.instance.info(
        'Attempting cache fallback',
        context: {'fallback': name, 'cache': cacheName, 'error': error.code},
      );

      final cachedValue = await getCachedValue();
      if (cachedValue != null) {
        LoggingService.instance.info(
          'Cache fallback successful',
          context: {'fallback': name, 'cache': cacheName},
        );
        return Result.success(cachedValue);
      } else {
        LoggingService.instance.warning(
          'Cache fallback failed - no cached value',
          context: {'fallback': name, 'cache': cacheName, 'error': error.code},
        );
        return Result.failure(error);
      }
    } on Exception catch (cacheError, stackTrace) {
      LoggingService.instance.error(
        'Cache fallback failed with error',
        context: {
          'fallback': name,
          'cache': cacheName,
          'originalError': error.code,
          'cacheError': cacheError.toString(),
        },
        error: cacheError,
        stackTrace: stackTrace,
      );

      return Result.failure(error);
    }
  }

  @override
  String get name => 'Cache($cacheName)';
}

/// Chain multiple fallback strategies
class ChainedFallback<T> extends FallbackStrategy<T> {
  ChainedFallback(this.strategies);

  final List<FallbackStrategy<T>> strategies;

  @override
  Future<Result<T>> execute(AppException error) async {
    LoggingService.instance.info(
      'Executing chained fallback',
      context: {
        'fallback': name,
        'strategies': strategies.map((s) => s.name).toList(),
        'error': error.code,
      },
    );

    for (final strategy in strategies) {
      final result = await strategy.execute(error);
      if (result.isSuccess) {
        LoggingService.instance.info(
          'Chained fallback succeeded with strategy',
          context: {
            'fallback': name,
            'successfulStrategy': strategy.name,
            'error': error.code,
          },
        );
        return result;
      }
    }

    LoggingService.instance.warning(
      'All chained fallback strategies failed',
      context: {
        'fallback': name,
        'strategies': strategies.map((s) => s.name).toList(),
        'error': error.code,
      },
    );

    return Result.failure(error);
  }

  @override
  String get name => 'Chained[${strategies.map((s) => s.name).join(', ')}]';
}

/// Fallback executor that combines operation with fallback strategy
class FallbackExecutor {
  static final LoggingService _logger = LoggingService.instance;

  /// Execute operation with fallback
  static Future<Result<T>> execute<T>(
    Future<T> Function() operation,
    FallbackStrategy<T> fallback, {
    String? operationName,
  }) async {
    final opName = operationName ?? 'operation';

    try {
      _logger.debug(
        'Executing $opName with fallback ${fallback.name}',
        context: {'operation': opName, 'fallback': fallback.name},
      );

      final result = await operation();
      return Result.success(result);
    } on Exception catch (error, stackTrace) {
      final appException = _handleError(error, stackTrace);

      _logger.warning(
        '$opName failed, executing fallback ${fallback.name}',
        context: {
          'operation': opName,
          'fallback': fallback.name,
          'error': appException.code,
        },
        error: appException,
      );

      return fallback.execute(appException);
    }
  }

  /// Execute operation with fallback (synchronous)
  static Result<T> executeSync<T>(
    T Function() operation,
    T fallbackValue, {
    String? operationName,
  }) {
    final opName = operationName ?? 'operation';

    try {
      _logger.debug(
        'Executing $opName with default fallback',
        context: {'operation': opName, 'fallback': 'default'},
      );

      final result = operation();
      return Result.success(result);
    } on Exception catch (error, stackTrace) {
      final appException = _handleError(error, stackTrace);

      _logger.warning(
        '$opName failed, using fallback value',
        context: {
          'operation': opName,
          'fallback': 'default',
          'error': appException.code,
          'fallbackValue': fallbackValue.toString(),
        },
        error: appException,
      );

      return Result.success(fallbackValue);
    }
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

import 'dart:async';

import '../errors/app_exceptions.dart';
import '../result/result.dart';
import '../services/logging_service.dart';

/// Circuit breaker states
enum CircuitBreakerState {
  /// Circuit is closed, allowing requests
  closed,

  /// Circuit is open, rejecting requests
  open,

  /// Circuit is half-open, testing if service is recovered
  halfOpen,
}

/// Circuit breaker configuration
class CircuitBreakerConfig {
  const CircuitBreakerConfig({
    this.failureThreshold = 5,
    this.timeout = const Duration(seconds: 60),
    this.successThreshold = 3,
    this.timeWindow = const Duration(minutes: 1),
    this.isFailure = _defaultIsFailure,
  });

  /// Number of failures before opening circuit
  final int failureThreshold;

  /// Time to wait before attempting to close circuit
  final Duration timeout;

  /// Number of successful calls needed to close circuit from half-open
  final int successThreshold;

  /// Time window for counting failures
  final Duration timeWindow;

  /// Function to determine if error should count as failure
  final bool Function(AppException) isFailure;

  /// Default failure detection logic
  static bool _defaultIsFailure(AppException error) {
    // Don't count validation errors or business logic errors as failures
    if (error is DataValidationException || error is BusinessException) {
      return false;
    }

    // Count network and database errors as failures
    return error is NetworkException || error is DatabaseException;
  }
}

/// Circuit breaker implementation following JP_GE resilience principles
class CircuitBreaker {
  CircuitBreaker({required this.name, required this.config}) {
    _stateChangeTime = DateTime.now();
  }
  final String name;
  final CircuitBreakerConfig config;
  final LoggingService _logger = LoggingService.instance;

  CircuitBreakerState _state = CircuitBreakerState.closed;
  int _failureCount = 0;
  int _successCount = 0;
  DateTime? _lastFailureTime;
  DateTime? _stateChangeTime;

  /// Current state of the circuit breaker
  CircuitBreakerState get state => _state;

  /// Current failure count
  int get failureCount => _failureCount;

  /// Current success count (in half-open state)
  int get successCount => _successCount;

  /// Execute operation with circuit breaker protection
  Future<Result<T>> execute<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) async {
    final opName = operationName ?? 'operation';

    // Check if circuit is open
    if (_state == CircuitBreakerState.open) {
      if (_shouldAttemptReset()) {
        _transitionToHalfOpen();
      } else {
        _logger.warning(
          'Circuit breaker $name is open, rejecting $opName',
          context: {
            'circuitBreaker': name,
            'state': _state.name,
            'failureCount': _failureCount,
            'timeSinceLastFailure': _timeSinceLastFailure?.inSeconds,
          },
        );
        return Result.failure(
          InvalidOperationException(
            message: 'Circuit breaker $name is open',
            context: {
              'circuitBreaker': name,
              'state': _state.name,
              'operation': opName,
            },
          ),
        );
      }
    }

    try {
      _logger.debug(
        'Executing $opName through circuit breaker $name',
        context: {
          'circuitBreaker': name,
          'state': _state.name,
          'operation': opName,
        },
      );

      final result = await operation();
      _onSuccess();
      return Result.success(result);
    } on Exception catch (error, stackTrace) {
      final appException = _handleError(error, stackTrace);
      _onFailure(appException);
      return Result.failure(appException);
    }
  }

  /// Execute operation synchronously with circuit breaker protection
  Result<T> executeSync<T>(T Function() operation, {String? operationName}) {
    final opName = operationName ?? 'operation';

    // Check if circuit is open
    if (_state == CircuitBreakerState.open) {
      if (_shouldAttemptReset()) {
        _transitionToHalfOpen();
      } else {
        _logger.warning(
          'Circuit breaker $name is open, rejecting $opName',
          context: {
            'circuitBreaker': name,
            'state': _state.name,
            'failureCount': _failureCount,
            'timeSinceLastFailure': _timeSinceLastFailure?.inSeconds,
          },
        );
        return Result.failure(
          InvalidOperationException(
            message: 'Circuit breaker $name is open',
            context: {
              'circuitBreaker': name,
              'state': _state.name,
              'operation': opName,
            },
          ),
        );
      }
    }

    try {
      _logger.debug(
        'Executing $opName through circuit breaker $name',
        context: {
          'circuitBreaker': name,
          'state': _state.name,
          'operation': opName,
        },
      );

      final result = operation();
      _onSuccess();
      return Result.success(result);
    } on Exception catch (error, stackTrace) {
      final appException = _handleError(error, stackTrace);
      _onFailure(appException);
      return Result.failure(appException);
    }
  }

  /// Reset circuit breaker to closed state
  void reset() {
    _logger.info(
      'Resetting circuit breaker $name',
      context: {
        'circuitBreaker': name,
        'previousState': _state.name,
        'failureCount': _failureCount,
      },
    );

    _state = CircuitBreakerState.closed;
    _failureCount = 0;
    _successCount = 0;
    _lastFailureTime = null;
    _stateChangeTime = DateTime.now();
  }

  /// Get circuit breaker metrics
  Map<String, dynamic> getMetrics() => {
    'name': name,
    'state': _state.name,
    'failureCount': _failureCount,
    'successCount': _successCount,
    'lastFailureTime': _lastFailureTime?.toIso8601String(),
    'stateChangeTime': _stateChangeTime?.toIso8601String(),
    'timeSinceLastFailure': _timeSinceLastFailure?.inSeconds,
    'config': {
      'failureThreshold': config.failureThreshold,
      'timeout': config.timeout.inSeconds,
      'successThreshold': config.successThreshold,
      'timeWindow': config.timeWindow.inSeconds,
    },
  };

  /// Handle successful operation
  void _onSuccess() {
    if (_state == CircuitBreakerState.halfOpen) {
      _successCount++;

      _logger.debug(
        'Circuit breaker $name recorded success in half-open state',
        context: {
          'circuitBreaker': name,
          'successCount': _successCount,
          'successThreshold': config.successThreshold,
        },
      );

      if (_successCount >= config.successThreshold) {
        _transitionToClosed();
      }
    } else if (_state == CircuitBreakerState.closed) {
      // Reset failure count on success in closed state
      if (_failureCount > 0) {
        _failureCount = 0;
        _lastFailureTime = null;
      }
    }
  }

  /// Handle failed operation
  void _onFailure(AppException error) {
    if (!config.isFailure(error)) {
      _logger.debug(
        'Circuit breaker $name ignoring non-failure error',
        context: {
          'circuitBreaker': name,
          'error': error.code,
          'message': error.message,
        },
      );
      return;
    }

    _failureCount++;
    _lastFailureTime = DateTime.now();

    _logger.warning(
      'Circuit breaker $name recorded failure',
      context: {
        'circuitBreaker': name,
        'state': _state.name,
        'failureCount': _failureCount,
        'failureThreshold': config.failureThreshold,
        'error': error.code,
      },
      error: error,
    );

    if (_state == CircuitBreakerState.closed &&
        _failureCount >= config.failureThreshold) {
      _transitionToOpen();
    } else if (_state == CircuitBreakerState.halfOpen) {
      _transitionToOpen();
    }
  }

  /// Check if enough time has passed to attempt reset
  bool _shouldAttemptReset() {
    if (_lastFailureTime == null) return false;
    return DateTime.now().difference(_lastFailureTime!) >= config.timeout;
  }

  /// Get time since last failure
  Duration? get _timeSinceLastFailure {
    if (_lastFailureTime == null) return null;
    return DateTime.now().difference(_lastFailureTime!);
  }

  /// Transition to half-open state
  void _transitionToHalfOpen() {
    _logger.info(
      'Circuit breaker $name transitioning to half-open',
      context: {
        'circuitBreaker': name,
        'previousState': _state.name,
        'failureCount': _failureCount,
      },
    );

    _state = CircuitBreakerState.halfOpen;
    _successCount = 0;
    _stateChangeTime = DateTime.now();
  }

  /// Transition to open state
  void _transitionToOpen() {
    _logger.error(
      'Circuit breaker $name transitioning to open',
      context: {
        'circuitBreaker': name,
        'previousState': _state.name,
        'failureCount': _failureCount,
        'failureThreshold': config.failureThreshold,
      },
    );

    _state = CircuitBreakerState.open;
    _successCount = 0;
    _stateChangeTime = DateTime.now();
  }

  /// Transition to closed state
  void _transitionToClosed() {
    _logger.info(
      'Circuit breaker $name transitioning to closed',
      context: {
        'circuitBreaker': name,
        'previousState': _state.name,
        'successCount': _successCount,
        'successThreshold': config.successThreshold,
      },
    );

    _state = CircuitBreakerState.closed;
    _failureCount = 0;
    _successCount = 0;
    _lastFailureTime = null;
    _stateChangeTime = DateTime.now();
  }

  /// Handle errors and convert to AppException
  AppException _handleError(Object error, StackTrace stackTrace) {
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

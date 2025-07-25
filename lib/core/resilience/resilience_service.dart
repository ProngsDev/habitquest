import 'dart:async';

import '../result/result.dart';
import '../services/logging_service.dart';
import 'circuit_breaker.dart';
import 'fallback.dart';
import 'retry_policy.dart';

/// Comprehensive resilience service combining retry, circuit breaker, and fallback
class ResilienceService {

  ResilienceService._internal();
  static final ResilienceService _instance = ResilienceService._internal();
  final Map<String, CircuitBreaker> _circuitBreakers = {};
  final LoggingService _logger = LoggingService.instance;

  /// Singleton instance
  static ResilienceService get instance => _instance;

  /// Execute operation with full resilience (retry + circuit breaker + fallback)
  Future<Result<T>> executeResilient<T>(
    Future<T> Function() operation, {
    required String operationName,
    RetryPolicy? retryPolicy,
    CircuitBreakerConfig? circuitBreakerConfig,
    FallbackStrategy<T>? fallback,
  }) async {
    final retry = retryPolicy ?? RetryPolicy.network;
    final circuitBreaker = _getOrCreateCircuitBreaker(
      operationName,
      circuitBreakerConfig ?? const CircuitBreakerConfig(),
    );

    _logger.debug(
      'Executing resilient operation: $operationName',
      context: {
        'operation': operationName,
        'retryPolicy': {
          'maxAttempts': retry.maxAttempts,
          'initialDelay': retry.initialDelay.inMilliseconds,
        },
        'circuitBreaker': circuitBreaker.getMetrics(),
        'hasFallback': fallback != null,
      },
    );

    // Execute with circuit breaker protection
    final circuitBreakerResult = await circuitBreaker.execute(
      () => RetryExecutor.execute(
        operation,
        retry,
        operationName: operationName,
      ).then((result) => result.getOrThrow()),
      operationName: operationName,
    );

    // If circuit breaker execution failed and we have a fallback, use it
    if (circuitBreakerResult.isFailure && fallback != null) {
      _logger.info(
        'Primary operation failed, executing fallback for $operationName',
        context: {
          'operation': operationName,
          'fallback': fallback.name,
          'error': circuitBreakerResult.error?.code,
        },
      );

      return fallback.execute(circuitBreakerResult.error!);
    }

    return circuitBreakerResult;
  }

  /// Execute operation with retry and circuit breaker (no fallback)
  Future<Result<T>> executeWithProtection<T>(
    Future<T> Function() operation, {
    required String operationName,
    RetryPolicy? retryPolicy,
    CircuitBreakerConfig? circuitBreakerConfig,
  }) async => executeResilient<T>(
      operation,
      operationName: operationName,
      retryPolicy: retryPolicy,
      circuitBreakerConfig: circuitBreakerConfig,
    );

  /// Execute operation with retry only
  Future<Result<T>> executeWithRetry<T>(
    Future<T> Function() operation, {
    required String operationName,
    RetryPolicy? retryPolicy,
  }) async {
    final retry = retryPolicy ?? RetryPolicy.network;
    return RetryExecutor.execute(
      operation,
      retry,
      operationName: operationName,
    );
  }

  /// Execute operation with circuit breaker only
  Future<Result<T>> executeWithCircuitBreaker<T>(
    Future<T> Function() operation, {
    required String operationName,
    CircuitBreakerConfig? circuitBreakerConfig,
  }) async {
    final circuitBreaker = _getOrCreateCircuitBreaker(
      operationName,
      circuitBreakerConfig ?? const CircuitBreakerConfig(),
    );

    return circuitBreaker.execute(operation, operationName: operationName);
  }

  /// Execute operation with fallback only
  Future<Result<T>> executeWithFallback<T>(
    Future<T> Function() operation,
    FallbackStrategy<T> fallback, {
    required String operationName,
  }) async => FallbackExecutor.execute(
      operation,
      fallback,
      operationName: operationName,
    );

  /// Get or create circuit breaker for operation
  CircuitBreaker _getOrCreateCircuitBreaker(
    String operationName,
    CircuitBreakerConfig config,
  ) => _circuitBreakers.putIfAbsent(
      operationName,
      () => CircuitBreaker(name: operationName, config: config),
    );

  /// Get circuit breaker for operation
  CircuitBreaker? getCircuitBreaker(String operationName) => _circuitBreakers[operationName];

  /// Reset circuit breaker for operation
  void resetCircuitBreaker(String operationName) {
    final circuitBreaker = _circuitBreakers[operationName];
    if (circuitBreaker != null) {
      circuitBreaker.reset();
      _logger.info(
        'Reset circuit breaker for $operationName',
        context: {'operation': operationName},
      );
    }
  }

  /// Reset all circuit breakers
  void resetAllCircuitBreakers() {
    for (final entry in _circuitBreakers.entries) {
      entry.value.reset();
    }
    _logger.info(
      'Reset all circuit breakers',
      context: {'count': _circuitBreakers.length},
    );
  }

  /// Get metrics for all circuit breakers
  Map<String, Map<String, dynamic>> getAllCircuitBreakerMetrics() => _circuitBreakers.map(
      (name, circuitBreaker) => MapEntry(name, circuitBreaker.getMetrics()),
    );

  /// Get health status of all operations
  Map<String, String> getHealthStatus() => _circuitBreakers.map(
      (name, circuitBreaker) => MapEntry(name, circuitBreaker.state.name),
    );

  /// Check if any circuit breakers are open
  bool hasOpenCircuitBreakers() => _circuitBreakers.values.any(
      (cb) => cb.state == CircuitBreakerState.open,
    );

  /// Get count of circuit breakers by state
  Map<CircuitBreakerState, int> getCircuitBreakerStateCounts() {
    final counts = <CircuitBreakerState, int>{
      CircuitBreakerState.closed: 0,
      CircuitBreakerState.open: 0,
      CircuitBreakerState.halfOpen: 0,
    };

    for (final circuitBreaker in _circuitBreakers.values) {
      counts[circuitBreaker.state] = (counts[circuitBreaker.state] ?? 0) + 1;
    }

    return counts;
  }

  /// Dispose of all circuit breakers
  void dispose() {
    _circuitBreakers.clear();
    _logger.info('Disposed resilience service');
  }
}

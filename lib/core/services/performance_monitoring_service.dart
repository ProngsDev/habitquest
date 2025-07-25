import 'dart:async';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import 'firebase_service.dart';

/// Service for monitoring app performance and user interactions
class PerformanceMonitoringService {
  factory PerformanceMonitoringService() => _instance;
  PerformanceMonitoringService._internal();
  static final PerformanceMonitoringService _instance =
      PerformanceMonitoringService._internal();

  final Logger _logger = Logger();
  final FirebaseService _firebaseService = FirebaseService();
  final Map<String, Trace> _activeTraces = {};
  final Map<String, DateTime> _operationStartTimes = {};

  /// Initialize performance monitoring
  Future<void> initialize() async {
    try {
      await _firebaseService.initialize();
      _logger.i('Performance monitoring service initialized');
    } on Exception catch (e) {
      _logger.e('Failed to initialize performance monitoring: $e');
    }
  }

  /// Start tracking a custom operation
  Future<void> startTrace(
    String traceName, {
    Map<String, String>? attributes,
  }) async {
    try {
      if (_activeTraces.containsKey(traceName)) {
        _logger.w('Trace $traceName is already active');
        return;
      }

      final trace = await _firebaseService.createTrace(traceName);

      // Add custom attributes
      if (attributes != null) {
        for (final entry in attributes.entries) {
          trace.putAttribute(entry.key, entry.value);
        }
      }

      await trace.start();
      _activeTraces[traceName] = trace;
      _operationStartTimes[traceName] = DateTime.now();

      if (kDebugMode) {
        _logger.d('Started trace: $traceName');
      }
    } on Exception catch (e) {
      _logger.e('Failed to start trace $traceName: $e');
    }
  }

  /// Stop tracking a custom operation
  Future<void> stopTrace(String traceName, {Map<String, int>? metrics}) async {
    try {
      final trace = _activeTraces.remove(traceName);
      final startTime = _operationStartTimes.remove(traceName);

      if (trace == null) {
        _logger.w('No active trace found for $traceName');
        return;
      }

      // Add custom metrics
      if (metrics != null) {
        for (final entry in metrics.entries) {
          trace.setMetric(entry.key, entry.value);
        }
      }

      // Add duration metric
      if (startTime != null) {
        final duration = DateTime.now().difference(startTime).inMilliseconds;
        trace.setMetric('duration_ms', duration);
      }

      await trace.stop();

      if (kDebugMode) {
        _logger.d('Stopped trace: $traceName');
      }
    } on Exception catch (e) {
      _logger.e('Failed to stop trace $traceName: $e');
    }
  }

  /// Track a habit operation (create, update, delete, complete)
  Future<void> trackHabitOperation(
    String operation,
    String habitId, {
    Map<String, String>? additionalAttributes,
  }) async {
    final traceName = 'habit_$operation';
    final attributes = {
      'habit_id': habitId,
      'operation': operation,
      ...?additionalAttributes,
    };

    await startTrace(traceName, attributes: attributes);
  }

  /// Complete tracking a habit operation
  Future<void> completeHabitOperation(
    String operation, {
    bool success = true,
    String? errorCode,
    Map<String, int>? additionalMetrics,
  }) async {
    final traceName = 'habit_$operation';
    final metrics = {'success': success ? 1 : 0, ...?additionalMetrics};

    // Add error information if operation failed
    if (!success && errorCode != null) {
      final trace = _activeTraces[traceName];
      trace?.putAttribute('error_code', errorCode);
    }

    await stopTrace(traceName, metrics: metrics);
  }

  /// Track navigation performance
  Future<void> trackNavigation(String fromScreen, String toScreen) async {
    final traceName = 'navigation_${fromScreen}_to_$toScreen';
    final attributes = {'from_screen': fromScreen, 'to_screen': toScreen};

    await startTrace(traceName, attributes: attributes);

    // Auto-stop navigation traces after a reasonable time
    Timer(const Duration(seconds: 5), () {
      stopTrace(traceName);
    });
  }

  /// Track app startup performance
  Future<void> trackAppStartup() async {
    await startTrace(
      'app_startup',
      attributes: {
        'app_version': '1.0.0', // This should come from package info
        'platform': defaultTargetPlatform.name,
      },
    );
  }

  /// Complete app startup tracking
  Future<void> completeAppStartup({bool success = true}) async {
    await stopTrace(
      'app_startup',
      metrics: {'startup_success': success ? 1 : 0},
    );
  }

  /// Track database operations
  Future<void> trackDatabaseOperation(
    String operation,
    String table, {
    int? recordCount,
  }) async {
    final traceName = 'db_${operation}_$table';
    final attributes = {'operation': operation, 'table': table};

    await startTrace(traceName, attributes: attributes);

    // Auto-complete database operations after timeout
    Timer(const Duration(seconds: 10), () {
      final metrics = <String, int>{};
      if (recordCount != null) {
        metrics['record_count'] = recordCount;
      }
      stopTrace(traceName, metrics: metrics);
    });
  }

  /// Track user engagement metrics
  void trackUserEngagement(String action, {Map<String, String>? properties}) {
    try {
      if (kDebugMode) {
        _logger.d('User engagement: $action with properties: $properties');
      }

      // In a real implementation, you might send this to analytics
      // For now, we'll just log it
    } on Exception catch (e) {
      _logger.e('Failed to track user engagement: $e');
    }
  }

  /// Track performance metrics for UI operations
  Future<void> trackUIOperation(
    String operation,
    Future<void> Function() task,
  ) async {
    final traceName = 'ui_$operation';

    await startTrace(
      traceName,
      attributes: {'operation_type': 'ui', 'operation': operation},
    );

    try {
      await task();
      await stopTrace(traceName, metrics: {'success': 1});
    } on Exception catch (e) {
      await stopTrace(traceName, metrics: {'success': 0});
      _logger.e('UI operation $operation failed: $e');
      rethrow;
    }
  }

  /// Track network requests
  HttpMetric trackNetworkRequest(String url, HttpMethod method) {
    try {
      return _firebaseService.createHttpMetric(url, method);
    } on Exception catch (e) {
      _logger.e('Failed to create HTTP metric for $url: $e');
      // Return a no-op metric
      return _NoOpHttpMetric();
    }
  }

  /// Get current performance metrics (for debugging)
  Map<String, dynamic> getCurrentMetrics() => {
      'active_traces': _activeTraces.keys.toList(),
      'operation_count': _operationStartTimes.length,
      'firebase_initialized': _firebaseService.isInitialized,
    };

  /// Clean up resources
  Future<void> dispose() async {
    // Stop all active traces
    final activeTraceNames = _activeTraces.keys.toList();
    for (final traceName in activeTraceNames) {
      await stopTrace(traceName);
    }

    _activeTraces.clear();
    _operationStartTimes.clear();

    _logger.i('Performance monitoring service disposed');
  }
}

/// No-op HTTP metric for fallback
class _NoOpHttpMetric implements HttpMetric {
  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  void putAttribute(String attributeName, String attributeValue) {}

  @override
  void removeAttribute(String attributeName) {}

  @override
  String getAttribute(String attributeName) => '';

  @override
  Map<String, String> getAttributes() => {};

  @override
  int? get httpResponseCode => null;

  @override
  set httpResponseCode(int? httpResponseCode) {}

  @override
  int? get requestPayloadSize => null;

  @override
  set requestPayloadSize(int? requestPayloadSize) {}

  @override
  String? get responseContentType => null;

  @override
  set responseContentType(String? responseContentType) {}

  @override
  int? get responsePayloadSize => null;

  @override
  set responsePayloadSize(int? responsePayloadSize) {}
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import 'performance_monitoring_service.dart';

/// Mixin for adding performance monitoring to any class
mixin PerformanceMonitoringMixin {
  final Logger _logger = Logger();
  final PerformanceMonitoringService _performanceService = 
      PerformanceMonitoringService();

  /// Wrap a method with performance monitoring
  Future<T> trackPerformance<T>(
    String operationName,
    Future<T> Function() operation, {
    Map<String, String>? attributes,
    Map<String, int>? customMetrics,
  }) async {
    final traceName = '${runtimeType.toString().toLowerCase()}_$operationName';
    
    try {
      // Start tracking
      await _performanceService.startTrace(traceName, attributes: attributes);
      
      final stopwatch = Stopwatch()..start();
      
      // Execute operation
      final result = await operation();
      
      stopwatch.stop();
      
      // Add execution time metric
      final metrics = {
        'execution_time_ms': stopwatch.elapsedMilliseconds,
        'success': 1,
        ...?customMetrics,
      };
      
      // Stop tracking with success
      await _performanceService.stopTrace(traceName, metrics: metrics);
      
      if (kDebugMode) {
        _logger.d('$traceName completed in ${stopwatch.elapsedMilliseconds}ms');
      }
      
      return result;
    } catch (error) {
      // Stop tracking with error
      await _performanceService.stopTrace(traceName, metrics: {
        'success': 0,
        'error': 1,
        ...?customMetrics,
      });
      
      _logger.e('$traceName failed: $error');
      rethrow;
    }
  }

  /// Track a synchronous operation
  T trackSyncPerformance<T>(
    String operationName,
    T Function() operation, {
    Map<String, String>? attributes,
    Map<String, int>? customMetrics,
  }) {
    final traceName = '${runtimeType.toString().toLowerCase()}_$operationName';
    
    try {
      final stopwatch = Stopwatch()..start();
      
      // Execute operation
      final result = operation();
      
      stopwatch.stop();
      
      // Log performance data (async tracking not suitable for sync operations)
      if (kDebugMode) {
        _logger.d('$traceName completed in ${stopwatch.elapsedMilliseconds}ms');
      }
      
      // Track user engagement for UI operations
      if (operationName.contains('ui') || operationName.contains('tap')) {
        _performanceService.trackUserEngagement(operationName, properties: {
          'duration_ms': stopwatch.elapsedMilliseconds.toString(),
          'component': runtimeType.toString(),
          ...?attributes,
        });
      }
      
      return result;
    } catch (error) {
      _logger.e('$traceName failed: $error');
      rethrow;
    }
  }

  /// Track database operations with specific metrics
  Future<T> trackDatabaseOperation<T>(
    String operation,
    String table,
    Future<T> Function() dbOperation, {
    int? recordCount,
    Map<String, String>? additionalAttributes,
  }) async {
    final attributes = {
      'operation': operation,
      'table': table,
      'record_count': recordCount?.toString() ?? 'unknown',
      ...?additionalAttributes,
    };

    return trackPerformance(
      'db_${operation}_$table',
      dbOperation,
      attributes: attributes,
      customMetrics: recordCount != null ? {'record_count': recordCount} : null,
    );
  }

  /// Track network operations
  Future<T> trackNetworkOperation<T>(
    String endpoint,
    String method,
    Future<T> Function() networkOperation, {
    Map<String, String>? additionalAttributes,
  }) async {
    final attributes = {
      'endpoint': endpoint,
      'method': method,
      ...?additionalAttributes,
    };

    return trackPerformance(
      'network_${method.toLowerCase()}_${endpoint.replaceAll('/', '_')}',
      networkOperation,
      attributes: attributes,
    );
  }
}

/// Performance wrapper for habit operations
class HabitPerformanceWrapper with PerformanceMonitoringMixin {
  /// Track habit creation performance
  Future<T> trackHabitCreation<T>(
    Future<T> Function() operation, {
    String? habitCategory,
    String? habitDifficulty,
  }) async => trackPerformance(
      'habit_create',
      operation,
      attributes: {
        'category': habitCategory ?? 'unknown',
        'difficulty': habitDifficulty ?? 'unknown',
      },
    );

  /// Track habit completion performance
  Future<T> trackHabitCompletion<T>(
    Future<T> Function() operation, {
    String? habitId,
    int? streakCount,
  }) async => trackPerformance(
      'habit_complete',
      operation,
      attributes: {
        'habit_id': habitId ?? 'unknown',
      },
      customMetrics: streakCount != null ? {'streak_count': streakCount} : null,
    );

  /// Track habit list loading performance
  Future<T> trackHabitListLoad<T>(
    Future<T> Function() operation, {
    int? habitCount,
  }) async => trackPerformance(
      'habit_list_load',
      operation,
      customMetrics: habitCount != null ? {'habit_count': habitCount} : null,
    );

  /// Track habit update performance
  Future<T> trackHabitUpdate<T>(
    Future<T> Function() operation, {
    String? habitId,
    List<String>? changedFields,
  }) async => trackPerformance(
      'habit_update',
      operation,
      attributes: {
        'habit_id': habitId ?? 'unknown',
        'changed_fields': changedFields?.join(',') ?? 'unknown',
      },
      customMetrics: {
        'changed_field_count': changedFields?.length ?? 0,
      },
    );

  /// Track habit deletion performance
  Future<T> trackHabitDeletion<T>(
    Future<T> Function() operation, {
    String? habitId,
    int? completionCount,
  }) async => trackPerformance(
      'habit_delete',
      operation,
      attributes: {
        'habit_id': habitId ?? 'unknown',
      },
      customMetrics: completionCount != null 
          ? {'completion_count': completionCount} 
          : null,
    );
}

/// Performance wrapper for UI operations
class UIPerformanceWrapper with PerformanceMonitoringMixin {
  /// Track screen navigation performance
  Future<T> trackScreenNavigation<T>(
    String fromScreen,
    String toScreen,
    Future<T> Function() operation,
  ) async => trackPerformance(
      'navigation_${fromScreen}_to_$toScreen',
      operation,
      attributes: {
        'from_screen': fromScreen,
        'to_screen': toScreen,
      },
    );

  /// Track widget build performance
  T trackWidgetBuild<T>(
    String widgetName,
    T Function() buildOperation,
  ) => trackSyncPerformance(
      'widget_build_$widgetName',
      buildOperation,
      attributes: {
        'widget': widgetName,
      },
    );

  /// Track animation performance
  Future<T> trackAnimation<T>(
    String animationName,
    Future<T> Function() animationOperation, {
    Duration? duration,
  }) async => trackPerformance(
      'animation_$animationName',
      animationOperation,
      attributes: {
        'animation': animationName,
        'duration_ms': duration?.inMilliseconds.toString() ?? 'unknown',
      },
      customMetrics: duration != null 
          ? {'animation_duration_ms': duration.inMilliseconds} 
          : null,
    );

  /// Track user interaction performance
  T trackUserInteraction<T>(
    String interactionType,
    T Function() interaction, {
    String? targetWidget,
  }) => trackSyncPerformance(
      'interaction_$interactionType',
      interaction,
      attributes: {
        'interaction_type': interactionType,
        'target_widget': targetWidget ?? 'unknown',
      },
    );
}

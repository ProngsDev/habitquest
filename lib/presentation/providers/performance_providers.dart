import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/performance_alerting_service.dart';
import '../../core/services/performance_monitoring_service.dart';

part 'performance_providers.g.dart';

/// Provider for the performance monitoring service
@Riverpod(keepAlive: true)
PerformanceMonitoringService performanceMonitoring(Ref ref) {
  final service = PerformanceMonitoringService()..initialize();

  // Dispose when the provider is disposed
  ref.onDispose(service.dispose);

  return service;
}

/// Provider for performance metrics (for debugging/monitoring)
@riverpod
Future<Map<String, dynamic>> performanceMetrics(Ref ref) async {
  final performanceService = ref.watch(performanceMonitoringProvider);
  return performanceService.getCurrentMetrics();
}

/// Provider for the performance alerting service
@Riverpod(keepAlive: true)
PerformanceAlertingService performanceAlerting(Ref ref) {
  final service = PerformanceAlertingService()..initialize();

  // Dispose when the provider is disposed
  ref.onDispose(service.dispose);

  return service;
}

/// Provider for performance alerts stream
@riverpod
Stream<PerformanceAlert> performanceAlerts(Ref ref) {
  final alertingService = ref.watch(performanceAlertingProvider);
  return alertingService.alertStream;
}

/// Provider for performance summary
@riverpod
PerformanceSummary performanceSummary(Ref ref) {
  final alertingService = ref.watch(performanceAlertingProvider);
  return alertingService.getPerformanceSummary();
}

/// Provider for tracking app lifecycle performance
@Riverpod(keepAlive: true)
class AppPerformanceTracker extends _$AppPerformanceTracker {
  @override
  bool build() {
    ref.watch(performanceMonitoringProvider).trackAppStartup();

    return true;
  }

  /// Mark app startup as complete
  void completeAppStartup({bool success = true}) {
    ref
        .read(performanceMonitoringProvider)
        .completeAppStartup(success: success);
  }

  /// Track navigation between screens
  void trackNavigation(String fromScreen, String toScreen) {
    ref
        .read(performanceMonitoringProvider)
        .trackNavigation(fromScreen, toScreen);
  }

  /// Track user engagement
  void trackUserEngagement(String action, {Map<String, String>? properties}) {
    ref
        .read(performanceMonitoringProvider)
        .trackUserEngagement(action, properties: properties);
  }
}

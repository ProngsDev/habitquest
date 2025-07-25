import 'package:flutter_test/flutter_test.dart';
import 'package:habitquest/core/services/performance_monitoring_service.dart';

void main() {
  group('PerformanceMonitoringService', () {
    late PerformanceMonitoringService service;

    setUp(() {
      service = PerformanceMonitoringService();
    });

    tearDown(() async {
      await service.dispose();
    });

    test('should initialize successfully', () async {
      await service.initialize();
      
      final metrics = service.getCurrentMetrics();
      expect(metrics, isA<Map<String, dynamic>>());
      expect(metrics.containsKey('active_traces'), isTrue);
      expect(metrics.containsKey('operation_count'), isTrue);
    });

    test('should track habit operations', () async {
      await service.initialize();
      
      await service.trackHabitOperation('create', 'test-habit-id');
      
      final metrics = service.getCurrentMetrics();
      final activeTraces = metrics['active_traces'] as List<String>;
      expect(activeTraces, contains('habit_create'));
      
      await service.completeHabitOperation('create');
      
      final updatedMetrics = service.getCurrentMetrics();
      final updatedTraces = updatedMetrics['active_traces'] as List<String>;
      expect(updatedTraces, isNot(contains('habit_create')));
    });

    test('should track navigation performance', () async {
      await service.initialize();
      
      await service.trackNavigation('home', 'habits');
      
      // Navigation tracking should auto-complete after timeout
      // For testing, we just verify it was started
      final metrics = service.getCurrentMetrics();
      expect(metrics, isA<Map<String, dynamic>>());
    });

    test('should track app startup', () async {
      await service.initialize();
      
      await service.trackAppStartup();
      
      final metrics = service.getCurrentMetrics();
      final activeTraces = metrics['active_traces'] as List<String>;
      expect(activeTraces, contains('app_startup'));
      
      await service.completeAppStartup();
      
      final updatedMetrics = service.getCurrentMetrics();
      final updatedTraces = updatedMetrics['active_traces'] as List<String>;
      expect(updatedTraces, isNot(contains('app_startup')));
    });

    test('should track database operations', () async {
      await service.initialize();
      
      await service.trackDatabaseOperation('select', 'habits', recordCount: 5);
      
      // Database operations auto-complete after timeout
      // For testing, we just verify the method doesn't throw
      final metrics = service.getCurrentMetrics();
      expect(metrics, isA<Map<String, dynamic>>());
    });

    test('should track user engagement', () {
      service.trackUserEngagement('habit_completed', properties: {
        'habit_id': 'test-habit',
        'streak': '5',
      });
      
      // User engagement tracking should not throw
      // In a real implementation, this would be verified through analytics
    });

    test('should handle errors gracefully', () async {
      // Test that the service handles errors without crashing
      await service.startTrace('test_trace');
      await service.stopTrace('non_existent_trace'); // Should not throw
      
      final metrics = service.getCurrentMetrics();
      expect(metrics, isA<Map<String, dynamic>>());
    });

    test('should clean up resources on dispose', () async {
      await service.initialize();
      
      await service.trackHabitOperation('create', 'test-habit');
      await service.trackAppStartup();
      
      final metricsBeforeDispose = service.getCurrentMetrics();
      final activeTraces = metricsBeforeDispose['active_traces'] as List<String>;
      expect(activeTraces.length, greaterThan(0));
      
      await service.dispose();
      
      final metricsAfterDispose = service.getCurrentMetrics();
      final tracesAfterDispose = metricsAfterDispose['active_traces'] as List<String>;
      expect(tracesAfterDispose, isEmpty);
    });
  });
}

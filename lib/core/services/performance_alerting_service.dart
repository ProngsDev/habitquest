import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import 'performance_monitoring_service.dart';

/// Service for monitoring performance metrics and triggering alerts
class PerformanceAlertingService {
  factory PerformanceAlertingService() => _instance;
  PerformanceAlertingService._internal();
  static final PerformanceAlertingService _instance =
      PerformanceAlertingService._internal();

  final Logger _logger = Logger();
  final PerformanceMonitoringService _performanceService =
      PerformanceMonitoringService();

  Timer? _monitoringTimer;
  final List<PerformanceAlert> _activeAlerts = [];
  final List<PerformanceThreshold> _thresholds = [];
  final StreamController<PerformanceAlert> _alertController =
      StreamController<PerformanceAlert>.broadcast();

  /// Stream of performance alerts
  Stream<PerformanceAlert> get alertStream => _alertController.stream;

  /// Initialize the alerting service
  void initialize() {
    _setupDefaultThresholds();
    _startMonitoring();
    _logger.i('Performance alerting service initialized');
  }

  /// Setup default performance thresholds
  void _setupDefaultThresholds() {
    _thresholds.addAll([
      // App startup performance
      const PerformanceThreshold(
        name: 'app_startup_time',
        metricName: 'app_startup',
        maxValue: 5000, // 5 seconds
        severity: AlertSeverity.warning,
        description: 'App startup time is too slow',
      ),

      // Habit operations
      const PerformanceThreshold(
        name: 'habit_creation_time',
        metricName: 'habit_create',
        maxValue: 2000, // 2 seconds
        severity: AlertSeverity.warning,
        description: 'Habit creation is taking too long',
      ),

      const PerformanceThreshold(
        name: 'habit_list_load_time',
        metricName: 'habit_list_load',
        maxValue: 1500, // 1.5 seconds
        severity: AlertSeverity.warning,
        description: 'Habit list loading is slow',
      ),

      // Navigation performance
      const PerformanceThreshold(
        name: 'navigation_time',
        metricName: 'navigation',
        maxValue: 1000, // 1 second
        severity: AlertSeverity.info,
        description: 'Screen navigation is slower than expected',
      ),

      // Memory usage (if available)
      const PerformanceThreshold(
        name: 'memory_usage',
        metricName: 'memory_usage_mb',
        maxValue: 200, // 200 MB
        severity: AlertSeverity.critical,
        description: 'High memory usage detected',
      ),

      // Database operations
      const PerformanceThreshold(
        name: 'database_operation_time',
        metricName: 'db_operation',
        maxValue: 1000, // 1 second
        severity: AlertSeverity.warning,
        description: 'Database operation is slow',
      ),
    ]);
  }

  /// Start monitoring performance metrics
  void _startMonitoring() {
    _monitoringTimer = Timer.periodic(
      const Duration(seconds: 30), // Check every 30 seconds
      (_) => _checkThresholds(),
    );
  }

  /// Check all thresholds against current metrics
  void _checkThresholds() {
    try {
      final currentMetrics = _performanceService.getCurrentMetrics();

      for (final threshold in _thresholds) {
        _checkThreshold(threshold, currentMetrics);
      }
    } on Exception catch (e) {
      _logger.e('Error checking performance thresholds: $e');
    }
  }

  /// Check a specific threshold
  void _checkThreshold(
    PerformanceThreshold threshold,
    Map<String, dynamic> metrics,
  ) {
    // This is a simplified check - in a real implementation,
    // you would have more sophisticated metric collection
    final metricValue = _extractMetricValue(threshold.metricName, metrics);

    if (metricValue != null && metricValue > threshold.maxValue) {
      _triggerAlert(threshold, metricValue);
    }
  }

  /// Extract metric value from metrics map
  double? _extractMetricValue(String metricName, Map<String, dynamic> metrics) {
    // This is a placeholder - real implementation would extract
    // actual performance metrics from Firebase Performance or custom tracking

    // For demo purposes, return some sample values
    switch (metricName) {
      case 'app_startup':
        return 3000; // 3 seconds
      case 'habit_create':
        return 800; // 800ms
      case 'habit_list_load':
        return 600; // 600ms
      case 'navigation':
        return 400; // 400ms
      case 'memory_usage_mb':
        return 150; // 150 MB
      case 'db_operation':
        return 300; // 300ms
      default:
        return null;
    }
  }

  /// Trigger a performance alert
  void _triggerAlert(PerformanceThreshold threshold, double actualValue) {
    final alert = PerformanceAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      threshold: threshold,
      actualValue: actualValue,
      timestamp: DateTime.now(),
    );

    // Check if we already have an active alert for this threshold
    final existingAlert = _activeAlerts.firstWhere(
      (a) => a.threshold.name == threshold.name,
      orElse: PerformanceAlert.empty,
    );

    if (existingAlert.id.isEmpty) {
      // New alert
      _activeAlerts.add(alert);
      _alertController.add(alert);

      _logger.w(
        'Performance alert triggered: ${threshold.name}',
        error: 'Threshold: ${threshold.maxValue}, Actual: $actualValue',
      );

      if (kDebugMode) {
        _showDebugAlert(alert);
      }
    }
  }

  /// Show debug alert in development
  void _showDebugAlert(PerformanceAlert alert) {
    if (kDebugMode) {
      print('🚨 PERFORMANCE ALERT 🚨');
      print('Alert: ${alert.threshold.description}');
      print('Threshold: ${alert.threshold.maxValue}');
      print('Actual: ${alert.actualValue}');
      print('Severity: ${alert.threshold.severity.name}');
      print('Time: ${alert.timestamp}');
      print('─' * 40);
    }
  }

  /// Add custom threshold
  void addThreshold(PerformanceThreshold threshold) {
    _thresholds.add(threshold);
    _logger.i('Added performance threshold: ${threshold.name}');
  }

  /// Remove threshold
  void removeThreshold(String name) {
    _thresholds.removeWhere((t) => t.name == name);
    _logger.i('Removed performance threshold: $name');
  }

  /// Get active alerts
  List<PerformanceAlert> getActiveAlerts() => List.unmodifiable(_activeAlerts);

  /// Clear alert
  void clearAlert(String alertId) {
    _activeAlerts.removeWhere((alert) => alert.id == alertId);
    _logger.i('Cleared performance alert: $alertId');
  }

  /// Clear all alerts
  void clearAllAlerts() {
    _activeAlerts.clear();
    _logger.i('Cleared all performance alerts');
  }

  /// Get performance summary
  PerformanceSummary getPerformanceSummary() => PerformanceSummary(
    activeAlerts: _activeAlerts.length,
    totalThresholds: _thresholds.length,
    criticalAlerts: _activeAlerts
        .where((a) => a.threshold.severity == AlertSeverity.critical)
        .length,
    warningAlerts: _activeAlerts
        .where((a) => a.threshold.severity == AlertSeverity.warning)
        .length,
    lastCheckTime: DateTime.now(),
    overallHealth: _calculateOverallHealth(),
  );

  /// Calculate overall performance health
  PerformanceHealth _calculateOverallHealth() {
    if (_activeAlerts.any(
      (a) => a.threshold.severity == AlertSeverity.critical,
    )) {
      return PerformanceHealth.critical;
    } else if (_activeAlerts.any(
      (a) => a.threshold.severity == AlertSeverity.warning,
    )) {
      return PerformanceHealth.warning;
    } else if (_activeAlerts.any(
      (a) => a.threshold.severity == AlertSeverity.info,
    )) {
      return PerformanceHealth.info;
    } else {
      return PerformanceHealth.good;
    }
  }

  /// Dispose resources
  void dispose() {
    _monitoringTimer?.cancel();
    _alertController.close();
    _activeAlerts.clear();
    _thresholds.clear();
    _logger.i('Performance alerting service disposed');
  }
}

/// Performance threshold configuration
class PerformanceThreshold {
  const PerformanceThreshold({
    required this.name,
    required this.metricName,
    required this.maxValue,
    required this.severity,
    required this.description,
  });

  final String name;
  final String metricName;
  final double maxValue;
  final AlertSeverity severity;
  final String description;
}

/// Performance alert
class PerformanceAlert {
  const PerformanceAlert({
    required this.id,
    required this.threshold,
    required this.actualValue,
    required this.timestamp,
  });

  factory PerformanceAlert.empty() => PerformanceAlert(
    id: '',
    threshold: const PerformanceThreshold(
      name: '',
      metricName: '',
      maxValue: 0,
      severity: AlertSeverity.info,
      description: '',
    ),
    actualValue: 0,
    timestamp: DateTime.now(),
  );

  final String id;
  final PerformanceThreshold threshold;
  final double actualValue;
  final DateTime timestamp;
}

/// Alert severity levels
enum AlertSeverity { info, warning, critical }

/// Performance health status
enum PerformanceHealth { good, info, warning, critical }

/// Performance summary
class PerformanceSummary {
  const PerformanceSummary({
    required this.activeAlerts,
    required this.totalThresholds,
    required this.criticalAlerts,
    required this.warningAlerts,
    required this.lastCheckTime,
    required this.overallHealth,
  });

  final int activeAlerts;
  final int totalThresholds;
  final int criticalAlerts;
  final int warningAlerts;
  final DateTime lastCheckTime;
  final PerformanceHealth overallHealth;
}

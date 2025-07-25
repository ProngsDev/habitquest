// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$performanceMonitoringHash() =>
    r'dcef2b1bec3780c672997b2c25d47eb65080ab2c';

/// Provider for the performance monitoring service
///
/// Copied from [performanceMonitoring].
@ProviderFor(performanceMonitoring)
final performanceMonitoringProvider =
    Provider<PerformanceMonitoringService>.internal(
  performanceMonitoring,
  name: r'performanceMonitoringProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$performanceMonitoringHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PerformanceMonitoringRef = ProviderRef<PerformanceMonitoringService>;
String _$performanceMetricsHash() =>
    r'f99d17b89d0c56a96c51c3b7d038d8c5dcb844e8';

/// Provider for performance metrics (for debugging/monitoring)
///
/// Copied from [performanceMetrics].
@ProviderFor(performanceMetrics)
final performanceMetricsProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>>.internal(
  performanceMetrics,
  name: r'performanceMetricsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$performanceMetricsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PerformanceMetricsRef
    = AutoDisposeFutureProviderRef<Map<String, dynamic>>;
String _$performanceAlertingHash() =>
    r'ae85e01071a26ba7e231ad9fba0886323589d7e7';

/// Provider for the performance alerting service
///
/// Copied from [performanceAlerting].
@ProviderFor(performanceAlerting)
final performanceAlertingProvider =
    Provider<PerformanceAlertingService>.internal(
  performanceAlerting,
  name: r'performanceAlertingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$performanceAlertingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PerformanceAlertingRef = ProviderRef<PerformanceAlertingService>;
String _$performanceAlertsHash() => r'211220e44ae8353be47b788beb581302447f4272';

/// Provider for performance alerts stream
///
/// Copied from [performanceAlerts].
@ProviderFor(performanceAlerts)
final performanceAlertsProvider =
    AutoDisposeStreamProvider<PerformanceAlert>.internal(
  performanceAlerts,
  name: r'performanceAlertsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$performanceAlertsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PerformanceAlertsRef = AutoDisposeStreamProviderRef<PerformanceAlert>;
String _$performanceSummaryHash() =>
    r'c04ee04379fb328719e116d9ac4d8921fe350ed1';

/// Provider for performance summary
///
/// Copied from [performanceSummary].
@ProviderFor(performanceSummary)
final performanceSummaryProvider =
    AutoDisposeProvider<PerformanceSummary>.internal(
  performanceSummary,
  name: r'performanceSummaryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$performanceSummaryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PerformanceSummaryRef = AutoDisposeProviderRef<PerformanceSummary>;
String _$appPerformanceTrackerHash() =>
    r'671eb1febfc76ec360619f1c89486711b179835d';

/// Provider for tracking app lifecycle performance
///
/// Copied from [AppPerformanceTracker].
@ProviderFor(AppPerformanceTracker)
final appPerformanceTrackerProvider =
    NotifierProvider<AppPerformanceTracker, bool>.internal(
  AppPerformanceTracker.new,
  name: r'appPerformanceTrackerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appPerformanceTrackerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppPerformanceTracker = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

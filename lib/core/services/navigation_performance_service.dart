import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';

import 'performance_monitoring_service.dart';

/// Service for tracking navigation performance
class NavigationPerformanceService {
  factory NavigationPerformanceService() => _instance;
  NavigationPerformanceService._internal();
  static final NavigationPerformanceService _instance =
      NavigationPerformanceService._internal();

  final Logger _logger = Logger();
  final PerformanceMonitoringService _performanceService =
      PerformanceMonitoringService();

  String? _currentScreen;
  final Map<String, DateTime> _screenStartTimes = {};
  final Map<String, int> _screenVisitCounts = {};

  /// Track navigation to a new screen
  Future<void> trackNavigation({
    required String fromScreen,
    required String toScreen,
    Map<String, String>? additionalData,
  }) async {
    try {
      // End tracking for previous screen
      if (_currentScreen != null) {
        await _endScreenTracking(_currentScreen!);
      }

      // Start tracking for new screen
      await _startScreenTracking(toScreen);

      // Track the navigation event
      await _performanceService.trackNavigation(fromScreen, toScreen);

      // Update current screen
      _currentScreen = toScreen;

      _logger.d('Navigation tracked: $fromScreen -> $toScreen');
    } on Exception catch (e) {
      _logger.e('Failed to track navigation: $e');
    }
  }

  /// Start tracking time spent on a screen
  Future<void> _startScreenTracking(String screenName) async {
    _screenStartTimes[screenName] = DateTime.now();
    _screenVisitCounts[screenName] = (_screenVisitCounts[screenName] ?? 0) + 1;

    await _performanceService.startTrace(
      'screen_time_$screenName',
      attributes: {
        'screen': screenName,
        'visit_count': _screenVisitCounts[screenName].toString(),
      },
    );
  }

  /// End tracking time spent on a screen
  Future<void> _endScreenTracking(String screenName) async {
    final startTime = _screenStartTimes.remove(screenName);
    if (startTime != null) {
      final timeSpent = DateTime.now().difference(startTime);

      await _performanceService.stopTrace(
        'screen_time_$screenName',
        metrics: {
          'time_spent_ms': timeSpent.inMilliseconds,
          'time_spent_seconds': timeSpent.inSeconds,
        },
      );

      _logger.d('Screen time tracked: $screenName - ${timeSpent.inSeconds}s');
    }
  }

  /// Track route change
  void trackRouteChange(
    Route<dynamic>? previousRoute,
    Route<dynamic>? newRoute,
  ) {
    if (newRoute?.settings.name != null &&
        previousRoute?.settings.name != null) {
      trackNavigation(
        fromScreen: previousRoute!.settings.name!,
        toScreen: newRoute!.settings.name!,
      );
    }
  }

  /// Track back navigation
  Future<void> trackBackNavigation(String fromScreen, String toScreen) async {
    await trackNavigation(
      fromScreen: fromScreen,
      toScreen: toScreen,
      additionalData: {'navigation_type': 'back'},
    );
  }

  /// Track deep link navigation
  Future<void> trackDeepLinkNavigation(
    String deepLink,
    String targetScreen,
  ) async {
    await _performanceService.startTrace(
      'deep_link_navigation',
      attributes: {'deep_link': deepLink, 'target_screen': targetScreen},
    );

    // Auto-complete after a reasonable time
    Future.delayed(const Duration(seconds: 5), () {
      _performanceService.stopTrace('deep_link_navigation');
    });
  }

  /// Track tab navigation
  Future<void> trackTabNavigation(
    int fromIndex,
    int toIndex,
    String tabName,
  ) async {
    await _performanceService.startTrace(
      'tab_navigation',
      attributes: {
        'from_tab_index': fromIndex.toString(),
        'to_tab_index': toIndex.toString(),
        'tab_name': tabName,
      },
    );

    // Auto-complete tab navigation tracking
    Future.delayed(const Duration(seconds: 2), () {
      _performanceService.stopTrace('tab_navigation');
    });
  }

  /// Get navigation analytics
  Map<String, dynamic> getNavigationAnalytics() => {
    'current_screen': _currentScreen,
    'screen_visit_counts': Map<String, int>.from(_screenVisitCounts),
    'active_screen_sessions': _screenStartTimes.keys.toList(),
  };

  /// Get most visited screens
  List<MapEntry<String, int>> getMostVisitedScreens({int limit = 5}) {
    final sortedEntries = _screenVisitCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.take(limit).toList();
  }

  /// Reset navigation tracking data
  void reset() {
    _currentScreen = null;
    _screenStartTimes.clear();
    _screenVisitCounts.clear();
    _logger.i('Navigation tracking data reset');
  }

  /// Dispose resources
  Future<void> dispose() async {
    // End tracking for current screen if any
    if (_currentScreen != null) {
      await _endScreenTracking(_currentScreen!);
    }

    reset();
    _logger.i('Navigation performance service disposed');
  }
}

/// Navigation observer that automatically tracks navigation performance
class PerformanceNavigatorObserver extends NavigatorObserver {
  final NavigationPerformanceService _navigationService =
      NavigationPerformanceService();
  final Logger _logger = Logger();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackRouteChange(previousRoute, route, 'push');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _trackRouteChange(route, previousRoute, 'pop');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _trackRouteChange(oldRoute, newRoute, 'replace');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _trackRouteChange(route, previousRoute, 'remove');
  }

  void _trackRouteChange(
    Route<dynamic>? fromRoute,
    Route<dynamic>? toRoute,
    String navigationType,
  ) {
    try {
      final fromScreen = fromRoute?.settings.name ?? 'unknown';
      final toScreen = toRoute?.settings.name ?? 'unknown';

      if (fromScreen != 'unknown' && toScreen != 'unknown') {
        _navigationService.trackNavigation(
          fromScreen: fromScreen,
          toScreen: toScreen,
          additionalData: {'navigation_type': navigationType},
        );
      }
    } on Exception catch (e) {
      _logger.e('Failed to track route change: $e');
    }
  }
}

/// Extension for easy navigation tracking
extension NavigationPerformanceExtension on NavigatorState {
  /// Push with performance tracking
  Future<T?> pushWithTracking<T extends Object?>(
    Route<T> route, {
    String? fromScreen,
  }) async {
    final navigationService = NavigationPerformanceService();

    final from = fromScreen ?? 'unknown';
    final to = route.settings.name ?? 'unknown';

    await navigationService.trackNavigation(fromScreen: from, toScreen: to);

    return push(route);
  }

  /// Push named with performance tracking
  Future<T?> pushNamedWithTracking<T extends Object?>(
    String routeName, {
    Object? arguments,
    String? fromScreen,
  }) async {
    final navigationService = NavigationPerformanceService();

    await navigationService.trackNavigation(
      fromScreen: fromScreen ?? 'unknown',
      toScreen: routeName,
    );

    return pushNamed(routeName, arguments: arguments);
  }

  /// Pop with performance tracking
  void popWithTracking<T extends Object?>([T? result, String? toScreen]) {
    final navigationService = NavigationPerformanceService();

    if (toScreen != null) {
      navigationService.trackBackNavigation('current', toScreen);
    }

    pop(result);
  }
}

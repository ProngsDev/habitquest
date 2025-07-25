import 'package:patrol/patrol.dart';

/// Configuration for Patrol integration tests
class PatrolConfig {
  static const PatrolTesterConfig defaultConfig = PatrolTesterConfig(
    settleTimeout: Duration(seconds: 5),

    // Enable verbose logging for debugging
    printLogs: true,
  );

  /// Custom configuration for habit-specific tests
  static const PatrolTesterConfig habitTestConfig = PatrolTesterConfig(
    visibleTimeout: Duration(
      seconds: 15,
    ), // Longer timeout for habit operations
    existsTimeout: Duration(seconds: 15),
    settleTimeout: Duration(seconds: 8),
    printLogs: true,
  );

  /// Configuration for performance-sensitive tests
  static const PatrolTesterConfig performanceTestConfig = PatrolTesterConfig(
    visibleTimeout: Duration(seconds: 5),
    existsTimeout: Duration(seconds: 5),
    settleTimeout: Duration(seconds: 2),
  );

  /// Native automator configuration for default tests
  static const NativeAutomatorConfig defaultNativeConfig =
      NativeAutomatorConfig(
        // Native automation is enabled by default in Patrol 3.x
      );

  /// Native automator configuration for performance tests
  static const NativeAutomatorConfig performanceNativeConfig =
      NativeAutomatorConfig(
        // Minimal configuration for performance tests
      );
}

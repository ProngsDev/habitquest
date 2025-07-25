import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitquest/main.dart' as app;
import 'package:integration_test/integration_test.dart';

import 'test_config.dart';

/// Utility class for common integration test operations
class IntegrationTestUtils {
  static const Duration defaultTimeout = Duration(seconds: 10);
  static const Duration shortTimeout = Duration(seconds: 3);
  static const Duration longTimeout = Duration(seconds: 15);

  /// Initialize the app for testing
  static Future<void> initializeApp(WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Wait for splash screen to complete
    await Future<void>.delayed(shortTimeout);
    await tester.pumpAndSettle();
  }

  /// Wait for an element to appear with timeout
  static Future<bool> waitForElement(
    WidgetTester tester,
    Finder finder, {
    Duration? timeout,
  }) async {
    final actualTimeout = timeout ?? defaultTimeout;
    final endTime = DateTime.now().add(actualTimeout);

    while (DateTime.now().isBefore(endTime)) {
      await tester.pumpAndSettle();

      if (tester.any(finder)) {
        return true;
      }

      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    return false;
  }

  /// Safely tap an element if it exists
  static Future<bool> safeTap(
    WidgetTester tester,
    Finder finder, {
    Duration? timeout,
  }) async {
    if (await waitForElement(tester, finder, timeout: timeout)) {
      await tester.tap(finder);
      await tester.pumpAndSettle();
      return true;
    }
    return false;
  }

  /// Safely enter text in a field if it exists
  static Future<bool> safeEnterText(
    WidgetTester tester,
    Finder finder,
    String text, {
    Duration? timeout,
  }) async {
    if (await waitForElement(tester, finder, timeout: timeout)) {
      await tester.tap(finder);
      await tester.pumpAndSettle();
      await tester.enterText(finder, text);
      await tester.pumpAndSettle();
      return true;
    }
    return false;
  }

  /// Navigate to a specific screen by tab name
  static Future<bool> navigateToTab(WidgetTester tester, String tabName) async {
    // Look for tab by text
    final tabFinder = find.text(tabName);
    if (await safeTap(tester, tabFinder)) {
      return true;
    }

    // Look for tab bar and try to find the tab
    final tabBar = find.byType(CupertinoTabBar);
    if (tester.any(tabBar)) {
      // Try to find tab by icon or other means
      // This would need to be customized based on actual tab implementation
      return false;
    }

    return false;
  }

  /// Check if we're on a specific screen by looking for screen indicators
  static bool isOnScreen(WidgetTester tester, String screenName) {
    final indicators =
        IntegrationTestConfig.screenIdentifiers[screenName.toLowerCase()];
    if (indicators == null) return false;

    for (final indicator in indicators) {
      if (tester.any(find.text(indicator))) {
        return true;
      }
    }
    return false;
  }

  /// Create a test habit with given data
  static Future<bool> createHabit(
    WidgetTester tester,
    Map<String, String> habitData,
  ) async {
    // Navigate to habits screen first
    if (!isOnScreen(tester, 'habits')) {
      if (!await navigateToTab(tester, 'Habits')) {
        return false;
      }
    }

    // Tap add button
    final addButton = find.text(
      IntegrationTestConfig.commonElements['addButton']!,
    );
    if (!await safeTap(tester, addButton)) {
      return false;
    }

    // Fill form fields
    if (!await _fillHabitForm(tester, habitData)) {
      return false;
    }

    // Save habit
    final saveButton = find.text(
      IntegrationTestConfig.commonElements['saveButton']!,
    );
    if (!await safeTap(tester, saveButton, timeout: longTimeout)) {
      return false;
    }

    // Verify habit was created
    return waitForElement(
      tester,
      find.text(habitData['name']!),
      timeout: longTimeout,
    );
  }

  /// Fill habit form with provided data
  static Future<bool> _fillHabitForm(
    WidgetTester tester,
    Map<String, String> habitData,
  ) async {
    // Fill name field
    final nameField = find.byWidgetPredicate(
      (widget) =>
          widget is CupertinoTextField &&
          (widget.placeholder?.toLowerCase().contains('name') ?? false),
    );

    if (!await safeEnterText(tester, nameField, habitData['name']!)) {
      return false;
    }

    // Fill description field
    final descField = find.byWidgetPredicate(
      (widget) =>
          widget is CupertinoTextField &&
          (widget.placeholder?.toLowerCase().contains('description') ?? false),
    );

    if (tester.any(descField)) {
      await safeEnterText(tester, descField, habitData['description']!);
    }

    // Select category, difficulty, frequency if available
    for (final field in ['category', 'difficulty', 'frequency']) {
      final value = habitData[field];
      if (value != null) {
        final selector = find.text(value);
        await safeTap(tester, selector, timeout: shortTimeout);
      }
    }

    return true;
  }

  /// Complete a habit by name
  static Future<bool> completeHabit(
    WidgetTester tester,
    String habitName,
  ) async {
    // Find the habit
    if (!await waitForElement(tester, find.text(habitName))) {
      return false;
    }

    // Look for completion button near the habit
    // This would need to be customized based on actual UI implementation
    final completionButton = find.byIcon(CupertinoIcons.circle);

    if (await safeTap(tester, completionButton)) {
      // Wait for completion animation/state change
      await tester.pumpAndSettle();
      await Future<void>.delayed(shortTimeout);
      return true;
    }

    return false;
  }

  /// Verify habit completion state
  static bool isHabitCompleted(WidgetTester tester, String habitName) {
    // Look for completion indicators
    final completionIndicators = [
      find.byIcon(CupertinoIcons.checkmark_circle_fill),
      find.byIcon(CupertinoIcons.checkmark),
    ];

    for (final indicator in completionIndicators) {
      if (tester.any(indicator)) {
        return true;
      }
    }

    return false;
  }

  /// Take a screenshot for debugging
  static Future<void> takeScreenshot(WidgetTester tester, String name) async {
    if (IntegrationTestConfig.screenshotOnFailure) {
      final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
      await binding.convertFlutterSurfaceToImage();
      // Screenshot will be automatically saved by integration test framework
    }
  }

  /// Find element using multiple finders (OR logic)
  static Future<Finder?> findAny(
    WidgetTester tester,
    List<Finder> finders, {
    Duration timeout = defaultTimeout,
  }) async {
    for (final finder in finders) {
      if (await waitForElement(
        tester,
        finder,
        timeout: const Duration(milliseconds: 500),
      )) {
        return finder;
      }
    }
    return null;
  }

  /// Safely tap any of multiple possible elements
  static Future<bool> safeTapAny(
    WidgetTester tester,
    List<Finder> finders, {
    Duration timeout = defaultTimeout,
  }) async {
    final finder = await findAny(tester, finders, timeout: timeout);
    if (finder != null) {
      await tester.tap(finder);
      await tester.pumpAndSettle();
      return true;
    }
    return false;
  }

  /// Log test information
  static void log(String message) {
    if (IntegrationTestConfig.verboseLogging) {
      debugPrint('[IntegrationTest] $message');
    }
  }
}

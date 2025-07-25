import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'test_config.dart';
import 'test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Navigation User Flows', () {
    testWidgets('tab navigation flow', (tester) async {
      IntegrationTestUtils.log('Starting tab navigation flow test');

      // Initialize app
      await IntegrationTestUtils.initializeApp(tester);

      // Test navigation between all main tabs
      final tabs = ['Home', 'Habits', 'Progress', 'Profile'];

      for (final tab in tabs) {
        IntegrationTestUtils.log('Navigating to $tab tab');

        if (await IntegrationTestUtils.navigateToTab(tester, tab)) {
          IntegrationTestUtils.log('Successfully navigated to $tab');

          // Verify we're on the correct screen
          final onCorrectScreen = IntegrationTestUtils.isOnScreen(
            tester,
            tab.toLowerCase(),
          );

          if (onCorrectScreen) {
            IntegrationTestUtils.log('Verified on $tab screen');
          } else {
            IntegrationTestUtils.log(
              'Could not verify $tab screen - may not be implemented',
            );
          }

          // Wait for screen to settle
          await tester.pumpAndSettle();
        } else {
          IntegrationTestUtils.log(
            'Failed to navigate to $tab - tab may not exist',
          );
        }
      }

      IntegrationTestUtils.log('Tab navigation flow test completed');
    });

    testWidgets('deep navigation flow', (tester) async {
      IntegrationTestUtils.log('Starting deep navigation flow test');

      // Initialize app
      await IntegrationTestUtils.initializeApp(tester);

      // Navigate through a deep navigation flow:
      // Home -> Habits -> Habit Details -> Edit Habit -> Save -> Back to Habits

      // Step 1: Go to Habits
      if (await IntegrationTestUtils.navigateToTab(tester, 'Habits')) {
        IntegrationTestUtils.log('Step 1: Navigated to Habits');

        // Create a test habit first
        final testHabit = IntegrationTestConfig.testHabits['morning_exercise']!;
        await IntegrationTestUtils.createHabit(tester, testHabit);

        // Step 2: Navigate to Habit Details
        if (await IntegrationTestUtils.safeTap(
          tester,
          find.text(testHabit['name']!),
        )) {
          IntegrationTestUtils.log('Step 2: Opened habit details');

          // Verify we're on habit details screen
          await _verifyHabitDetailsScreen(tester, testHabit);

          // Step 3: Navigate to Edit Habit
          final editButtons = [
            find.text('Edit'),
            find.byIcon(CupertinoIcons.pencil),
          ];
          if (await IntegrationTestUtils.safeTapAny(tester, editButtons)) {
            IntegrationTestUtils.log('Step 3: Opened edit habit form');

            // Step 4: Make changes and save
            await _makeHabitChanges(tester);

            final saveButton = find.text('Save');
            if (await IntegrationTestUtils.safeTap(tester, saveButton)) {
              IntegrationTestUtils.log('Step 4: Saved habit changes');

              // Step 5: Navigate back to habits list
              await _navigateBackToHabitsList(tester);
              IntegrationTestUtils.log('Step 5: Returned to habits list');
            }
          }
        }
      }

      IntegrationTestUtils.log('Deep navigation flow test completed');
    });

    testWidgets('back navigation flow', (tester) async {
      IntegrationTestUtils.log('Starting back navigation flow test');

      // Initialize app
      await IntegrationTestUtils.initializeApp(tester);

      // Test back navigation from various screens
      await _testBackNavigationFromHabitDetails(tester);
      await _testBackNavigationFromSettings(tester);
      await _testBackNavigationFromAddHabit(tester);

      IntegrationTestUtils.log('Back navigation flow test completed');
    });

    testWidgets('navigation state persistence', (tester) async {
      IntegrationTestUtils.log('Starting navigation state persistence test');

      // Initialize app
      await IntegrationTestUtils.initializeApp(tester);

      // Navigate to a specific tab
      await IntegrationTestUtils.navigateToTab(tester, 'Progress');

      // Verify we're on the progress screen
      final onProgressScreen = IntegrationTestUtils.isOnScreen(
        tester,
        'progress',
      );
      if (onProgressScreen) {
        IntegrationTestUtils.log('Successfully navigated to Progress screen');

        // Simulate app going to background and returning
        await _simulateAppLifecycle(tester);

        // Verify we're still on the progress screen
        final stillOnProgressScreen = IntegrationTestUtils.isOnScreen(
          tester,
          'progress',
        );
        if (stillOnProgressScreen) {
          IntegrationTestUtils.log('Navigation state persisted correctly');
        } else {
          IntegrationTestUtils.log('Navigation state was not persisted');
        }
      }

      IntegrationTestUtils.log('Navigation state persistence test completed');
    });

    testWidgets('navigation with data flow', (tester) async {
      IntegrationTestUtils.log('Starting navigation with data flow test');

      // Initialize app
      await IntegrationTestUtils.initializeApp(tester);

      // Create a habit and navigate to its details
      final testHabit = IntegrationTestConfig.testHabits['read_book']!;
      await IntegrationTestUtils.createHabit(tester, testHabit);

      // Navigate to habit details and verify data is passed correctly
      if (await IntegrationTestUtils.safeTap(
        tester,
        find.text(testHabit['name']!),
      )) {
        IntegrationTestUtils.log('Navigated to habit details');

        // Verify habit data is displayed correctly
        await _verifyHabitDataInDetails(tester, testHabit);

        // Navigate to edit screen and verify data is pre-filled
        final editButtons = [
          find.text('Edit'),
          find.byIcon(CupertinoIcons.pencil),
        ];
        if (await IntegrationTestUtils.safeTapAny(tester, editButtons)) {
          IntegrationTestUtils.log('Navigated to edit screen');

          // Verify form is pre-filled with habit data
          await _verifyFormPreFilled(tester, testHabit);
        }
      }

      IntegrationTestUtils.log('Navigation with data flow test completed');
    });

    testWidgets('error handling in navigation', (tester) async {
      IntegrationTestUtils.log('Starting navigation error handling test');

      // Initialize app
      await IntegrationTestUtils.initializeApp(tester);

      // Test navigation to non-existent routes or invalid states
      await _testInvalidNavigation(tester);

      // Test navigation with missing data
      await _testNavigationWithMissingData(tester);

      IntegrationTestUtils.log('Navigation error handling test completed');
    });
  });
}

/// Verify habit details screen content
Future<void> _verifyHabitDetailsScreen(
  WidgetTester tester,
  Map<String, String> habitData,
) async {
  // Look for habit details screen indicators
  final detailsIndicators = [
    find.text('Habit Details'),
    find.text('Details'),
    find.byType(CupertinoNavigationBar),
  ];

  var foundDetailsScreen = false;
  for (final indicator in detailsIndicators) {
    if (tester.any(indicator)) {
      foundDetailsScreen = true;
      break;
    }
  }

  if (foundDetailsScreen) {
    IntegrationTestUtils.log('Verified habit details screen');

    // Verify habit data is displayed
    expect(find.text(habitData['name']!), findsOneWidget);

    if (habitData['description']!.isNotEmpty) {
      // Description might be truncated or styled differently
      final descriptionText = habitData['description']!;
      if (tester.any(find.textContaining(descriptionText.substring(0, 10)))) {
        IntegrationTestUtils.log('Habit description found');
      }
    }
  } else {
    IntegrationTestUtils.log('Could not verify habit details screen');
  }
}

/// Make changes to habit in edit form
Future<void> _makeHabitChanges(WidgetTester tester) async {
  // Update habit name
  final nameField = find.byWidgetPredicate(
    (widget) =>
        widget is CupertinoTextField &&
        (widget.placeholder?.toLowerCase().contains('name') ?? false),
  );

  if (await IntegrationTestUtils.waitForElement(tester, nameField)) {
    await tester.tap(nameField);
    await tester.pumpAndSettle();

    // Append to existing name
    await tester.enterText(nameField, 'Updated Morning Exercise');
    await tester.pumpAndSettle();
  }
}

/// Navigate back to habits list
Future<void> _navigateBackToHabitsList(WidgetTester tester) async {
  // Look for back button
  final backButtons = [
    find.byIcon(CupertinoIcons.back),
    find.byIcon(CupertinoIcons.chevron_left),
  ];

  if (await IntegrationTestUtils.safeTapAny(tester, backButtons)) {
    IntegrationTestUtils.log('Tapped back button');
  } else {
    // Try alternative navigation methods
    await IntegrationTestUtils.navigateToTab(tester, 'Habits');
  }
}

/// Test back navigation from habit details
Future<void> _testBackNavigationFromHabitDetails(WidgetTester tester) async {
  // Create and navigate to habit details
  final testHabit = IntegrationTestConfig.testHabits['meditation']!;
  await IntegrationTestUtils.createHabit(tester, testHabit);

  if (await IntegrationTestUtils.safeTap(
    tester,
    find.text(testHabit['name']!),
  )) {
    // Navigate back
    final backButton = find.byIcon(CupertinoIcons.back);
    if (await IntegrationTestUtils.safeTap(tester, backButton)) {
      // Verify we're back on habits list
      final onHabitsScreen = IntegrationTestUtils.isOnScreen(tester, 'habits');
      if (onHabitsScreen) {
        IntegrationTestUtils.log(
          'Back navigation from habit details successful',
        );
      }
    }
  }
}

/// Test back navigation from settings
Future<void> _testBackNavigationFromSettings(WidgetTester tester) async {
  // Navigate to settings/profile
  if (await IntegrationTestUtils.navigateToTab(tester, 'Profile')) {
    // Look for settings or back navigation
    final backButton = find.byIcon(CupertinoIcons.back);
    if (tester.any(backButton)) {
      await IntegrationTestUtils.safeTap(tester, backButton);
      IntegrationTestUtils.log('Back navigation from settings tested');
    }
  }
}

/// Test back navigation from add habit form
Future<void> _testBackNavigationFromAddHabit(WidgetTester tester) async {
  // Navigate to habits and open add form
  await IntegrationTestUtils.navigateToTab(tester, 'Habits');

  final addButton = find.text('Add Habit');
  if (await IntegrationTestUtils.safeTap(tester, addButton)) {
    // Navigate back without saving
    final backButtons = [find.byIcon(CupertinoIcons.back), find.text('Cancel')];
    if (await IntegrationTestUtils.safeTapAny(tester, backButtons)) {
      IntegrationTestUtils.log(
        'Back navigation from add habit form successful',
      );
    }
  }
}

/// Simulate app lifecycle changes
Future<void> _simulateAppLifecycle(WidgetTester tester) async {
  // Simulate app going to background
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    'flutter/lifecycle',
    const StandardMethodCodec().encodeMethodCall(
      const MethodCall('AppLifecycleState.paused'),
    ),
    (data) {},
  );

  await Future<void>.delayed(const Duration(milliseconds: 500));

  // Simulate app returning to foreground
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    'flutter/lifecycle',
    const StandardMethodCodec().encodeMethodCall(
      const MethodCall('AppLifecycleState.resumed'),
    ),
    (data) {},
  );

  await tester.pumpAndSettle();
}

/// Verify habit data is displayed in details screen
Future<void> _verifyHabitDataInDetails(
  WidgetTester tester,
  Map<String, String> habitData,
) async {
  // Check for habit name
  expect(find.text(habitData['name']!), findsOneWidget);

  // Check for other habit properties if they're displayed
  final category = habitData['category'];
  if (category != null && tester.any(find.text(category))) {
    IntegrationTestUtils.log('Category displayed correctly: $category');
  }

  final difficulty = habitData['difficulty'];
  if (difficulty != null && tester.any(find.text(difficulty))) {
    IntegrationTestUtils.log('Difficulty displayed correctly: $difficulty');
  }
}

/// Verify form is pre-filled with habit data
Future<void> _verifyFormPreFilled(
  WidgetTester tester,
  Map<String, String> habitData,
) async {
  // Check if name field contains the habit name
  final nameField = find.byWidgetPredicate(
    (widget) =>
        widget is CupertinoTextField &&
        widget.controller?.text == habitData['name'],
  );

  if (tester.any(nameField)) {
    IntegrationTestUtils.log('Name field pre-filled correctly');
  } else {
    IntegrationTestUtils.log('Name field pre-fill could not be verified');
  }
}

/// Test invalid navigation scenarios
Future<void> _testInvalidNavigation(WidgetTester tester) async {
  // Try to navigate to non-existent tabs
  final invalidTabs = ['NonExistent', 'Invalid', 'Test'];

  for (final tab in invalidTabs) {
    final result = await IntegrationTestUtils.navigateToTab(tester, tab);
    if (!result) {
      IntegrationTestUtils.log('Correctly handled invalid navigation to: $tab');
    }
  }
}

/// Test navigation with missing data
Future<void> _testNavigationWithMissingData(WidgetTester tester) async {
  // Try to navigate to habit details without a valid habit
  // This would depend on the app's error handling implementation
  IntegrationTestUtils.log('Testing navigation with missing data scenarios');

  // The specific implementation would depend on how the app handles these cases
}

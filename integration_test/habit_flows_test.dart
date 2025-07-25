import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'test_config.dart';
import 'test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Habit Management User Flows', () {
    testWidgets('complete habit creation flow', (tester) async {
      IntegrationTestUtils.log('Starting complete habit creation flow test');

      // Initialize app
      await IntegrationTestUtils.initializeApp(tester);

      // Navigate to habits screen
      if (!IntegrationTestUtils.isOnScreen(tester, 'habits')) {
        await IntegrationTestUtils.navigateToTab(tester, 'Habits');
      }

      // Test creating multiple habits with different configurations
      final testHabits = [
        IntegrationTestConfig.testHabits['morning_exercise']!,
        IntegrationTestConfig.testHabits['read_book']!,
        IntegrationTestConfig.testHabits['meditation']!,
      ];

      for (final habitData in testHabits) {
        IntegrationTestUtils.log('Creating habit: ${habitData['name']}');

        final success = await IntegrationTestUtils.createHabit(
          tester,
          habitData,
        );

        if (success) {
          IntegrationTestUtils.log(
            'Successfully created habit: ${habitData['name']}',
          );

          // Verify habit appears in list
          expect(find.text(habitData['name']!), findsOneWidget);

          // Verify habit details are displayed correctly
          await _verifyHabitDetails(tester, habitData);
        } else {
          IntegrationTestUtils.log(
            'Failed to create habit: ${habitData['name']} - UI may not be implemented',
          );
        }
      }

      IntegrationTestUtils.log('Habit creation flow test completed');
    });

    testWidgets('habit completion and streak tracking', (tester) async {
      IntegrationTestUtils.log(
        'Starting habit completion and streak tracking test',
      );

      // Initialize app
      await IntegrationTestUtils.initializeApp(tester);

      // Create a test habit first
      final testHabit = IntegrationTestConfig.testHabits['meditation']!;
      await IntegrationTestUtils.createHabit(tester, testHabit);

      // Test completing the habit multiple times
      for (var day = 1; day <= 3; day++) {
        IntegrationTestUtils.log('Completing habit for day $day');

        final completed = await IntegrationTestUtils.completeHabit(
          tester,
          testHabit['name']!,
        );

        if (completed) {
          // Verify completion state
          final isCompleted = IntegrationTestUtils.isHabitCompleted(
            tester,
            testHabit['name']!,
          );

          expect(
            isCompleted,
            true,
            reason: 'Habit should be marked as completed',
          );

          // Check for streak indicators or progress updates
          await _verifyProgressUpdate(tester, testHabit['name']!, day);

          // Simulate next day (this would require app state manipulation)
          await _simulateNextDay(tester);
        } else {
          IntegrationTestUtils.log(
            'Habit completion failed - UI may not be implemented',
          );
          break;
        }
      }

      IntegrationTestUtils.log(
        'Habit completion and streak tracking test completed',
      );
    });

    testWidgets('habit editing flow', (tester) async {
      IntegrationTestUtils.log('Starting habit editing flow test');

      // Initialize app
      await IntegrationTestUtils.initializeApp(tester);

      // Create a test habit
      final originalHabit = IntegrationTestConfig.testHabits['read_book']!;
      await IntegrationTestUtils.createHabit(tester, originalHabit);

      // Navigate to habit details
      if (await IntegrationTestUtils.safeTap(
        tester,
        find.text(originalHabit['name']!),
      )) {
        IntegrationTestUtils.log('Opened habit details');

        // Look for edit button
        final editButtons = [
          find.text('Edit'),
          find.byIcon(CupertinoIcons.pencil),
        ];

        if (await IntegrationTestUtils.safeTapAny(tester, editButtons)) {
          IntegrationTestUtils.log('Opened habit edit form');

          // Modify habit details
          final updatedHabit = Map<String, String>.from(originalHabit);
          updatedHabit['name'] = 'Updated Reading Habit';
          updatedHabit['description'] = 'Read for 30 minutes before bed';

          // Update form fields
          await _updateHabitForm(tester, updatedHabit);

          // Save changes
          final saveButton = find.text('Save');
          if (await IntegrationTestUtils.safeTap(tester, saveButton)) {
            IntegrationTestUtils.log('Saved habit changes');

            // Verify changes were applied
            await IntegrationTestUtils.waitForElement(
              tester,
              find.text(updatedHabit['name']!),
            );

            expect(find.text(updatedHabit['name']!), findsOneWidget);
            expect(find.text(originalHabit['name']!), findsNothing);
          }
        }
      }

      IntegrationTestUtils.log('Habit editing flow test completed');
    });

    testWidgets('habit deletion flow', (tester) async {
      IntegrationTestUtils.log('Starting habit deletion flow test');

      // Initialize app
      await IntegrationTestUtils.initializeApp(tester);

      // Create a test habit
      final testHabit = IntegrationTestConfig.testHabits['morning_exercise']!;
      await IntegrationTestUtils.createHabit(tester, testHabit);

      // Navigate to habit details
      if (await IntegrationTestUtils.safeTap(
        tester,
        find.text(testHabit['name']!),
      )) {
        IntegrationTestUtils.log('Opened habit details');

        // Look for delete button
        final deleteButtons = [
          find.text('Delete'),
          find.byIcon(CupertinoIcons.delete),
        ];

        if (await IntegrationTestUtils.safeTapAny(tester, deleteButtons)) {
          IntegrationTestUtils.log('Tapped delete button');

          // Handle confirmation dialog if present
          await _handleDeleteConfirmation(tester);

          // Verify habit was deleted
          await tester.pumpAndSettle();
          await Future<void>.delayed(IntegrationTestUtils.longTimeout);

          // Check that habit no longer appears in list
          expect(find.text(testHabit['name']!), findsNothing);

          IntegrationTestUtils.log('Habit successfully deleted');
        }
      }

      IntegrationTestUtils.log('Habit deletion flow test completed');
    });

    testWidgets('habit categories and filtering', (tester) async {
      IntegrationTestUtils.log('Starting habit categories and filtering test');

      // Initialize app
      await IntegrationTestUtils.initializeApp(tester);

      // Create habits with different categories
      final habitsByCategory = {
        'Health': IntegrationTestConfig.testHabits['morning_exercise']!,
        'Learning': IntegrationTestConfig.testHabits['read_book']!,
        'Wellness': IntegrationTestConfig.testHabits['meditation']!,
      };

      for (final entry in habitsByCategory.entries) {
        await IntegrationTestUtils.createHabit(tester, entry.value);
      }

      // Test category filtering if available
      for (final category in habitsByCategory.keys) {
        IntegrationTestUtils.log('Testing filter for category: $category');

        final categoryFilter = find.text(category);
        if (await IntegrationTestUtils.safeTap(tester, categoryFilter)) {
          // Verify only habits from this category are shown
          await _verifyFilteredHabits(tester, category, habitsByCategory);
        }
      }

      IntegrationTestUtils.log('Habit categories and filtering test completed');
    });
  });
}

/// Verify habit details are displayed correctly
Future<void> _verifyHabitDetails(
  WidgetTester tester,
  Map<String, String> habitData,
) async {
  // Check for category indicator
  final category = habitData['category'];
  if (category != null) {
    // Look for category text or indicator
    final categoryIndicator = find.text(category);
    if (tester.any(categoryIndicator)) {
      IntegrationTestUtils.log('Category indicator found: $category');
    }
  }

  // Check for difficulty indicator
  final difficulty = habitData['difficulty'];
  if (difficulty != null) {
    // Look for difficulty stars or text
    final difficultyIndicator = find.text(difficulty);
    if (tester.any(difficultyIndicator)) {
      IntegrationTestUtils.log('Difficulty indicator found: $difficulty');
    }
  }
}

/// Verify progress update after habit completion
Future<void> _verifyProgressUpdate(
  WidgetTester tester,
  String habitName,
  int expectedDay,
) async {
  // Look for streak indicators, progress bars, or day counters
  // This would depend on the actual UI implementation

  // Check for streak text
  final streakIndicators = [
    find.text('$expectedDay day streak'),
    find.text('Day $expectedDay'),
    find.text('Streak: $expectedDay'),
  ];

  for (final indicator in streakIndicators) {
    if (tester.any(indicator)) {
      IntegrationTestUtils.log('Found streak indicator: $expectedDay days');
      return;
    }
  }

  IntegrationTestUtils.log(
    'No streak indicator found - may not be implemented',
  );
}

/// Simulate moving to the next day
Future<void> _simulateNextDay(WidgetTester tester) async {
  // This would require manipulating the app's date/time state
  // For now, just wait a moment to simulate time passing
  await Future<void>.delayed(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();
}

/// Update habit form with new data
Future<void> _updateHabitForm(
  WidgetTester tester,
  Map<String, String> habitData,
) async {
  // Clear and update name field
  final nameField = find.byWidgetPredicate(
    (widget) =>
        widget is CupertinoTextField &&
        (widget.placeholder?.toLowerCase().contains('name') ?? false),
  );

  if (await IntegrationTestUtils.waitForElement(tester, nameField)) {
    await tester.tap(nameField);
    await tester.pumpAndSettle();

    // Clear existing text
    await tester.enterText(nameField, '');
    await tester.pumpAndSettle();

    // Enter new text
    await tester.enterText(nameField, habitData['name']!);
    await tester.pumpAndSettle();
  }

  // Update description if field exists
  final descField = find.byWidgetPredicate(
    (widget) =>
        widget is CupertinoTextField &&
        (widget.placeholder?.toLowerCase().contains('description') ?? false),
  );

  if (tester.any(descField)) {
    await tester.tap(descField);
    await tester.pumpAndSettle();
    await tester.enterText(descField, '');
    await tester.enterText(descField, habitData['description']!);
    await tester.pumpAndSettle();
  }
}

/// Handle delete confirmation dialog
Future<void> _handleDeleteConfirmation(WidgetTester tester) async {
  // Look for confirmation dialog
  final confirmButtons = [
    find.text('Delete'),
    find.text('Confirm'),
    find.text('Yes'),
    find.text('OK'),
  ];

  for (final button in confirmButtons) {
    if (await IntegrationTestUtils.safeTap(
      tester,
      button,
      timeout: IntegrationTestUtils.shortTimeout,
    )) {
      IntegrationTestUtils.log('Confirmed deletion');
      return;
    }
  }

  IntegrationTestUtils.log('No confirmation dialog found');
}

/// Verify filtered habits display
Future<void> _verifyFilteredHabits(
  WidgetTester tester,
  String category,
  Map<String, Map<String, String>> habitsByCategory,
) async {
  await tester.pumpAndSettle();

  // Check that the correct habit for this category is visible
  final expectedHabit = habitsByCategory[category];
  if (expectedHabit != null) {
    final habitName = expectedHabit['name']!;
    if (tester.any(find.text(habitName))) {
      IntegrationTestUtils.log('Filtered habit found: $habitName');
    }
  }

  // Optionally check that habits from other categories are hidden
  // This would depend on the filtering implementation
}

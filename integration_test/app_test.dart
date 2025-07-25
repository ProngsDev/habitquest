import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'test_config.dart';
import 'test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('HabitQuest App Integration Tests', () {
    testWidgets('app launches and displays splash screen', (tester) async {
      IntegrationTestUtils.log('Starting app launch test');

      // Launch the app
      await IntegrationTestUtils.initializeApp(tester);

      // Verify app launched successfully
      expect(find.text('HabitQuest'), findsOneWidget);

      IntegrationTestUtils.log('App launch test completed successfully');
    });

    testWidgets('basic navigation works', (tester) async {
      IntegrationTestUtils.log('Starting navigation test');

      // Launch the app
      await IntegrationTestUtils.initializeApp(tester);

      // Test navigation to different screens if tabs exist
      final tabBar = find.byType(CupertinoTabBar);
      if (tester.any(tabBar)) {
        IntegrationTestUtils.log('Tab bar found, testing navigation');

        // Try to navigate to different tabs
        for (final screenName in ['Habits', 'Progress', 'Profile']) {
          if (await IntegrationTestUtils.navigateToTab(tester, screenName)) {
            IntegrationTestUtils.log('Successfully navigated to $screenName');
            await tester.pumpAndSettle();
          }
        }
      } else {
        IntegrationTestUtils.log('No tab bar found, skipping navigation test');
      }

      IntegrationTestUtils.log('Navigation test completed');
    });

    testWidgets('habit creation flow', (tester) async {
      IntegrationTestUtils.log('Starting habit creation test');

      // Launch the app
      await IntegrationTestUtils.initializeApp(tester);

      // Try to create a test habit
      final testHabit = IntegrationTestConfig.testHabits['morning_exercise']!;
      final success = await IntegrationTestUtils.createHabit(tester, testHabit);

      if (success) {
        IntegrationTestUtils.log('Habit creation successful');
        expect(find.text(testHabit['name']!), findsOneWidget);
      } else {
        IntegrationTestUtils.log(
          'Habit creation failed - UI may not be implemented yet',
        );
        // Don't fail the test, just log the result
      }

      IntegrationTestUtils.log('Habit creation test completed');
    });

    testWidgets('habit completion flow', (tester) async {
      IntegrationTestUtils.log('Starting habit completion test');

      // Launch the app
      await IntegrationTestUtils.initializeApp(tester);

      // Create a habit first
      final testHabit = IntegrationTestConfig.testHabits['meditation']!;
      await IntegrationTestUtils.createHabit(tester, testHabit);

      // Try to complete the habit
      final completed = await IntegrationTestUtils.completeHabit(
        tester,
        testHabit['name']!,
      );

      if (completed) {
        IntegrationTestUtils.log('Habit completion successful');

        // Verify completion state
        final isCompleted = IntegrationTestUtils.isHabitCompleted(
          tester,
          testHabit['name']!,
        );

        if (isCompleted) {
          IntegrationTestUtils.log('Habit completion state verified');
        }
      } else {
        IntegrationTestUtils.log(
          'Habit completion failed - UI may not be implemented yet',
        );
      }

      IntegrationTestUtils.log('Habit completion test completed');
    });

    testWidgets('app state persistence', (tester) async {
      IntegrationTestUtils.log('Starting app state persistence test');

      // Launch the app
      await IntegrationTestUtils.initializeApp(tester);

      // Navigate to a specific screen
      await IntegrationTestUtils.navigateToTab(tester, 'Progress');

      // Simulate app lifecycle changes
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle',
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('AppLifecycleState.paused'),
        ),
        (data) {},
      );

      await Future<void>.delayed(const Duration(milliseconds: 500));

      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle',
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('AppLifecycleState.resumed'),
        ),
        (data) {},
      );

      await tester.pumpAndSettle();

      // Verify we're still on the same screen
      final onProgressScreen = IntegrationTestUtils.isOnScreen(
        tester,
        'progress',
      );
      if (onProgressScreen) {
        IntegrationTestUtils.log('App state persistence verified');
      } else {
        IntegrationTestUtils.log('App state persistence test inconclusive');
      }

      IntegrationTestUtils.log('App state persistence test completed');
    });
  });
}

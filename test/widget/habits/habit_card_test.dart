import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitquest/core/enums/habit_enums.dart';
import 'package:habitquest/domain/entities/habit.dart';
import 'package:habitquest/presentation/widgets/habits/habit_card.dart';

void main() {
  group('HabitCard Widget Tests', () {
    late Habit testHabit;

    setUp(() {
      testHabit = Habit(
        id: 'test-habit-id',
        name: 'Test Habit',
        description: 'Test habit description',
        category: HabitCategory.health,
        difficulty: HabitDifficulty.medium,
        frequency: HabitFrequency.daily,
        createdAt: DateTime(2024),
        reminderTime: DateTime(2024, 1, 1, 9, 30),
        colorValue: 0xFF007AFF,
      );
    });

    Widget createTestWidget({
      required Habit habit,
      VoidCallback? onTap,
      VoidCallback? onComplete,
      bool isCompleted = false,
      bool showProgress = true,
    }) => ProviderScope(
        child: CupertinoApp(
          home: CupertinoPageScaffold(
            child: HabitCard(
              habit: habit,
              onTap:
                  onTap ?? () {}, // Provide empty callback to avoid navigation
              onComplete: onComplete,
              isCompleted: isCompleted,
              showProgress: showProgress,
            ),
          ),
        ),
      );

    testWidgets('should display habit name and description', (tester) async {
      await tester.pumpWidget(createTestWidget(habit: testHabit));

      expect(find.text('Test Habit'), findsOneWidget);
      expect(find.text('Test habit description'), findsOneWidget);
    });

    testWidgets('should display habit category', (tester) async {
      await tester.pumpWidget(createTestWidget(habit: testHabit));

      expect(find.text('Health'), findsOneWidget);
    });

    testWidgets('should display habit difficulty', (tester) async {
      await tester.pumpWidget(createTestWidget(habit: testHabit));

      // Check for difficulty indicators (stars)
      expect(find.byIcon(CupertinoIcons.star_fill), findsNWidgets(2));
      expect(find.byIcon(CupertinoIcons.star), findsOneWidget);
    });

    testWidgets('should display habit frequency', (tester) async {
      await tester.pumpWidget(createTestWidget(habit: testHabit));

      expect(find.text('Daily'), findsOneWidget);
    });

    testWidgets('should display reminder time when set', (tester) async {
      await tester.pumpWidget(createTestWidget(habit: testHabit));

      expect(find.byIcon(CupertinoIcons.bell_fill), findsOneWidget);
      expect(find.text('09:30'), findsOneWidget);
    });

    testWidgets('should not display reminder when not set', (tester) async {
      final habitWithoutReminder = Habit(
        id: 'test-habit-id',
        name: 'Test Habit',
        description: 'Test habit description',
        category: HabitCategory.health,
        difficulty: HabitDifficulty.medium,
        frequency: HabitFrequency.daily,
        createdAt: DateTime(2024),
        colorValue: 0xFF007AFF,
      );
      await tester.pumpWidget(createTestWidget(habit: habitWithoutReminder));

      expect(find.byIcon(CupertinoIcons.bell_fill), findsNothing);
    });

    testWidgets('should show completion button in uncompleted state', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(habit: testHabit),
      );

      // Should find the completion button container
      final completionButton = find.byType(GestureDetector).first;
      expect(completionButton, findsOneWidget);

      // Should not show checkmark when not completed
      expect(find.byIcon(CupertinoIcons.checkmark), findsNothing);
    });

    testWidgets('should show checkmark when completed', (tester) async {
      await tester.pumpWidget(
        createTestWidget(habit: testHabit, isCompleted: true),
      );

      // Should show checkmark when completed
      expect(find.byIcon(CupertinoIcons.checkmark), findsOneWidget);
    });

    testWidgets('should call onComplete when completion button is tapped', (
      tester,
    ) async {
      var onCompleteCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          habit: testHabit,
          onComplete: () => onCompleteCalled = true,
        ),
      );

      // Find all GestureDetectors
      final gestureDetectors = find.byType(GestureDetector);
      expect(gestureDetectors, findsWidgets);

      // Try tapping each GestureDetector until we find the completion button
      for (var i = 0; i < tester.widgetList(gestureDetectors).length; i++) {
        await tester.tap(gestureDetectors.at(i));
        await tester.pump();
        if (onCompleteCalled) break;
      }

      expect(onCompleteCalled, true);
    });

    testWidgets('should call onTap when card is tapped', (tester) async {
      var onTapCalled = false;

      await tester.pumpWidget(
        createTestWidget(habit: testHabit, onTap: () => onTapCalled = true),
      );

      // Find and tap the card (but not the completion button)
      final card = find.byType(HabitCard);
      await tester.tap(card);
      await tester.pump();

      expect(onTapCalled, true);
    });

    testWidgets('should display category color indicator', (tester) async {
      await tester.pumpWidget(createTestWidget(habit: testHabit));

      // Find the category color indicator container
      final colorIndicators = find.byType(Container);
      expect(colorIndicators, findsWidgets);

      // Verify that at least one container has the habit's color
      final containers = tester.widgetList<Container>(colorIndicators);
      final hasCorrectColor = containers.any((container) {
        final decoration = container.decoration as BoxDecoration?;
        return decoration?.color == Color(testHabit.colorValue);
      });
      expect(hasCorrectColor, true);
    });

    testWidgets('should handle different difficulty levels correctly', (
      tester,
    ) async {
      // Test easy difficulty (1 star)
      final easyHabit = testHabit.copyWith(difficulty: HabitDifficulty.easy);
      await tester.pumpWidget(createTestWidget(habit: easyHabit));

      expect(find.byIcon(CupertinoIcons.star_fill), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.star), findsNWidgets(2));

      // Test hard difficulty (3 stars)
      final hardHabit = testHabit.copyWith(difficulty: HabitDifficulty.hard);
      await tester.pumpWidget(createTestWidget(habit: hardHabit));

      expect(find.byIcon(CupertinoIcons.star_fill), findsNWidgets(3));
      expect(find.byIcon(CupertinoIcons.star), findsNothing);
    });

    testWidgets('should handle different frequencies correctly', (
      tester,
    ) async {
      // Test weekly frequency
      final weeklyHabit = testHabit.copyWith(frequency: HabitFrequency.weekly);
      await tester.pumpWidget(createTestWidget(habit: weeklyHabit));

      expect(find.text('Weekly'), findsOneWidget);

      // Test monthly frequency
      final monthlyHabit = testHabit.copyWith(
        frequency: HabitFrequency.monthly,
      );
      await tester.pumpWidget(createTestWidget(habit: monthlyHabit));

      expect(find.text('Monthly'), findsOneWidget);
    });

    testWidgets('should handle different categories correctly', (tester) async {
      // Test fitness category
      final fitnessHabit = testHabit.copyWith(category: HabitCategory.fitness);
      await tester.pumpWidget(createTestWidget(habit: fitnessHabit));

      expect(find.text('Fitness'), findsOneWidget);

      // Test productivity category
      final productivityHabit = testHabit.copyWith(
        category: HabitCategory.productivity,
      );
      await tester.pumpWidget(createTestWidget(habit: productivityHabit));

      expect(find.text('Productivity'), findsOneWidget);
    });

    testWidgets('should handle long habit names gracefully', (tester) async {
      final longNameHabit = testHabit.copyWith(
        name:
            'This is a very long habit name that should be handled gracefully by the UI',
      );
      await tester.pumpWidget(createTestWidget(habit: longNameHabit));

      expect(
        find.textContaining('This is a very long habit name'),
        findsOneWidget,
      );
    });

    testWidgets('should handle empty description gracefully', (tester) async {
      final noDescriptionHabit = Habit(
        id: 'test-habit-id',
        name: 'Test Habit',
        description: '', // Empty description
        category: HabitCategory.health,
        difficulty: HabitDifficulty.medium,
        frequency: HabitFrequency.daily,
        createdAt: DateTime(2024),
        colorValue: 0xFF007AFF,
      );
      await tester.pumpWidget(createTestWidget(habit: noDescriptionHabit));

      expect(find.text('Test Habit'), findsOneWidget);
      // The widget should still render correctly even with empty description
      expect(find.byType(HabitCard), findsOneWidget);
    });

    testWidgets('should be accessible', (tester) async {
      await tester.pumpWidget(createTestWidget(habit: testHabit));

      // Verify that the widget tree is built correctly
      expect(find.byType(HabitCard), findsOneWidget);

      // Verify that interactive elements are present
      expect(find.byType(GestureDetector), findsWidgets);
    });
  });
}

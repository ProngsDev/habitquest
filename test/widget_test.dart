// Basic Flutter widget test for HabitQuest app.

import 'package:flutter_test/flutter_test.dart';

import 'package:habitquest/main.dart';

void main() {
  testWidgets('HabitQuest app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HabitQuestApp());

    // Verify that the welcome message is displayed.
    expect(find.text('🚀 Welcome to HabitQuest!'), findsOneWidget);
    expect(
      find.text('Your gamified habit tracker is being built...'),
      findsOneWidget,
    );

    // Verify that the app bar title is correct.
    expect(find.text('HabitQuest'), findsOneWidget);
  });
}

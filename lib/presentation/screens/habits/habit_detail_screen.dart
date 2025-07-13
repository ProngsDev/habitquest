import 'package:flutter/cupertino.dart';

/// Screen for viewing habit details and progress
class HabitDetailScreen extends StatelessWidget {
  final String habitId;

  const HabitDetailScreen({
    super.key,
    required this.habitId,
  });

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Habit Details'),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.pop(context),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            // TODO: Edit habit
          },
          child: const Text('Edit'),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Habit Details',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Habit ID: $habitId',
                  style: const TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Coming Soon!',
                  style: TextStyle(
                    fontSize: 18,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
}

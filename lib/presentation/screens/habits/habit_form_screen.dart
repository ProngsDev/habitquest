import 'package:flutter/cupertino.dart';

/// Screen for creating and editing habits
class HabitFormScreen extends StatefulWidget {
  final String? habitId;
  final bool isEditing;

  const HabitFormScreen({
    super.key,
    this.habitId,
    this.isEditing = false,
  });

  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.isEditing ? 'Edit Habit' : 'New Habit'),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.pop(context),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            // TODO: Save habit
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ),
      child: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Habit Form - Coming Soon!',
              style: TextStyle(
                fontSize: 18,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ),
        ),
      ),
    );
}

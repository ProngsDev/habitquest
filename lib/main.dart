import 'package:flutter/cupertino.dart';
import 'presentation/screens/home/home_screen.dart';

void main() {
  runApp(const HabitQuestApp());
}

class HabitQuestApp extends StatelessWidget {
  const HabitQuestApp({super.key});

  @override
  Widget build(BuildContext context) => const CupertinoApp(
    title: 'HabitQuest',
    theme: CupertinoThemeData(
      primaryColor: CupertinoColors.systemBlue,
      brightness: Brightness.light,
    ),
    home: HomeScreen(),
    debugShowCheckedModeBanner: false,
  );
}

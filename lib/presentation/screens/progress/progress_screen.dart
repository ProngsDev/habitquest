import 'package:flutter/cupertino.dart';

/// Screen for viewing progress and analytics
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) => const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Progress'),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.chart_bar,
                  size: 64,
                  color: CupertinoColors.systemBlue,
                ),
                SizedBox(height: 16),
                Text(
                  'Progress & Analytics',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Track your habit completion rates, streaks, and achievements.',
                  style: TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.systemGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
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

import 'package:flutter/cupertino.dart';

import '../../../core/navigation/app_router.dart';

/// Screen for user profile and settings
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Profile'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => AppNavigation.toSettings(context),
          child: const Icon(CupertinoIcons.settings),
        ),
      ),
      child: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.person_circle,
                  size: 80,
                  color: CupertinoColors.systemBlue,
                ),
                SizedBox(height: 16),
                Text(
                  'Your Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'View your level, achievements, and statistics.',
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

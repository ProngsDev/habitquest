import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/app_router.dart';
import '../../providers/app_providers.dart';
import '../profile/profile_screen.dart';
import '../progress/progress_screen.dart';

/// Main home screen with tab navigation
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedTabIndexProvider);

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: selectedIndex,
        onTap: (index) =>
            ref.read(selectedTabIndexProvider.notifier).state = index,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.checkmark_circle),
            label: 'Habits',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: 'Profile',
          ),
        ],
      ),
      tabBuilder: (context, index) =>
          CupertinoTabView(builder: (context) => _getTabScreen(index)),
    );
  }

  Widget _getTabScreen(int index) {
    switch (index) {
      case 0:
        return const HabitsTab();
      case 1:
        return const ProgressScreen();
      case 2:
        return const ProfileScreen();
      default:
        return const HabitsTab();
    }
  }
}

/// Habits tab content
class HabitsTab extends StatelessWidget {
  const HabitsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Habits'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => AppNavigation.toHabitForm(context),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Welcome section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CupertinoColors.systemBlue,
                      CupertinoColors.systemBlue.darkColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🚀 Welcome to HabitQuest!',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Start your journey to better habits',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Level',
                      '1',
                      CupertinoIcons.star_fill,
                      CupertinoColors.systemYellow,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Streak',
                      '0',
                      CupertinoIcons.flame_fill,
                      CupertinoColors.systemOrange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'XP',
                      '0',
                      CupertinoIcons.bolt_fill,
                      CupertinoColors.systemPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Habits section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Today\'s Habits',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),

              // Empty state
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.add_circled,
                        size: 64,
                        color: CupertinoColors.systemGrey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No habits yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap the + button to create your first habit',
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.systemGrey2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: CupertinoColors.systemBackground,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: CupertinoColors.systemGrey5),
    ),
    child: Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    ),
  );
}

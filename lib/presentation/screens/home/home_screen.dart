import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/app_router.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/utils/xp_calculator.dart';
import '../../providers/app_providers.dart';
import '../../providers/habit_providers.dart';
import '../../widgets/habits/habit_list_widget.dart';
import '../../widgets/layout/responsive_grid.dart';
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
      tabBuilder: (context, index) => CupertinoTabView(
        onGenerateRoute: AppRouter.generateRoute,
        builder: (context) => _getTabScreen(index),
      ),
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
class HabitsTab extends ConsumerWidget {
  const HabitsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(habitStatsProvider);
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
        child: ResponsiveContainer(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Welcome section
                    Container(
                      width: double.infinity,
                      padding: ResponsiveUtils.getResponsivePadding(context),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            CupertinoColors.systemBlue,
                            CupertinoColors.systemBlue,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🚀 Welcome to HabitQuest!',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                baseFontSize: 24,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start your journey to better habits',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                baseFontSize: 16,
                              ),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height:
                          ResponsiveUtils.getResponsiveSpacing(context) * 1.5,
                    ),

                    // Quick stats
                    statsAsync.when(
                      data: (stats) => ResponsiveGrid(
                        forceColumns: ResponsiveUtils.isMobile(context)
                            ? 3
                            : null,
                        children: [
                          _buildStatCard(
                            'Level',
                            '${stats['userLevel'] ?? 1}',
                            XpCalculator.getLevelIcon(
                              (stats['userLevel'] ?? 1) as int,
                            ),
                            CupertinoColors.systemYellow,
                          ),
                          _buildStatCard(
                            'Streak',
                            '${stats['currentStreak'] ?? 0}',
                            CupertinoIcons.flame_fill,
                            CupertinoColors.systemOrange,
                          ),
                          _buildStatCard(
                            'XP',
                            '${stats['userXp'] ?? 0}',
                            CupertinoIcons.bolt_fill,
                            CupertinoColors.systemPurple,
                          ),
                        ],
                      ),
                      loading: () => ResponsiveGrid(
                        forceColumns: ResponsiveUtils.isMobile(context)
                            ? 3
                            : null,
                        children: [
                          _buildStatCard(
                            'Level',
                            '1',
                            CupertinoIcons.star_fill,
                            CupertinoColors.systemYellow,
                          ),
                          _buildStatCard(
                            'Streak',
                            '0',
                            CupertinoIcons.flame_fill,
                            CupertinoColors.systemOrange,
                          ),
                          _buildStatCard(
                            'XP',
                            '0',
                            CupertinoIcons.bolt_fill,
                            CupertinoColors.systemPurple,
                          ),
                        ],
                      ),
                      error: (_, __) => ResponsiveGrid(
                        forceColumns: ResponsiveUtils.isMobile(context)
                            ? 3
                            : null,
                        children: [
                          _buildStatCard(
                            'Level',
                            '1',
                            CupertinoIcons.star_fill,
                            CupertinoColors.systemYellow,
                          ),
                          _buildStatCard(
                            'Streak',
                            '0',
                            CupertinoIcons.flame_fill,
                            CupertinoColors.systemOrange,
                          ),
                          _buildStatCard(
                            'XP',
                            '0',
                            CupertinoIcons.bolt_fill,
                            CupertinoColors.systemPurple,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Habits section header
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Today\'s Habits',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Habits list - now properly scrollable
              const SliverFillRemaining(child: TodaysHabitsWidget()),
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

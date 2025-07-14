import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/responsive_utils.dart';
import '../../providers/habit_completion_providers.dart';
import '../../providers/habit_providers.dart';
import '../../providers/user_providers.dart';
import '../../widgets/common/error_widgets.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/modern_header.dart';
import '../../widgets/common/modern_stat_card.dart';
import '../../widgets/progress/empty_progress_widget.dart';
import '../../widgets/progress/enhanced_progress_charts_widget.dart';
import '../../widgets/progress/streak_calendar_widget.dart';
import '../../widgets/progress/weekly_overview_widget.dart';

/// Screen for viewing progress and analytics
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStats = ref.watch(userStatisticsProvider);
    final user = ref.watch(currentUserProvider);

    return CupertinoPageScaffold(
      child: Column(
        children: [
          ModernHeader(
            title: 'Progress',
            subtitle: user.when(
              data: (userData) => userData != null
                  ? 'Level ${userData.level} • ${userData.totalXp} XP'
                  : 'Welcome to HabitQuest',
              loading: () => 'Loading...',
              error: (_, __) => 'HabitQuest',
            ),
            actions: [
              ModernActionButton(
                icon: CupertinoIcons.refresh,
                onPressed: () => _refreshData(ref),
                tooltip: 'Refresh',
              ),
            ],
          ),
          Expanded(
            child: userStats.when(
              data: (stats) => _buildProgressContent(context, ref, stats),
              loading: () =>
                  const Center(child: CupertinoActivityIndicator(radius: 20)),
              error: (error, _) => Center(
                child: AnimatedErrorWidget(
                  message: 'Failed to load progress data',
                  onRetry: () => _refreshData(ref),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _refreshData(WidgetRef ref) {
    ref
      ..invalidate(userStatisticsProvider)
      ..invalidate(todaysCompletionsProvider)
      ..invalidate(currentUserProvider)
      ..invalidate(activeHabitsProvider);
  }

  Widget _buildProgressContent(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> stats,
  ) {
    // Check if user has any active habits to show progress
    final activeHabits = ref.watch(activeHabitsProvider);
    final hasProgress = activeHabits.when(
      data: (habits) => habits.isNotEmpty,
      loading: () => false,
      error: (_, __) => false,
    );
    final user = ref.watch(currentUserProvider);

    return CustomScrollView(
      slivers: [
        CupertinoSliverRefreshControl(onRefresh: () async => _refreshData(ref)),
        SliverPadding(
          padding: ResponsiveUtils.getResponsivePadding(context),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (!hasProgress) ...[
                // Show empty state
                const EmptyProgressWidget(),
                const SizedBox(height: 24),
                const SampleProgressWidget(),
              ] else ...[
                // Show quick stats overview
                _buildQuickStatsSection(ref, stats),
                const SizedBox(height: 24),

                // Show level progress
                user.when(
                  data: (userData) => userData != null
                      ? _buildModernLevelSection(userData)
                      : const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

                // Show weekly overview
                _buildWeeklyOverviewSection(ref),
                const SizedBox(height: 24),

                // Show charts
                _buildChartsSection(ref),
                const SizedBox(height: 24),

                // Show streak calendar
                _buildStreakCalendarSection(ref),
              ],
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyOverviewSection(WidgetRef ref) {
    final userStats = ref.watch(userStatisticsProvider);

    return userStats.when(
      data: (stats) => WeeklyOverviewWidget(
        currentStreak: stats['currentStreak'] as int,
        longestStreak: stats['longestStreak'] as int,
        totalHabitsCompleted: stats['totalHabitsCompleted'] as int,
        coins: stats['coins'] as int,
      ),
      loading: () =>
          const CardLoadingWidget(message: 'Loading weekly overview...'),
      error: (error, _) => AnimatedErrorWidget(
        message: 'Failed to load weekly overview',
        onRetry: () => ref.invalidate(userStatisticsProvider),
      ),
    );
  }

  Widget _buildChartsSection(WidgetRef ref) {
    final todaysCompletions = ref.watch(todaysCompletionsProvider);

    return todaysCompletions.when(
      data: (completions) =>
          EnhancedProgressChartsWidget(completions: completions),
      loading: () => const CardLoadingWidget(message: 'Loading charts...'),
      error: (error, _) => AnimatedErrorWidget(
        message: 'Failed to load progress charts',
        onRetry: () => ref.invalidate(todaysCompletionsProvider),
      ),
    );
  }

  Widget _buildStreakCalendarSection(WidgetRef ref) {
    final todaysCompletions = ref.watch(todaysCompletionsProvider);

    return todaysCompletions.when(
      data: (completions) => StreakCalendarWidget(completions: completions),
      loading: () => const CardLoadingWidget(message: 'Loading calendar...'),
      error: (error, _) => AnimatedErrorWidget(
        message: 'Failed to load streak calendar',
        onRetry: () => ref.invalidate(todaysCompletionsProvider),
      ),
    );
  }

  Widget _buildQuickStatsSection(WidgetRef ref, Map<String, dynamic> stats) =>
      Column(
        children: [
          const ModernSectionHeader(
            title: 'Quick Stats',
            subtitle: 'Your progress at a glance',
          ),
          Row(
            children: [
              Expanded(
                child: ModernStatCard(
                  title: 'Total Habits',
                  value: '${stats['totalHabitsCompleted'] ?? 0}',
                  subtitle: 'Completed',
                  icon: CupertinoIcons.checkmark_circle_fill,
                  iconColor: CupertinoColors.systemGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ModernStatCard(
                  title: 'Current Streak',
                  value: '${stats['currentStreak'] ?? 0}',
                  subtitle: 'Days',
                  icon: CupertinoIcons.flame_fill,
                  iconColor: CupertinoColors.systemOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ModernStatCard(
                  title: 'This Week',
                  value: '${stats['weeklyCompletions'] ?? 0}',
                  subtitle: 'Completed',
                  icon: CupertinoIcons.calendar,
                  iconColor: CupertinoColors.systemBlue,
                  showTrend: true,
                  trendValue: (stats['weeklyTrend'] as double?) ?? 0.0,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ModernStatCard(
                  title: 'Success Rate',
                  value:
                      '${((stats['successRate'] as double?) ?? 0.0).round()}%',
                  subtitle: 'Overall',
                  icon: CupertinoIcons.star_fill,
                  iconColor: CupertinoColors.systemYellow,
                ),
              ),
            ],
          ),
        ],
      );

  Widget _buildModernLevelSection(dynamic userData) {
    // Calculate level progress
    final currentLevel = userData.level as int;
    final totalXp = userData.totalXp as int;

    // Simple level calculation - each level requires 100 * level XP
    final xpRequiredForCurrentLevel = currentLevel > 1
        ? (100 * (currentLevel - 1))
        : 0;
    final xpRequiredForNextLevel = 100 * currentLevel;
    final xpInCurrentLevel = totalXp - xpRequiredForCurrentLevel;
    final progressPercentage = xpInCurrentLevel / xpRequiredForNextLevel;

    return Column(
      children: [
        const ModernSectionHeader(
          title: 'Level Progress',
          subtitle: 'Keep going to reach the next level!',
        ),
        ModernLevelCard(
          currentLevel: currentLevel,
          totalXp: totalXp,
          xpInCurrentLevel: xpInCurrentLevel,
          xpRequiredForNextLevel: xpRequiredForNextLevel - xpInCurrentLevel,
          progressPercentage: progressPercentage.clamp(0.0, 1.0),
        ),
      ],
    );
  }
}

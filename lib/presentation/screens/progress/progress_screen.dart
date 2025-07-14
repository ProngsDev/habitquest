import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/responsive_utils.dart';
import '../../providers/habit_completion_providers.dart';
import '../../providers/user_providers.dart';
import '../../widgets/common/error_widgets.dart';
import '../../widgets/common/loading_widget.dart';

import '../../widgets/progress/level_progress_widget.dart';
import '../../widgets/progress/progress_charts_widget.dart';
import '../../widgets/progress/streak_calendar_widget.dart';
import '../../widgets/progress/weekly_overview_widget.dart';

/// Screen for viewing progress and analytics
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Progress')),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: () async {
                // Refresh all progress data
                ref
                  ..invalidate(userStatisticsProvider)
                  ..invalidate(totalXpProvider)
                  ..invalidate(todaysCompletionsProvider);
              },
            ),
            SliverPadding(
              padding: ResponsiveUtils.getResponsivePadding(context),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Level and XP Progress Section
                  _buildLevelProgressSection(ref),
                  const SizedBox(height: 24),

                  // Weekly Overview Section
                  _buildWeeklyOverviewSection(ref),
                  const SizedBox(height: 24),

                  // Charts Section
                  _buildChartsSection(ref),
                  const SizedBox(height: 24),

                  // Streak Calendar Section
                  _buildStreakCalendarSection(ref),
                  const SizedBox(height: 24),

                  // Additional spacing for bottom
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelProgressSection(WidgetRef ref) {
    final userLevelProgress = ref.watch(userLevelProgressProvider);

    return userLevelProgress.when(
      data: (progress) => LevelProgressWidget(
        currentLevel: progress['currentLevel'] as int,
        totalXp: progress['totalXp'] as int,
        xpInCurrentLevel: progress['xpInCurrentLevel'] as int,
        xpRequiredForNextLevel: progress['xpRequiredForNextLevel'] as int,
        progressPercentage: progress['progressPercentage'] as double,
      ),
      loading: () =>
          const CardLoadingWidget(message: 'Loading level progress...'),
      error: (error, _) => AnimatedErrorWidget(
        message: 'Failed to load level progress',
        onRetry: () => ref.invalidate(userLevelProgressProvider),
      ),
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
      data: (completions) => ProgressChartsWidget(completions: completions),
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
}

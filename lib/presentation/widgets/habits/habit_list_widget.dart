import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/app_router.dart';
import '../../../domain/entities/habit.dart';
import '../../providers/habit_completion_providers.dart';
import '../../providers/habit_providers.dart';
import '../../providers/user_providers.dart';
import '../animations/congratulatory_dialog.dart';
import '../common/empty_state_widget.dart';
import '../common/loading_widget.dart';
import 'habit_card.dart';

/// Widget for displaying a list of habits with loading and empty states
class HabitListWidget extends ConsumerWidget {
  final bool showActiveOnly;
  final String? categoryFilter;
  final String? searchQuery;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const HabitListWidget({
    super.key,
    this.showActiveOnly = true,
    this.categoryFilter,
    this.searchQuery,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Choose the appropriate provider based on parameters
    final habitsAsyncValue = _getHabitsProvider(ref);

    return habitsAsyncValue.when(
      data: (habits) => _buildHabitsList(context, ref, habits),
      loading: () => _buildLoadingState(),
      error: (error, stackTrace) => _buildErrorState(context, error),
    );
  }

  AsyncValue<List<Habit>> _getHabitsProvider(WidgetRef ref) {
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      return ref.watch(habitSearchProvider(searchQuery!));
    } else if (showActiveOnly) {
      return ref.watch(activeHabitsProvider);
    } else {
      return ref.watch(habitsProvider);
    }
  }

  Widget _buildHabitsList(
    BuildContext context,
    WidgetRef ref,
    List<Habit> habits,
  ) {
    // Apply category filter if specified
    final filteredHabits = categoryFilter != null
        ? habits
              .where((habit) => habit.category.name == categoryFilter)
              .toList()
        : habits;

    if (filteredHabits.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: filteredHabits.length,
      itemBuilder: (context, index) {
        final habit = filteredHabits[index];
        return Consumer(
          builder: (context, ref, child) {
            final isCompletedAsync = ref.watch(
              isHabitCompletedTodayProvider(habit.id),
            );

            return isCompletedAsync.when(
              data: (isCompleted) => HabitCard(
                habit: habit,
                onTap: () => AppNavigation.toHabitDetail(context, habit.id),
                onComplete: () => _handleHabitCompletion(ref, habit, context),
                isCompleted: isCompleted,
              ),
              loading: () => HabitCard(
                habit: habit,
                onTap: () => AppNavigation.toHabitDetail(context, habit.id),
                onComplete: null, // Disable while loading
                isCompleted: false,
              ),
              error: (_, __) => HabitCard(
                habit: habit,
                onTap: () => AppNavigation.toHabitDetail(context, habit.id),
                onComplete: () => _handleHabitCompletion(ref, habit, context),
                isCompleted: false,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: LoadingWidget(message: 'Loading habits...'),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 48,
              color: CupertinoColors.systemRed,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load habits',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.secondaryLabel,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CupertinoButton(
              onPressed: () {
                // Refresh the habits list
                // This will be implemented when we add the refresh functionality
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      return EmptySearchWidget(searchQuery: searchQuery!);
    }

    return EmptyHabitsWidget(
      onCreateHabit: () => AppNavigation.toHabitForm(context),
    );
  }

  Future<void> _handleHabitCompletion(
    WidgetRef ref,
    Habit habit,
    BuildContext context,
  ) async {
    final notifier = ref.read(habitCompletionNotifierProvider.notifier);
    await notifier.completeHabit(habit);

    // Check if all habits are completed for today
    await _checkForDailyCompletion(ref, context);
  }

  Future<void> _checkForDailyCompletion(
    WidgetRef ref,
    BuildContext context,
  ) async {
    try {
      // Get all active habits
      final activeHabitsAsync = ref.read(activeHabitsProvider);
      final activeHabits = activeHabitsAsync.value ?? [];

      if (activeHabits.isEmpty) return;

      // Check if all active habits are completed today
      bool allCompleted = true;
      for (final habit in activeHabits) {
        final isCompletedAsync = ref.read(
          isHabitCompletedTodayProvider(habit.id),
        );
        final isCompleted = isCompletedAsync.value ?? false;
        if (!isCompleted) {
          allCompleted = false;
          break;
        }
      }

      // Show congratulatory dialog if all habits are completed
      if (allCompleted && context.mounted) {
        final totalXp = activeHabits.fold<int>(
          0,
          (sum, habit) => sum + 10, // Default XP per habit
        );
        final totalCoins = activeHabits.fold<int>(
          0,
          (sum, habit) => sum + 5, // Default coins per habit
        );

        CongratulatoryService.showDailyCompletion(
          context,
          xpEarned: totalXp,
          coinsEarned: totalCoins,
        );
      }
    } catch (e) {
      // Silently handle errors to not disrupt the user experience
      debugPrint('Error checking daily completion: $e');
    }
  }
}

/// Specialized widget for displaying today's habits
class TodaysHabitsWidget extends ConsumerWidget {
  const TodaysHabitsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const HabitListWidget(
      showActiveOnly: true,
      shrinkWrap: false,
      physics: AlwaysScrollableScrollPhysics(),
    );
  }
}

/// Widget for displaying habits in a specific category
class CategoryHabitsWidget extends ConsumerWidget {
  final String category;

  const CategoryHabitsWidget({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HabitListWidget(showActiveOnly: true, categoryFilter: category);
  }
}

/// Widget for displaying search results
class HabitSearchResultsWidget extends ConsumerWidget {
  final String searchQuery;

  const HabitSearchResultsWidget({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HabitListWidget(
      searchQuery: searchQuery,
      showActiveOnly: false, // Show all habits in search
    );
  }
}

/// Compact habit list for dashboard/overview screens
class CompactHabitListWidget extends ConsumerWidget {
  final int maxItems;

  const CompactHabitListWidget({super.key, this.maxItems = 3});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsyncValue = ref.watch(activeHabitsProvider);

    return habitsAsyncValue.when(
      data: (habits) {
        if (habits.isEmpty) {
          return const EmptyHabitsWidget();
        }

        final displayHabits = habits.take(maxItems).toList();

        return Column(
          children: [
            ...displayHabits.map(
              (habit) => Consumer(
                builder: (context, ref, child) {
                  final isCompletedAsync = ref.watch(
                    isHabitCompletedTodayProvider(habit.id),
                  );

                  return isCompletedAsync.when(
                    data: (isCompleted) => HabitCard(
                      habit: habit,
                      onTap: () =>
                          AppNavigation.toHabitDetail(context, habit.id),
                      onComplete: () => _handleHabitCompletion(ref, habit),
                      isCompleted: isCompleted,
                    ),
                    loading: () => HabitCard(
                      habit: habit,
                      onTap: () =>
                          AppNavigation.toHabitDetail(context, habit.id),
                      onComplete: null,
                      isCompleted: false,
                    ),
                    error: (_, __) => HabitCard(
                      habit: habit,
                      onTap: () =>
                          AppNavigation.toHabitDetail(context, habit.id),
                      onComplete: () => _handleHabitCompletion(ref, habit),
                      isCompleted: false,
                    ),
                  );
                },
              ),
            ),

            if (habits.length > maxItems) ...[
              const SizedBox(height: 8),
              CupertinoButton(
                onPressed: () {
                  // Navigate to full habits list
                  // This will be implemented when we have proper navigation
                },
                child: Text('View all ${habits.length} habits'),
              ),
            ],
          ],
        );
      },
      loading: () => const LoadingWidget(message: 'Loading habits...'),
      error: (error, _) => Text('Error: $error'),
    );
  }

  Future<void> _handleHabitCompletion(WidgetRef ref, Habit habit) async {
    final notifier = ref.read(habitCompletionNotifierProvider.notifier);
    await notifier.completeHabit(habit);
  }
}

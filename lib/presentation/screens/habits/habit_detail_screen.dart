import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../domain/entities/habit.dart';
import '../../../domain/entities/habit_completion.dart';
import '../../providers/app_providers.dart';
import '../../providers/habit_completion_providers.dart' as completion;
import '../../providers/habit_providers.dart';
import '../../widgets/common/custom_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/progress_widgets.dart';

/// Screen for viewing habit details and progress
class HabitDetailScreen extends ConsumerWidget {

  const HabitDetailScreen({required this.habitId, super.key});
  final String habitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitAsync = ref.watch(habitByIdProvider(habitId));

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Habit Details'),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.pop(context),
        ),
        trailing: habitAsync.when(
          data: (habit) => habit != null
              ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () =>
                      AppNavigation.toHabitForm(context, habitId: habitId),
                  child: const Text('Edit'),
                )
              : null,
          loading: () => null,
          error: (_, __) => null,
        ),
      ),
      child: SafeArea(
        child: habitAsync.when(
          data: (habit) => habit != null
              ? _buildHabitDetails(context, habit)
              : _buildNotFound(context),
          loading: () => const LoadingWidget(),
          error: (error, _) => _buildError(context, error.toString()),
        ),
      ),
    );
  }

  Widget _buildHabitDetails(BuildContext context, Habit habit) => SingleChildScrollView(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _buildHeaderSection(context, habit),
          const SizedBox(height: 24),

          // Progress Overview
          _buildProgressSection(context, habit),
          const SizedBox(height: 24),

          // Statistics Section
          _buildStatisticsSection(context, habit),
          const SizedBox(height: 24),

          // Details Section
          _buildDetailsSection(context, habit),
          const SizedBox(height: 24),

          // Action Buttons
          _buildActionButtons(context, habit),
          const SizedBox(height: 32),
        ],
      ),
    );

  Widget _buildHeaderSection(BuildContext context, Habit habit) {
    final categoryColor = AppTheme.getCategoryColor(habit.category.name);
    final difficultyColor = AppTheme.getDifficultyColor(habit.difficulty.name);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  habit.category.icon,
                  size: 24,
                  color: categoryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            habit.category.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: categoryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: difficultyColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            habit.difficulty.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: difficultyColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (habit.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              habit.description,
              style: const TextStyle(
                fontSize: 16,
                color: CupertinoColors.secondaryLabel,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, Habit habit) => Consumer(
      builder: (context, ref, child) {
        final statsAsync = ref.watch(completion.habitStatsProvider(habit.id));

        return statsAsync.when(
          data: (HabitStats stats) =>
              _buildProgressContent(context, habit, stats),
          loading: () => const CustomCard(
            child: Center(child: LoadingWidget(message: 'Loading progress...')),
          ),
          error: (error, _) =>
              CustomCard(child: Text('Error loading progress: $error')),
        );
      },
    );

  Widget _buildProgressContent(
    BuildContext context,
    Habit habit,
    HabitStats stats,
  ) => CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progress Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    CircularProgressWidget(
                      progress: stats.completionRate,
                      progressColor: AppTheme.getCategoryColor(
                        habit.category.name,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Completion Rate',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildProgressStat(
                      'Current Streak',
                      '${stats.currentStreak} days',
                      CupertinoIcons.flame_fill,
                      CupertinoColors.systemOrange,
                    ),
                    const SizedBox(height: 12),
                    _buildProgressStat(
                      'Longest Streak',
                      '${stats.longestStreak} days',
                      CupertinoIcons.star_fill,
                      CupertinoColors.systemYellow,
                    ),
                    const SizedBox(height: 12),
                    _buildProgressStat(
                      'Total Completions',
                      '${stats.totalCompletions} times',
                      CupertinoIcons.checkmark_circle_fill,
                      CupertinoColors.systemGreen,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

  Widget _buildProgressStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) => Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            ],
          ),
        ),
      ],
    );

  Widget _buildStatisticsSection(BuildContext context, Habit habit) {
    final createdDate = DateFormat('MMM dd, yyyy').format(habit.createdAt);
    final daysSinceCreated = DateTime.now().difference(habit.createdAt).inDays;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 16),

          _buildStatRow('Created', createdDate),
          const SizedBox(height: 12),
          _buildStatRow('Days Active', '$daysSinceCreated days'),
          const SizedBox(height: 12),
          _buildStatRow('Frequency', habit.frequency.displayName),
          const SizedBox(height: 12),
          _buildStatRow(
            'Target',
            '${habit.targetCount}${habit.unit != null ? ' ${habit.unit}' : ''}',
          ),
          const SizedBox(height: 12),
          _buildStatRow('XP Multiplier', '${habit.difficulty.xpMultiplier}x'),
          if (habit.reminderTime != null) ...[
            const SizedBox(height: 12),
            _buildStatRow(
              'Reminder',
              '${habit.reminderTime!.hour.toString().padLeft(2, '0')}:${habit.reminderTime!.minute.toString().padLeft(2, '0')}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: CupertinoColors.label,
          ),
        ),
      ],
    );

  Widget _buildDetailsSection(BuildContext context, Habit habit) => CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Habit Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 16),

          _buildDetailRow(
            'Category',
            habit.category.displayName,
            habit.category.icon,
            AppTheme.getCategoryColor(habit.category.name),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Difficulty',
            habit.difficulty.displayName,
            null,
            AppTheme.getDifficultyColor(habit.difficulty.name),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Status',
            habit.isActive ? 'Active' : 'Inactive',
            habit.isActive
                ? CupertinoIcons.checkmark_circle_fill
                : CupertinoIcons.pause_circle_fill,
            habit.isActive
                ? CupertinoColors.systemGreen
                : CupertinoColors.systemGrey,
          ),
        ],
      ),
    );

  Widget _buildDetailRow(
    String label,
    String value,
    IconData? icon,
    Color color,
  ) => Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
        ] else ...[
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            ],
          ),
        ),
      ],
    );

  Widget _buildActionButtons(BuildContext context, Habit habit) => Consumer(
      builder: (context, ref, child) {
        final isCompletedAsync = ref.watch(
          completion.isHabitCompletedTodayProvider(habit.id),
        );

        return isCompletedAsync.when(
          data: (isCompleted) => Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: isCompleted
                    ? CupertinoButton(
                        onPressed: () => _undoCompletion(ref, habit.id),
                        color: CupertinoColors.systemGreen,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.checkmark_circle_fill,
                              color: CupertinoColors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Completed Today',
                              style: TextStyle(color: CupertinoColors.white),
                            ),
                          ],
                        ),
                      )
                    : CupertinoButton.filled(
                        onPressed: () => _completeHabit(ref, habit),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.checkmark_circle,
                              color: CupertinoColors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Mark as Complete',
                              style: TextStyle(color: CupertinoColors.white),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      onPressed: () =>
                          AppNavigation.toHabitForm(context, habitId: habit.id),
                      color: CupertinoColors.systemGrey5,
                      child: const Text(
                        'Edit Habit',
                        style: TextStyle(color: CupertinoColors.label),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CupertinoButton(
                      onPressed: () => _showDeleteDialog(context, habit),
                      color: CupertinoColors.systemRed,
                      child: const Text('Delete Habit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          loading: () => const SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              onPressed: null,
              child: CupertinoActivityIndicator(),
            ),
          ),
          error: (_, __) => const SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              onPressed: null,
              child: Text('Error loading completion status'),
            ),
          ),
        );
      },
    );

  Future<void> _completeHabit(WidgetRef ref, Habit habit) async {
    final notifier = ref.read(
      completion.habitCompletionNotifierProvider.notifier,
    );
    await notifier.completeHabit(habit);
  }

  Future<void> _undoCompletion(WidgetRef ref, String habitId) async {
    final notifier = ref.read(
      completion.habitCompletionNotifierProvider.notifier,
    );
    await notifier.undoCompletion(habitId);
  }

  void _showDeleteDialog(BuildContext context, Habit habit) {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Habit'),
        content: Text(
          'Are you sure you want to delete "${habit.name}"? This action cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () async {
              Navigator.pop(context); // Close dialog first
              await _deleteHabitWithLoading(context, habit);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteHabitWithLoading(
    BuildContext context,
    Habit habit,
  ) async {
    // Show loading dialog
    unawaited(
      showCupertinoDialog<void>(
        context: context,
        builder: (context) => const CupertinoAlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoActivityIndicator(),
              SizedBox(height: 16),
              Text('Deleting habit...'),
            ],
          ),
        ),
      ),
    );

    try {
      final ref = ProviderScope.containerOf(context);
      final repository = ref.read(habitRepositoryProvider);

      // Delete the habit
      await repository.deleteHabit(habit.id);

      // Invalidate providers to refresh UI
      ref
        ..invalidate(habitsProvider)
        ..invalidate(activeHabitsProvider);

      // Wait a brief moment for providers to update
      await Future<void>.delayed(const Duration(milliseconds: 100));

      if (context.mounted) {
        // Close loading dialog
        Navigator.pop(context);

        // Navigate back to home with proper route clearing
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on Exception catch (e) {
      if (context.mounted) {
        // Close loading dialog
        Navigator.pop(context);

        // Show error dialog
        unawaited(
          showCupertinoDialog<void>(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Error'),
              content: Text('Failed to delete habit: $e'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  Widget _buildNotFound(BuildContext context) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: 64,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Habit Not Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'The habit you\'re looking for doesn\'t exist or has been deleted.',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.secondaryLabel,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );

  Widget _buildError(BuildContext context, String error) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.xmark_circle,
            size: 64,
            color: CupertinoColors.systemRed,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error Loading Habit',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.secondaryLabel,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
}

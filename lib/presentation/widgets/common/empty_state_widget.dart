import 'package:flutter/cupertino.dart';

/// Empty state widget for when there's no data to display
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: iconColor ?? CupertinoColors.systemGrey,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.systemGrey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              CupertinoButton(
                onPressed: onAction,
                color: CupertinoColors.systemBlue,
                borderRadius: BorderRadius.circular(12),
                child: Text(
                  actionText!,
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
}

/// Specific empty states for different sections
class EmptyHabitsWidget extends StatelessWidget {
  final VoidCallback? onCreateHabit;

  const EmptyHabitsWidget({
    super.key,
    this.onCreateHabit,
  });

  @override
  Widget build(BuildContext context) => EmptyStateWidget(
      icon: CupertinoIcons.add_circled,
      title: 'No habits yet',
      subtitle: 'Create your first habit to start your journey',
      actionText: 'Create Habit',
      onAction: onCreateHabit,
      iconColor: CupertinoColors.systemBlue,
    );
}

class EmptyAchievementsWidget extends StatelessWidget {
  const EmptyAchievementsWidget({super.key});

  @override
  Widget build(BuildContext context) => const EmptyStateWidget(
      icon: CupertinoIcons.star,
      title: 'No achievements yet',
      subtitle: 'Complete habits to unlock achievements',
      iconColor: CupertinoColors.systemYellow,
    );
}

class EmptyProgressWidget extends StatelessWidget {
  const EmptyProgressWidget({super.key});

  @override
  Widget build(BuildContext context) => const EmptyStateWidget(
      icon: CupertinoIcons.chart_bar,
      title: 'No progress data',
      subtitle: 'Complete some habits to see your progress',
      iconColor: CupertinoColors.systemGreen,
    );
}

class EmptySearchWidget extends StatelessWidget {
  final String searchQuery;

  const EmptySearchWidget({
    super.key,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) => EmptyStateWidget(
      icon: CupertinoIcons.search,
      title: 'No results found',
      subtitle: 'No habits found for "$searchQuery"',
      iconColor: CupertinoColors.systemGrey,
    );
}

/// Error state widget
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const ErrorStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => EmptyStateWidget(
      icon: CupertinoIcons.exclamationmark_triangle,
      title: title,
      subtitle: subtitle,
      actionText: actionText,
      onAction: onAction,
      iconColor: CupertinoColors.systemRed,
    );
}

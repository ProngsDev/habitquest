import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/habit_enums.dart';
import '../../../core/navigation/app_router.dart';
import '../../../domain/entities/habit.dart';
import '../animations/completion_animation_widget.dart';
import '../common/custom_card.dart';

/// Elegant iOS-style card for displaying individual habits
class HabitCard extends ConsumerWidget {
  final Habit habit;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final bool isCompleted;
  final bool showProgress;

  const HabitCard({
    super.key,
    required this.habit,
    this.onTap,
    this.onComplete,
    this.isCompleted = false,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryColor = Color(habit.colorValue);
    final isDarkMode = CupertinoTheme.of(context).brightness == Brightness.dark;

    return CompletionAnimationWidget(
      isCompleted: isCompleted,
      animationType: CompletionAnimationType.scale,
      child: CustomCard(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        onTap: onTap ?? () => AppNavigation.toHabitDetail(context, habit.id),
        child: Row(
          children: [
            // Category color indicator and completion button
            _buildLeadingSection(categoryColor),
            const SizedBox(width: 16),

            // Habit content
            Expanded(child: _buildContentSection(context, isDarkMode)),

            // Trailing section with difficulty and frequency
            _buildTrailingSection(context, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingSection(Color categoryColor) {
    return Column(
      children: [
        // Completion button
        GestureDetector(
          onTap: onComplete,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? categoryColor : CupertinoColors.systemGrey5,
              border: Border.all(color: categoryColor, width: 2),
            ),
            child: isCompleted
                ? const Icon(
                    CupertinoIcons.checkmark,
                    color: CupertinoColors.white,
                    size: 18,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 8),

        // Category color indicator
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: categoryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection(BuildContext context, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Habit name
        Text(
          habit.name,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: isCompleted
                ? CupertinoColors.systemGrey
                : CupertinoColors.label,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        if (habit.description.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            habit.description,
            style: TextStyle(
              fontSize: 14,
              color: isCompleted
                  ? CupertinoColors.systemGrey2
                  : CupertinoColors.secondaryLabel,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        const SizedBox(height: 8),

        // Target and category info
        Row(
          children: [
            _buildInfoChip(
              '${habit.targetCount}${habit.unit != null ? ' ${habit.unit}' : ''}',
              CupertinoIcons.flag_fill,
              CupertinoColors.systemBlue,
            ),
            const SizedBox(width: 8),
            _buildInfoChip(
              habit.category.displayName,
              _getCategoryIcon(habit.category),
              Color(habit.colorValue),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrailingSection(BuildContext context, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // XP value
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: CupertinoColors.systemYellow.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: CupertinoColors.systemYellow.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.bolt_fill,
                color: CupertinoColors.systemYellow,
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                '${_calculateXP()}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.systemYellow,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Difficulty indicator
        _buildDifficultyIndicator(),

        const SizedBox(height: 4),

        // Frequency
        Text(
          habit.frequency.displayName,
          style: const TextStyle(
            fontSize: 12,
            color: CupertinoColors.systemGrey,
            fontWeight: FontWeight.w500,
          ),
        ),

        if (habit.reminderTime != null) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.bell_fill,
                color: CupertinoColors.systemGrey,
                size: 10,
              ),
              const SizedBox(width: 2),
              Text(
                '${habit.reminderTime!.hour.toString().padLeft(2, '0')}:${habit.reminderTime!.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 10,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildInfoChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyIndicator() {
    final stars = habit.difficulty.index + 1;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Icon(
          index < stars ? CupertinoIcons.star_fill : CupertinoIcons.star,
          color: index < stars
              ? CupertinoColors.systemYellow
              : CupertinoColors.systemGrey4,
          size: 12,
        );
      }),
    );
  }

  IconData _getCategoryIcon(HabitCategory category) {
    return category.icon;
  }

  int _calculateXP() {
    return (habit.difficulty.xpMultiplier * 10).round();
  }
}

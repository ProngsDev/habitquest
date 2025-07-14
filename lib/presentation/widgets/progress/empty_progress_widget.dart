import 'package:flutter/cupertino.dart';

import '../../../core/navigation/app_router.dart';
import '../common/custom_card.dart';

/// Widget displayed when user has no progress data yet
class EmptyProgressWidget extends StatelessWidget {
  const EmptyProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CupertinoColors.systemBlue.withOpacity(0.1),
                  CupertinoColors.systemPurple.withOpacity(0.1),
                ],
              ),
            ),
            child: const Icon(
              CupertinoIcons.chart_bar_alt_fill,
              size: 60,
              color: CupertinoColors.systemBlue,
            ),
          ),
          const SizedBox(height: 24),

          // Title
          const Text(
            'Start Your Journey!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Description
          const Text(
            'Create your first habit to see your progress and start earning XP!',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.secondaryLabel,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Action Button
          CupertinoButton.filled(
            onPressed: () => AppNavigation.toHabitForm(context),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.add, size: 20),
                SizedBox(width: 8),
                Text('Create First Habit'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Secondary Action
          CupertinoButton(
            onPressed: () => _showProgressInfo(context),
            child: const Text('Learn About Progress'),
          ),
        ],
      ),
    );
  }

  void _showProgressInfo(BuildContext context) {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Progress Tracking'),
        content: const Text(
          'Track your habits and watch your progress grow! '
          'Earn XP, level up, maintain streaks, and unlock achievements '
          'as you build better habits.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Got it!'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

/// Widget for showing sample progress data
class SampleProgressWidget extends StatelessWidget {
  const SampleProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        children: [
          // Header
          const Row(
            children: [
              Icon(
                CupertinoIcons.info_circle,
                size: 24,
                color: CupertinoColors.systemBlue,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sample Progress',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sample stats
          const Text(
            'This is how your progress will look once you start completing habits!',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.secondaryLabel,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Sample progress indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSampleStat('Level', '5', CupertinoIcons.star_fill, CupertinoColors.systemYellow),
              _buildSampleStat('Streak', '12', CupertinoIcons.flame_fill, CupertinoColors.systemOrange),
              _buildSampleStat('XP', '450', CupertinoIcons.bolt_fill, CupertinoColors.systemPurple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSampleStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
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
    );
  }
}

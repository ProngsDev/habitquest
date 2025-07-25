import 'package:flutter/cupertino.dart';

import 'completion_animation_widget.dart';

/// Dialog shown when user completes all daily habits
class CongratulatoryDialog extends StatefulWidget {

  const CongratulatoryDialog({
    required this.title, required this.message, super.key,
    this.xpEarned = 0,
    this.coinsEarned = 0,
    this.onDismiss,
  });
  final String title;
  final String message;
  final int xpEarned;
  final int coinsEarned;
  final VoidCallback? onDismiss;

  @override
  State<CongratulatoryDialog> createState() => _CongratulatoryDialogState();
}

class _CongratulatoryDialogState extends State<CongratulatoryDialog>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimationSequence();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
  }

  void _startAnimationSequence() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _slideController.forward();
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      _scaleController.forward();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showConfetti = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ConfettiAnimationWidget(
      shouldPlay: _showConfetti,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: CupertinoAlertDialog(
            title: Column(
              children: [
                const Icon(
                  CupertinoIcons.star_circle_fill,
                  size: 60,
                  color: CupertinoColors.systemYellow,
                ),
                const SizedBox(height: 12),
                Text(widget.title),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Text(
                  widget.message,
                  style: const TextStyle(fontSize: 16),
                ),
                if (widget.xpEarned > 0 || widget.coinsEarned > 0) ...[
                  const SizedBox(height: 20),
                  _buildRewardsSection(),
                ],
              ],
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('Awesome!'),
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onDismiss?.call();
                },
              ),
            ],
          ),
        ),
      ),
    );

  Widget _buildRewardsSection() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'Rewards Earned!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (widget.xpEarned > 0)
                _buildRewardItem(
                  icon: CupertinoIcons.bolt_fill,
                  value: '+${widget.xpEarned}',
                  label: 'XP',
                  color: CupertinoColors.systemPurple,
                ),
              if (widget.coinsEarned > 0)
                _buildRewardItem(
                  icon: CupertinoIcons.money_dollar_circle_fill,
                  value: '+${widget.coinsEarned}',
                  label: 'Coins',
                  color: CupertinoColors.systemYellow,
                ),
            ],
          ),
        ],
      ),
    );

  Widget _buildRewardItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) => Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
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
    );
}

/// Service for showing congratulatory dialogs
class CongratulatoryService {
  static void showDailyCompletion(
    BuildContext context, {
    int xpEarned = 0,
    int coinsEarned = 0,
    VoidCallback? onDismiss,
  }) {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CongratulatoryDialog(
        title: 'Daily Goals Complete!',
        message: 'Congratulations! You\'ve completed all your habits for today. Keep up the amazing work!',
        xpEarned: xpEarned,
        coinsEarned: coinsEarned,
        onDismiss: onDismiss,
      ),
    );
  }

  static void showStreakMilestone(
    BuildContext context, {
    required int streakDays,
    int xpEarned = 0,
    int coinsEarned = 0,
    VoidCallback? onDismiss,
  }) {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CongratulatoryDialog(
        title: 'Streak Milestone!',
        message: 'Amazing! You\'ve maintained your streak for $streakDays days in a row!',
        xpEarned: xpEarned,
        coinsEarned: coinsEarned,
        onDismiss: onDismiss,
      ),
    );
  }

  static void showLevelUp(
    BuildContext context, {
    required int newLevel,
    int xpEarned = 0,
    int coinsEarned = 0,
    VoidCallback? onDismiss,
  }) {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CongratulatoryDialog(
        title: 'Level Up!',
        message: 'Congratulations! You\'ve reached level $newLevel! Your dedication is paying off!',
        xpEarned: xpEarned,
        coinsEarned: coinsEarned,
        onDismiss: onDismiss,
      ),
    );
  }

  static void showAchievementUnlocked(
    BuildContext context, {
    required String achievementName,
    required String achievementDescription,
    int xpEarned = 0,
    int coinsEarned = 0,
    VoidCallback? onDismiss,
  }) {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CongratulatoryDialog(
        title: 'Achievement Unlocked!',
        message: '$achievementName\n\n$achievementDescription',
        xpEarned: xpEarned,
        coinsEarned: coinsEarned,
        onDismiss: onDismiss,
      ),
    );
  }
}

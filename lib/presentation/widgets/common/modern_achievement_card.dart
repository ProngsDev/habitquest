import 'package:flutter/cupertino.dart';

import '../../../core/utils/enhanced_animation_utils.dart';
import '../../../domain/entities/achievement.dart';
import 'modern_card.dart';

/// Modern achievement card with iOS-like design
class ModernAchievementCard extends StatefulWidget {
  const ModernAchievementCard({
    required this.achievement,
    required this.isUnlocked,
    super.key,
    this.onTap,
    this.showProgress = false,
    this.progress,
    this.animateOnAppear = true,
    this.animationDelay,
  });
  final Achievement achievement;
  final bool isUnlocked;
  final VoidCallback? onTap;
  final bool showProgress;
  final double? progress;
  final bool animateOnAppear;
  final int? animationDelay;

  @override
  State<ModernAchievementCard> createState() => _ModernAchievementCardState();
}

class _ModernAchievementCardState extends State<ModernAchievementCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    if (widget.animateOnAppear) {
      _animateIn();
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: EnhancedAnimationUtils.normalDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  void _animateIn() {
    final delay = widget.animationDelay ?? 0;
    Future.delayed(Duration(milliseconds: 100 + (delay * 100)), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  IconData _getAchievementIcon() {
    switch (widget.achievement.iconName) {
      case 'flame':
      case 'flame_fill':
        return CupertinoIcons.flame_fill;
      case 'star':
      case 'star_fill':
        return CupertinoIcons.star_fill;
      case 'trophy':
        return CupertinoIcons.rosette;
      case 'medal':
        return CupertinoIcons.star_circle_fill;
      case 'crown':
        return CupertinoIcons.star_circle_fill;
      case 'diamond':
        return CupertinoIcons.star_fill;
      default:
        return CupertinoIcons.star_fill;
    }
  }

  Color _getAchievementColor() {
    if (!widget.isUnlocked) {
      return CupertinoColors.systemGrey;
    }

    switch (widget.achievement.rarity) {
      case AchievementRarity.common:
        return CupertinoColors.systemGreen;
      case AchievementRarity.uncommon:
        return CupertinoColors.systemOrange;
      case AchievementRarity.rare:
        return CupertinoColors.systemBlue;
      case AchievementRarity.epic:
        return CupertinoColors.systemPurple;
      case AchievementRarity.legendary:
        return CupertinoColors.systemYellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final achievementColor = _getAchievementColor();
    final isLocked = !widget.isUnlocked;

    Widget content = ModernCard(
      isInteractive: widget.onTap != null,
      onTap: widget.onTap,
      backgroundColor: isLocked
          ? CupertinoColors.systemGrey6
          : achievementColor.withValues(alpha: 0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isLocked
                  ? CupertinoColors.systemGrey4
                  : achievementColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isLocked
                    ? CupertinoColors.systemGrey3
                    : achievementColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              _getAchievementIcon(),
              size: 28,
              color: isLocked ? CupertinoColors.systemGrey : achievementColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.achievement.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isLocked
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.label,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            widget.achievement.description,
            style: TextStyle(
              fontSize: 12,
              color: isLocked
                  ? CupertinoColors.systemGrey2
                  : CupertinoColors.secondaryLabel,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.showProgress && widget.progress != null) ...[
            const SizedBox(height: 12),
            _buildProgressIndicator(),
          ],
          if (widget.achievement.coinsReward > 0 ||
              widget.achievement.xpReward > 0) ...[
            const SizedBox(height: 8),
            _buildRewards(),
          ],
        ],
      ),
    );

    if (widget.animateOnAppear) {
      content = AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(opacity: _fadeAnimation.value, child: child),
        ),
        child: content,
      );
    }

    return content;
  }

  Widget _buildProgressIndicator() {
    final progress = widget.progress!.clamp(0.0, 1.0);
    final achievementColor = _getAchievementColor();

    return Column(
      children: [
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey5,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: achievementColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).round()}%',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: CupertinoColors.secondaryLabel,
          ),
        ),
      ],
    );
  }

  Widget _buildRewards() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      if (widget.achievement.xpReward > 0) ...[
        const Icon(
          CupertinoIcons.bolt_fill,
          size: 12,
          color: CupertinoColors.systemPurple,
        ),
        const SizedBox(width: 2),
        Text(
          '${widget.achievement.xpReward}',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.systemPurple,
          ),
        ),
      ],
      if (widget.achievement.xpReward > 0 && widget.achievement.coinsReward > 0)
        const SizedBox(width: 8),
      if (widget.achievement.coinsReward > 0) ...[
        const Icon(
          CupertinoIcons.money_dollar_circle_fill,
          size: 12,
          color: CupertinoColors.systemYellow,
        ),
        const SizedBox(width: 2),
        Text(
          '${widget.achievement.coinsReward}',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.systemYellow,
          ),
        ),
      ],
    ],
  );
}

/// Modern badge widget for displaying small achievements or status
class ModernBadge extends StatelessWidget {
  const ModernBadge({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    super.key,
    this.icon,
    this.isSmall = false,
  });
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final bool isSmall;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: isSmall ? 8 : 12,
      vertical: isSmall ? 4 : 6,
    ),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(isSmall ? 8 : 12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: isSmall ? 12 : 16, color: textColor),
          SizedBox(width: isSmall ? 4 : 6),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: isSmall ? 10 : 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    ),
  );
}

/// Modern streak indicator
class ModernStreakIndicator extends StatefulWidget {
  const ModernStreakIndicator({
    required this.streakDays,
    required this.isActive,
    super.key,
    this.activeColor,
    this.animateOnAppear = true,
  });
  final int streakDays;
  final bool isActive;
  final Color? activeColor;
  final bool animateOnAppear;

  @override
  State<ModernStreakIndicator> createState() => _ModernStreakIndicatorState();
}

class _ModernStreakIndicatorState extends State<ModernStreakIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    if (widget.animateOnAppear && widget.isActive) {
      _startPulseAnimation();
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _startPulseAnimation() {
    _animationController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(ModernStreakIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _startPulseAnimation();
    } else if (!widget.isActive && oldWidget.isActive) {
      _animationController
        ..stop()
        ..reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.activeColor ?? CupertinoColors.systemOrange;

    Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: widget.isActive
            ? effectiveColor.withValues(alpha: 0.1)
            : CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isActive
              ? effectiveColor.withValues(alpha: 0.3)
              : CupertinoColors.systemGrey4,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.flame_fill,
            size: 20,
            color: widget.isActive
                ? effectiveColor
                : CupertinoColors.systemGrey,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.streakDays}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.isActive
                      ? effectiveColor
                      : CupertinoColors.systemGrey,
                ),
              ),
              Text(
                widget.streakDays == 1 ? 'day' : 'days',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.isActive
                      ? effectiveColor
                      : CupertinoColors.systemGrey2,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (widget.isActive && widget.animateOnAppear) {
      content = AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) =>
            Transform.scale(scale: _pulseAnimation.value, child: child),
        child: content,
      );
    }

    return content;
  }
}

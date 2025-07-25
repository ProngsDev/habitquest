import 'package:flutter/cupertino.dart';

import '../../../core/utils/enhanced_animation_utils.dart';
import 'modern_card.dart';

/// Modern stat card with iOS-like design
class ModernStatCard extends StatefulWidget {
  const ModernStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    super.key,
    this.subtitle,
    this.backgroundColor,
    this.onTap,
    this.showTrend = false,
    this.trendValue,
    this.animateOnAppear = true,
  });
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool showTrend;
  final double? trendValue;
  final bool animateOnAppear;

  @override
  State<ModernStatCard> createState() => _ModernStatCardState();
}

class _ModernStatCardState extends State<ModernStatCard>
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
    Future.delayed(const Duration(milliseconds: 100), () {
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

  @override
  Widget build(BuildContext context) {
    Widget content = ModernCard(
      backgroundColor: widget.backgroundColor,
      isInteractive: widget.onTap != null,
      onTap: widget.onTap,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 20),
              ),
              const Spacer(),
              if (widget.showTrend && widget.trendValue != null)
                _buildTrendIndicator(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
          ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.subtitle!,
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
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

  Widget _buildTrendIndicator() {
    final isPositive = widget.trendValue! > 0;

    if (widget.trendValue == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPositive
            ? CupertinoColors.systemGreen.withOpacity(0.1)
            : CupertinoColors.systemRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? CupertinoIcons.arrow_up : CupertinoIcons.arrow_down,
            size: 12,
            color: isPositive
                ? CupertinoColors.systemGreen
                : CupertinoColors.systemRed,
          ),
          const SizedBox(width: 2),
          Text(
            '${widget.trendValue!.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isPositive
                  ? CupertinoColors.systemGreen
                  : CupertinoColors.systemRed,
            ),
          ),
        ],
      ),
    );
  }
}

/// Modern level card with progress indicator
class ModernLevelCard extends StatefulWidget {
  const ModernLevelCard({
    required this.currentLevel,
    required this.totalXp,
    required this.xpInCurrentLevel,
    required this.xpRequiredForNextLevel,
    required this.progressPercentage,
    super.key,
    this.levelColor,
    this.animateProgress = true,
  });
  final int currentLevel;
  final int totalXp;
  final int xpInCurrentLevel;
  final int xpRequiredForNextLevel;
  final double progressPercentage;
  final Color? levelColor;
  final bool animateProgress;

  @override
  State<ModernLevelCard> createState() => _ModernLevelCardState();
}

class _ModernLevelCardState extends State<ModernLevelCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _setupProgressAnimation();
  }

  void _setupProgressAnimation() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0, end: widget.progressPercentage)
        .animate(
          CurvedAnimation(
            parent: _progressController,
            curve: Curves.easeOutCubic,
          ),
        );

    if (widget.animateProgress) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _progressController.forward();
        }
      });
    }
  }

  @override
  void didUpdateWidget(ModernLevelCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progressPercentage != oldWidget.progressPercentage) {
      _progressAnimation =
          Tween<double>(
            begin: oldWidget.progressPercentage,
            end: widget.progressPercentage,
          ).animate(
            CurvedAnimation(
              parent: _progressController,
              curve: Curves.easeOutCubic,
            ),
          );

      if (widget.animateProgress) {
        _progressController
          ..reset()
          ..forward();
      }
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveLevelColor = widget.levelColor ?? CupertinoColors.systemBlue;

    return ModernCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      effectiveLevelColor,
                      effectiveLevelColor.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.star_fill,
                      color: CupertinoColors.white,
                      size: 20,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.currentLevel}',
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level ${widget.currentLevel}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.label,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.totalXp} XP Total',
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.xpInCurrentLevel} XP',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.label,
                    ),
                  ),
                  Text(
                    '${widget.xpRequiredForNextLevel} XP to Level ${widget.currentLevel + 1}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: AnimatedBuilder(
                  animation: widget.animateProgress
                      ? _progressAnimation
                      : AlwaysStoppedAnimation(widget.progressPercentage),
                  builder: (context, child) {
                    final currentProgress = widget.animateProgress
                        ? _progressAnimation.value
                        : widget.progressPercentage;
                    return FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: currentProgress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              effectiveLevelColor,
                              effectiveLevelColor.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

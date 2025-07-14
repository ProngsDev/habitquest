import 'package:flutter/cupertino.dart';

import '../../../core/utils/enhanced_animation_utils.dart';

/// Modern iOS-like card widget with enhanced styling
class ModernCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double borderRadius;
  final bool hasShadow;
  final bool isInteractive;
  final VoidCallback? onTap;
  final bool animateOnTap;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius = 16.0,
    this.hasShadow = true,
    this.isInteractive = false,
    this.onTap,
    this.animateOnTap = true,
  });

  @override
  State<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<ModernCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: EnhancedAnimationUtils.ultraFastDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isInteractive && widget.animateOnTap) {
      setState(() {
        _isPressed = true;
      });
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isInteractive && widget.animateOnTap) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.isInteractive && widget.animateOnTap) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = widget.backgroundColor ??
        CupertinoTheme.of(context).scaffoldBackgroundColor;

    Widget card = Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: widget.padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: widget.hasShadow
            ? [
                BoxShadow(
                  color: CupertinoColors.systemGrey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: CupertinoColors.systemGrey.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
        border: Border.all(
          color: CupertinoColors.systemGrey.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: widget.child,
    );

    if (widget.isInteractive) {
      card = GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        child: card,
      );

      if (widget.animateOnTap) {
        card = ScaleTransition(
          scale: _scaleAnimation,
          child: card,
        );
      }
    }

    return card;
  }
}

/// Modern button with iOS-like styling
class ModernButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final bool isLoading;
  final bool isDisabled;
  final ModernButtonStyle style;

  const ModernButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius = 12.0,
    this.isLoading = false,
    this.isDisabled = false,
    this.style = ModernButtonStyle.filled,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: EnhancedAnimationUtils.ultraFastDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color get _effectiveBackgroundColor {
    if (widget.isDisabled) {
      return CupertinoColors.systemGrey4;
    }

    switch (widget.style) {
      case ModernButtonStyle.filled:
        return widget.backgroundColor ?? CupertinoColors.systemBlue;
      case ModernButtonStyle.outlined:
        return CupertinoColors.systemBackground;
      case ModernButtonStyle.text:
        return CupertinoColors.systemBackground;
    }
  }

  Color get _effectiveForegroundColor {
    if (widget.isDisabled) {
      return CupertinoColors.systemGrey;
    }

    switch (widget.style) {
      case ModernButtonStyle.filled:
        return widget.foregroundColor ?? CupertinoColors.white;
      case ModernButtonStyle.outlined:
      case ModernButtonStyle.text:
        return widget.foregroundColor ?? CupertinoColors.systemBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: widget.isDisabled || widget.isLoading
            ? null
            : (_) => _animationController.forward(),
        onTapUp: widget.isDisabled || widget.isLoading
            ? null
            : (_) => _animationController.reverse(),
        onTapCancel: widget.isDisabled || widget.isLoading
            ? null
            : () => _animationController.reverse(),
        onTap: widget.isDisabled || widget.isLoading ? null : widget.onPressed,
        child: Container(
          padding: widget.padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: _effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.style == ModernButtonStyle.outlined
                ? Border.all(
                    color: _effectiveForegroundColor.withOpacity(0.3),
                    width: 1.5,
                  )
                : null,
          ),
          child: widget.isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CupertinoActivityIndicator(
                    color: _effectiveForegroundColor,
                    radius: 10,
                  ),
                )
              : DefaultTextStyle(
                  style: TextStyle(
                    color: _effectiveForegroundColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  child: widget.child,
                ),
        ),
      ),
    );
  }
}

enum ModernButtonStyle {
  filled,
  outlined,
  text,
}

/// Modern progress indicator
class ModernProgressIndicator extends StatefulWidget {
  final double progress;
  final Color? progressColor;
  final Color? backgroundColor;
  final double height;
  final bool showPercentage;
  final bool animated;

  const ModernProgressIndicator({
    super.key,
    required this.progress,
    this.progressColor,
    this.backgroundColor,
    this.height = 8.0,
    this.showPercentage = false,
    this.animated = true,
  });

  @override
  State<ModernProgressIndicator> createState() => _ModernProgressIndicatorState();
}

class _ModernProgressIndicatorState extends State<ModernProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: EnhancedAnimationUtils.normalDuration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.animated) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(ModernProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress != oldWidget.progress) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));

      if (widget.animated) {
        _animationController.reset();
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveProgressColor = widget.progressColor ?? CupertinoColors.systemBlue;
    final effectiveBackgroundColor = widget.backgroundColor ?? CupertinoColors.systemGrey5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(widget.height / 2),
          ),
          child: AnimatedBuilder(
            animation: widget.animated ? _progressAnimation : AlwaysStoppedAnimation(widget.progress),
            builder: (context, child) {
              final currentProgress = widget.animated ? _progressAnimation.value : widget.progress;
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: currentProgress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: effectiveProgressColor,
                    borderRadius: BorderRadius.circular(widget.height / 2),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.showPercentage) ...[
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: widget.animated ? _progressAnimation : AlwaysStoppedAnimation(widget.progress),
            builder: (context, child) {
              final currentProgress = widget.animated ? _progressAnimation.value : widget.progress;
              return Text(
                '${(currentProgress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.secondaryLabel,
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

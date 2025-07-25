import 'package:flutter/cupertino.dart';

/// Enhanced animation utilities for HabitQuest
class EnhancedAnimationUtils {
  // Animation durations
  static const Duration ultraFastDuration = Duration(milliseconds: 150);
  static const Duration fastDuration = Duration(milliseconds: 250);
  static const Duration normalDuration = Duration(milliseconds: 350);
  static const Duration slowDuration = Duration(milliseconds: 500);
  static const Duration ultraSlowDuration = Duration(milliseconds: 800);

  // Animation curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeOutCubic;
  static const Curve sharpCurve = Curves.easeInCubic;

  /// Create a smooth scale animation
  static Widget createScaleAnimation({
    required Widget child,
    required AnimationController controller,
    double beginScale = 0.0,
    double endScale = 1.0,
    Curve curve = defaultCurve,
  }) {
    final animation = Tween<double>(
      begin: beginScale,
      end: endScale,
    ).animate(CurvedAnimation(parent: controller, curve: curve));

    return ScaleTransition(scale: animation, child: child);
  }

  /// Create a slide animation
  static Widget createSlideAnimation({
    required Widget child,
    required AnimationController controller,
    Offset beginOffset = const Offset(0, 1),
    Offset endOffset = Offset.zero,
    Curve curve = defaultCurve,
  }) {
    final animation = Tween<Offset>(
      begin: beginOffset,
      end: endOffset,
    ).animate(CurvedAnimation(parent: controller, curve: curve));

    return SlideTransition(position: animation, child: child);
  }

  /// Create a fade animation
  static Widget createFadeAnimation({
    required Widget child,
    required AnimationController controller,
    double beginOpacity = 0.0,
    double endOpacity = 1.0,
    Curve curve = defaultCurve,
  }) {
    final animation = Tween<double>(
      begin: beginOpacity,
      end: endOpacity,
    ).animate(CurvedAnimation(parent: controller, curve: curve));

    return FadeTransition(opacity: animation, child: child);
  }

  /// Create a rotation animation
  static Widget createRotationAnimation({
    required Widget child,
    required AnimationController controller,
    double beginRotation = 0.0,
    double endRotation = 1.0,
    Curve curve = defaultCurve,
  }) {
    final animation = Tween<double>(
      begin: beginRotation,
      end: endRotation,
    ).animate(CurvedAnimation(parent: controller, curve: curve));

    return RotationTransition(turns: animation, child: child);
  }

  /// Create a combined scale and fade animation
  static Widget createScaleFadeAnimation({
    required Widget child,
    required AnimationController controller,
    double beginScale = 0.8,
    double endScale = 1.0,
    double beginOpacity = 0.0,
    double endOpacity = 1.0,
    Curve curve = defaultCurve,
  }) {
    final scaleAnimation = Tween<double>(
      begin: beginScale,
      end: endScale,
    ).animate(CurvedAnimation(parent: controller, curve: curve));

    final fadeAnimation = Tween<double>(
      begin: beginOpacity,
      end: endOpacity,
    ).animate(CurvedAnimation(parent: controller, curve: curve));

    return ScaleTransition(
      scale: scaleAnimation,
      child: FadeTransition(opacity: fadeAnimation, child: child),
    );
  }

  /// Create a bounce animation
  static Widget createBounceAnimation({
    required Widget child,
    required AnimationController controller,
    double intensity = 0.2,
  }) {
    final animation = Tween<double>(
      begin: 1,
      end: 1.0 + intensity,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));

    return ScaleTransition(scale: animation, child: child);
  }

  /// Create a shake animation
  static Widget createShakeAnimation({
    required Widget child,
    required AnimationController controller,
    double intensity = 10.0,
  }) {
    final animation = Tween<double>(
      begin: -intensity,
      end: intensity,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticIn));

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) =>
          Transform.translate(offset: Offset(animation.value, 0), child: child),
      child: child,
    );
  }

  /// Create a pulse animation
  static Widget createPulseAnimation({
    required Widget child,
    required AnimationController controller,
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    final animation = Tween<double>(
      begin: minScale,
      end: maxScale,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    return ScaleTransition(scale: animation, child: child);
  }

  /// Create a staggered list animation
  static Widget createStaggeredAnimation({
    required Widget child,
    required int index,
    required AnimationController controller,
    required TickerProvider vsync,
    Duration staggerDelay = const Duration(milliseconds: 100),
    Curve curve = defaultCurve,
  }) {
    final delayedController = AnimationController(
      duration: controller.duration,
      vsync: vsync,
    );

    // Start the animation with a delay based on index
    Future.delayed(staggerDelay * index, () {
      if (delayedController.isCompleted || delayedController.isAnimating) {
        return;
      }
      delayedController.forward();
    });

    return createScaleFadeAnimation(
      child: child,
      controller: delayedController,
      curve: curve,
    );
  }

  /// Create a morphing container animation
  static Widget createMorphingContainer({
    required Widget child,
    required AnimationController controller,
    required Color beginColor,
    required Color endColor,
    required BorderRadius beginBorderRadius,
    required BorderRadius endBorderRadius,
    Curve curve = defaultCurve,
  }) {
    final colorAnimation = ColorTween(
      begin: beginColor,
      end: endColor,
    ).animate(CurvedAnimation(parent: controller, curve: curve));

    final borderRadiusAnimation = BorderRadiusTween(
      begin: beginBorderRadius,
      end: endBorderRadius,
    ).animate(CurvedAnimation(parent: controller, curve: curve));

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => DecoratedBox(
        decoration: BoxDecoration(
          color: colorAnimation.value,
          borderRadius: borderRadiusAnimation.value,
        ),
        child: child,
      ),
      child: child,
    );
  }

  /// Create a ripple effect animation
  static Widget createRippleAnimation({
    required Widget child,
    required AnimationController controller,
    Color rippleColor = CupertinoColors.systemBlue,
    double maxRadius = 100.0,
  }) {
    final radiusAnimation = Tween<double>(
      begin: 0,
      end: maxRadius,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    final opacityAnimation = Tween<double>(
      begin: 0.5,
      end: 0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        AnimatedBuilder(
          animation: controller,
          builder: (context, child) => Container(
            width: radiusAnimation.value * 2,
            height: radiusAnimation.value * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: rippleColor.withValues(alpha: opacityAnimation.value),
            ),
          ),
        ),
      ],
    );
  }

  /// Create a typing animation for text
  static Widget createTypingAnimation({
    required String text,
    required AnimationController controller,
    TextStyle? style,
    Duration characterDelay = const Duration(milliseconds: 50),
  }) => AnimatedBuilder(
    animation: controller,
    builder: (context, child) {
      final progress = controller.value;
      final visibleCharacters = (text.length * progress).round();
      final visibleText = text.substring(0, visibleCharacters);

      return Text(visibleText, style: style);
    },
  );

  /// Create a progress bar animation
  static Widget createProgressBarAnimation({
    required AnimationController controller,
    required double progress,
    Color progressColor = CupertinoColors.systemBlue,
    Color backgroundColor = CupertinoColors.systemGrey5,
    double height = 8.0,
    BorderRadius? borderRadius,
  }) {
    final progressAnimation = Tween<double>(
      begin: 0,
      end: progress,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => Container(
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progressAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: progressColor,
              borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
            ),
          ),
        ),
      ),
    );
  }
}

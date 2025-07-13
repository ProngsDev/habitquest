import 'package:flutter/cupertino.dart';
import 'package:confetti/confetti.dart';

/// Animation constants and utilities for consistent animations throughout the app
class AnimationUtils {
  // Animation durations
  static const Duration fastDuration = Duration(milliseconds: 200);
  static const Duration normalDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 500);
  static const Duration extraSlowDuration = Duration(milliseconds: 800);

  // Animation curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeOutCubic;
  static const Curve sharpCurve = Curves.easeInCubic;

  // Scale animation values
  static const double scaleStart = 0.0;
  static const double scaleNormal = 1.0;
  static const double scalePressed = 0.95;
  static const double scaleExpanded = 1.05;

  // Opacity values
  static const double opacityHidden = 0.0;
  static const double opacityVisible = 1.0;
  static const double opacityDisabled = 0.5;

  // Slide animation offsets
  static const Offset slideFromLeft = Offset(-1.0, 0.0);
  static const Offset slideFromRight = Offset(1.0, 0.0);
  static const Offset slideFromTop = Offset(0.0, -1.0);
  static const Offset slideFromBottom = Offset(0.0, 1.0);
  static const Offset slideCenter = Offset.zero;

  /// Create a fade transition
  static Widget fadeTransition({
    required Animation<double> animation,
    required Widget child,
    Curve curve = defaultCurve,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: curve),
      child: child,
    );
  }

  /// Create a scale transition
  static Widget scaleTransition({
    required Animation<double> animation,
    required Widget child,
    Curve curve = defaultCurve,
    Alignment alignment = Alignment.center,
  }) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: animation, curve: curve),
      alignment: alignment,
      child: child,
    );
  }

  /// Create a slide transition
  static Widget slideTransition({
    required Animation<double> animation,
    required Widget child,
    required Offset begin,
    Offset end = slideCenter,
    Curve curve = defaultCurve,
  }) {
    return SlideTransition(
      position: Tween<Offset>(begin: begin, end: end).animate(
        CurvedAnimation(parent: animation, curve: curve),
      ),
      child: child,
    );
  }

  /// Create a combined fade and scale transition
  static Widget fadeScaleTransition({
    required Animation<double> animation,
    required Widget child,
    Curve curve = defaultCurve,
    double scaleBegin = scaleStart,
    double scaleEnd = scaleNormal,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: curve),
      child: ScaleTransition(
        scale: Tween<double>(begin: scaleBegin, end: scaleEnd).animate(
          CurvedAnimation(parent: animation, curve: curve),
        ),
        child: child,
      ),
    );
  }

  /// Create a combined fade and slide transition
  static Widget fadeSlideTransition({
    required Animation<double> animation,
    required Widget child,
    required Offset begin,
    Offset end = slideCenter,
    Curve curve = defaultCurve,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: curve),
      child: SlideTransition(
        position: Tween<Offset>(begin: begin, end: end).animate(
          CurvedAnimation(parent: animation, curve: curve),
        ),
        child: child,
      ),
    );
  }

  /// Create a rotation transition
  static Widget rotationTransition({
    required Animation<double> animation,
    required Widget child,
    Curve curve = defaultCurve,
    Alignment alignment = Alignment.center,
  }) {
    return RotationTransition(
      turns: CurvedAnimation(parent: animation, curve: curve),
      alignment: alignment,
      child: child,
    );
  }

  /// Create a size transition
  static Widget sizeTransition({
    required Animation<double> animation,
    required Widget child,
    Curve curve = defaultCurve,
    Axis axis = Axis.vertical,
  }) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: curve),
      axis: axis,
      child: child,
    );
  }

  /// Create an animated container with smooth transitions
  static Widget animatedContainer({
    required Duration duration,
    required Widget child,
    Color? color,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Decoration? decoration,
    Curve curve = defaultCurve,
  }) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      color: color,
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: decoration,
      child: child,
    );
  }

  /// Create an animated opacity widget
  static Widget animatedOpacity({
    required Duration duration,
    required double opacity,
    required Widget child,
    Curve curve = defaultCurve,
  }) {
    return AnimatedOpacity(
      duration: duration,
      opacity: opacity,
      curve: curve,
      child: child,
    );
  }

  /// Create an animated positioned widget
  static Widget animatedPositioned({
    required Duration duration,
    required Widget child,
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? width,
    double? height,
    Curve curve = defaultCurve,
  }) {
    return AnimatedPositioned(
      duration: duration,
      curve: curve,
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      width: width,
      height: height,
      child: child,
    );
  }

  /// Create a staggered animation for lists
  static Widget staggeredListAnimation({
    required int index,
    required Widget child,
    Duration delay = const Duration(milliseconds: 100),
    Duration duration = normalDuration,
    Curve curve = defaultCurve,
    Offset slideBegin = slideFromBottom,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration + Duration(milliseconds: delay.inMilliseconds * index),
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset.lerp(slideBegin, Offset.zero, value)!,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Create a pulse animation
  static Widget pulseAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: minScale, end: maxScale),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      onEnd: () {
        // This would need to be implemented with a proper AnimationController
        // for continuous pulsing
      },
      child: child,
    );
  }

  /// Create a shake animation
  static Widget shakeAnimation({
    required Widget child,
    required AnimationController controller,
    double intensity = 5.0,
  }) {
    final animation = Tween<double>(begin: -intensity, end: intensity).animate(
      CurvedAnimation(parent: controller, curve: Curves.elasticIn),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(animation.value, 0),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Create confetti animation for celebrations
  static Widget confettiAnimation({
    required ConfettiController controller,
    required Widget child,
    BlastDirection blastDirection = BlastDirection.explosive,
    int numberOfParticles = 50,
    double gravity = 0.1,
    Color? color,
  }) {
    return Stack(
      children: [
        child,
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: controller,
            blastDirection: blastDirection,
            numberOfParticles: numberOfParticles,
            gravity: gravity,
            colors: color != null ? [color] : [
              CupertinoColors.systemBlue,
              CupertinoColors.systemGreen,
              CupertinoColors.systemYellow,
              CupertinoColors.systemOrange,
              CupertinoColors.systemPink,
              CupertinoColors.systemPurple,
            ],
          ),
        ),
      ],
    );
  }

  /// Create a loading animation
  static Widget loadingAnimation({
    double size = 20.0,
    Color color = CupertinoColors.systemBlue,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CupertinoActivityIndicator(
        color: color,
      ),
    );
  }

  /// Create a custom page transition
  static PageRouteBuilder<T> createPageTransition<T>({
    required Widget page,
    Duration duration = normalDuration,
    PageTransitionType type = PageTransitionType.slideFromRight,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (type) {
          case PageTransitionType.fade:
            return fadeTransition(animation: animation, child: child);
          case PageTransitionType.scale:
            return scaleTransition(animation: animation, child: child);
          case PageTransitionType.slideFromLeft:
            return slideTransition(
              animation: animation,
              child: child,
              begin: slideFromLeft,
            );
          case PageTransitionType.slideFromRight:
            return slideTransition(
              animation: animation,
              child: child,
              begin: slideFromRight,
            );
          case PageTransitionType.slideFromTop:
            return slideTransition(
              animation: animation,
              child: child,
              begin: slideFromTop,
            );
          case PageTransitionType.slideFromBottom:
            return slideTransition(
              animation: animation,
              child: child,
              begin: slideFromBottom,
            );
        }
      },
    );
  }
}

/// Page transition types
enum PageTransitionType {
  fade,
  scale,
  slideFromLeft,
  slideFromRight,
  slideFromTop,
  slideFromBottom,
}

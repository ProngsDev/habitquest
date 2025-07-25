import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

/// Widget for displaying task completion animations
class CompletionAnimationWidget extends StatefulWidget {

  const CompletionAnimationWidget({
    required this.child, required this.isCompleted, super.key,
    this.onAnimationComplete,
    this.animationType = CompletionAnimationType.scale,
  });
  final Widget child;
  final bool isCompleted;
  final VoidCallback? onAnimationComplete;
  final CompletionAnimationType animationType;

  @override
  State<CompletionAnimationWidget> createState() =>
      _CompletionAnimationWidgetState();
}

class _CompletionAnimationWidgetState extends State<CompletionAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(
        milliseconds: 200,
      ), // Optimized for iOS-like responsiveness
      vsync: this,
    );

    // Create smooth scale animation: 1.0 → 1.05 → 1.0
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 1.05,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40, // 40% of animation (80ms) - quick scale up
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.05,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 60, // 60% of animation (120ms) - smooth scale down
      ),
    ]).animate(_scaleController);
  }

  @override
  void didUpdateWidget(CompletionAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCompleted && !oldWidget.isCompleted) {
      _triggerAnimation();
    } else if (!widget.isCompleted && oldWidget.isCompleted) {
      // Reset animation state when habit is uncompleted
      _hasAnimated = false;
      _scaleController.reset();
    }
  }

  void _triggerAnimation() {
    if (_hasAnimated || _scaleController.isAnimating) return;
    _hasAnimated = true;

    switch (widget.animationType) {
      case CompletionAnimationType.scale:
      case CompletionAnimationType.bounce:
        // Single smooth animation cycle: 1.0 → 1.05 → 1.0
        _scaleController.forward().then((_) {
          if (mounted) {
            widget.onAnimationComplete?.call();
            // Reset for potential future use
            _scaleController.reset();
          }
        });
        break;
      case CompletionAnimationType.checkmark:
        // Checkmark overlay removed - just call completion callback
        widget.onAnimationComplete?.call();
        break;
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
      child: AnimatedBuilder(
        animation: _scaleController,
        builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          ),
      ),
    );
}

/// Types of completion animations
enum CompletionAnimationType { scale, checkmark, bounce }

/// Confetti animation widget for celebrations
class ConfettiAnimationWidget extends StatefulWidget {

  const ConfettiAnimationWidget({
    required this.child, required this.shouldPlay, super.key,
    this.onComplete,
  });
  final Widget child;
  final bool shouldPlay;
  final VoidCallback? onComplete;

  @override
  State<ConfettiAnimationWidget> createState() =>
      _ConfettiAnimationWidgetState();
}

class _ConfettiAnimationWidgetState extends State<ConfettiAnimationWidget> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void didUpdateWidget(ConfettiAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldPlay && !oldWidget.shouldPlay) {
      _confettiController.play();
      Future.delayed(const Duration(seconds: 3), () {
        widget.onComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
      children: [
        widget.child,
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 1.5708, // radians for downward
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.05,
            colors: const [
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

/// Lottie animation widget for celebrations
class CelebrationLottieWidget extends StatefulWidget {

  const CelebrationLottieWidget({
    required this.animationAsset, required this.shouldPlay, super.key,
    this.onComplete,
    this.size = 200,
  });
  final String animationAsset;
  final bool shouldPlay;
  final VoidCallback? onComplete;
  final double size;

  @override
  State<CelebrationLottieWidget> createState() =>
      _CelebrationLottieWidgetState();
}

class _CelebrationLottieWidgetState extends State<CelebrationLottieWidget>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(CelebrationLottieWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldPlay && !oldWidget.shouldPlay) {
      _lottieController.forward().then((_) {
        widget.onComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.shouldPlay) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Lottie.asset(
        widget.animationAsset,
        controller: _lottieController,
        onLoaded: (composition) {
          _lottieController.duration = composition.duration;
          if (widget.shouldPlay) {
            _lottieController.forward();
          }
        },
      ),
    );
  }
}

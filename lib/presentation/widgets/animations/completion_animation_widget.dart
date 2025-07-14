import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

import '../../../core/utils/animation_utils.dart';

/// Widget for displaying task completion animations
class CompletionAnimationWidget extends StatefulWidget {
  final Widget child;
  final bool isCompleted;
  final VoidCallback? onAnimationComplete;
  final CompletionAnimationType animationType;

  const CompletionAnimationWidget({
    super.key,
    required this.child,
    required this.isCompleted,
    this.onAnimationComplete,
    this.animationType = CompletionAnimationType.scale,
  });

  @override
  State<CompletionAnimationWidget> createState() =>
      _CompletionAnimationWidgetState();
}

class _CompletionAnimationWidgetState extends State<CompletionAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkmarkController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkmarkAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _scaleController = AnimationController(
      duration: AnimationUtils.normalDuration,
      vsync: this,
    );

    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _checkmarkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkmarkController, curve: Curves.elasticOut),
    );

    _checkmarkController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(CompletionAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCompleted && !oldWidget.isCompleted && !_hasAnimated) {
      _triggerAnimation();
    }
  }

  void _triggerAnimation() {
    if (_hasAnimated) return;
    _hasAnimated = true;

    switch (widget.animationType) {
      case CompletionAnimationType.scale:
        _scaleController.forward().then((_) {
          _scaleController.reverse();
          _checkmarkController.forward();
        });
        break;
      case CompletionAnimationType.checkmark:
        _checkmarkController.forward();
        break;
      case CompletionAnimationType.bounce:
        _scaleController.forward().then((_) {
          _scaleController.reverse();
        });
        break;
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkmarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleController, _checkmarkController]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(scale: _scaleAnimation.value, child: widget.child),
            if (widget.isCompleted && _checkmarkAnimation.value > 0)
              _buildCheckmarkOverlay(),
          ],
        );
      },
    );
  }

  Widget _buildCheckmarkOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            color: CupertinoColors.systemGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Transform.scale(
              scale: _checkmarkAnimation.value,
              child: const Icon(
                CupertinoIcons.checkmark_circle_fill,
                size: 40,
                color: CupertinoColors.systemGreen,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Types of completion animations
enum CompletionAnimationType { scale, checkmark, bounce }

/// Confetti animation widget for celebrations
class ConfettiAnimationWidget extends StatefulWidget {
  final Widget child;
  final bool shouldPlay;
  final VoidCallback? onComplete;

  const ConfettiAnimationWidget({
    super.key,
    required this.child,
    required this.shouldPlay,
    this.onComplete,
  });

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
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 1.5708, // radians for downward
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.05,
            shouldLoop: false,
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
}

/// Lottie animation widget for celebrations
class CelebrationLottieWidget extends StatefulWidget {
  final String animationAsset;
  final bool shouldPlay;
  final VoidCallback? onComplete;
  final double size;

  const CelebrationLottieWidget({
    super.key,
    required this.animationAsset,
    required this.shouldPlay,
    this.onComplete,
    this.size = 200,
  });

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

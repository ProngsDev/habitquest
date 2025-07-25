import 'package:flutter/cupertino.dart';

import 'custom_card.dart';

/// Loading widget with iOS-style activity indicator
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.message, this.color, this.size = 20});
  final String? message;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        width: size,
        height: size,
        child: CupertinoActivityIndicator(
          color: color ?? CupertinoColors.systemBlue,
        ),
      ),
      if (message != null) ...[
        const SizedBox(height: 16),
        Text(
          message!,
          style: const TextStyle(
            fontSize: 16,
            color: CupertinoColors.systemGrey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ],
  );
}

/// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key, this.message, this.isVisible = true});
  final String? message;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return ColoredBox(
      color: CupertinoColors.black.withValues(alpha: 0.3),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: LoadingWidget(message: message, size: 32),
        ),
      ),
    );
  }
}

/// Inline loading state for lists
class InlineLoadingWidget extends StatelessWidget {
  const InlineLoadingWidget({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CupertinoActivityIndicator(),
        if (message != null) ...[
          const SizedBox(width: 12),
          Text(
            message!,
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ],
    ),
  );
}

/// Loading button state
class LoadingButton extends StatelessWidget {
  const LoadingButton({
    required this.text,
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  });
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) => CupertinoButton(
    onPressed: isLoading ? null : onPressed,
    color: backgroundColor ?? CupertinoColors.systemBlue,
    borderRadius: BorderRadius.circular(12),
    child: isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CupertinoActivityIndicator(color: CupertinoColors.white),
          )
        : Text(
            text,
            style: TextStyle(
              color: textColor ?? CupertinoColors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
  );
}

/// Enhanced loading widget with card background
class CardLoadingWidget extends StatelessWidget {
  const CardLoadingWidget({super.key, this.message, this.size, this.color});
  final String? message;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) => CustomCard(
    child: LoadingWidget(message: message, size: size ?? 20, color: color),
  );
}

/// Skeleton loading widget for list items
class SkeletonLoadingWidget extends StatefulWidget {
  const SkeletonLoadingWidget({
    required this.height,
    super.key,
    this.width,
    this.borderRadius,
  });
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  @override
  State<SkeletonLoadingWidget> createState() => _SkeletonLoadingWidgetState();
}

class _SkeletonLoadingWidgetState extends State<SkeletonLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.3,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _animation,
    builder: (context, child) => Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey5.withOpacity(_animation.value),
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
      ),
    ),
  );
}

import 'package:flutter/cupertino.dart';

/// Loading widget with iOS-style activity indicator
class LoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;
  final double size;

  const LoadingWidget({
    super.key,
    this.message,
    this.color,
    this.size = 20,
  });

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
  final String? message;
  final bool isVisible;

  const LoadingOverlay({
    super.key,
    this.message,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      color: CupertinoColors.black.withOpacity(0.3),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: LoadingWidget(
            message: message,
            size: 32,
          ),
        ),
      ),
    );
  }
}

/// Inline loading state for lists
class InlineLoadingWidget extends StatelessWidget {
  final String? message;

  const InlineLoadingWidget({
    super.key,
    this.message,
  });

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
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  const LoadingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) => CupertinoButton(
      onPressed: isLoading ? null : onPressed,
      color: backgroundColor ?? CupertinoColors.systemBlue,
      borderRadius: BorderRadius.circular(12),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CupertinoActivityIndicator(
                color: CupertinoColors.white,
              ),
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

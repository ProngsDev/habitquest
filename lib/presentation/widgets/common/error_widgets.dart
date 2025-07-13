import 'package:flutter/cupertino.dart';

import '../../../core/utils/animation_utils.dart';
import 'custom_card.dart';

/// Error widget for displaying errors in a consistent way
class ErrorWidget extends StatelessWidget {
  final String message;
  final String? title;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryText;
  final bool showIcon;

  const ErrorWidget({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.onRetry,
    this.retryText,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              icon ?? CupertinoIcons.exclamationmark_triangle,
              size: 48,
              color: CupertinoColors.systemRed,
            ),
            const SizedBox(height: 16),
          ],
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.secondaryLabel,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            CupertinoButton(
              onPressed: onRetry,
              color: CupertinoColors.systemBlue,
              borderRadius: BorderRadius.circular(8),
              child: Text(retryText ?? 'Try Again'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Network error widget
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorWidget(
      title: 'Connection Error',
      message: 'Please check your internet connection and try again.',
      icon: CupertinoIcons.wifi_slash,
      onRetry: onRetry,
    );
  }
}

/// Data not found error widget
class DataNotFoundWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const DataNotFoundWidget({
    super.key,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorWidget(
      title: 'No Data Found',
      message: message ?? 'The requested data could not be found.',
      icon: CupertinoIcons.doc_text_search,
      onRetry: onRetry,
    );
  }
}

/// Permission error widget
class PermissionErrorWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const PermissionErrorWidget({
    super.key,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorWidget(
      title: 'Permission Required',
      message: message ?? 'This feature requires additional permissions.',
      icon: CupertinoIcons.lock_shield,
      onRetry: onRetry,
      retryText: 'Grant Permission',
    );
  }
}

/// Generic error widget with animation
class AnimatedErrorWidget extends StatefulWidget {
  final String message;
  final String? title;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryText;

  const AnimatedErrorWidget({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.onRetry,
    this.retryText,
  });

  @override
  State<AnimatedErrorWidget> createState() => _AnimatedErrorWidgetState();
}

class _AnimatedErrorWidgetState extends State<AnimatedErrorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationUtils.normalDuration,
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimationUtils.fadeScaleTransition(
      animation: _controller,
      child: ErrorWidget(
        message: widget.message,
        title: widget.title,
        icon: widget.icon,
        onRetry: widget.onRetry,
        retryText: widget.retryText,
      ),
    );
  }
}

/// Error boundary widget for catching and displaying errors
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!, _stackTrace) ??
          ErrorWidget(
            title: 'Something went wrong',
            message: 'An unexpected error occurred. Please try again.',
            onRetry: () {
              setState(() {
                _error = null;
                _stackTrace = null;
              });
            },
          );
    }

    return widget.child;
  }

  void _handleError(Object error, StackTrace stackTrace) {
    setState(() {
      _error = error;
      _stackTrace = stackTrace;
    });
  }
}

/// Inline error widget for form fields
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final bool visible;

  const InlineErrorWidget({
    super.key,
    required this.message,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: AnimationUtils.fastDuration,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          color: CupertinoColors.systemRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: CupertinoColors.systemRed.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_circle_fill,
              size: 16,
              color: CupertinoColors.systemRed,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Success message widget
class SuccessWidget extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onDismiss;

  const SuccessWidget({
    super.key,
    required this.message,
    this.title,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      backgroundColor: CupertinoColors.systemGreen.withOpacity(0.1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            CupertinoIcons.checkmark_circle_fill,
            size: 48,
            color: CupertinoColors.systemGreen,
          ),
          const SizedBox(height: 16),
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.secondaryLabel,
            ),
            textAlign: TextAlign.center,
          ),
          if (onDismiss != null) ...[
            const SizedBox(height: 16),
            CupertinoButton(
              onPressed: onDismiss,
              color: CupertinoColors.systemGreen,
              borderRadius: BorderRadius.circular(8),
              child: const Text('OK'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Warning widget
class WarningWidget extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onAction;
  final String? actionText;

  const WarningWidget({
    super.key,
    required this.message,
    this.title,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      backgroundColor: CupertinoColors.systemYellow.withOpacity(0.1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle_fill,
            size: 48,
            color: CupertinoColors.systemYellow,
          ),
          const SizedBox(height: 16),
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.secondaryLabel,
            ),
            textAlign: TextAlign.center,
          ),
          if (onAction != null) ...[
            const SizedBox(height: 16),
            CupertinoButton(
              onPressed: onAction,
              color: CupertinoColors.systemYellow,
              borderRadius: BorderRadius.circular(8),
              child: Text(actionText ?? 'OK'),
            ),
          ],
        ],
      ),
    );
  }
}

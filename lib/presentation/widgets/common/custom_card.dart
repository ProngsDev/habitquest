import 'package:flutter/material.dart';

/// Custom card widget with iOS-style design
class CustomCard extends StatelessWidget {
  const CustomCard({
    required this.child,
    super.key,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.showShadow = true,
  });
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultBackgroundColor =
        backgroundColor ?? (isDark ? Colors.grey[850] : Colors.white);

    final defaultBorderRadius = borderRadius ?? BorderRadius.circular(12);

    final Widget cardContent = Container(
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      decoration: BoxDecoration(
        color: defaultBackgroundColor,
        borderRadius: defaultBorderRadius,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
        border: isDark
            ? Border.all(color: Colors.grey[700]!, width: 0.5)
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: defaultBorderRadius,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

/// Compact card variant
class CustomCardCompact extends StatelessWidget {
  const CustomCardCompact({
    required this.child,
    super.key,
    this.onTap,
    this.backgroundColor,
  });
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) => CustomCard(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.symmetric(vertical: 4),
    onTap: onTap,
    backgroundColor: backgroundColor,
    child: child,
  );
}

/// List tile style card
class CustomListCard extends StatelessWidget {
  const CustomListCard({
    required this.title,
    super.key,
    this.leading,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding,
  });
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => CustomCard(
    padding: padding ?? const EdgeInsets.all(16),
    margin: const EdgeInsets.symmetric(vertical: 4),
    onTap: onTap,
    child: Row(
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 12)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              title,
              if (subtitle != null) ...[const SizedBox(height: 4), subtitle!],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    ),
  );
}

import 'dart:ui';
import 'package:flutter/cupertino.dart';

/// Glassmorphism effect widget for modern iOS-like design
class GlassmorphismWidget extends StatelessWidget {
  final Widget child;
  final double blurIntensity;
  final double opacity;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final List<Color>? gradientColors;
  final Border? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassmorphismWidget({
    super.key,
    required this.child,
    this.blurIntensity = 10.0,
    this.opacity = 0.8,
    this.borderRadius,
    this.backgroundColor,
    this.gradientColors,
    this.border,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    final defaultBorderRadius = borderRadius ?? BorderRadius.circular(16);
    final defaultBackgroundColor =
        backgroundColor ??
        (isDark
            ? CupertinoColors.systemGrey6.darkColor.withValues(alpha: opacity)
            : CupertinoColors.systemBackground.color.withValues(
                alpha: opacity,
              ));

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: defaultBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurIntensity,
            sigmaY: blurIntensity,
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: defaultBackgroundColor,
              gradient: gradientColors != null
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors!,
                    )
                  : null,
              borderRadius: defaultBorderRadius,
              border: border ?? _getDefaultBorder(isDark),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Border _getDefaultBorder(bool isDark) {
    return Border.all(
      color: isDark
          ? CupertinoColors.white.withValues(alpha: 0.1)
          : CupertinoColors.black.withValues(alpha: 0.05),
      width: 1,
    );
  }
}

/// Glassmorphism card with enhanced styling
class GlassmorphismCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double blurIntensity;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final bool showShadow;

  const GlassmorphismCard({
    super.key,
    required this.child,
    this.onTap,
    this.blurIntensity = 12.0,
    this.opacity = 0.85,
    this.padding,
    this.margin,
    this.borderRadius,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = CupertinoTheme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    Widget content = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        boxShadow: showShadow ? _buildShadows(isDark) : null,
      ),
      child: GlassmorphismWidget(
        blurIntensity: blurIntensity,
        opacity: opacity,
        borderRadius: borderRadius,
        padding: padding ?? const EdgeInsets.all(20),
        child: child,
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }

    return content;
  }

  List<BoxShadow> _buildShadows(bool isDark) {
    if (isDark) {
      return [
        BoxShadow(
          color: CupertinoColors.black.withValues(alpha: 0.4),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: CupertinoColors.black.withValues(alpha: 0.2),
          blurRadius: 40,
          offset: const Offset(0, 16),
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: CupertinoColors.black.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: CupertinoColors.black.withValues(alpha: 0.05),
          blurRadius: 40,
          offset: const Offset(0, 16),
        ),
      ];
    }
  }
}

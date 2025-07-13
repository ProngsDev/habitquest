import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Custom button widget with iOS-style design
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 50.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final defaultBackgroundColor = isSecondary
        ? (isDark ? Colors.grey[800] : Colors.grey[200])
        : theme.primaryColor;
    
    final defaultTextColor = isSecondary
        ? theme.textTheme.bodyLarge?.color
        : Colors.white;

    return SizedBox(
      width: width,
      height: height,
      child: CupertinoButton(
        onPressed: isLoading ? null : onPressed,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
        color: backgroundColor ?? defaultBackgroundColor,
        borderRadius: BorderRadius.circular(12.0),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CupertinoActivityIndicator(
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: textColor ?? defaultTextColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: textColor ?? defaultTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Small variant of CustomButton
class CustomButtonSmall extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButtonSmall({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isSecondary: isSecondary,
      icon: icon,
      backgroundColor: backgroundColor,
      textColor: textColor,
      height: 36.0,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
    );
  }
}

/// Icon-only button variant
class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.iconColor,
    this.size = 44.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: size,
      height: size,
      child: CupertinoButton(
        onPressed: isLoading ? null : onPressed,
        padding: EdgeInsets.zero,
        color: backgroundColor ?? theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size / 4),
        child: isLoading
            ? SizedBox(
                width: size * 0.4,
                height: size * 0.4,
                child: const CupertinoActivityIndicator(),
              )
            : Icon(
                icon,
                color: iconColor ?? theme.primaryColor,
                size: size * 0.5,
              ),
      ),
    );
  }
}

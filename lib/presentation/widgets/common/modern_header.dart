import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Tooltip;

import '../../../core/utils/enhanced_animation_utils.dart';

/// Modern header widget with iOS-like design
class ModernHeader extends StatefulWidget {

  const ModernHeader({
    required this.title, super.key,
    this.subtitle,
    this.leading,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
    this.backgroundColor,
    this.animateOnAppear = true,
  });
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final bool animateOnAppear;

  @override
  State<ModernHeader> createState() => _ModernHeaderState();
}

class _ModernHeaderState extends State<ModernHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    if (widget.animateOnAppear) {
      _animateIn();
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: EnhancedAnimationUtils.normalDuration,
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  void _animateIn() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color:
            widget.backgroundColor ??
            CupertinoTheme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (widget.showBackButton || widget.leading != null) ...[
              widget.leading ?? _buildBackButton(),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.label,
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (widget.actions != null) ...[
              const SizedBox(width: 16),
              Row(mainAxisSize: MainAxisSize.min, children: widget.actions!),
            ],
          ],
        ),
      ),
    );

    if (widget.animateOnAppear) {
      content = AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(opacity: _fadeAnimation, child: child),
          ),
        child: content,
      );
    }

    return content;
  }

  Widget _buildBackButton() => CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: widget.onBackPressed ?? () => Navigator.of(context).pop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          CupertinoIcons.back,
          size: 20,
          color: CupertinoColors.label,
        ),
      ),
    );
}

/// Modern section header
class ModernSectionHeader extends StatelessWidget {

  const ModernSectionHeader({
    required this.title, super.key,
    this.subtitle,
    this.trailing,
    this.padding,
  });
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.label,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 16), trailing!],
        ],
      ),
    );
}

/// Modern action button for headers
class ModernActionButton extends StatefulWidget {

  const ModernActionButton({
    required this.icon, super.key,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.tooltip,
    this.isLoading = false,
  });
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? tooltip;
  final bool isLoading;

  @override
  State<ModernActionButton> createState() => _ModernActionButtonState();
}

class _ModernActionButtonState extends State<ModernActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: EnhancedAnimationUtils.ultraFastDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget button = ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: widget.onPressed != null && !widget.isLoading
            ? (_) => _animationController.forward()
            : null,
        onTapUp: widget.onPressed != null && !widget.isLoading
            ? (_) => _animationController.reverse()
            : null,
        onTapCancel: widget.onPressed != null && !widget.isLoading
            ? () => _animationController.reverse()
            : null,
        onTap: widget.onPressed != null && !widget.isLoading
            ? widget.onPressed
            : null,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(12),
          ),
          child: widget.isLoading
              ? const CupertinoActivityIndicator(radius: 8)
              : Icon(
                  widget.icon,
                  size: 20,
                  color: widget.iconColor ?? CupertinoColors.label,
                ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip, child: button);
    }

    return button;
  }
}

/// Modern tab bar for bottom navigation
class ModernTabBar extends StatelessWidget {

  const ModernTabBar({
    required this.currentIndex, required this.onTap, required this.items, super.key,
  });
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<ModernTabItem> items;

  @override
  Widget build(BuildContext context) => Container(
      height: 80,
      decoration: BoxDecoration(
        color: CupertinoTheme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = index == currentIndex;

            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: EnhancedAnimationUtils.fastDuration,
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? CupertinoColors.systemBlue.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isSelected ? item.activeIcon : item.icon,
                        size: 24,
                        color: isSelected
                            ? CupertinoColors.systemBlue
                            : CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: EnhancedAnimationUtils.fastDuration,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? CupertinoColors.systemBlue
                            : CupertinoColors.systemGrey,
                      ),
                      child: Text(item.label),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
}

class ModernTabItem {

  const ModernTabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

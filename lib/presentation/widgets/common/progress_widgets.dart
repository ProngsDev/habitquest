import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../../../core/utils/xp_calculator.dart';

/// Circular progress indicator with percentage
class CircularProgressWidget extends StatelessWidget {

  const CircularProgressWidget({
    required this.progress, super.key,
    this.size = 80,
    this.strokeWidth = 8,
    this.progressColor,
    this.backgroundColor,
    this.child,
    this.showPercentage = true,
  });
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final Widget? child;
  final bool showPercentage;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size(size, size),
          painter: _CircularProgressPainter(
            progress: progress,
            strokeWidth: strokeWidth,
            progressColor: progressColor ?? CupertinoColors.systemBlue,
            backgroundColor: backgroundColor ?? CupertinoColors.systemGrey5,
          ),
        ),
        if (child != null)
          child!
        else if (showPercentage)
          Text(
            '${(progress * 100).round()}%',
            style: TextStyle(
              fontSize: size * 0.2,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
      ],
    ),
  );
}

class _CircularProgressPainter extends CustomPainter {

  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.backgroundColor,
  });
  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2; // Start from top
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Linear progress bar
class LinearProgressWidget extends StatelessWidget {

  const LinearProgressWidget({
    required this.progress, super.key,
    this.height = 8,
    this.progressColor,
    this.backgroundColor,
    this.borderRadius,
  });
  final double progress; // 0.0 to 1.0
  final double height;
  final Color? progressColor;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(height / 2);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? CupertinoColors.systemGrey5,
        borderRadius: effectiveBorderRadius,
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: progressColor ?? CupertinoColors.systemBlue,
            borderRadius: effectiveBorderRadius,
          ),
        ),
      ),
    );
  }
}

/// XP Progress bar with level information
class XpProgressWidget extends StatelessWidget {

  const XpProgressWidget({
    required this.currentXp, required this.xpForNextLevel, required this.level, super.key,
    this.title,
  });
  final int currentXp;
  final int xpForNextLevel;
  final int level;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final progress = xpForNextLevel > 0 ? currentXp / xpForNextLevel : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Icon(
              XpCalculator.getLevelIcon(level),
              size: 16,
              color: CupertinoColors.systemBlue,
            ),
            const SizedBox(width: 4),
            Text(
              'Level $level',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: CupertinoColors.systemBlue,
              ),
            ),
            const Spacer(),
            Text(
              '$currentXp / $xpForNextLevel XP',
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressWidget(
          progress: progress,
          height: 12,
          progressColor: CupertinoColors.systemBlue,
        ),
      ],
    );
  }
}

/// Streak progress widget
class StreakProgressWidget extends StatelessWidget {

  const StreakProgressWidget({
    required this.currentStreak, required this.targetStreak, super.key,
    this.title,
  });
  final int currentStreak;
  final int targetStreak;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final progress = targetStreak > 0 ? currentStreak / targetStreak : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            const Icon(
              CupertinoIcons.flame_fill,
              color: CupertinoColors.systemOrange,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '$currentStreak day streak',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
            ),
            const Spacer(),
            Text(
              'Goal: $targetStreak',
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressWidget(
          progress: progress,
          progressColor: CupertinoColors.systemOrange,
        ),
      ],
    );
  }
}

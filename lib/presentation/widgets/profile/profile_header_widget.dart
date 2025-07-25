import 'package:flutter/cupertino.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/xp_calculator.dart';
import '../../../domain/entities/user.dart';
import '../common/custom_card.dart';
import '../common/progress_widgets.dart';

/// Widget for displaying user profile header with avatar and level info
class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({
    required this.user,
    required this.currentLevel,
    required this.totalXp,
    required this.progressPercentage,
    super.key,
  });
  final User user;
  final int currentLevel;
  final int totalXp;
  final double progressPercentage;

  @override
  Widget build(BuildContext context) => CustomCard(
    child: Column(
      children: [
        // Avatar and Basic Info
        Row(
          children: [
            // Avatar
            _buildAvatar(),
            const SizedBox(width: 20),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.label,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (user.email != null) ...[
                    Text(
                      user.email!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  _buildLevelBadge(),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Level Progress
        _buildLevelProgress(),
      ],
    ),
  );

  Widget _buildAvatar() => Container(
    width: 80,
    height: 80,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTheme.getLevelColor(currentLevel),
          AppTheme.getLevelColor(currentLevel).withValues(alpha: 0.7),
        ],
      ),
      border: Border.all(color: AppTheme.getLevelColor(currentLevel), width: 3),
    ),
    child: user.avatarPath != null
        ? ClipOval(
            child: Image.asset(
              user.avatarPath!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildDefaultAvatar(),
            ),
          )
        : _buildDefaultAvatar(),
  );

  Widget _buildDefaultAvatar() => Icon(
    XpCalculator.getLevelIcon(currentLevel),
    size: 40,
    color: CupertinoColors.white,
  );

  Widget _buildLevelBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: AppTheme.getLevelColor(currentLevel),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          XpCalculator.getLevelIcon(currentLevel),
          size: 16,
          color: CupertinoColors.white,
        ),
        const SizedBox(width: 6),
        Text(
          'Level $currentLevel',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.white,
          ),
        ),
      ],
    ),
  );

  Widget _buildLevelProgress() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            XpCalculator.getLevelTitle(currentLevel),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.getLevelColor(currentLevel),
            ),
          ),
          Text(
            '$totalXp XP',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.label,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),

      // Progress Bar
      LinearProgressWidget(
        progress: progressPercentage,
        progressColor: AppTheme.getLevelColor(currentLevel),
        backgroundColor: CupertinoColors.systemGrey5,
      ),
      const SizedBox(height: 8),

      // Progress Text
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${(progressPercentage * 100).round()}% to next level',
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          Text(
            'Level ${currentLevel + 1}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
        ],
      ),
    ],
  );
}

import 'package:flutter/cupertino.dart';

import '../../../domain/entities/achievement.dart';
import '../common/custom_card.dart';

/// Widget for displaying user's achievement gallery
class AchievementGalleryWidget extends StatelessWidget {
  final List<Achievement> achievements;

  const AchievementGalleryWidget({
    super.key,
    required this.achievements,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                CupertinoIcons.rosette,
                size: 24,
                color: CupertinoColors.systemPink,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Achievements',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
              ),
              Text(
                '${achievements.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.systemPink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Achievement Grid
          if (achievements.isEmpty)
            _buildEmptyState()
          else
            _buildAchievementGrid(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              CupertinoIcons.rosette,
              size: 48,
              color: CupertinoColors.systemGrey3,
            ),
            const SizedBox(height: 16),
            const Text(
              'No achievements yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Complete habits to unlock your first achievement!',
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: achievements.length > 6 ? 6 : achievements.length,
      itemBuilder: (context, index) {
        if (index == 5 && achievements.length > 6) {
          return _buildMoreAchievementsCard();
        }
        return _buildAchievementCard(achievements[index]);
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      decoration: BoxDecoration(
        color: Color(achievement.rarity.colorValue).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(achievement.rarity.colorValue).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getAchievementIcon(achievement.iconName),
            size: 32,
            color: Color(achievement.rarity.colorValue),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(achievement.rarity.colorValue),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Color(achievement.rarity.colorValue),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              achievement.rarity.displayName,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreAchievementsCard() {
    final remainingCount = achievements.length - 5;
    
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey5,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.systemGrey4,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.ellipsis,
            size: 32,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 8),
          Text(
            '+$remainingCount more',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.systemGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getAchievementIcon(String iconName) {
    switch (iconName) {
      case 'flame':
        return CupertinoIcons.flame;
      case 'flame_fill':
        return CupertinoIcons.flame_fill;
      case 'star':
        return CupertinoIcons.star;
      case 'star_fill':
        return CupertinoIcons.star_fill;
      case 'star_circle':
        return CupertinoIcons.star_circle;
      case 'star_circle_fill':
        return CupertinoIcons.star_circle_fill;
      case 'checkmark_circle':
        return CupertinoIcons.checkmark_circle;
      case 'checkmark_circle_fill':
        return CupertinoIcons.checkmark_circle_fill;
      case 'bolt':
        return CupertinoIcons.bolt;
      case 'bolt_fill':
        return CupertinoIcons.bolt_fill;
      case 'rosette':
        return CupertinoIcons.rosette;
      case 'trophy':
        return CupertinoIcons.star_circle_fill; // Closest to trophy
      case 'crown':
        return CupertinoIcons.star_fill; // Closest to crown
      default:
        return CupertinoIcons.star;
    }
  }
}

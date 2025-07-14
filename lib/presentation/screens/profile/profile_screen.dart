import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/app_router.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../providers/achievement_providers.dart';
import '../../providers/user_providers.dart';
import '../../widgets/common/error_widgets.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/profile/achievement_gallery_widget.dart';
import '../../widgets/profile/profile_header_widget.dart';
import '../../widgets/profile/profile_stats_widget.dart';
import '../../widgets/profile/settings_section_widget.dart';

/// Screen for viewing and editing user profile
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Profile'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => AppNavigation.toSettings(context),
          child: const Icon(CupertinoIcons.settings),
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: () async {
                // Refresh all profile data
                ref
                  ..invalidate(currentUserProvider)
                  ..invalidate(userStatisticsProvider)
                  ..invalidate(unlockedAchievementsProvider);
              },
            ),
            SliverPadding(
              padding: ResponsiveUtils.getResponsivePadding(context),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Profile Header Section
                  _buildProfileHeaderSection(ref),
                  const SizedBox(height: 24),

                  // Profile Statistics Section
                  _buildProfileStatsSection(ref),
                  const SizedBox(height: 24),

                  // Achievement Gallery Section
                  _buildAchievementGallerySection(ref),
                  const SizedBox(height: 24),

                  // Settings Section
                  _buildSettingsSection(ref),
                  const SizedBox(height: 24),

                  // Additional spacing for bottom
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeaderSection(WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final userLevelProgress = ref.watch(userLevelProgressProvider);

    return currentUser.when(
      data: (user) {
        if (user == null) {
          return const CardLoadingWidget(message: 'No user found...');
        }

        return userLevelProgress.when(
          data: (progress) => ProfileHeaderWidget(
            user: user,
            currentLevel: progress['currentLevel'] as int,
            totalXp: progress['totalXp'] as int,
            progressPercentage: progress['progressPercentage'] as double,
          ),
          loading: () =>
              const CardLoadingWidget(message: 'Loading progress...'),
          error: (error, _) => AnimatedErrorWidget(
            message: 'Failed to load progress',
            onRetry: () => ref.invalidate(userLevelProgressProvider),
          ),
        );
      },
      loading: () => const CardLoadingWidget(message: 'Loading profile...'),
      error: (error, _) => AnimatedErrorWidget(
        message: 'Failed to load profile',
        onRetry: () => ref.invalidate(currentUserProvider),
      ),
    );
  }

  Widget _buildProfileStatsSection(WidgetRef ref) {
    final userStats = ref.watch(userStatisticsProvider);

    return userStats.when(
      data: (stats) => ProfileStatsWidget(
        totalHabitsCompleted: stats['totalHabitsCompleted'] as int,
        currentStreak: stats['currentStreak'] as int,
        longestStreak: stats['longestStreak'] as int,
        coins: stats['coins'] as int,
        unlockedAchievements: stats['unlockedAchievements'] as int,
        memberSince: stats['memberSince'] as DateTime,
      ),
      loading: () => const CardLoadingWidget(message: 'Loading statistics...'),
      error: (error, _) => AnimatedErrorWidget(
        message: 'Failed to load statistics',
        onRetry: () => ref.invalidate(userStatisticsProvider),
      ),
    );
  }

  Widget _buildAchievementGallerySection(WidgetRef ref) {
    final unlockedAchievements = ref.watch(unlockedAchievementsProvider);

    return unlockedAchievements.when(
      data: (achievements) =>
          AchievementGalleryWidget(achievements: achievements),
      loading: () =>
          const CardLoadingWidget(message: 'Loading achievements...'),
      error: (error, _) => AnimatedErrorWidget(
        message: 'Failed to load achievements',
        onRetry: () => ref.invalidate(unlockedAchievementsProvider),
      ),
    );
  }

  Widget _buildSettingsSection(WidgetRef ref) {
    return const SettingsSectionWidget();
  }
}

import 'package:flutter/cupertino.dart';

import '../common/custom_card.dart';

/// Widget for displaying settings section in profile
class SettingsSectionWidget extends StatelessWidget {
  const SettingsSectionWidget({super.key});

  @override
  Widget build(BuildContext context) => CustomCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const Row(
          children: [
            Icon(
              CupertinoIcons.settings,
              size: 24,
              color: CupertinoColors.systemGrey,
            ),
            SizedBox(width: 12),
            Text(
              'Settings & More',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Settings Options
        Column(
          children: [
            _buildSettingsItem(
              context,
              'Edit Profile',
              'Update your name, email, and avatar',
              CupertinoIcons.person_crop_circle,
              CupertinoColors.systemBlue,
              () => _showComingSoon(context, 'Edit Profile'),
            ),
            _buildDivider(),
            _buildSettingsItem(
              context,
              'Notifications',
              'Manage habit reminders and alerts',
              CupertinoIcons.bell,
              CupertinoColors.systemOrange,
              () => _showComingSoon(context, 'Notifications'),
            ),
            _buildDivider(),
            _buildSettingsItem(
              context,
              'Theme',
              'Choose between light and dark mode',
              CupertinoIcons.moon,
              CupertinoColors.systemPurple,
              () => _showComingSoon(context, 'Theme Settings'),
            ),
            _buildDivider(),
            _buildSettingsItem(
              context,
              'Data & Privacy',
              'Manage your data and privacy settings',
              CupertinoIcons.lock_shield,
              CupertinoColors.systemGreen,
              () => _showComingSoon(context, 'Data & Privacy'),
            ),
            _buildDivider(),
            _buildSettingsItem(
              context,
              'Help & Support',
              'Get help and contact support',
              CupertinoIcons.question_circle,
              CupertinoColors.systemTeal,
              () => _showComingSoon(context, 'Help & Support'),
            ),
            _buildDivider(),
            _buildSettingsItem(
              context,
              'About',
              'App version and information',
              CupertinoIcons.info_circle,
              CupertinoColors.systemGrey,
              () => _showComingSoon(context, 'About'),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildSettingsItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) => CupertinoButton(
    padding: EdgeInsets.zero,
    onPressed: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.label,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            CupertinoIcons.chevron_right,
            size: 16,
            color: CupertinoColors.systemGrey3,
          ),
        ],
      ),
    ),
  );

  Widget _buildDivider() => Container(
    height: 1,
    margin: const EdgeInsets.only(left: 56),
    color: CupertinoColors.separator,
  );

  void _showComingSoon(BuildContext context, String feature) {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(feature),
        content: const Text('This feature is coming soon!'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

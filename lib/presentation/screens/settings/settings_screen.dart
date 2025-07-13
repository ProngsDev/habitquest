import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/theme_providers.dart';

/// Settings screen for app configuration
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Settings'),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 16),

            // Theme Section
            _buildSection(
              title: 'Appearance',
              children: [
                _buildSettingsTile(
                  title: 'Theme',
                  subtitle: _getThemeModeText(themeMode),
                  trailing: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _showThemeSelector(context, ref),
                    child: const Icon(CupertinoIcons.chevron_right),
                  ),
                ),
              ],
            ),

            // Notifications Section
            _buildSection(
              title: 'Notifications',
              children: [
                _buildSettingsTile(
                  title: 'Habit Reminders',
                  subtitle: 'Get notified about your habits',
                  trailing: CupertinoSwitch(
                    value: true, // TODO: Connect to actual setting
                    onChanged: (value) {
                      // TODO: Handle notification toggle
                    },
                  ),
                ),
              ],
            ),

            // Data Section
            _buildSection(
              title: 'Data',
              children: [
                _buildSettingsTile(
                  title: 'Export Data',
                  subtitle: 'Export your habits and progress',
                  onTap: () {
                    // TODO: Implement data export
                  },
                ),
                _buildSettingsTile(
                  title: 'Clear All Data',
                  subtitle: 'Reset all habits and progress',
                  textColor: CupertinoColors.systemRed,
                  onTap: () => _showClearDataDialog(context),
                ),
              ],
            ),

            // About Section
            _buildSection(
              title: 'About',
              children: [
                _buildSettingsTile(title: 'Version', subtitle: '1.0.0'),
                _buildSettingsTile(
                  title: 'Privacy Policy',
                  onTap: () {
                    // TODO: Show privacy policy
                  },
                ),
                _buildSettingsTile(
                  title: 'Terms of Service',
                  onTap: () {
                    // TODO: Show terms of service
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: children),
      ),
      const SizedBox(height: 24),
    ],
  );

  Widget _buildSettingsTile({
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) => CupertinoListTile(
    title: Text(
      title,
      style: TextStyle(color: textColor ?? CupertinoColors.label, fontSize: 17),
    ),
    subtitle: subtitle != null
        ? Text(
            subtitle,
            style: const TextStyle(
              color: CupertinoColors.systemGrey,
              fontSize: 15,
            ),
          )
        : null,
    trailing:
        trailing ??
        (onTap != null
            ? const Icon(CupertinoIcons.chevron_right, size: 16)
            : null),
    onTap: onTap,
  );

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showThemeSelector(BuildContext context, WidgetRef ref) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Choose Theme'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              ref.read(themeModeProvider.notifier).setLightMode();
              Navigator.pop(context);
            },
            child: const Text('Light'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              ref.read(themeModeProvider.notifier).setDarkMode();
              Navigator.pop(context);
            },
            child: const Text('Dark'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              ref.read(themeModeProvider.notifier).setSystemMode();
              Navigator.pop(context);
            },
            child: const Text('System'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your habits, progress, and achievements. This action cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              // TODO: Implement clear data
              Navigator.pop(context);
            },
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }
}

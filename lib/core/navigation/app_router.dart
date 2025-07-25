import 'package:flutter/cupertino.dart';

import '../../presentation/screens/habits/habit_detail_screen.dart';
import '../../presentation/screens/habits/habit_form_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/progress/progress_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';

/// App routes constants
class AppRoutes {
  static const String home = '/';
  static const String habitForm = '/habit-form';
  static const String habitDetail = '/habit-detail';
  static const String progress = '/progress';
  static const String profile = '/profile';
  static const String settings = '/settings';
}

/// App router for navigation
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return CupertinoPageRoute<void>(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case AppRoutes.habitForm:
        final args = settings.arguments as Map<String, dynamic>?;
        return CupertinoPageRoute<void>(
          builder: (_) => HabitFormScreen(
            habitId: args?['habitId'] as String?,
            isEditing: args?['isEditing'] as bool? ?? false,
          ),
          settings: settings,
          fullscreenDialog: true,
        );

      case AppRoutes.habitDetail:
        final habitId = settings.arguments as String?;
        if (habitId == null) {
          return CupertinoPageRoute<void>(
            builder: (_) => const _NotFoundScreen(),
            settings: settings,
          );
        }
        return CupertinoPageRoute<void>(
          builder: (_) => HabitDetailScreen(habitId: habitId),
          settings: settings,
        );

      case AppRoutes.progress:
        return CupertinoPageRoute<void>(
          builder: (_) => const ProgressScreen(),
          settings: settings,
        );

      case AppRoutes.profile:
        return CupertinoPageRoute<void>(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );

      case AppRoutes.settings:
        return CupertinoPageRoute<void>(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );

      default:
        return CupertinoPageRoute<void>(
          builder: (_) => const _NotFoundScreen(),
          settings: settings,
        );
    }
  }
}

/// Navigation helper methods
class AppNavigation {
  static void pushNamed(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void pushReplacementNamed(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void pop(BuildContext context, [Object? result]) {
    Navigator.pop(context, result);
  }

  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }

  // Specific navigation methods
  static void toHabitForm(BuildContext context, {String? habitId}) {
    pushNamed(
      context,
      AppRoutes.habitForm,
      arguments: {'habitId': habitId, 'isEditing': habitId != null},
    );
  }

  static void toHabitDetail(BuildContext context, String habitId) {
    pushNamed(context, AppRoutes.habitDetail, arguments: habitId);
  }

  static void toSettings(BuildContext context) {
    pushNamed(context, AppRoutes.settings);
  }
}

/// 404 Not Found screen
class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) => const CupertinoPageScaffold(
    navigationBar: CupertinoNavigationBar(middle: Text('Page Not Found')),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: 64,
            color: CupertinoColors.systemGrey,
          ),
          SizedBox(height: 16),
          Text(
            'Page Not Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'The page you are looking for does not exist.',
            style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

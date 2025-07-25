import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/enums/habit_enums.dart';
import 'core/navigation/app_router.dart';
import 'core/services/app_initialization_service.dart';
import 'core/services/firebase_service.dart';
import 'core/services/navigation_performance_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/performance_monitoring_service.dart';
import 'data/models/achievement_model.dart';
import 'data/models/habit_completion_model.dart';
import 'data/models/habit_model.dart';
import 'data/models/user_model.dart';
import 'presentation/providers/performance_providers.dart';
import 'presentation/providers/theme_providers.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase services
  await FirebaseService().initialize();

  // Initialize performance monitoring
  await PerformanceMonitoringService().initialize();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive
    ..registerAdapter(HabitModelAdapter())
    ..registerAdapter(HabitCompletionModelAdapter())
    ..registerAdapter(UserModelAdapter())
    ..registerAdapter(AchievementModelAdapter())
    ..registerAdapter(HabitDifficultyAdapter())
    ..registerAdapter(HabitCategoryAdapter())
    ..registerAdapter(HabitFrequencyAdapter())
    ..registerAdapter(CompletionStatusAdapter())
    ..registerAdapter(AchievementTypeAdapter());

  // Open Hive boxes
  await Hive.openBox<UserModel>(AppConstants.userBoxName);
  await Hive.openBox<HabitModel>(AppConstants.habitsBoxName);
  await Hive.openBox<HabitCompletionModel>(AppConstants.completionsBoxName);
  await Hive.openBox<AchievementModel>(AppConstants.achievementsBoxName);

  // Initialize notification service
  await NotificationService().initialize();

  runApp(const ProviderScope(child: HabitQuestApp()));
}

class HabitQuestApp extends ConsumerWidget {
  const HabitQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(currentThemeProvider);
    final appInitialization = ref.watch(appInitializationProvider);

    // Initialize performance tracking
    ref.watch(appPerformanceTrackerProvider);

    return CupertinoApp(
      title: 'HabitQuest',
      theme: currentTheme,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.generateRoute,
      navigatorObservers: [PerformanceNavigatorObserver()],
      home: appInitialization.when(
        data: (_) {
          // Mark app startup as complete when initialization is done
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(appPerformanceTrackerProvider.notifier)
                .completeAppStartup();
          });
          return const SplashScreen();
        },
        loading: () => const SplashScreen(),
        error: (error, _) {
          // Mark app startup as failed
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(appPerformanceTrackerProvider.notifier)
                .completeAppStartup(success: false);
          });
          return CupertinoPageScaffold(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    size: 48,
                    color: CupertinoColors.systemRed,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to initialize app',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

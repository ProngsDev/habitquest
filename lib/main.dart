import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/enums/habit_enums.dart';
import 'core/navigation/app_router.dart';
import 'core/services/notification_service.dart';
import 'data/models/achievement_model.dart';
import 'data/models/habit_completion_model.dart';
import 'data/models/habit_model.dart';
import 'data/models/user_model.dart';
import 'presentation/providers/theme_providers.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

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

    return CupertinoApp(
      title: 'HabitQuest',
      theme: currentTheme,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}

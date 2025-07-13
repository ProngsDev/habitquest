import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/hive_datasource.dart';
import '../../data/repositories/achievement_repository_impl.dart';
import '../../data/repositories/habit_completion_repository_impl.dart';
import '../../data/repositories/habit_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/achievement_repository.dart';
import '../../domain/repositories/habit_completion_repository.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/repositories/user_repository.dart';

/// Core data source providers
final hiveDataSourceProvider = Provider<HiveDataSource>(
  (ref) => HiveDataSource(),
);

/// Repository providers
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final dataSource = ref.watch(hiveDataSourceProvider);
  return HabitRepositoryImpl(dataSource);
});

final habitCompletionRepositoryProvider = Provider<HabitCompletionRepository>((
  ref,
) {
  final dataSource = ref.watch(hiveDataSourceProvider);
  return HabitCompletionRepositoryImpl(dataSource);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dataSource = ref.watch(hiveDataSourceProvider);
  return UserRepositoryImpl(dataSource);
});

final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  final dataSource = ref.watch(hiveDataSourceProvider);
  return AchievementRepositoryImpl(dataSource);
});

/// UI State providers
final selectedTabIndexProvider = StateProvider<int>((ref) => 0);

/// Theme providers
final isDarkModeProvider = StateProvider<bool>((ref) => false);

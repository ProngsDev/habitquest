import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/notification_service.dart';
import '../../domain/entities/habit.dart';

/// Provider for the notification service
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

/// Provider for notification permissions status
final notificationPermissionsProvider = FutureProvider<bool>((ref) async {
  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.areNotificationsEnabled();
});

/// Provider for managing habit notifications
final habitNotificationProvider =
    StateNotifierProvider<HabitNotificationNotifier, HabitNotificationState>((
      ref,
    ) {
      final notificationService = ref.watch(notificationServiceProvider);
      return HabitNotificationNotifier(notificationService);
    });

/// State for habit notifications
class HabitNotificationState {
  const HabitNotificationState({
    this.isInitialized = false,
    this.hasPermissions = false,
    this.habitNotificationIds = const {},
    this.error,
  });
  final bool isInitialized;
  final bool hasPermissions;
  final Map<String, int> habitNotificationIds;
  final String? error;

  HabitNotificationState copyWith({
    bool? isInitialized,
    bool? hasPermissions,
    Map<String, int>? habitNotificationIds,
    String? error,
  }) => HabitNotificationState(
    isInitialized: isInitialized ?? this.isInitialized,
    hasPermissions: hasPermissions ?? this.hasPermissions,
    habitNotificationIds: habitNotificationIds ?? this.habitNotificationIds,
    error: error,
  );
}

/// Notifier for managing habit notifications
class HabitNotificationNotifier extends StateNotifier<HabitNotificationState> {
  HabitNotificationNotifier(this._notificationService)
    : super(const HabitNotificationState()) {
    _initialize();
  }
  final NotificationService _notificationService;

  /// Initialize the notification service
  Future<void> _initialize() async {
    try {
      final isInitialized = await _notificationService.initialize();
      final hasPermissions = await _notificationService
          .areNotificationsEnabled();

      state = state.copyWith(
        isInitialized: isInitialized,
        hasPermissions: hasPermissions,
      );
    } on Exception catch (e) {
      state = state.copyWith(error: 'Failed to initialize notifications: $e');
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      final granted = await _notificationService.requestPermissions();
      state = state.copyWith(hasPermissions: granted);
      return granted;
    } on Exception catch (e) {
      state = state.copyWith(error: 'Failed to request permissions: $e');
      return false;
    }
  }

  /// Schedule notification for a habit
  Future<void> scheduleHabitNotification(Habit habit) async {
    if (!state.isInitialized || !state.hasPermissions) {
      await _initialize();
      if (!state.hasPermissions) {
        final granted = await requestPermissions();
        if (!granted) return;
      }
    }

    if (habit.reminderTime == null) return;

    try {
      // Generate unique notification ID based on habit ID
      final notificationId = habit.id.hashCode.abs();

      // Calculate next reminder time
      final now = DateTime.now();
      final reminderTime = habit.reminderTime!;

      var nextReminder = DateTime(
        now.year,
        now.month,
        now.day,
        reminderTime.hour,
        reminderTime.minute,
      );

      // If the time has passed today, schedule for tomorrow
      if (nextReminder.isBefore(now)) {
        nextReminder = nextReminder.add(const Duration(days: 1));
      }

      await _notificationService.scheduleHabitReminder(
        id: notificationId,
        habitName: habit.name,
        scheduledTime: nextReminder,
        habitDescription: habit.description,
      );

      // Update state with new notification ID
      final updatedIds = Map<String, int>.from(state.habitNotificationIds);
      updatedIds[habit.id] = notificationId;

      state = state.copyWith(habitNotificationIds: updatedIds);
    } on Exception catch (e) {
      state = state.copyWith(error: 'Failed to schedule notification: $e');
    }
  }

  /// Cancel notification for a habit
  Future<void> cancelHabitNotification(String habitId) async {
    final notificationId = state.habitNotificationIds[habitId];
    if (notificationId == null) return;

    try {
      await _notificationService.cancelNotification(notificationId);

      // Remove from state
      final updatedIds = Map<String, int>.from(state.habitNotificationIds)
        ..remove(habitId);

      state = state.copyWith(habitNotificationIds: updatedIds);
    } on Exception catch (e) {
      state = state.copyWith(error: 'Failed to cancel notification: $e');
    }
  }

  /// Update notification for a habit (reschedule)
  Future<void> updateHabitNotification(Habit habit) async {
    // Cancel existing notification
    await cancelHabitNotification(habit.id);

    // Schedule new notification if reminder is set
    if (habit.reminderTime != null) {
      await scheduleHabitNotification(habit);
    }
  }

  /// Cancel all habit notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationService.cancelAllNotifications();
      state = state.copyWith(habitNotificationIds: {});
    } on Exception catch (e) {
      state = state.copyWith(error: 'Failed to cancel all notifications: $e');
    }
  }

  /// Get pending notifications count
  Future<int> getPendingNotificationsCount() async {
    try {
      final pending = await _notificationService.getPendingNotifications();
      return pending.length;
    } on Exception {
      return 0;
    }
  }

  /// Show test notification
  Future<void> showTestNotification() async {
    if (!state.isInitialized || !state.hasPermissions) {
      await _initialize();
      if (!state.hasPermissions) {
        final granted = await requestPermissions();
        if (!granted) return;
      }
    }

    try {
      await _notificationService.showImmediateNotification(
        id: 999999,
        title: '🎯 HabitQuest Test',
        body: 'Notifications are working correctly!',
        payload: 'test_notification',
      );
    } on Exception catch (e) {
      state = state.copyWith(error: 'Failed to show test notification: $e');
    }
  }
}

import 'package:intl/intl.dart';

/// Utility functions for date operations
class DateUtils {
  /// Get the start of the day for a given date
  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Get the end of the day for a given date
  static DateTime endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  /// Check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) =>
      date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;

  /// Get the number of days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    final fromStart = startOfDay(from);
    final toStart = startOfDay(to);
    return (toStart.difference(fromStart).inHours / 24).round();
  }

  /// Format date for display
  static String formatDate(DateTime date) =>
      DateFormat('MMM dd, yyyy').format(date);

  /// Format date for short display
  static String formatDateShort(DateTime date) =>
      DateFormat('MMM dd').format(date);

  /// Format time for display
  static String formatTime(DateTime time) => DateFormat('HH:mm').format(time);

  /// Get the start of the week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return startOfDay(date.subtract(Duration(days: daysFromMonday)));
  }

  /// Get the end of the week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    final daysToSunday = 7 - date.weekday;
    return endOfDay(date.add(Duration(days: daysToSunday)));
  }

  /// Get the start of the month
  static DateTime startOfMonth(DateTime date) =>
      DateTime(date.year, date.month);

  /// Get the end of the month
  static DateTime endOfMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);

  /// Get a list of dates for the current week
  static List<DateTime> getCurrentWeekDates() {
    final now = DateTime.now();
    final startOfWeekDate = startOfWeek(now);
    return List.generate(
      7,
      (index) => startOfWeekDate.add(Duration(days: index)),
    );
  }

  /// Get a list of dates for the current month
  static List<DateTime> getCurrentMonthDates() {
    final now = DateTime.now();
    final startOfMonthDate = startOfMonth(now);
    final endOfMonthDate = endOfMonth(now);
    final daysInMonth = endOfMonthDate.day;

    return List.generate(
      daysInMonth,
      (index) => startOfMonthDate.add(Duration(days: index)),
    );
  }

  /// Check if a date is today
  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());

  /// Check if a date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  /// Check if a date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(date, tomorrow);
  }

  /// Get relative date string (Today, Yesterday, Tomorrow, or formatted date)
  static String getRelativeDateString(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isYesterday(date)) {
      return 'Yesterday';
    } else if (isTomorrow(date)) {
      return 'Tomorrow';
    } else {
      return formatDate(date);
    }
  }
}

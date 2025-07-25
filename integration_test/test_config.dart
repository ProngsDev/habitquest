/// Configuration for integration tests
class IntegrationTestConfig {
  /// Default timeout for finding elements
  static const Duration defaultFindTimeout = Duration(seconds: 10);
  
  /// Default timeout for settling animations
  static const Duration defaultSettleTimeout = Duration(seconds: 5);
  
  /// Timeout for app initialization
  static const Duration appInitTimeout = Duration(seconds: 15);
  
  /// Timeout for navigation operations
  static const Duration navigationTimeout = Duration(seconds: 8);
  
  /// Timeout for habit operations (create, update, delete)
  static const Duration habitOperationTimeout = Duration(seconds: 12);
  
  /// Whether to take screenshots on test failures
  static const bool screenshotOnFailure = true;
  
  /// Whether to enable verbose logging
  static const bool verboseLogging = true;
  
  /// Test data for creating sample habits
  static const Map<String, Map<String, String>> testHabits = {
    'morning_exercise': {
      'name': 'Morning Exercise',
      'description': '30 minutes of exercise every morning',
      'category': 'Health',
      'difficulty': 'Medium',
      'frequency': 'Daily',
    },
    'read_book': {
      'name': 'Read Book',
      'description': 'Read for 20 minutes before bed',
      'category': 'Learning',
      'difficulty': 'Easy',
      'frequency': 'Daily',
    },
    'meditation': {
      'name': 'Meditation',
      'description': '10 minutes of mindfulness meditation',
      'category': 'Wellness',
      'difficulty': 'Easy',
      'frequency': 'Daily',
    },
  };
  
  /// Screen identifiers for navigation tests
  static const Map<String, List<String>> screenIdentifiers = {
    'home': ['Dashboard', 'HabitQuest', 'Welcome'],
    'habits': ['Habits', 'My Habits', 'Habit List'],
    'progress': ['Progress', 'Analytics', 'Statistics'],
    'profile': ['Profile', 'Settings', 'Account'],
  };
  
  /// Common UI element selectors
  static const Map<String, String> commonElements = {
    'addButton': 'Add Habit',
    'saveButton': 'Save',
    'cancelButton': 'Cancel',
    'deleteButton': 'Delete',
    'editButton': 'Edit',
    'backButton': 'Back',
  };
}

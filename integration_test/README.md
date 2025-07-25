# HabitQuest Integration Tests

This directory contains integration tests for the HabitQuest application. Integration tests verify that the app works correctly as a whole, testing user flows and interactions across multiple screens and components.

## 📁 Structure

```
integration_test/
├── README.md                    # This file
├── app_test.dart               # Main integration tests
├── patrol_integration_test.dart # Advanced Patrol-based tests (experimental)
├── test_utils.dart             # Utility functions for tests
├── test_config.dart            # Test configuration and constants
├── patrol_config.dart          # Patrol-specific configuration
├── gherkin_test_runner.dart    # BDD-style test runner
├── run_tests.sh               # Test execution script
├── features/                   # Gherkin feature files
│   ├── habit_management.feature
│   └── navigation.feature
└── steps/                     # Gherkin step definitions
    ├── common_steps.dart
    ├── habit_steps.dart
    └── navigation_steps.dart
```

## 🚀 Quick Start

### Prerequisites

1. **Flutter SDK** 3.8.1 or higher
2. **Device/Emulator** - iOS Simulator, Android Emulator, or physical device
3. **Dependencies** - Run `flutter pub get` to install required packages

### Running Tests

#### Option 1: Using the Test Script (Recommended)

```bash
# Run all integration tests
./integration_test/run_tests.sh

# Run tests on specific device
./integration_test/run_tests.sh -d "iPhone 15 Simulator"

# Run with verbose output
./integration_test/run_tests.sh -v

# Run with code coverage
./integration_test/run_tests.sh -c

# Run specific test file
./integration_test/run_tests.sh -t app_test.dart

# Show help
./integration_test/run_tests.sh -h
```

#### Option 2: Using Flutter Command Directly

```bash
# Run main integration tests
flutter test integration_test/app_test.dart

# Run on specific device
flutter test integration_test/app_test.dart -d "iPhone 15 Simulator"

# Run with verbose output
flutter test integration_test/app_test.dart --verbose
```

## 🧪 Test Categories

### 1. App Launch Tests
- Verifies app launches successfully
- Checks splash screen display
- Validates initial app state

### 2. Navigation Tests
- Tests tab navigation (if implemented)
- Verifies screen transitions
- Checks back navigation

### 3. Habit Management Tests
- Tests habit creation flow
- Verifies habit completion
- Checks habit editing and deletion

### 4. State Persistence Tests
- Tests app lifecycle handling
- Verifies data persistence
- Checks state restoration

## 🛠️ Test Utilities

### IntegrationTestUtils

The `IntegrationTestUtils` class provides helper methods for common test operations:

```dart
// Initialize app for testing
await IntegrationTestUtils.initializeApp(tester);

// Wait for element to appear
await IntegrationTestUtils.waitForElement(tester, finder);

// Safely tap an element
await IntegrationTestUtils.safeTap(tester, finder);

// Navigate to a tab
await IntegrationTestUtils.navigateToTab(tester, 'Habits');

// Create a test habit
await IntegrationTestUtils.createHabit(tester, habitData);

// Complete a habit
await IntegrationTestUtils.completeHabit(tester, habitName);
```

### Test Configuration

The `IntegrationTestConfig` class contains:
- Timeout configurations
- Test data for habits
- Screen identifiers
- Common UI element selectors

## 🎭 BDD Testing with Gherkin

### Feature Files

Feature files describe test scenarios in natural language:

```gherkin
Feature: Habit Management
  As a user
  I want to manage my habits
  So that I can track my progress

  Scenario: Create a new habit
    Given I am on the habits screen
    When I tap the "Add Habit" button
    And I enter "Morning Exercise" as the habit name
    Then I should see "Morning Exercise" in the habits list
```

### Running Gherkin Tests

```bash
# Run BDD tests (experimental)
flutter test integration_test/gherkin_test_runner.dart
```

## 🔧 Configuration

### Timeouts

Adjust timeouts in `test_config.dart`:

```dart
static const Duration defaultFindTimeout = Duration(seconds: 10);
static const Duration habitOperationTimeout = Duration(seconds: 12);
```

### Test Data

Modify test habits in `test_config.dart`:

```dart
static const Map<String, Map<String, String>> testHabits = {
  'morning_exercise': {
    'name': 'Morning Exercise',
    'description': '30 minutes of exercise every morning',
    'category': 'Health',
    'difficulty': 'Medium',
    'frequency': 'Daily',
  },
};
```

## 📊 Code Coverage

Generate code coverage reports:

```bash
# Run tests with coverage
./integration_test/run_tests.sh -c

# View coverage report
open coverage/html/index.html
```

## 🐛 Debugging

### Verbose Logging

Enable verbose logging in tests:

```dart
IntegrationTestUtils.log('Custom debug message');
```

### Screenshots

Screenshots are automatically taken on test failures when enabled in config.

### Common Issues

1. **Element not found**: Increase timeout or check element selectors
2. **Navigation fails**: Verify tab structure matches expectations
3. **Form submission fails**: Check form field selectors and validation

## 📱 Device-Specific Testing

### iOS Simulator

```bash
flutter test integration_test/app_test.dart -d "iPhone 15 Simulator"
```

### Android Emulator

```bash
flutter test integration_test/app_test.dart -d "Pixel_7_API_34"
```

### Physical Device

```bash
# List connected devices
flutter devices

# Run on specific device
flutter test integration_test/app_test.dart -d "Your Device Name"
```

## 🚨 Best Practices

1. **Keep tests independent** - Each test should be able to run in isolation
2. **Use descriptive names** - Test names should clearly describe what they test
3. **Handle timing issues** - Use appropriate waits and timeouts
4. **Clean up state** - Reset app state between tests when needed
5. **Test real user flows** - Focus on actual user journeys, not implementation details

## 🔄 Continuous Integration

Integration tests can be run in CI/CD pipelines:

```yaml
# Example GitHub Actions step
- name: Run Integration Tests
  run: |
    flutter test integration_test/app_test.dart
```

## 📚 Further Reading

- [Flutter Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Patrol Testing Framework](https://patrol.leancode.co/)
- [Gherkin BDD Testing](https://pub.dev/packages/flutter_gherkin)
- [Test-Driven Development](https://flutter.dev/docs/testing)

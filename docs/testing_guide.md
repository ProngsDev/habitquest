# HabitQuest Testing Guide

This guide covers the comprehensive testing strategy for HabitQuest, including unit tests, widget tests, and integration tests.

## 📋 Testing Strategy

HabitQuest follows a three-tier testing approach:

1. **Unit Tests** - Test individual functions, classes, and business logic
2. **Widget Tests** - Test UI components and their interactions
3. **Integration Tests** - Test complete user flows and app behavior

## 🚀 Quick Start

### Running All Tests

```bash
# Using the development workflow script (recommended)
./scripts/dev_workflow.sh test

# Or run each type individually
./scripts/dev_workflow.sh test-unit
./scripts/dev_workflow.sh test-widget
./scripts/dev_workflow.sh test-integration
```

### Using VS Code

1. Open Command Palette (`Cmd+Shift+P` / `Ctrl+Shift+P`)
2. Type "Tasks: Run Task"
3. Select from available test tasks:
   - `Flutter: Run All Tests`
   - `Flutter: Run Unit Tests`
   - `Flutter: Run Widget Tests`
   - `Flutter: Run Integration Tests`

## 🧪 Test Types

### Unit Tests

Located in `test/unit/`, these tests verify:
- Business logic in repositories and services
- Data models and entities
- Utility functions and helpers
- Error handling and validation

**Running unit tests:**
```bash
flutter test test/unit/
```

### Widget Tests

Located in `test/widget/`, these tests verify:
- UI component rendering
- User interactions (taps, swipes, etc.)
- Widget state changes
- Navigation between screens

**Running widget tests:**
```bash
flutter test test/widget/
```

### Integration Tests

Located in `integration_test/`, these tests verify:
- Complete user journeys
- App lifecycle behavior
- Cross-screen navigation
- Data persistence
- Real device/simulator behavior

**Running integration tests:**
```bash
# All integration tests
./integration_test/run_tests.sh

# Specific test file
flutter test integration_test/app_test.dart

# On specific device
flutter test integration_test/app_test.dart -d "iPhone 15 Simulator"
```

## 🛠️ Development Workflow

### Pre-commit Testing

Before committing code, run the quality check:

```bash
./scripts/dev_workflow.sh check
```

This runs:
- Code formatting check
- Static analysis
- All tests (unit, widget, integration)

### Test-Driven Development (TDD)

1. **Write a failing test** for the new feature
2. **Write minimal code** to make the test pass
3. **Refactor** while keeping tests green
4. **Repeat** for each new requirement

### Debugging Tests

#### VS Code Debugging

1. Set breakpoints in your test code
2. Use the debug configurations:
   - `Integration Tests (Debug)`
   - `Habit Flows Integration Tests`
   - `Navigation Flows Integration Tests`

#### Command Line Debugging

```bash
# Run tests with verbose output
flutter test --verbose

# Run specific test
flutter test test/unit/core/result/result_test.dart

# Run tests with coverage
flutter test --coverage
```

## 📊 Code Coverage

### Generating Coverage Reports

```bash
# Run tests with coverage
flutter test --coverage

# Generate HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html

# View report
open coverage/html/index.html
```

### Coverage Goals

- **Unit Tests**: 90%+ coverage
- **Widget Tests**: 80%+ coverage
- **Integration Tests**: Cover all critical user flows

## 🎯 Testing Best Practices

### General Principles

1. **Test behavior, not implementation**
2. **Keep tests simple and focused**
3. **Use descriptive test names**
4. **Arrange, Act, Assert pattern**
5. **Independent and isolated tests**

### Unit Test Best Practices

```dart
group('HabitRepository', () {
  late HabitRepository repository;
  late MockDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDataSource();
    repository = HabitRepositoryImpl(mockDataSource);
  });

  test('should return habits when data source succeeds', () async {
    // Arrange
    final expectedHabits = [testHabit];
    when(mockDataSource.getAllHabits())
        .thenAnswer((_) async => expectedHabits);

    // Act
    final result = await repository.getAllHabits();

    // Assert
    expect(result.isSuccess, true);
    expect(result.data, expectedHabits);
    verify(mockDataSource.getAllHabits()).called(1);
  });
});
```

### Widget Test Best Practices

```dart
testWidgets('should display habit name and description', (tester) async {
  // Arrange
  const testHabit = Habit(name: 'Test Habit', description: 'Test description');

  // Act
  await tester.pumpWidget(
    MaterialApp(
      home: HabitCard(habit: testHabit),
    ),
  );

  // Assert
  expect(find.text('Test Habit'), findsOneWidget);
  expect(find.text('Test description'), findsOneWidget);
});
```

### Integration Test Best Practices

```dart
testWidgets('complete habit creation flow', (tester) async {
  // Arrange
  await IntegrationTestUtils.initializeApp(tester);

  // Act
  final success = await IntegrationTestUtils.createHabit(
    tester,
    {'name': 'Morning Exercise', 'category': 'Health'},
  );

  // Assert
  expect(success, true);
  expect(find.text('Morning Exercise'), findsOneWidget);
});
```

## 🔧 Test Configuration

### Test Data

Test data is centralized in `integration_test/test_config.dart`:

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

### Timeouts

Configure timeouts for different operations:

```dart
static const Duration defaultFindTimeout = Duration(seconds: 10);
static const Duration habitOperationTimeout = Duration(seconds: 12);
```

## 🚨 Troubleshooting

### Common Issues

#### Tests Timing Out

- Increase timeout values in `test_config.dart`
- Check for infinite loops or blocking operations
- Ensure proper `await` usage

#### Element Not Found

- Verify element selectors match actual UI
- Check if elements are rendered conditionally
- Use `IntegrationTestUtils.waitForElement()` for dynamic content

#### Device/Simulator Issues

- Ensure device is properly started
- Check device compatibility
- Try different devices/simulators

#### Flaky Tests

- Add proper waits for animations
- Use `pumpAndSettle()` after interactions
- Avoid hardcoded delays

### Debug Commands

```bash
# List available devices
flutter devices

# Run with verbose logging
flutter test --verbose

# Run specific test method
flutter test --name "should create habit successfully"

# Run tests with custom timeout
flutter test --timeout 60s
```

## 📈 Continuous Integration

### GitHub Actions

The CI pipeline automatically runs:

1. **Code quality checks** (formatting, analysis)
2. **Unit and widget tests** with coverage
3. **Integration tests** on multiple devices
4. **Build verification** for iOS and Android

### Local CI Simulation

```bash
# Run the same checks as CI
./scripts/dev_workflow.sh check

# Format code
dart format .

# Analyze code
flutter analyze

# Run all tests
./scripts/dev_workflow.sh test
```

## 📚 Additional Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Integration Testing Guide](https://docs.flutter.dev/testing/integration-tests)
- [Mockito for Dart](https://pub.dev/packages/mockito)
- [Test-Driven Development](https://en.wikipedia.org/wiki/Test-driven_development)

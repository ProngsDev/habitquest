# HabitQuest Core Infrastructure

This directory contains the core infrastructure components following JP_GE (Japanese-German Engineering) principles, emphasizing Monozukuri craftsmanship, Kaizen continuous improvement, Langfristigkeit long-term thinking, and Präzision technical excellence.

## 🏗️ Architecture Overview

The core infrastructure is organized into several key modules:

### Error Handling (`/errors`)
- **Comprehensive Exception Hierarchy**: Structured error types with proper categorization
- **Central Error Handler**: Converts generic exceptions to typed AppExceptions
- **Severity Levels**: Proper error classification for appropriate handling

### Result Pattern (`/result`)
- **Functional Error Handling**: Explicit error handling without exceptions
- **Composable Operations**: Map, flatMap, fold operations for Result types
- **Utility Functions**: Helper functions for common Result operations

### Validation (`/validation`)
- **Trust Boundary Validation**: Input validation at service boundaries
- **Composable Validators**: Reusable validation components
- **Domain-Specific Validators**: Habit, User, and other entity validators

### Resilience (`/resilience`)
- **Retry Policies**: Configurable retry logic with exponential backoff
- **Circuit Breakers**: Prevent cascading failures with state management
- **Fallback Strategies**: Graceful degradation with multiple fallback options
- **Comprehensive Service**: Unified resilience service combining all patterns

### Services (`/services`)
- **Structured Logging**: Contextual logging with multiple levels
- **Service Interfaces**: Clean abstractions for core services

## 🚀 Quick Start Guide

### 1. Error Handling

Replace basic try-catch blocks with the Result pattern:

```dart
// ❌ Old way
Future<Habit> getHabit(String id) async {
  try {
    return await repository.getHabit(id);
  } catch (e) {
    throw Exception('Failed to get habit: $e');
  }
}

// ✅ New way
Future<Result<Habit>> getHabit(String id) async {
  return ResilienceService.instance.executeResilient(
    () => repository.getHabit(id),
    operationName: 'getHabit',
    fallback: DefaultValueFallback(Habit.empty()),
  );
}
```

### 2. Validation

Validate inputs at trust boundaries:

```dart
// ✅ Repository method with validation
Future<Result<void>> createHabit(Habit habit) async {
  // Validate input
  final validation = ValidationService.instance.validateHabit(habit);
  if (!validation.isValid) {
    return Result.failure(DataValidationException(
      validationErrors: validation.errors,
    ));
  }

  // Execute with resilience
  return ResilienceService.instance.executeWithRetry(
    () => dataSource.saveHabit(habit),
    operationName: 'createHabit',
    retryPolicy: RetryPolicy.database,
  );
}
```

### 3. Logging

Use structured logging throughout:

```dart
LoggingService.instance.info(
  'Habit created successfully',
  context: {
    'habitId': habit.id,
    'habitName': habit.name,
    'category': habit.category.name,
  },
);
```

## 📋 Migration Checklist

### Phase 1: Core Infrastructure ✅
- [x] Implement comprehensive error types and exception hierarchy
- [x] Add structured logging infrastructure with Logger package
- [x] Enhance input validation at repository and service boundaries
- [x] Implement Result pattern for better error handling
- [x] Add error recovery mechanisms and fallback strategies

### Phase 2: Repository Layer (Next)
- [ ] Update HabitRepositoryImpl to use Result pattern
- [ ] Update UserRepositoryImpl to use Result pattern
- [ ] Update HabitCompletionRepositoryImpl to use Result pattern
- [ ] Add validation to all repository methods
- [ ] Implement resilience patterns in repositories

### Phase 3: Service Layer (Next)
- [ ] Update providers to handle Result types
- [ ] Add error handling to state notifiers
- [ ] Implement proper error display in UI
- [ ] Add loading and error states

### Phase 4: Testing (Next)
- [ ] Unit tests for error handling components
- [ ] Integration tests for resilience patterns
- [ ] Widget tests for error states
- [ ] End-to-end tests for critical flows

## 🎯 Best Practices

### Error Handling
1. **Use Result pattern** for all operations that can fail
2. **Validate at boundaries** - repositories, services, and UI entry points
3. **Log with context** - include relevant information for debugging
4. **Fail fast and safe** - detect errors early, handle gracefully

### Resilience
1. **Apply appropriate policies** - network vs database vs UI operations
2. **Use circuit breakers** for external dependencies
3. **Implement fallbacks** for critical user flows
4. **Monitor and alert** on resilience pattern activations

### Validation
1. **Validate early** - at the earliest possible point
2. **Provide clear messages** - user-friendly error descriptions
3. **Combine validators** - use composite validation for complex objects
4. **Cache validation results** - avoid redundant validation

## 🔧 Configuration

### Retry Policies
```dart
// Network operations
RetryPolicy.network  // 3 attempts, 1s initial delay, 10s max

// Database operations
RetryPolicy.database // 5 attempts, 100ms initial delay, 5s max

// Custom policy
const RetryPolicy(
  maxAttempts: 3,
  initialDelay: Duration(milliseconds: 500),
  maxDelay: Duration(seconds: 30),
  backoffMultiplier: 2.0,
)
```

### Circuit Breakers
```dart
const CircuitBreakerConfig(
  failureThreshold: 5,        // Open after 5 failures
  timeout: Duration(seconds: 60), // Wait 60s before retry
  successThreshold: 3,        // Close after 3 successes
)
```

### Logging Levels
- **Debug**: Development information
- **Info**: General application flow
- **Warning**: Potential issues
- **Error**: Error conditions
- **Fatal**: Critical failures

## 📊 Monitoring

The infrastructure provides comprehensive metrics:

### Circuit Breaker Metrics
```dart
final metrics = ResilienceService.instance.getAllCircuitBreakerMetrics();
final health = ResilienceService.instance.getHealthStatus();
```

### Error Tracking
All errors are automatically logged with:
- Error code and message
- Severity level
- Context information
- Stack traces (when appropriate)
- Retry attempts and outcomes

## 🔄 Continuous Improvement

Following Kaizen principles:

1. **Monitor error patterns** - identify common failure modes
2. **Adjust policies** - tune retry and circuit breaker settings
3. **Enhance validation** - add new validators based on real usage
4. **Improve fallbacks** - better default values and alternative flows
5. **Optimize performance** - reduce overhead while maintaining reliability

## 📚 Further Reading

- [JP_GE Development Principles](../docs/jp_ge_principles.md)
- [Error Handling Best Practices](../docs/error_handling.md)
- [Resilience Patterns](../docs/resilience_patterns.md)
- [Testing Strategy](../docs/testing_strategy.md)
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Service for managing Firebase initialization and configuration
class FirebaseService {
  factory FirebaseService() => _instance;
  FirebaseService._internal();
  static final FirebaseService _instance = FirebaseService._internal();

  final Logger _logger = Logger();
  bool _isInitialized = false;

  /// Initialize Firebase services
  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.i('Firebase already initialized');
      return;
    }

    try {
      // Initialize Firebase Core
      await Firebase.initializeApp(options: _getFirebaseOptions());

      // Initialize Firebase Performance Monitoring
      await _initializePerformanceMonitoring();

      _isInitialized = true;
      _logger.i('Firebase services initialized successfully');
    } on Exception catch (e) {
      _logger.e('Failed to initialize Firebase services: $e');
      // Don't rethrow - app should continue to work without Firebase
    }
  }

  /// Initialize Firebase Performance Monitoring
  Future<void> _initializePerformanceMonitoring() async {
    try {
      final performance = FirebasePerformance.instance;

      // Enable performance monitoring
      await performance.setPerformanceCollectionEnabled(true);

      _logger.i('Firebase Performance Monitoring enabled');
    } on Exception catch (e) {
      _logger.e('Failed to initialize Performance Monitoring: $e');
    }
  }

  /// Get Firebase options based on platform
  FirebaseOptions? _getFirebaseOptions() {
    // For now, return null to use default configuration
    // In a real app, you would configure this with your Firebase project settings
    if (kDebugMode) {
      _logger.w(
        'Using default Firebase configuration - configure with your project settings',
      );
    }
    return null;
  }

  /// Check if Firebase is initialized
  bool get isInitialized => _isInitialized;

  /// Get Firebase Performance instance
  FirebasePerformance get performance {
    if (!_isInitialized) {
      throw StateError('Firebase not initialized. Call initialize() first.');
    }
    return FirebasePerformance.instance;
  }
}

/// Extension for easy access to Firebase services
extension FirebaseServiceExtension on FirebaseService {
  /// Create a custom trace for performance monitoring
  Future<Trace> createTrace(String name) async {
    try {
      final trace = performance.newTrace(name);
      return trace;
    } on Exception catch (e) {
      _logger.e('Failed to create trace $name: $e');
      // Return a no-op trace to prevent app crashes
      return _NoOpTrace();
    }
  }

  /// Start an HTTP metric for network monitoring
  HttpMetric createHttpMetric(String url, HttpMethod httpMethod) {
    try {
      return performance.newHttpMetric(url, httpMethod);
    } on Exception catch (e) {
      _logger.e('Failed to create HTTP metric for $url: $e');
      // Return a no-op metric to prevent app crashes
      return _NoOpHttpMetric(url, httpMethod);
    }
  }
}

/// No-op trace implementation for fallback
class _NoOpTrace implements Trace {
  _NoOpTrace();

  @override
  Future<void> start() async {
    // No-op
  }

  @override
  Future<void> stop() async {
    // No-op
  }

  @override
  void incrementMetric(String metricName, int value) {
    // No-op
  }

  @override
  void putAttribute(String attributeName, String attributeValue) {
    // No-op
  }

  @override
  void setMetric(String metricName, int value) {
    // No-op
  }

  @override
  void removeAttribute(String attributeName) {
    // No-op
  }

  @override
  String getAttribute(String attributeName) => '';

  @override
  Map<String, String> getAttributes() => {};

  @override
  int getMetric(String metricName) => 0;
}

/// No-op HTTP metric implementation for fallback
class _NoOpHttpMetric implements HttpMetric {
  _NoOpHttpMetric(String _, HttpMethod __);

  @override
  Future<void> start() async {
    // No-op
  }

  @override
  Future<void> stop() async {
    // No-op
  }

  @override
  void putAttribute(String attributeName, String attributeValue) {
    // No-op
  }

  @override
  void removeAttribute(String attributeName) {
    // No-op
  }

  @override
  String getAttribute(String attributeName) => '';

  @override
  Map<String, String> getAttributes() => {};

  @override
  int? get httpResponseCode => null;

  @override
  set httpResponseCode(int? httpResponseCode) {
    // No-op
  }

  @override
  int? get requestPayloadSize => null;

  @override
  set requestPayloadSize(int? requestPayloadSize) {
    // No-op
  }

  @override
  String? get responseContentType => null;

  @override
  set responseContentType(String? responseContentType) {
    // No-op
  }

  @override
  int? get responsePayloadSize => null;

  @override
  set responsePayloadSize(int? responsePayloadSize) {
    // No-op
  }
}

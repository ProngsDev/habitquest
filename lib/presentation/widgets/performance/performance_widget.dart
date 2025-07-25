import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/performance_wrapper.dart';
import '../../providers/performance_providers.dart';

/// Widget that tracks its build performance
class PerformanceTrackedWidget extends ConsumerWidget {
  const PerformanceTrackedWidget({
    required this.widgetName,
    required this.builder,
    this.trackRebuild = false,
    super.key,
  });

  final String widgetName;
  final Widget Function(BuildContext context, WidgetRef ref) builder;
  final bool trackRebuild;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final performanceWrapper = UIPerformanceWrapper();
    
    return performanceWrapper.trackWidgetBuild(
      widgetName,
      () => builder(context, ref),
    );
  }
}

/// Widget that tracks user interactions
class InteractionTrackedWidget extends ConsumerWidget {
  const InteractionTrackedWidget({
    required this.child,
    required this.interactionType,
    this.onTap,
    this.onLongPress,
    this.targetWidget,
    super.key,
  });

  final Widget child;
  final String interactionType;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? targetWidget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final performanceWrapper = UIPerformanceWrapper();
    
    return GestureDetector(
      onTap: onTap != null
          ? () => performanceWrapper.trackUserInteraction(
                interactionType,
                onTap!,
                targetWidget: targetWidget,
              )
          : null,
      onLongPress: onLongPress != null
          ? () => performanceWrapper.trackUserInteraction(
                '${interactionType}_long_press',
                onLongPress!,
                targetWidget: targetWidget,
              )
          : null,
      child: child,
    );
  }
}

/// Widget that tracks navigation performance
class NavigationTrackedWidget extends ConsumerWidget {
  const NavigationTrackedWidget({
    required this.child,
    required this.fromScreen,
    required this.toScreen,
    required this.onNavigate,
    super.key,
  });

  final Widget child;
  final String fromScreen;
  final String toScreen;
  final Future<void> Function() onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final performanceWrapper = UIPerformanceWrapper();
    
    return GestureDetector(
      onTap: () async {
        // Track navigation performance
        ref.read(appPerformanceTrackerProvider.notifier)
            .trackNavigation(fromScreen, toScreen);
        
        await performanceWrapper.trackScreenNavigation(
          fromScreen,
          toScreen,
          onNavigate,
        );
      },
      child: child,
    );
  }
}

/// Widget that tracks animation performance
class AnimationTrackedWidget extends ConsumerStatefulWidget {
  const AnimationTrackedWidget({
    required this.animationName,
    required this.duration,
    required this.builder,
    this.autoStart = true,
    super.key,
  });

  final String animationName;
  final Duration duration;
  final Widget Function(BuildContext context, Animation<double> animation) builder;
  final bool autoStart;

  @override
  ConsumerState<AnimationTrackedWidget> createState() => _AnimationTrackedWidgetState();
}

class _AnimationTrackedWidgetState extends ConsumerState<AnimationTrackedWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late UIPerformanceWrapper _performanceWrapper;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _performanceWrapper = UIPerformanceWrapper();

    if (widget.autoStart) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    _performanceWrapper.trackAnimation(
      widget.animationName,
      () async {
        await _controller.forward();
      },
      duration: widget.duration,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => widget.builder(context, _controller),
    );
}

/// Mixin for widgets that need performance tracking
mixin PerformanceTrackingMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  late UIPerformanceWrapper _performanceWrapper;
  String get widgetName => T.toString();

  @override
  void initState() {
    super.initState();
    _performanceWrapper = UIPerformanceWrapper();
  }

  /// Track a user interaction
  void trackInteraction(String interactionType, VoidCallback action) {
    _performanceWrapper.trackUserInteraction(
      interactionType,
      action,
      targetWidget: widgetName,
    );
  }

  /// Track an async operation
  Future<R> trackAsyncOperation<R>(
    String operationName,
    Future<R> Function() operation,
  ) async => _performanceWrapper.trackPerformance(
      '${widgetName.toLowerCase()}_$operationName',
      operation,
      attributes: {
        'widget': widgetName,
        'operation': operationName,
      },
    );

  /// Track navigation from this widget
  void trackNavigation(String toScreen) {
    ref.read(appPerformanceTrackerProvider.notifier)
        .trackNavigation(widgetName, toScreen);
  }

  /// Track user engagement
  void trackEngagement(String action, {Map<String, String>? properties}) {
    ref.read(appPerformanceTrackerProvider.notifier)
        .trackUserEngagement(action, properties: {
          'widget': widgetName,
          ...?properties,
        });
  }
}

/// Performance monitoring wrapper for habit-specific widgets
class HabitWidgetPerformanceWrapper {
  final UIPerformanceWrapper _uiWrapper = UIPerformanceWrapper();

  /// Track habit card rendering performance
  Widget trackHabitCard(String habitId, Widget Function() builder) => _uiWrapper.trackWidgetBuild(
      'habit_card_$habitId',
      builder,
    );

  /// Track habit completion animation
  Future<void> trackHabitCompletionAnimation(
    String habitId,
    Future<void> Function() animation,
  ) async {
    await _uiWrapper.trackAnimation(
      'habit_completion_$habitId',
      animation,
      duration: const Duration(milliseconds: 1500), // Typical completion animation duration
    );
  }

  /// Track habit form performance
  Widget trackHabitForm(String formType, Widget Function() builder) => _uiWrapper.trackWidgetBuild(
      'habit_form_$formType',
      builder,
    );

  /// Track habit list performance
  Widget trackHabitList(int habitCount, Widget Function() builder) => _uiWrapper.trackWidgetBuild(
      'habit_list_${habitCount}_items',
      builder,
    );
}

/// Performance monitoring for progress widgets
class ProgressWidgetPerformanceWrapper {
  final UIPerformanceWrapper _uiWrapper = UIPerformanceWrapper();

  /// Track progress chart rendering
  Widget trackProgressChart(String chartType, Widget Function() builder) => _uiWrapper.trackWidgetBuild(
      'progress_chart_$chartType',
      builder,
    );

  /// Track statistics calculation
  Future<T> trackStatisticsCalculation<T>(
    String statisticType,
    Future<T> Function() calculation,
  ) async => _uiWrapper.trackPerformance(
      'statistics_$statisticType',
      calculation,
      attributes: {
        'statistic_type': statisticType,
      },
    );

  /// Track progress animation
  Future<void> trackProgressAnimation(
    String animationType,
    Future<void> Function() animation,
    Duration duration,
  ) async {
    await _uiWrapper.trackAnimation(
      'progress_animation_$animationType',
      animation,
      duration: duration,
    );
  }
}

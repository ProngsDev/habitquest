import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/navigation_performance_service.dart';
import '../../../core/services/performance_monitoring_service.dart';
import '../../providers/performance_providers.dart';

/// Debug widget for monitoring app performance
class PerformanceDebugWidget extends ConsumerWidget {
  const PerformanceDebugWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only show in debug mode
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    final performanceMetrics = ref.watch(performanceMetricsProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        border: Border.all(
          color: CupertinoColors.systemGrey4.resolveFrom(context),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.speedometer,
                size: 16,
                color: CupertinoColors.systemBlue,
              ),
              const SizedBox(width: 8),
              Text(
                'Performance Monitor',
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _showDetailedMetrics(context, ref),
                minimumSize: Size.zero,
                child: const Icon(
                  CupertinoIcons.info_circle,
                  size: 16,
                  color: CupertinoColors.systemBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          performanceMetrics.when(
            data: (metrics) => _buildMetricsDisplay(context, metrics),
            loading: () => const CupertinoActivityIndicator(),
            error: (error, _) => Text(
              'Error: $error',
              style: const TextStyle(
                color: CupertinoColors.systemRed,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsDisplay(
    BuildContext context,
    Map<String, dynamic> metrics,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildMetricRow(
        'Active Traces',
        '${(metrics['active_traces'] as List?)?.length ?? 0}',
        CupertinoColors.systemGreen,
      ),
      _buildMetricRow(
        'Operations',
        '${metrics['operation_count'] ?? 0}',
        CupertinoColors.systemBlue,
      ),
      _buildMetricRow(
        'Firebase',
        metrics['firebase_initialized'] == true ? 'Connected' : 'Disconnected',
        metrics['firebase_initialized'] == true
            ? CupertinoColors.systemGreen
            : CupertinoColors.systemOrange,
      ),
    ],
  );

  Widget _buildMetricRow(String label, String value, Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ],
    ),
  );

  void _showDetailedMetrics(BuildContext context, WidgetRef ref) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => PerformanceDetailModal(ref: ref),
    );
  }
}

/// Detailed performance metrics modal
class PerformanceDetailModal extends StatelessWidget {
  const PerformanceDetailModal({required this.ref, super.key});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) => CupertinoActionSheet(
    title: const Text('Performance Metrics'),
    message: const Text('Detailed performance monitoring information'),
    actions: [
      CupertinoActionSheetAction(
        onPressed: () => _showPerformanceMetrics(context),
        child: const Text('View Performance Metrics'),
      ),
      CupertinoActionSheetAction(
        onPressed: () => _showNavigationMetrics(context),
        child: const Text('View Navigation Metrics'),
      ),
      CupertinoActionSheetAction(
        onPressed: () => _exportMetrics(context),
        child: const Text('Export Metrics'),
      ),
    ],
    cancelButton: CupertinoActionSheetAction(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text('Cancel'),
    ),
  );

  void _showPerformanceMetrics(BuildContext context) {
    Navigator.of(context).pop();

    final performanceService = PerformanceMonitoringService();
    final metrics = performanceService.getCurrentMetrics();

    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Performance Metrics'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              ...metrics.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        entry.value.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showNavigationMetrics(BuildContext context) {
    Navigator.of(context).pop();

    final navigationService = NavigationPerformanceService();
    final analytics = navigationService.getNavigationAnalytics();
    final mostVisited = navigationService.getMostVisitedScreens();

    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Navigation Metrics'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Current Screen: ${analytics['current_screen'] ?? 'Unknown'}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              const Text(
                'Most Visited Screens:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              ...mostVisited.map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Text(
                        '${entry.value} visits',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _exportMetrics(BuildContext context) {
    Navigator.of(context).pop();

    // In a real app, this would export metrics to a file or send to analytics
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Export Metrics'),
        content: const Text(
          'Metrics would be exported to analytics service or local file in a production app.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Floating performance indicator
class FloatingPerformanceIndicator extends ConsumerWidget {
  const FloatingPerformanceIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      right: 16,
      child: GestureDetector(
        onTap: () => _showQuickMetrics(context, ref),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: CupertinoColors.systemBlue.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            CupertinoIcons.speedometer,
            color: CupertinoColors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _showQuickMetrics(BuildContext context, WidgetRef ref) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: const PerformanceDebugWidget(),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/navigation_performance_service.dart';
import '../../../core/services/performance_alerting_service.dart';
import '../../providers/performance_providers.dart';

/// Performance monitoring dashboard screen (debug only)
class PerformanceDashboardScreen extends ConsumerStatefulWidget {
  const PerformanceDashboardScreen({super.key});

  @override
  ConsumerState<PerformanceDashboardScreen> createState() =>
      _PerformanceDashboardScreenState();
}

class _PerformanceDashboardScreenState
    extends ConsumerState<PerformanceDashboardScreen> {
  final PerformanceAlertingService _alertingService =
      PerformanceAlertingService();
  final NavigationPerformanceService _navigationService =
      NavigationPerformanceService();

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      _alertingService.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Performance Dashboard'),
        ),
        child: Center(
          child: Text('Performance dashboard is only available in debug mode'),
        ),
      );
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Performance Dashboard'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _refreshMetrics,
          child: const Icon(CupertinoIcons.refresh),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPerformanceSummaryCard(),
            const SizedBox(height: 16),
            _buildActiveAlertsCard(),
            const SizedBox(height: 16),
            _buildNavigationMetricsCard(),
            const SizedBox(height: 16),
            _buildSystemMetricsCard(),
            const SizedBox(height: 16),
            _buildActionsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSummaryCard() {
    final summary = _alertingService.getPerformanceSummary();

    return _buildCard(
      title: 'Performance Summary',
      icon: CupertinoIcons.speedometer,
      child: Column(
        children: [
          _buildSummaryRow(
            'Overall Health',
            _getHealthText(summary.overallHealth),
            _getHealthColor(summary.overallHealth),
          ),
          _buildSummaryRow(
            'Active Alerts',
            '${summary.activeAlerts}',
            summary.activeAlerts > 0
                ? CupertinoColors.systemRed
                : CupertinoColors.systemGreen,
          ),
          _buildSummaryRow(
            'Critical Alerts',
            '${summary.criticalAlerts}',
            summary.criticalAlerts > 0
                ? CupertinoColors.systemRed
                : CupertinoColors.systemGrey,
          ),
          _buildSummaryRow(
            'Warning Alerts',
            '${summary.warningAlerts}',
            summary.warningAlerts > 0
                ? CupertinoColors.systemOrange
                : CupertinoColors.systemGrey,
          ),
          _buildSummaryRow(
            'Last Check',
            _formatTime(summary.lastCheckTime),
            CupertinoColors.systemGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveAlertsCard() {
    final alerts = _alertingService.getActiveAlerts();

    return _buildCard(
      title: 'Active Alerts',
      icon: CupertinoIcons.exclamationmark_triangle,
      child: alerts.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No active alerts',
                style: TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          : Column(children: alerts.map(_buildAlertItem).toList()),
    );
  }

  Widget _buildAlertItem(PerformanceAlert alert) => Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getSeverityColor(
          alert.threshold.severity,
        ).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getSeverityColor(
            alert.threshold.severity,
          ).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getSeverityIcon(alert.threshold.severity),
                size: 16,
                color: _getSeverityColor(alert.threshold.severity),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  alert.threshold.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                onPressed: () => _alertingService.clearAlert(alert.id),
                child: const Icon(
                  CupertinoIcons.xmark_circle,
                  size: 16,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Threshold: ${alert.threshold.maxValue} | Actual: ${alert.actualValue}',
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey,
            ),
          ),
          Text(
            'Time: ${_formatTime(alert.timestamp)}',
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );

  Widget _buildNavigationMetricsCard() {
    final analytics = _navigationService.getNavigationAnalytics();
    final mostVisited = _navigationService.getMostVisitedScreens(limit: 3);

    return _buildCard(
      title: 'Navigation Metrics',
      icon: CupertinoIcons.arrow_branch,
      child: Column(
        children: [
          _buildSummaryRow(
            'Current Screen',
            (analytics['current_screen'] as String?) ?? 'Unknown',
            CupertinoColors.systemBlue,
          ),
          const SizedBox(height: 12),
          const Text(
            'Most Visited Screens:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ...mostVisited.map(
            (entry) => _buildSummaryRow(
              entry.key,
              '${entry.value} visits',
              CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMetricsCard() {
    final performanceMetrics = ref.watch(performanceMetricsProvider);

    return _buildCard(
      title: 'System Metrics',
      icon: CupertinoIcons.device_phone_portrait,
      child: performanceMetrics.when(
        data: (metrics) => Column(
          children: [
            _buildSummaryRow(
              'Active Traces',
              '${(metrics['active_traces'] as List?)?.length ?? 0}',
              CupertinoColors.systemBlue,
            ),
            _buildSummaryRow(
              'Operations',
              '${metrics['operation_count'] ?? 0}',
              CupertinoColors.systemGreen,
            ),
            _buildSummaryRow(
              'Firebase Status',
              metrics['firebase_initialized'] == true
                  ? 'Connected'
                  : 'Disconnected',
              metrics['firebase_initialized'] == true
                  ? CupertinoColors.systemGreen
                  : CupertinoColors.systemOrange,
            ),
          ],
        ),
        loading: () => const CupertinoActivityIndicator(),
        error: (error, _) => Text(
          'Error loading metrics: $error',
          style: const TextStyle(color: CupertinoColors.systemRed),
        ),
      ),
    );
  }

  Widget _buildActionsCard() => _buildCard(
      title: 'Actions',
      icon: CupertinoIcons.settings,
      child: Column(
        children: [
          _buildActionButton(
            'Clear All Alerts',
            CupertinoIcons.clear,
            _alertingService.clearAllAlerts,
          ),
          _buildActionButton(
            'Reset Navigation Data',
            CupertinoIcons.arrow_counterclockwise,
            _navigationService.reset,
          ),
          _buildActionButton(
            'Export Performance Data',
            CupertinoIcons.share,
            _exportPerformanceData,
          ),
        ],
      ),
    );

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) => DecoratedBox(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.systemGrey4.resolveFrom(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: CupertinoColors.systemBlue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: child,
          ),
        ],
      ),
    );

  Widget _buildSummaryRow(String label, String value, Color valueColor) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );

  Widget _buildActionButton(
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) => Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: CupertinoColors.systemGrey6.resolveFrom(context),
        onPressed: onPressed,
        child: Row(
          children: [
            Icon(icon, size: 16, color: CupertinoColors.systemBlue),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: CupertinoColors.systemBlue,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );

  String _getHealthText(PerformanceHealth health) {
    switch (health) {
      case PerformanceHealth.good:
        return 'Good';
      case PerformanceHealth.info:
        return 'Info';
      case PerformanceHealth.warning:
        return 'Warning';
      case PerformanceHealth.critical:
        return 'Critical';
    }
  }

  Color _getHealthColor(PerformanceHealth health) {
    switch (health) {
      case PerformanceHealth.good:
        return CupertinoColors.systemGreen;
      case PerformanceHealth.info:
        return CupertinoColors.systemBlue;
      case PerformanceHealth.warning:
        return CupertinoColors.systemOrange;
      case PerformanceHealth.critical:
        return CupertinoColors.systemRed;
    }
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.info:
        return CupertinoColors.systemBlue;
      case AlertSeverity.warning:
        return CupertinoColors.systemOrange;
      case AlertSeverity.critical:
        return CupertinoColors.systemRed;
    }
  }

  IconData _getSeverityIcon(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.info:
        return CupertinoIcons.info_circle;
      case AlertSeverity.warning:
        return CupertinoIcons.exclamationmark_triangle;
      case AlertSeverity.critical:
        return CupertinoIcons.exclamationmark_octagon;
    }
  }

  String _formatTime(DateTime time) => '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';

  void _refreshMetrics() {
    setState(() {
      // Trigger rebuild to refresh all metrics
    });
  }

  void _exportPerformanceData() {
    // In a real app, this would export performance data
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Export Performance Data'),
        content: const Text(
          'Performance data would be exported to a file or sent to analytics service.',
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

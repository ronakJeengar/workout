import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_loading.dart';
import '../theme.dart';
import 'crash_triage.dart';

class CrashReportDashboard extends ConsumerStatefulWidget {
  const CrashReportDashboard({super.key});

  @override
  ConsumerState<CrashReportDashboard> createState() => _CrashReportDashboardState();
}

class _CrashReportDashboardState extends ConsumerState<CrashReportDashboard> {
  late Future<List<CrashReport>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    _reportsFuture = ref.read(crashTriageServiceProvider).getReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRASH & STABILITY'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () async {
              await ref.read(crashTriageServiceProvider).clearReports();
              setState(() {
                _loadReports();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<CrashReport>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoading(message: 'ANALYZING CRASH REPORTS...');
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load crash logs'));
          }

          final reports = snapshot.data ?? [];
          if (reports.isEmpty) {
            return const Center(child: Text('0 Crashes Detected. App is stable.'));
          }

          // Category mapping & grouping
          final Map<String, List<CrashReport>> grouped = {};
          final Map<String, String> categorySeverity = {};
          for (final r in reports) {
            grouped.putIfAbsent(r.category, () => []).add(r);
            categorySeverity[r.category] = r.severity;
          }

          final sortedCategories = grouped.keys.toList()
            ..sort((a, b) => grouped[b]!.length.compareTo(grouped[a]!.length));

          return ListView(
            padding: const EdgeInsets.all(AppSizes.m),
            children: [
              _buildSummaryStats(reports, sortedCategories, categorySeverity, grouped),
              const SizedBox(height: AppSizes.l),
              _buildSectionHeader('TOP CRASH CATEGORIES & PRIORITY'),
              const SizedBox(height: AppSizes.s),
              ...sortedCategories.take(10).map((cat) {
                final count = grouped[cat]!.length;
                final severity = categorySeverity[cat] ?? 'MEDIUM';
                final percentage = count / reports.length;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.s),
                  child: AppCard(
                    showBorder: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                cat.toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                              ),
                            ),
                            _buildPriorityBadge(severity),
                          ],
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          '$count occurrence${count > 1 ? 's' : ''} (${(percentage * 100).toInt()}%)',
                          style: const TextStyle(fontSize: 10, color: Colors.white38),
                        ),
                        const SizedBox(height: AppSizes.s),
                        LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: Colors.white10,
                          color: _getSeverityColor(severity),
                          borderRadius: BorderRadius.circular(2),
                          minHeight: 4,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: AppSizes.l),
              _buildSectionHeader('ROOT CAUSE DETAILED GROUPING'),
              const SizedBox(height: AppSizes.s),
              ...sortedCategories.map((cat) {
                final items = grouped[cat]!;
                return Card(
                  margin: const EdgeInsets.only(bottom: AppSizes.s),
                  child: ExpansionTile(
                    title: Text(cat, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    subtitle: Text('${items.length} crash events logged', style: const TextStyle(fontSize: 10, color: Colors.white38)),
                    leading: Icon(Icons.bug_report, color: _getSeverityColor(items.first.severity)),
                    children: items.map((r) {
                      return ListTile(
                        title: Text(r.error, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (r.reason != null)
                              Text('Reason: ${r.reason}', style: const TextStyle(fontSize: 10, color: Colors.amber, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.all(AppSizes.s),
                              color: Colors.black26,
                              width: double.infinity,
                              child: Text(
                                r.stackTrace,
                                style: const TextStyle(fontFamily: 'monospace', fontSize: 9, color: Colors.white54),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              r.timestamp.toLocal().toString().substring(0, 19),
                              style: const TextStyle(fontSize: 8, color: Colors.white24),
                            ),
                            const Divider(),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryStats(
    List<CrashReport> reports,
    List<String> sortedCategories,
    Map<String, String> categorySeverity,
    Map<String, List<CrashReport>> grouped,
  ) {
    int criticalCount = 0;
    int highCount = 0;
    for (final key in grouped.keys) {
      final severity = categorySeverity[key];
      if (severity == 'CRITICAL') criticalCount += grouped[key]!.length;
      if (severity == 'HIGH') highCount += grouped[key]!.length;
    }

    return Row(
      children: [
        Expanded(
          child: AppCard(
            child: Column(
              children: [
                const Text('TOTAL CRASHES', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white38)),
                Text('${reports.length}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSizes.s),
        Expanded(
          child: AppCard(
            child: Column(
              children: [
                const Text('CRITICAL ISSUES', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white38)),
                Text('$criticalCount', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.redAccent)),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSizes.s),
        Expanded(
          child: AppCard(
            child: Column(
              children: [
                const Text('HIGH SEVERITY', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white38)),
                Text('$highCount', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.orange)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: Colors.white38,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildPriorityBadge(String severity) {
    final color = _getSeverityColor(severity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        severity,
        style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'CRITICAL':
        return Colors.red;
      case 'HIGH':
        return Colors.orange;
      case 'MEDIUM':
        return Colors.yellow;
      case 'LOW':
        return AppTheme.primaryLime;
      default:
        return Colors.white54;
    }
  }
}

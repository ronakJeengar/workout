import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_loading.dart';
import '../theme.dart';
import 'user_behavior_tracker.dart';

class RetentionDashboard extends ConsumerWidget {
  const RetentionDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracker = ref.watch(userBehaviorTrackerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('USER BEHAVIOR & RETENTION'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: tracker.getEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoading(message: 'COMPUTING USER METRICS...');
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load behavior analytics'));
          }

          return FutureBuilder<Map<String, dynamic>>(
            future: _calculateMetrics(tracker),
            builder: (context, metricsSnapshot) {
              if (metricsSnapshot.connectionState == ConnectionState.waiting) {
                return const AppLoading(message: 'CALCULATING RETENTION FUNNELS...');
              }

              final metrics = metricsSnapshot.data ?? {};
              final onboardingComplete = metrics['onboardingComplete'] as bool;
              final firstWorkoutStarted = metrics['firstWorkoutStarted'] as bool;
              final dropoffs = metrics['dropoffs'] as Map<String, int>;
              final avgDuration = metrics['avgDuration'] as double;
              final retention = metrics['retention'] as double;
              final exportCount = metrics['exportCount'] as int;

              return ListView(
                padding: const EdgeInsets.all(AppSizes.m),
                children: [
                  _buildRetentionHeroCard(retention, avgDuration),
                  const SizedBox(height: AppSizes.l),
                  _buildSectionHeader('ONBOARDING & ENGAGEMENT FUNNEL'),
                  const SizedBox(height: AppSizes.s),
                  _buildFunnelStep('1. Onboarding Completion', onboardingComplete, 'User completed welcome walkthrough'),
                  const SizedBox(height: AppSizes.xs),
                  _buildFunnelStep('2. First Workout Started', firstWorkoutStarted, 'User loaded and started their first session'),
                  const SizedBox(height: AppSizes.xs),
                  _buildFunnelStep('3. Export Usage', exportCount > 0, 'User utilized backup / data export capability ($exportCount times)'),
                  const SizedBox(height: AppSizes.l),
                  _buildSectionHeader('SESSION DROP-OFF POINTS'),
                  const SizedBox(height: AppSizes.s),
                  if (dropoffs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSizes.m),
                      child: Text('No drop-off events recorded. Excellent completion rate!', style: TextStyle(color: Colors.white38, fontSize: 11)),
                    )
                  else
                    ...dropoffs.entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.s),
                        child: AppCard(
                          showBorder: true,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.key.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                                  const Text('USER ABANDONED AT THIS STEP', style: TextStyle(fontSize: 8, color: Colors.redAccent)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withAlpha(20),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${e.value} drop-off${e.value > 1 ? 's' : ''}',
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _calculateMetrics(UserBehaviorTracker tracker) async {
    final onboardingComplete = await tracker.isOnboardingCompleted();
    final firstWorkoutStarted = await tracker.isFirstWorkoutStarted();
    final dropoffs = await tracker.getSessionDropoffs();
    final avgDuration = await tracker.getAverageSessionDurationMinutes();
    final retention = await tracker.getWeeklyRetentionRate();
    final exportCount = await tracker.getExportUsageCount();

    return {
      'onboardingComplete': onboardingComplete,
      'firstWorkoutStarted': firstWorkoutStarted,
      'dropoffs': dropoffs,
      'avgDuration': avgDuration,
      'retention': retention,
      'exportCount': exportCount,
    };
  }

  Widget _buildRetentionHeroCard(double retention, double avgDuration) {
    return AppCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Icon(Icons.star_half_rounded, color: AppTheme.primaryLime, size: 36),
                  const SizedBox(height: AppSizes.xs),
                  const Text('D7 RETENTION', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white38)),
                  Text('${(retention * 100).toInt()}%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                ],
              ),
              Container(width: 1, height: 60, color: Colors.white10),
              Column(
                children: [
                  const Icon(Icons.timer_outlined, color: AppTheme.primaryLime, size: 36),
                  const SizedBox(height: AppSizes.xs),
                  const Text('AVG SESSION', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white38)),
                  Text('${avgDuration.toStringAsFixed(1)}m', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSizes.m),
          const Divider(color: Colors.white10),
          const SizedBox(height: AppSizes.xs),
          Text(
            'Target D7 Retention: >60%  •  Current: ${(retention * 100).toInt()}% (EXCELLENT)',
            style: const TextStyle(fontSize: 10, color: AppTheme.primaryLime, fontWeight: FontWeight.bold),
          ),
        ],
      ),
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

  Widget _buildFunnelStep(String title, bool completed, String subtitle) {
    return AppCard(
      showBorder: true,
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle_rounded : Icons.pending_outlined,
            color: completed ? AppTheme.primaryLime : Colors.white24,
            size: 24,
          ),
          const SizedBox(width: AppSizes.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: completed ? Colors.white : Colors.white38,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10, color: Colors.white38),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

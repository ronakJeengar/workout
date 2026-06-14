import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_sizes.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../core/theme.dart';
import '../domain/fatigue_model.dart';
import '../providers/coach_providers.dart';
import '../../progress/providers/progress_provider.dart';
import '../../workout/providers/workout_providers.dart';
import 'widgets/coach_card.dart';
import 'widgets/insight_widgets.dart';

class CoachScreen extends ConsumerWidget {
  const CoachScreen({super.key});

  Color _getIntensityColor(FatigueState state) {
    switch (state) {
      case FatigueState.low:
        return AppTheme.primaryLime;
      case FatigueState.moderate:
        return const Color(0xFF38BDF8); // Cyan
      case FatigueState.high:
        return const Color(0xFFF97316); // Orange
      case FatigueState.overtrained:
        return const Color(0xFFEF4444); // Red
    }
  }

  String _getIntensityLabel(FatigueState state) {
    switch (state) {
      case FatigueState.low:
        return 'HIGH INTENSITY';
      case FatigueState.moderate:
        return 'MEDIUM INTENSITY';
      case FatigueState.high:
        return 'LOW INTENSITY / RECOVERY';
      case FatigueState.overtrained:
        return 'REST & DELOAD ONLY';
    }
  }

  LinearGradient _getIntensityGradient(FatigueState state) {
    switch (state) {
      case FatigueState.low:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3F6212), Color(0xFF1E293B)],
        );
      case FatigueState.moderate:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
        );
      case FatigueState.high:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C2D12), Color(0xFF0F172A)],
        );
      case FatigueState.overtrained:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7F1D1D), Color(0xFF0F172A)],
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fatigueAsync = ref.watch(fatigueProvider);
    final recommendationsAsync = ref.watch(dailyCoachProvider);
    final consistencyAsync = ref.watch(consistencyProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            title: Text(
              'AI COACH',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                letterSpacing: 2.0,
              ),
            ),
          ),
          fatigueAsync.when(
            data: (fatigue) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==========================================
                    // TODAY'S COACH CARD
                    // ==========================================
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: _getIntensityGradient(fatigue.recoveryState),
                        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                        border: Border.all(
                          color: _getIntensityColor(fatigue.recoveryState).withAlpha(60),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.cardPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "TODAY'S TARGET",
                              style: TextStyle(
                                color: _getIntensityColor(fatigue.recoveryState),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: AppSizes.xs),
                            Text(
                              _getIntensityLabel(fatigue.recoveryState),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: AppSizes.s),
                            Text(
                              fatigue.recoveryState == FatigueState.overtrained
                                  ? 'Your body is showing signs of high stress and fatigue. Prioritize sleep, active mobility, and light walking.'
                                  : fatigue.recoveryState == FatigueState.high
                                      ? 'System load is heavy. Keep workouts brief, focus on form, and avoid training to failure today.'
                                      : fatigue.recoveryState == FatigueState.moderate
                                          ? 'Good balance. You can train hard but monitor joint pain and keep volume moderate.'
                                          : 'Optimal recovery state. Excellent day to attempt progressive overload or set a new PR!',
                              style: TextStyle(
                                color: Colors.white.withAlpha(200),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.l),

                    // ==========================================
                    // WARNING BANNER (High Fatigue / Overtraining)
                    // ==========================================
                    if (fatigue.recoveryState == FatigueState.high ||
                        fatigue.recoveryState == FatigueState.overtrained) ...[
                      AppCard(
                        padding: const EdgeInsets.all(AppSizes.cardPadding),
                        showBorder: true,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.warning_rounded,
                              color: Color(0xFFEF4444),
                              size: 28,
                            ),
                            const SizedBox(width: AppSizes.m),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'RECOVERY CRITICAL',
                                    style: TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.xs),
                                  Text(
                                    'Contributing: ${fatigue.contributingFactors.join(" ")}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.l),
                    ],

                    // ==========================================
                    // INSIGHT SECTION (Gauges side-by-side)
                    // ==========================================
                    const Text(
                      'PERFORMANCE METRICS',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1.5,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: AppSizes.m),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(child: FatigueMeter(fatigue: fatigue)),
                        consistencyAsync.when(
                          data: (score) => Expanded(child: ConsistencyScoreRing(score: score)),
                          loading: () => const Expanded(child: Center(child: CircularProgressIndicator())),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.xl),

                    // ==========================================
                    // VOLUME TREND MINI CHART
                    // ==========================================
                    const Text(
                      '30-DAY WORKOUT VOLUME',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1.5,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: AppSizes.m),
                    const AppCard(
                      padding: EdgeInsets.all(AppSizes.cardPadding),
                      showBorder: true,
                      child: VolumeTrendMiniChart(),
                    ),
                    const SizedBox(height: AppSizes.xl),

                    // ==========================================
                    // RECOMMENDATIONS SECTION
                    // ==========================================
                    const Text(
                      'COACH RECOMMENDATIONS',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1.5,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: AppSizes.m),
                  ],
                ),
              ),
            ),
            loading: () => const SliverFillRemaining(
              child: AppLoading(message: 'CALCULATING COACH INSIGHTS...'),
            ),
            error: (err, _) => SliverFillRemaining(
              child: AppErrorWidget(
                message: 'COULD NOT ANALYZE TRAINING LOGS',
                onRetry: () => ref.invalidate(workoutHistoryProvider),
              ),
            ),
          ),
          recommendationsAsync.when(
            data: (recs) {
              if (recs.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSizes.l),
                      child: Text(
                        'NO RECOMMENDATIONS AVAILABLE',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.m),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final rec = recs[index];
                      return CoachCard(recommendation: rec);
                    },
                    childCount: recs.length,
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator(color: AppTheme.primaryLime)),
              ),
            ),
            error: (err, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.m),
                child: Text('Failed to load recommendation list: $err', style: const TextStyle(color: Colors.redAccent)),
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: AppSizes.xl)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryLime,
        foregroundColor: Colors.black,
        onPressed: () => context.push('/auto-program'),
        icon: const Icon(Icons.auto_awesome, fontWeight: FontWeight.bold),
        label: const Text('GENERATE TRAINING PLAN', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }
}

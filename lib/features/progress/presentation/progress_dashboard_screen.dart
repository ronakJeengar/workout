import 'package:workout/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/utils/unit_formatter.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../workout/data/exercise_library.dart';
import '../../workout/providers/workout_providers.dart';
import '../domain/progress_overview.dart';
import '../providers/progress_provider.dart';
import 'widgets/volume_chart.dart';

class ProgressDashboardScreen extends ConsumerStatefulWidget {
  const ProgressDashboardScreen({super.key});

  @override
  ConsumerState<ProgressDashboardScreen> createState() => _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState extends ConsumerState<ProgressDashboardScreen> {
  String? _selectedExerciseId;

  @override
  void initState() {
    super.initState();
    _selectedExerciseId = ExerciseLibrary.exercises.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final overviewAsync = ref.watch(progressOverviewProvider);
    final trendAsync = ref.watch(volumeTrendProvider);
    final consistencyAsync = ref.watch(consistencyProvider);

    return Scaffold(
      body: overviewAsync.when(
        data: (overview) {
          if (overview.totalSessions == 0) {
            return Scaffold(
              appBar: AppBar(title: Text(AppLocalizations.of(context)!.progress)),
              body: const AppEmptyState(
                icon: Icons.analytics_outlined,
                title: 'NO ANALYTICS YET',
                subtitle: 'Complete sessions to reveal insights.',
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppTheme.primaryLime.withAlpha(50), Colors.transparent],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.m),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.lifetimeVolume, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.primaryLime, letterSpacing: 1.5)),
                          Text(UnitFormatter.formatWeight(overview.totalVolume).toUpperCase(), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroStats(overview),
                      const SizedBox(height: AppSizes.xl),
                      _buildSectionHeader('30-DAY VOLUME TREND'),
                      const SizedBox(height: AppSizes.m),
                      trendAsync.when(
                        data: (points) => AppCard(showBorder: true, child: VolumeChart(points: points)),
                        loading: () => const SizedBox(height: 120, child: AppLoading()),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: AppSizes.xl),
                      _buildSectionHeader('CONSISTENCY'),
                      const SizedBox(height: AppSizes.m),
                      consistencyAsync.when(
                        data: (score) => _buildConsistencyCard(score),
                        loading: () => const SizedBox(height: 80, child: AppLoading()),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: AppSizes.xl),
                      _buildSectionHeader('EXERCISE INSIGHTS'),
                      const SizedBox(height: AppSizes.m),
                      _buildExerciseInsightsSelector(),
                    ],
                  ),
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          );
        },
        loading: () => const AppLoading(message: 'CALCULATING INSIGHTS...'),
        error: (err, _) => AppErrorWidget(
          message: 'FAILED TO LOAD ANALYTICS',
          onRetry: () => ref.invalidate(workoutHistoryProvider),
        ),
      ),
    );
  }

  Widget _buildHeroStats(ProgressOverview overview) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('SESSIONS', '${overview.totalSessions}'),
        _buildStatItem('STREAK', '${overview.currentStreak}D'),
        _buildStatItem('TIME', '${overview.totalDuration.inHours}H'),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Colors.white54, fontSize: 12));
  }

  Widget _buildConsistencyCard(double score) {
    return AppCard(
      showBorder: true,
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  value: score,
                  strokeWidth: 6,
                  backgroundColor: Colors.white10,
                  color: AppTheme.primaryLime,
                ),
              ),
              Text('${(score * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
            ],
          ),
          const SizedBox(width: AppSizes.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.monthlyScore, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                Text(score > 0.5 ? 'EXCELLENT PROGRESS!' : 'STAY DISCIPLINED.', style: const TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseInsightsSelector() {
    return Column(
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          showBorder: true,
          child: DropdownButton<String>(
            value: _selectedExerciseId,
            isExpanded: true,
            underline: const SizedBox(),
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.m),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primaryLime),
            items: ExerciseLibrary.exercises.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)))).toList(),
            onChanged: (val) => setState(() => _selectedExerciseId = val),
          ),
        ),
        const SizedBox(height: AppSizes.s),
        if (_selectedExerciseId != null)
          Consumer(
            builder: (context, ref, _) {
              final insightAsync = ref.watch(exerciseInsightProvider(_selectedExerciseId!));
              return insightAsync.when(
                data: (insight) {
                  if (insight == null) return Padding(padding: EdgeInsets.all(AppSizes.m), child: Text(AppLocalizations.of(context)!.noData, style: TextStyle(color: Colors.white24)));
                  return Column(
                    children: [
                      _buildInsightCard('PERSONAL BEST', UnitHighlight(value: UnitFormatter.formatWeight(insight.currentPR))),
                      _buildInsightCard('ESTIMATED 1RM', UnitHighlight(value: UnitFormatter.formatWeight(insight.estimated1RM))),
                      _buildInsightCard('IMPROVEMENT', UnitHighlight(
                        value: '${(insight.improvementPercent * 100).toStringAsFixed(1)}%',
                        color: insight.improvementPercent >= 0 ? AppTheme.primaryLime : Colors.redAccent,
                      )),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
      ],
    );
  }

  Widget _buildInsightCard(String label, UnitHighlight highlight) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSizes.s),
      showBorder: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38)),
          Text(highlight.value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: highlight.color ?? Colors.white)),
        ],
      ),
    );
  }
}

class UnitHighlight {
  final String value;
  final Color? color;
  UnitHighlight({required this.value, this.color});
}

import 'package:workout/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/utils/duration_formatter.dart';
import '../../../shared/widgets/app_button.dart';
import '../domain/workout_session.dart';
import '../providers/workout_providers.dart';

class WorkoutSummaryScreen extends ConsumerWidget {
  final WorkoutSession session;

  const WorkoutSummaryScreen({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duration = session.endTime?.difference(session.startTime);
    final totalSets = session.workout.exercises.fold<int>(
      0,
      (sum, e) => sum + e.sets.where((s) => s.isCompleted).length,
    );
    final totalExercises = session.workout.exercises.where((e) => e.sets.any((s) => s.isCompleted)).length;

    final prCount = session.workout.exercises.fold<int>(0, (sum, exercise) {
      final currentPR = ref.watch(exercisePRProvider(exercise.exercise.id));
      return sum + (exercise.sets.any((set) => set.isCompleted && (currentPR == null || set.weight > currentPR.weight || (set.weight == currentPR.weight && set.reps > currentPR.reps))) ? 1 : 0);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.workoutSummary),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: AppSizes.l),
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 800),
                tween: Tween<double>(begin: 0.5, end: 1.0),
                curve: Curves.elasticOut,
                builder: (context, value, child) => Transform.scale(
                  scale: value,
                  child: const Icon(Icons.celebration, size: 100, color: AppTheme.primaryLime),
                ),
              ),
              const SizedBox(height: AppSizes.l),
              Text(
                'Great Job!',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSizes.m),
              Text(
                session.workout.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Divider(indent: 50, endIndent: 50, height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SummaryStat(
                    label: 'Duration',
                    value: duration != null 
                      ? DurationFormatter.formatMinutesSeconds(duration) 
                      : 'N/A',
                  ),
                  _SummaryStat(
                    label: 'Exercises',
                    value: '$totalExercises',
                  ),
                  _SummaryStat(
                    label: 'Total Sets',
                    value: '$totalSets',
                  ),
                ],
              ),
              if (prCount > 0) ...[
                const SizedBox(height: AppSizes.l),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.l, vertical: AppSizes.cardPadding),
                  decoration: BoxDecoration(
                    color: Colors.amber.withAlpha(50),
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius * 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: AppSizes.s),
                      Text(
                        '$prCount New Personal Record${prCount > 1 ? 's' : ''}!',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSizes.xl + AppSizes.m),
              AppButton(
                text: 'Back to Home',
                onPressed: () {
                  ref.read(workoutHistoryProvider.notifier).refresh();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              const SizedBox(height: AppSizes.l),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.s),
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

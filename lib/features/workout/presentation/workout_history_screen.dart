import 'package:workout/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/utils/date_formatter.dart';
import '../../../shared/utils/duration_formatter.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/app_loading.dart';
import '../providers/workout_providers.dart';

class WorkoutHistoryScreen extends ConsumerWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(workoutHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.workoutHistory),
      ),
      body: historyAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return const AppEmptyState(
              icon: Icons.history,
              title: 'No completed workouts yet.',
            );
          }
          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              final duration = session.endTime?.difference(session.startTime);
              final totalSets = session.workout.exercises.fold<int>(
                0,
                (sum, e) => sum + e.sets.where((s) => s.isCompleted).length,
              );

              return AppCard(
                margin: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: AppSizes.s),
                padding: EdgeInsets.zero,
                child: ListTile(
                  title: Text(session.workout.name),
                  subtitle: Text(
                    '${DateFormatter.formatDate(session.startTime)} • '
                    '${DurationFormatter.formatMinutes(duration)} • $totalSets sets',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Show summary again or just details
                  },
                ),
              );
            },
          );
        },
        loading: () => const AppLoading(),
        error: (err, stack) => AppErrorWidget(
          message: 'Failed to load workout history.',
          onRetry: () => ref.invalidate(workoutHistoryProvider),
        ),
      ),
    );
  }
}

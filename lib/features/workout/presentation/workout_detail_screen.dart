import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/app_loading.dart';
import '../providers/workout_providers.dart';

class WorkoutDetailScreen extends ConsumerWidget {
  final String workoutId;

  const WorkoutDetailScreen({
    super.key,
    required this.workoutId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutListProvider);
    final activeSession = ref.watch(activeSessionProvider);

    return workoutsAsync.when(
      data: (workouts) {
        final workout = workouts.firstWhere((w) => w.id == workoutId);
        final isSessionActive = activeSession?.workout.id == workout.id;

        return Scaffold(
          appBar: AppBar(
            title: Text(workout.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => context.push('/add-exercise', extra: workout.id),
                tooltip: 'Add Exercise',
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: workout.exercises.isEmpty
                    ? const AppEmptyState(
                        icon: Icons.fitness_center,
                        title: 'No exercises added yet.',
                      )
                    : ListView.builder(
                        itemCount: workout.exercises.length,
                        itemBuilder: (context, index) {
                          final exercise = workout.exercises[index];
                          return ListTile(
                            title: Text(exercise.exercise.name),
                            subtitle: Text('${exercise.sets.length} sets'),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSizes.m),
                child: SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    text: isSessionActive ? 'Resume Session' : 'Start Session',
                    onPressed: isSessionActive
                        ? () => context.push('/session')
                        : () async {
                            await ref.read(activeSessionProvider.notifier).startSession(workout);
                            if (context.mounted) context.push('/session');
                          },
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: AppLoading()),
      error: (err, stack) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(
          message: 'Failed to load workout details.',
          onRetry: () => ref.invalidate(workoutListProvider),
        ),
      ),
    );
  }
}

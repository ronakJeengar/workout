import 'package:workout/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/exercise_library.dart';
import '../providers/workout_providers.dart';

class AddExerciseScreen extends ConsumerWidget {
  final String workoutId;

  const AddExerciseScreen({
    super.key,
    required this.workoutId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addExercise),
      ),
      body: ListView.builder(
        itemCount: ExerciseLibrary.exercises.length,
        itemBuilder: (context, index) {
          final exercise = ExerciseLibrary.exercises[index];
          return ListTile(
            title: Text(exercise.name),
            subtitle: Text(exercise.muscleGroup ?? 'General'),
            onTap: () {
              ref.read(workoutListProvider.notifier).addExerciseToWorkout(workoutId, exercise);
              context.pop();
            },
          );
        },
      ),
    );
  }
}

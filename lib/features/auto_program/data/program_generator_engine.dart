import '../../workout/domain/workout.dart';
import '../../workout/domain/workout_session.dart';
import '../../workout/domain/workout_set.dart';
import '../../workout/domain/exercise.dart';
import '../../workout/data/exercise_library.dart';
import '../../progress/domain/progress_overview.dart';
import '../../goals/domain/goal.dart';
import '../../settings/domain/app_settings.dart';
import '../../coach/domain/fatigue_model.dart';
import '../domain/exercise_template.dart';
import '../domain/workout_day_template.dart';
import '../domain/program_template.dart';
import '../domain/generated_program.dart';

class ProgramGeneratorEngine {
  const ProgramGeneratorEngine();

  GeneratedProgram generate({
    required List<WorkoutSession> history,
    required ProgressOverview overview,
    required double consistencyScore,
    required FatigueModel fatigue,
    required List<Goal> goals,
    required AppSettings settings,
  }) {
    final now = DateTime.now();

    // -------------------------------------------------------------
    // STEP 1 — USER CLASSIFICATION
    // -------------------------------------------------------------
    String level = 'beginner';
    final oldestSessionDate = history.isEmpty ? now : history.last.startTime;
    final trainingAgeDays = now.difference(oldestSessionDate).inDays;

    if (history.length >= 10 && trainingAgeDays >= 90 && consistencyScore >= 0.4) {
      level = 'intermediate';
      if (history.length >= 40 && trainingAgeDays >= 365 && consistencyScore >= 0.7) {
        level = 'advanced';
      }
    }

    // -------------------------------------------------------------
    // STEP 2 — GOAL MAPPING
    // -------------------------------------------------------------
    // Extract primary goal type
    ProgramGoalType goalType = ProgramGoalType.general;
    if (goals.isNotEmpty) {
      final primaryGoal = goals.first.title.toLowerCase();
      if (primaryGoal.contains('muscle') || primaryGoal.contains('gain') || primaryGoal.contains('size') || primaryGoal.contains('hypertrophy')) {
        goalType = ProgramGoalType.muscle_gain;
      } else if (primaryGoal.contains('strength') || primaryGoal.contains('power') || primaryGoal.contains('lift')) {
        goalType = ProgramGoalType.strength;
      } else if (primaryGoal.contains('fat') || primaryGoal.contains('loss') || primaryGoal.contains('cut') || primaryGoal.contains('lean')) {
        goalType = ProgramGoalType.fat_loss;
      }
    }

    final template = _selectTemplate(goalType, level);

    // -------------------------------------------------------------
    // STEP 3 & 4 — FATIGUE ADAPTATION & PROGRESSION ENGINE
    // -------------------------------------------------------------
    final List<WorkoutDay> weeklyPlan = [];
    final List<String> adaptations = [];
    double difficultyModifier = 1.0;

    // Safety checks & fatigue multipliers
    final double fatigueScore = fatigue.fatigueScore;
    double setsMultiplier = 1.0;
    double weightMultiplier = 1.0;
    bool removeAccessories = false;

    if (fatigueScore >= 0.9) {
      // Safety rule: never increase load, reduce volume heavily
      setsMultiplier = 0.6;
      weightMultiplier = 0.8;
      removeAccessories = true;
      difficultyModifier = 0.5;
      adaptations.add('CRITICAL FATIGUE: Vol: -40%, Weight: -20%, compound movements only, deload enforced.');
    } else if (fatigueScore > 0.8) {
      // Rule A - Overtraining
      setsMultiplier = 0.7; // reduce volume by 30%
      weightMultiplier = 0.85;
      removeAccessories = true;
      difficultyModifier = 0.6;
      adaptations.add('Overtraining detected: Vol: -30%, Compound exercises only, Deload active.');
    } else if (fatigueScore >= 0.6) {
      // Moderate-High Fatigue
      setsMultiplier = 1.0;
      weightMultiplier = 0.9; // reduce intensity slightly
      difficultyModifier = 0.85;
      adaptations.add('High fatigue: Maintained sets, reduced intensity (-10%) to prevent burnout.');
    } else {
      // Low Fatigue - Progressive Overload
      setsMultiplier = 1.0;
      difficultyModifier = 1.15;
      adaptations.add('Low fatigue: Optimal recovery. Progressive overload target enabled (+2.5% to +5.0%).');
    }

    // Determine PR and Plateau status for each exercise
    final prExercises = _detectRecentPRs(history);
    final plateauExercises = _detectPlateaus(history);

    int dayCounter = 1;
    for (final dayTemplate in template.splitStructure) {
      final List<WorkoutExercise> workoutExercises = [];

      for (final exTemplate in dayTemplate.exercises) {
        final exerciseId = exTemplate.exerciseId;
        final exercise = ExerciseLibrary.exercises.firstWhere(
          (e) => e.id == exerciseId,
          orElse: () => Exercise(id: exerciseId, name: 'Exercise $exerciseId', muscleGroup: 'Mixed'),
        );

        // Check if accessory and needs removal
        final isAccessory = !_isCompoundMovement(exerciseId);
        if (removeAccessories && isAccessory) {
          continue; // skip accessory exercise
        }

        // Determine base sets and reps range
        final setsRangeParts = exTemplate.setsRange.split('–');
        int targetSets = setsRangeParts.isNotEmpty ? (int.tryParse(setsRangeParts.first) ?? 3) : 3;

        // Apply fatigue multiplier to sets
        targetSets = (targetSets * setsMultiplier).round().clamp(1, 6);

        // If low fatigue, add accessory volume
        if (fatigueScore < 0.6 && isAccessory) {
          targetSets = (targetSets + 1).clamp(1, 6);
        }

        final repsRangeParts = exTemplate.repsRange.split('–');
        int targetReps = repsRangeParts.isNotEmpty ? (int.tryParse(repsRangeParts.first) ?? 8) : 8;

        // Progression logic: check for PRs and plateaus
        double progressionMultiplier = 1.0;
        Exercise finalExercise = exercise;

        if (plateauExercises.contains(exerciseId)) {
          // Plateau detected: swap exercise or change rep range
          final alternative = _getAlternativeExercise(exerciseId);
          if (alternative != null) {
            finalExercise = alternative;
            adaptations.add('Swapped $exerciseId for ${alternative.id} due to plateau.');
          } else {
            // Change rep range
            targetReps = (targetReps - 2).clamp(3, 15);
            adaptations.add('Decreased target reps range for $exerciseId due to plateau.');
          }
        } else if (prExercises.contains(exerciseId) && fatigueScore < 0.9) {
          // PR recently & low fatigue: Progressive overload +2.5% to 5%
          progressionMultiplier = 1.035; // 3.5% jump
        }

        // Get user's last session weight for this exercise as baseline
        final double baselineWeight = _getLastCompletedWeight(history, exerciseId);
        final double targetWeight = (baselineWeight * weightMultiplier * progressionMultiplier);

        // Build sets
        final List<WorkoutSet> sets = List.generate(
          targetSets,
          (index) => WorkoutSet(
            reps: targetReps,
            weight: _roundWeight(targetWeight),
            isCompleted: false,
            restTime: Duration(seconds: exTemplate.intensityType == 'strength' ? 180 : 90),
          ),
        );

        workoutExercises.add(WorkoutExercise(
          exercise: finalExercise,
          sets: sets,
        ));
      }

      // Only add day if we have exercises
      if (workoutExercises.isNotEmpty) {
        weeklyPlan.add(WorkoutDay(
          dayName: dayTemplate.dayName,
          workout: Workout(
            id: 'gen_workout_${template.id}_${dayCounter++}',
            name: '${dayTemplate.dayName} - ${dayTemplate.muscleGroups.join("/")}',
            exercises: workoutExercises,
          ),
        ));
      }
    }

    final double difficulty = (difficultyModifier * (template.daysPerWeek / 5.0)).clamp(0.1, 1.0);

    return GeneratedProgram(
      id: 'gen_prog_${now.millisecondsSinceEpoch}',
      templateUsed: template,
      adaptationReason: adaptations.isNotEmpty ? adaptations.join('\n') : 'Baseline program created.',
      weeklyPlan: weeklyPlan,
      estimatedDifficulty: difficulty,
      createdAt: now,
    );
  }

  ProgramTemplate _selectTemplate(ProgramGoalType goal, String level) {
    if (goal == ProgramGoalType.strength) {
      if (level == 'beginner') {
        return const ProgramTemplate(
          id: 'str_beg_3',
          name: 'Beginner Strength Lift',
          goalType: ProgramGoalType.strength,
          level: 'beginner',
          daysPerWeek: 3,
          splitStructure: [
            WorkoutDayTemplate(
              dayName: 'Day 1',
              muscleGroups: ['Squat', 'Chest', 'Back'],
              exercises: [
                ExerciseTemplate(exerciseId: '3', setsRange: '3–3', repsRange: '5–5', intensityType: 'strength'), // Squat
                ExerciseTemplate(exerciseId: '4', setsRange: '3–3', repsRange: '5–5', intensityType: 'strength'), // Bench
                ExerciseTemplate(exerciseId: '8', setsRange: '3–3', repsRange: '5–5', intensityType: 'strength'), // Row
              ],
            ),
            WorkoutDayTemplate(
              dayName: 'Day 2',
              muscleGroups: ['Deadlift', 'Shoulders', 'Chest'],
              exercises: [
                ExerciseTemplate(exerciseId: '5', setsRange: '1–1', repsRange: '5–5', intensityType: 'strength'), // Deadlift
                ExerciseTemplate(exerciseId: '6', setsRange: '3–3', repsRange: '5–5', intensityType: 'strength'), // Press
                ExerciseTemplate(exerciseId: '1', setsRange: '3–3', repsRange: '8–10', intensityType: 'hypertrophy'), // Push-up
              ],
            ),
            WorkoutDayTemplate(
              dayName: 'Day 3',
              muscleGroups: ['Squat', 'Chest', 'Back'],
              exercises: [
                ExerciseTemplate(exerciseId: '3', setsRange: '3–3', repsRange: '5–5', intensityType: 'strength'), // Squat
                ExerciseTemplate(exerciseId: '4', setsRange: '3–3', repsRange: '5–5', intensityType: 'strength'), // Bench
                ExerciseTemplate(exerciseId: '2', setsRange: '3–3', repsRange: '6–8', intensityType: 'hypertrophy'), // Pull-up
              ],
            ),
          ],
        );
      } else {
        return const ProgramTemplate(
          id: 'str_int_4',
          name: 'Power & Strength Split',
          goalType: ProgramGoalType.strength,
          level: 'intermediate',
          daysPerWeek: 4,
          splitStructure: [
            WorkoutDayTemplate(
              dayName: 'Upper Body A',
              muscleGroups: ['Chest', 'Back', 'Shoulders'],
              exercises: [
                ExerciseTemplate(exerciseId: '4', setsRange: '4–5', repsRange: '4–6', intensityType: 'strength'), // Bench Press
                ExerciseTemplate(exerciseId: '8', setsRange: '4–4', repsRange: '6–8', intensityType: 'strength'), // Barbell Row
                ExerciseTemplate(exerciseId: '6', setsRange: '3–4', repsRange: '6–8', intensityType: 'strength'), // Overhead Press
                ExerciseTemplate(exerciseId: '1', setsRange: '3–3', repsRange: '10–12', intensityType: 'hypertrophy'), // Push-up
              ],
            ),
            WorkoutDayTemplate(
              dayName: 'Lower Body A',
              muscleGroups: ['Legs', 'Deadlift'],
              exercises: [
                ExerciseTemplate(exerciseId: '3', setsRange: '4–5', repsRange: '4–6', intensityType: 'strength'), // Squat
                ExerciseTemplate(exerciseId: '5', setsRange: '3–3', repsRange: '5–5', intensityType: 'strength'), // Deadlift
                ExerciseTemplate(exerciseId: '7', setsRange: '3–3', repsRange: '8–10', intensityType: 'hypertrophy'), // Lunges
              ],
            ),
            WorkoutDayTemplate(
              dayName: 'Upper Body B',
              muscleGroups: ['Chest', 'Back'],
              exercises: [
                ExerciseTemplate(exerciseId: '4', setsRange: '3–4', repsRange: '6–8', intensityType: 'strength'),
                ExerciseTemplate(exerciseId: '2', setsRange: '4–4', repsRange: '8–10', intensityType: 'hypertrophy'), // Pull-up
                ExerciseTemplate(exerciseId: '1', setsRange: '3–3', repsRange: '12–15', intensityType: 'endurance'),
              ],
            ),
            WorkoutDayTemplate(
              dayName: 'Lower Body B',
              muscleGroups: ['Legs'],
              exercises: [
                ExerciseTemplate(exerciseId: '3', setsRange: '3–4', repsRange: '6–8', intensityType: 'strength'),
                ExerciseTemplate(exerciseId: '7', setsRange: '4–4', repsRange: '10–12', intensityType: 'hypertrophy'),
              ],
            ),
          ],
        );
      }
    } else if (goal == ProgramGoalType.muscle_gain) {
      return const ProgramTemplate(
        id: 'mus_gain_4',
        name: 'Hypertrophy Builder',
        goalType: ProgramGoalType.muscle_gain,
        level: 'intermediate',
        daysPerWeek: 4,
        splitStructure: [
          WorkoutDayTemplate(
            dayName: 'Push Day A',
            muscleGroups: ['Chest', 'Shoulders'],
            exercises: [
              ExerciseTemplate(exerciseId: '4', setsRange: '4–4', repsRange: '8–10', intensityType: 'hypertrophy'), // Bench
              ExerciseTemplate(exerciseId: '6', setsRange: '3–4', repsRange: '8–12', intensityType: 'hypertrophy'), // OHP
              ExerciseTemplate(exerciseId: '1', setsRange: '3–3', repsRange: '10–12', intensityType: 'hypertrophy'), // Push-up
            ],
          ),
          WorkoutDayTemplate(
            dayName: 'Pull Day A',
            muscleGroups: ['Back'],
            exercises: [
              ExerciseTemplate(exerciseId: '2', setsRange: '4–4', repsRange: '8–10', intensityType: 'hypertrophy'), // Pull-up
              ExerciseTemplate(exerciseId: '8', setsRange: '3–4', repsRange: '8–12', intensityType: 'hypertrophy'), // Barbell Row
            ],
          ),
          WorkoutDayTemplate(
            dayName: 'Legs Day A',
            muscleGroups: ['Legs'],
            exercises: [
              ExerciseTemplate(exerciseId: '3', setsRange: '4–4', repsRange: '8–12', intensityType: 'hypertrophy'), // Squat
              ExerciseTemplate(exerciseId: '7', setsRange: '3–4', repsRange: '10–12', intensityType: 'hypertrophy'), // Lunges
              ExerciseTemplate(exerciseId: '5', setsRange: '2–3', repsRange: '6–8', intensityType: 'strength'), // Deadlift
            ],
          ),
          WorkoutDayTemplate(
            dayName: 'Upper Body B',
            muscleGroups: ['Chest', 'Back'],
            exercises: [
              ExerciseTemplate(exerciseId: '4', setsRange: '3–4', repsRange: '10–12', intensityType: 'hypertrophy'),
              ExerciseTemplate(exerciseId: '8', setsRange: '3–4', repsRange: '10–12', intensityType: 'hypertrophy'),
              ExerciseTemplate(exerciseId: '1', setsRange: '3–3', repsRange: '12–15', intensityType: 'endurance'),
            ],
          ),
        ],
      );
    } else {
      // General or Fat Loss template
      return const ProgramTemplate(
        id: 'gen_fit_3',
        name: 'General Fitness & Tone',
        goalType: ProgramGoalType.general,
        level: 'beginner',
        daysPerWeek: 3,
        splitStructure: [
          WorkoutDayTemplate(
            dayName: 'Full Body A',
            muscleGroups: ['Chest', 'Back', 'Legs'],
            exercises: [
              ExerciseTemplate(exerciseId: '3', setsRange: '3–3', repsRange: '10–12', intensityType: 'hypertrophy'), // Squat
              ExerciseTemplate(exerciseId: '4', setsRange: '3–3', repsRange: '8–10', intensityType: 'hypertrophy'), // Bench Press
              ExerciseTemplate(exerciseId: '2', setsRange: '3–3', repsRange: '8–10', intensityType: 'hypertrophy'), // Pull-up
            ],
          ),
          WorkoutDayTemplate(
            dayName: 'Full Body B',
            muscleGroups: ['Legs', 'Shoulders', 'Back'],
            exercises: [
              ExerciseTemplate(exerciseId: '7', setsRange: '3–3', repsRange: '10–12', intensityType: 'hypertrophy'), // Lunges
              ExerciseTemplate(exerciseId: '6', setsRange: '3–3', repsRange: '8–10', intensityType: 'hypertrophy'), // Press
              ExerciseTemplate(exerciseId: '8', setsRange: '3–3', repsRange: '10–12', intensityType: 'hypertrophy'), // Row
            ],
          ),
          WorkoutDayTemplate(
            dayName: 'Full Body C',
            muscleGroups: ['Chest', 'Back', 'Legs'],
            exercises: [
              ExerciseTemplate(exerciseId: '1', setsRange: '3–3', repsRange: '12–15', intensityType: 'endurance'), // Pushups
              ExerciseTemplate(exerciseId: '2', setsRange: '3–3', repsRange: '6–8', intensityType: 'hypertrophy'), // Pullups
              ExerciseTemplate(exerciseId: '5', setsRange: '2–2', repsRange: '8–10', intensityType: 'strength'), // Deadlift
            ],
          ),
        ],
      );
    }
  }

  bool _isCompoundMovement(String id) {
    return id == '3' || id == '4' || id == '5' || id == '6' || id == '8';
  }

  Exercise? _getAlternativeExercise(String exerciseId) {
    // Swaps to variation
    switch (exerciseId) {
      case '4': // Bench Press -> Push-up
        return ExerciseLibrary.exercises.firstWhere((e) => e.id == '1');
      case '1': // Push-up -> Bench Press
        return ExerciseLibrary.exercises.firstWhere((e) => e.id == '4');
      case '3': // Squat -> Lunges
        return ExerciseLibrary.exercises.firstWhere((e) => e.id == '7');
      case '7': // Lunges -> Squat
        return ExerciseLibrary.exercises.firstWhere((e) => e.id == '3');
      case '8': // Barbell Row -> Pull-up
        return ExerciseLibrary.exercises.firstWhere((e) => e.id == '2');
      case '2': // Pull-up -> Barbell Row
        return ExerciseLibrary.exercises.firstWhere((e) => e.id == '8');
      default:
        return null;
    }
  }

  List<String> _detectRecentPRs(List<WorkoutSession> history) {
    final prs = <String>[];
    final now = DateTime.now();
    final fourteenDaysAgo = now.subtract(const Duration(days: 14));

    // Simple rule: if we logged any workout session in last 14 days where the weight is high,
    // let's assume those exercises had progress.
    // For a real calculation, we check if max weight for that exercise in last 14 days
    // is greater than max weight before.
    final recentSessions = history.where((s) => s.startTime.isAfter(fourteenDaysAgo)).toList();
    final olderSessions = history.where((s) => s.startTime.isBefore(fourteenDaysAgo)).toList();

    if (recentSessions.isEmpty || olderSessions.isEmpty) return prs;

    final baseBests = _getBests(olderSessions);
    final recentBests = _getBests(recentSessions);

    recentBests.forEach((exerciseId, weight) {
      final baseWeight = baseBests[exerciseId] ?? 0.0;
      if (weight > baseWeight && baseWeight > 0) {
        prs.add(exerciseId);
      }
    });

    return prs;
  }

  List<String> _detectPlateaus(List<WorkoutSession> history) {
    final plateaus = <String>[];
    final now = DateTime.now();
    final fourteenDaysAgo = now.subtract(const Duration(days: 14));

    final recentSessions = history.where((s) => s.startTime.isAfter(fourteenDaysAgo)).toList();
    if (recentSessions.length < 2) return plateaus;

    // A plateau means no increase in working weight over 14 days,
    // we can check if their max weights are identical for all recent sessions.
    final Map<String, List<double>> exerciseWeights = {};
    for (final s in recentSessions) {
      for (final ex in s.workout.exercises) {
        for (final set in ex.sets) {
          if (set.isCompleted) {
            exerciseWeights.putIfAbsent(ex.exercise.id, () => []).add(set.weight);
          }
        }
      }
    }

    exerciseWeights.forEach((exerciseId, weights) {
      if (weights.length >= 3) {
        final first = weights.first;
        final allSame = weights.every((w) => w == first);
        if (allSame) {
          plateaus.add(exerciseId);
        }
      }
    });

    return plateaus;
  }

  Map<String, double> _getBests(List<WorkoutSession> sessions) {
    final bests = <String, double>{};
    for (final s in sessions) {
      for (final ex in s.workout.exercises) {
        for (final set in ex.sets) {
          if (set.isCompleted) {
            final currentBest = bests[ex.exercise.id] ?? 0.0;
            if (set.weight > currentBest) {
              bests[ex.exercise.id] = set.weight;
            }
          }
        }
      }
    }
    return bests;
  }

  double _getLastCompletedWeight(List<WorkoutSession> history, String exerciseId) {
    for (final s in history) {
      for (final ex in s.workout.exercises) {
        if (ex.exercise.id == exerciseId) {
          for (final set in ex.sets) {
            if (set.isCompleted && set.weight > 0) {
              return set.weight;
            }
          }
        }
      }
    }
    // Default weights for exercises if no history
    switch (exerciseId) {
      case '3': // Squat
        return 60.0;
      case '4': // Bench
        return 50.0;
      case '5': // Deadlift
        return 70.0;
      case '6': // OHP
        return 30.0;
      case '8': // Barbell Row
        return 40.0;
      default:
        return 0.0; // Bodyweight
    }
  }

  double _roundWeight(double weight) {
    // Round to nearest 2.5kg increment (standard gym plates)
    return (weight / 2.5).roundToDouble() * 2.5;
  }
}

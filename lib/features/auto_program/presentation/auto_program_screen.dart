import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_sizes.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../core/theme.dart';
import '../providers/auto_program_provider.dart';
import '../domain/generated_program.dart';
import 'widgets/program_day_card.dart';
import 'widgets/adaptation_banner.dart';

class AutoProgramScreen extends ConsumerWidget {
  const AutoProgramScreen({super.key});

  void _showWorkoutDetails(BuildContext context, WorkoutDay day) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      day.dayName.toUpperCase(),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryLime,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Text(
                  day.workout.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withAlpha(150),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: AppSizes.m),
                const Divider(color: Colors.white10),
                const SizedBox(height: AppSizes.s),
                Expanded(
                  child: ListView.builder(
                    itemCount: day.workout.exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = day.workout.exercises[index];
                      final totalSets = exercise.sets.length;
                      final reps = exercise.sets.isNotEmpty ? exercise.sets.first.reps : 0;
                      final weight = exercise.sets.isNotEmpty ? exercise.sets.first.weight : 0.0;
                      final rest = exercise.sets.isNotEmpty ? (exercise.sets.first.restTime?.inSeconds ?? 90) : 90;

                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSizes.m),
                        padding: const EdgeInsets.all(AppSizes.m),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise.exercise.name.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    (exercise.exercise.muscleGroup ?? '').toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white.withAlpha(120),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$totalSets SETS × $reps REPS',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  weight > 0 ? '${weight}KG • ${rest}S REST' : 'BODYWEIGHT • ${rest}S REST',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.primaryLime.withAlpha(200),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generatedAsync = ref.watch(generatedProgramProvider);
    final notifierState = ref.watch(autoProgramNotifierProvider);
    final theme = Theme.of(context);

    // Listen to notifierState to show SnackBar on success or error
    ref.listen<AsyncValue<void>>(autoProgramNotifierProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('AI PROGRAM SAVED AND ACTIVATED SUCCESSFULY!'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        },
        error: (err, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save program: $err'),
              backgroundColor: Colors.redAccent,
            ),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI PROGRAM GENERATOR',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: generatedAsync.when(
        data: (program) => Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==========================================
                    // CURRENT RECOMMENDED PROGRAM CARD
                    // ==========================================
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                        ),
                        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                        border: Border.all(
                          color: AppTheme.primaryLime.withAlpha(50),
                          width: 1.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.cardPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RECOMMENDED WORKOUT SYSTEM',
                              style: TextStyle(
                                color: AppTheme.primaryLime,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: AppSizes.xs),
                            Text(
                              program.templateUsed.name.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: AppSizes.s),
                            Row(
                              children: [
                                _buildBadge('GOAL: ${program.templateUsed.goalType.name.replaceAll("_", " ")}', const Color(0xFF38BDF8)),
                                const SizedBox(width: AppSizes.s),
                                _buildBadge('LEVEL: ${program.templateUsed.level}', const Color(0xFFFBBF24)),
                              ],
                            ),
                            const SizedBox(height: AppSizes.m),
                            const Text(
                              'ESTIMATED DIFFICULTY',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54),
                            ),
                            const SizedBox(height: AppSizes.xs),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: LinearProgressIndicator(
                                value: program.estimatedDifficulty,
                                minHeight: 8,
                                backgroundColor: Colors.white12,
                                valueColor: AlwaysStoppedAnimation<Color>(_getDifficultyColor(program.estimatedDifficulty)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.l),

                    // ==========================================
                    // WHY THIS PROGRAM (ADAPTATIONS)
                    // ==========================================
                    const Text(
                      'ADAPTIVE INTELLIGENCE LOG',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1.5,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: AppSizes.m),
                    AdaptationBanner(adaptationReason: program.adaptationReason),
                    const SizedBox(height: AppSizes.l),

                    // ==========================================
                    // WEEKLY PLAN PREVIEW
                    // ==========================================
                    const Text(
                      'WEEKLY TRAINING SPLIT',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1.5,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: AppSizes.m),
                    ...program.weeklyPlan.map(
                      (day) => ProgramDayCard(
                        workoutDay: day,
                        onTap: () => _showWorkoutDetails(context, day),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ==========================================
            // ACTIVATE BUTTON
            // ==========================================
            Container(
              padding: const EdgeInsets.all(AppSizes.m),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceDark,
                border: Border(top: BorderSide(color: Colors.white10, width: 1)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: notifierState.isLoading
                      ? null
                      : () => ref.read(autoProgramNotifierProvider.notifier).saveCurrentGeneratedProgram(),
                  icon: notifierState.isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
                        )
                      : const Icon(Icons.check_circle_outline, color: Colors.black),
                  label: Text(
                    notifierState.isLoading ? 'SAVING SPLIT...' : 'ACTIVATE RECOMMENDED PROGRAM',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
        loading: () => const AppLoading(message: 'CLASSIFYING PROFILE & COMPUTING ADAPTATIONS...'),
        error: (err, _) => AppErrorWidget(
          message: 'FAILED TO GENERATE TRAINING PROGRAM',
          onRetry: () => ref.invalidate(generatedProgramProvider),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s, vertical: AppSizes.xs),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(60), width: 1),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getDifficultyColor(double diff) {
    if (diff > 0.75) return const Color(0xFFEF4444); // Hard - Red
    if (diff > 0.45) return const Color(0xFFF97316); // Med - Orange
    return AppTheme.primaryLime; // Easy - Lime
  }
}

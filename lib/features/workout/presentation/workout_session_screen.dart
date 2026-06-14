import 'package:workout/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../settings/domain/app_settings.dart';
import '../../settings/providers/settings_provider.dart';
import '../domain/workout_set.dart';
import '../providers/workout_providers.dart';
import 'rest_timer.dart';
import '../../fitness_intelligence/providers/fitness_intelligence_providers.dart';
import '../../fitness_intelligence/warmup/warmup_generator.dart';
import '../../fitness_intelligence/progression/progressive_overload_engine.dart';
import '../../fitness_intelligence/exercise_execution/exercise_execution_guide.dart';

import 'package:flutter/services.dart';

class WorkoutSessionScreen extends ConsumerWidget {
  const WorkoutSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(activeSessionProvider);
    final settings = ref.watch(settingsProvider);
    final unitLabel = settings.unitSystem == UnitSystem.kg ? 'kg' : 'lb';

    if (activeSession == null) {
      return Scaffold(body: Center(child: Text(AppLocalizations.of(context)!.noActiveSession)));
    }

    final workout = activeSession.workout;

    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name.toUpperCase(), style: const TextStyle(letterSpacing: 1.5, fontSize: 16)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 120),
              itemCount: workout.exercises.length,
              itemBuilder: (context, exerciseIndex) {
                final workoutExercise = workout.exercises[exerciseIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSizes.m, AppSizes.l, AppSizes.m, AppSizes.s),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(workoutExercise.exercise.name.toUpperCase(), 
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryLime),
                            onPressed: () => ref.read(activeSessionProvider.notifier).addSet(exerciseIndex),
                          ),
                        ],
                      ),
                    ),
                    _ExerciseIntelligencePanel(
                      exerciseId: workoutExercise.exercise.id,
                      exerciseName: workoutExercise.exercise.name,
                      muscleGroup: workoutExercise.exercise.muscleGroup ?? 'Full Body',
                      workWeight: workoutExercise.sets.isNotEmpty ? workoutExercise.sets.first.weight : 0.0,
                    ),
                    ...workoutExercise.sets.asMap().entries.map((entry) {
                      final setIndex = entry.key;
                      final set = entry.value;
                      final bool isNext = !set.isCompleted && 
                        (setIndex == 0 || workoutExercise.sets[setIndex - 1].isCompleted);

                      return _SetRow(
                        setIndex: setIndex,
                        set: set,
                        isNext: isNext,
                        unitLabel: unitLabel,
                        onUpdate: (updated) => ref.read(activeSessionProvider.notifier).updateSet(exerciseIndex, setIndex, updated),
                      );
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: AppSizes.s),
                      child: OutlinedButton.icon(
                        onPressed: () => ref.read(activeSessionProvider.notifier).addSet(exerciseIndex),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('QUICK ADD SET', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          side: BorderSide(color: AppTheme.primaryLime.withAlpha(80)),
                          foregroundColor: AppTheme.primaryLime,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 32, indent: AppSizes.m, endIndent: AppSizes.m),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(AppSizes.m),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(top: BorderSide(color: Colors.white.withAlpha(20))),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RestTimer(
                duration: Duration(seconds: settings.defaultRestSeconds),
                onFinished: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.restFinished)),
                  );
                },
              ),
              const SizedBox(height: AppSizes.m),
              AppButton(
                text: 'FINISH WORKOUT',
                onPressed: () async {
                  final session = await ref.read(activeSessionProvider.notifier).endSession();
                  if (context.mounted && session != null) {
                    context.pushReplacement('/workout-summary', extra: session);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  final int setIndex;
  final WorkoutSet set;
  final bool isNext;
  final String unitLabel;
  final Function(WorkoutSet) onUpdate;

  const _SetRow({
    required this.setIndex,
    required this.set,
    required this.isNext,
    required this.unitLabel,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = set.isCompleted 
      ? AppTheme.primaryLime.withAlpha(30)
      : (isNext ? Colors.white.withAlpha(10) : Colors.transparent);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text('${setIndex + 1}', 
              style: TextStyle(
                fontWeight: FontWeight.w900, 
                color: set.isCompleted ? AppTheme.primaryLime : Colors.white24
              )
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildInput(
                  context,
                  initial: set.weight % 1 == 0 ? set.weight.toInt().toString() : set.weight.toString(),
                  label: unitLabel,
                  onChanged: (v) => onUpdate(set.copyWith(weight: double.tryParse(v) ?? 0)),
                  onIncrement: () => onUpdate(set.copyWith(weight: set.weight + 2.5)),
                  onDecrement: () => onUpdate(set.copyWith(weight: (set.weight - 2.5).clamp(0, 999))),
                ),
                const SizedBox(width: AppSizes.m),
                _buildInput(
                  context,
                  initial: set.reps.toString(),
                  label: 'REPS',
                  onChanged: (v) => onUpdate(set.copyWith(reps: int.tryParse(v) ?? 0)),
                  onIncrement: () => onUpdate(set.copyWith(reps: set.reps + 1)),
                  onDecrement: () => onUpdate(set.copyWith(reps: (set.reps - 1).clamp(0, 999))),
                ),
              ],
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.lightImpact();
              onUpdate(set.copyWith(isCompleted: !set.isCompleted));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Icon(
                set.isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                size: 32,
                color: set.isCompleted ? AppTheme.primaryLime : Colors.white12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
    BuildContext context, {
    required String initial,
    required String label,
    required Function(String) onChanged,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white38)),
          Row(
            children: [
              GestureDetector(
                onTap: onDecrement,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Icon(Icons.remove_circle_outline, size: 20, color: Colors.white38),
                ),
              ),
              Expanded(
                child: TextFormField(
                  key: ValueKey(initial),
                  initialValue: initial,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                    border: InputBorder.none,
                  ),
                  onChanged: onChanged,
                ),
              ),
              GestureDetector(
                onTap: onIncrement,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Icon(Icons.add_circle_outline, size: 20, color: Colors.white38),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExerciseIntelligencePanel extends ConsumerStatefulWidget {
  final String exerciseId;
  final String exerciseName;
  final String muscleGroup;
  final double workWeight;

  const _ExerciseIntelligencePanel({
    required this.exerciseId,
    required this.exerciseName,
    required this.muscleGroup,
    required this.workWeight,
  });

  @override
  ConsumerState<_ExerciseIntelligencePanel> createState() => _ExerciseIntelligencePanelState();
}

class _ExerciseIntelligencePanelState extends ConsumerState<_ExerciseIntelligencePanel> {
  bool _isWarmupExpanded = false;
  bool _isGuideExpanded = false;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<ProgressiveOverloadRecommendation> overloadAsync = ref.watch(progressionProvider(widget.exerciseId));
    final ExecutionInstructions guide = ref.watch(executionGuideProvider(widget.exerciseName));

    final WarmupPlan warmupPlan = ref.watch(warmupProvider((
      muscleGroup: widget.muscleGroup,
      workWeight: widget.workWeight > 0.0 ? widget.workWeight : 50.0,
    )));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Progressive Overload Banner
        overloadAsync.maybeWhen(
          data: (rec) {
            if (rec.action == 'BASELINE') return const SizedBox.shrink();

            Color bannerColor = Colors.white24;
            IconData bannerIcon = Icons.info_outline;
            switch (rec.action) {
              case 'WEIGHT_INCREASE':
                bannerColor = AppTheme.primaryLime;
                bannerIcon = Icons.trending_up_rounded;
                break;
              case 'REP_INCREASE':
                bannerColor = Colors.orange;
                bannerIcon = Icons.plus_one_rounded;
                break;
              case 'DELOAD':
                bannerColor = Colors.blueAccent;
                bannerIcon = Icons.shield_rounded;
                break;
              case 'VARIATION_SUGGESTION':
                bannerColor = Colors.purpleAccent;
                bannerIcon = Icons.shuffle_rounded;
                break;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: 4),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.s),
                decoration: BoxDecoration(
                  color: bannerColor.withValues(alpha: 0.1),
                  border: Border.all(color: bannerColor.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(bannerIcon, color: bannerColor, size: 18),
                    const SizedBox(width: AppSizes.s),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OVERLOAD TARGET: ${rec.action.replaceAll('_', ' ')}',
                            style: TextStyle(color: bannerColor, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            rec.explanation,
                            style: const TextStyle(fontSize: 10, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        ),

        // 2. Expandable Warm-up & Guide Chips row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: 4),
          child: Row(
            children: [
              FilterChip(
                selected: _isWarmupExpanded,
                label: const Text('Warmup sets', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                onSelected: (val) {
                  setState(() {
                    _isWarmupExpanded = val;
                    if (val) _isGuideExpanded = false;
                  });
                },
                selectedColor: AppTheme.primaryLime.withValues(alpha: 0.2),
                checkmarkColor: AppTheme.primaryLime,
              ),
              const SizedBox(width: AppSizes.s),
              FilterChip(
                selected: _isGuideExpanded,
                label: const Text('Form Guide', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                onSelected: (val) {
                  setState(() {
                    _isGuideExpanded = val;
                    if (val) _isWarmupExpanded = false;
                  });
                },
                selectedColor: AppTheme.primaryLime.withValues(alpha: 0.2),
                checkmarkColor: AppTheme.primaryLime,
              ),
            ],
          ),
        ),

        // 3. Warm-up Plan Detail Card
        if (_isWarmupExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: 4),
            child: SizedBox(
              width: double.infinity,
              child: Card(
                color: Colors.white.withValues(alpha: 0.03),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('DYNAMIC WARMUP SETS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppTheme.primaryLime)),
                      const SizedBox(height: AppSizes.s),
                      ...warmupPlan.sets.map((ws) {
                        final calculatedWeight = (widget.workWeight * (ws.percent / 100.0)).toStringAsFixed(1);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${ws.percent.toInt()}% of Working Load', style: const TextStyle(fontSize: 11, color: Colors.white60)),
                              Text('$calculatedWeight kg x ${ws.reps} reps', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      }),
                      const Divider(height: 16, color: Colors.white10),
                      const Text('ACTIVATION & MOBILITY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.white54)),
                      const SizedBox(height: 4),
                      ...warmupPlan.mobilitySuggestions.map((m) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Text('• $m', style: const TextStyle(fontSize: 10, color: Colors.white70)),
                      )),
                      ...warmupPlan.activationExercises.map((a) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Text('• $a', style: const TextStyle(fontSize: 10, color: Colors.white70)),
                      )),
                      const SizedBox(height: AppSizes.s),
                      Text(
                        warmupPlan.injuryPreventionNotes,
                        style: const TextStyle(fontSize: 9, fontStyle: FontStyle.italic, color: Colors.orangeAccent),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // 4. Execution Guide Detail Card
        if (_isGuideExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: 4),
            child: SizedBox(
              width: double.infinity,
              child: Card(
                color: Colors.white.withValues(alpha: 0.03),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('FORM EXECUTION STEPS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppTheme.primaryLime)),
                      const SizedBox(height: AppSizes.s),
                      ...guide.steps.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('${e.key + 1}. ${e.value}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                      )),
                      const Divider(height: 16, color: Colors.white10),
                      const Text('COMMON MISTAKES TO AVOID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.redAccent)),
                      const SizedBox(height: 4),
                      ...guide.commonMistakes.map((m) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Text('❌ $m', style: const TextStyle(fontSize: 10, color: Colors.white70)),
                      )),
                      const Divider(height: 16, color: Colors.white10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('BREATHING', style: TextStyle(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.bold)),
                                Text(guide.breathing, style: const TextStyle(fontSize: 10, color: Colors.white70)),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSizes.m),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('TEMPO', style: TextStyle(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.bold)),
                              Text(guide.tempo, style: const TextStyle(fontSize: 10, color: AppTheme.primaryLime, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

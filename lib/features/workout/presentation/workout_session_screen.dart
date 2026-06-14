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

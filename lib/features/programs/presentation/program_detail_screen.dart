import 'package:workout/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../workout/providers/workout_providers.dart';
import '../domain/program.dart';
import '../providers/program_providers.dart';

class ProgramDetailScreen extends ConsumerStatefulWidget {
  final String programId;

  const ProgramDetailScreen({super.key, required this.programId});

  @override
  ConsumerState<ProgramDetailScreen> createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends ConsumerState<ProgramDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final programsAsync = ref.watch(programListProvider);
    final workoutsAsync = ref.watch(workoutListProvider);

    return programsAsync.when(
      data: (programs) {
        final program = programs.firstWhere((p) => p.id == widget.programId);
        
        return Scaffold(
          appBar: AppBar(
            title: Text(program.name.toUpperCase()),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _renameProgram(context, ref, program),
              ),
            ],
          ),
          body: Column(
            children: [
              if (program.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSizes.m),
                  child: Text(program.description, style: const TextStyle(color: Colors.white70)),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.m),
                  itemCount: 7, // Days of week
                  itemBuilder: (context, index) {
                    final dayNumber = index + 1;
                    return _buildDaySection(context, ref, program, dayNumber, workoutsAsync);
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildDaySection(BuildContext context, WidgetRef ref, Program program, int dayNumber, AsyncValue<List<dynamic>> workoutsAsync) {
    final dayWorkouts = program.workouts.where((sw) => sw.dayOfWeek == dayNumber).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    final dayName = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'][dayNumber - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.s),
          child: Text(dayName, style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primaryLime, letterSpacing: 1, fontSize: 12)),
        ),
        if (dayWorkouts.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.m),
            child: TextButton(
              onPressed: () => _showAddWorkoutDialog(context, ref, program, dayNumber),
              child: const Text('+ ADD WORKOUT', style: TextStyle(fontSize: 10, color: Colors.white24)),
            ),
          )
        else
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: (oldIndex, newIndex) => ref.read(programListProvider.notifier).reorderWorkout(program.id, dayNumber, oldIndex, newIndex),
            children: dayWorkouts.map((sw) {
              return Padding(
                key: ValueKey(sw.workoutId + sw.order.toString()),
                padding: const EdgeInsets.only(bottom: AppSizes.s),
                child: AppCard(
                  showBorder: true,
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    dense: true,
                    title: Consumer(
                      builder: (context, ref, _) {
                        final workouts = workoutsAsync.asData?.value ?? [];
                        final workout = workouts.firstWhere((w) => w.id == sw.workoutId, orElse: () => null);
                        return Text(workout?.name ?? 'Unknown Workout', style: const TextStyle(fontWeight: FontWeight.bold));
                      },
                    ),
                    trailing: const Icon(Icons.drag_handle, color: Colors.white24),
                  ),
                ),
              );
            }).toList(),
          ),
        if (dayWorkouts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.m),
            child: AppButton(
              text: 'ADD ANOTHER',
              variant: AppButtonVariant.secondary,
              onPressed: () => _showAddWorkoutDialog(context, ref, program, dayNumber),
            ),
          ),
      ],
    );
  }

  Future<void> _renameProgram(BuildContext context, WidgetRef ref, Program program) async {
    final controller = TextEditingController(text: program.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.renameProgram),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: Text(AppLocalizations.of(context)!.save)),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      final updated = program.copyWith(name: newName);
      await ref.read(programListProvider.notifier).updateProgram(updated);
    }
  }

  Future<void> _showAddWorkoutDialog(BuildContext context, WidgetRef ref, Program program, int dayNumber) async {
    final workouts = ref.read(workoutListProvider).asData?.value ?? [];
    
    if (workouts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.createWorkoutFirst)));
      return;
    }

    final selectedWorkoutId = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(AppLocalizations.of(context)!.chooseWorkout),
        children: workouts.map((w) => SimpleDialogOption(
          onPressed: () => Navigator.pop(context, w.id),
          child: Text(w.name.toUpperCase()),
        )).toList(),
      ),
    );

    if (selectedWorkoutId != null) {
      await ref.read(programListProvider.notifier).scheduleWorkout(program.id, selectedWorkoutId, dayNumber);
    }
  }
}

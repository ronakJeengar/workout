import 'package:workout/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../domain/program.dart';
import '../providers/program_providers.dart';
import '../../coach/providers/coach_providers.dart';
import '../../coach/domain/fatigue_model.dart';
import '../../../core/theme.dart';

class ProgramsScreen extends ConsumerWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programsAsync = ref.watch(programListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.trainingPrograms, 
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 2,
          )
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'AI Program Generator',
            onPressed: () => context.push('/auto-program'),
          ),
        ],
      ),
      body: programsAsync.when(
        data: (programs) {
          if (programs.isEmpty) {
            return const AppEmptyState(
              icon: Icons.assignment_outlined,
              title: 'NO PROGRAMS YET',
              subtitle: 'Plan your next training block.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.m),
            itemCount: programs.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildContextualSuggestion(context, ref);
              }
              final program = programs[index - 1];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.m),
                child: AppCard(
                  showBorder: true,
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: AppSizes.s),
                        title: Text(program.name.toUpperCase(), 
                          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)
                        ),
                        subtitle: Text('${program.workouts.length} WORKOUTS', 
                          style: TextStyle(color: Theme.of(context).colorScheme.primary.withAlpha(180), fontSize: 11, fontWeight: FontWeight.bold)
                        ),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                        onTap: () => context.push('/program-detail', extra: program.id),
                      ),
                      const Divider(height: 1, color: Colors.white10),
                      Padding(
                        padding: const EdgeInsets.all(AppSizes.s),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => ref.read(programListProvider.notifier).duplicateProgram(program),
                              icon: const Icon(Icons.copy_rounded, size: 16),
                              label: Text(AppLocalizations.of(context)!.duplicate, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                            TextButton.icon(
                              onPressed: () => _confirmDelete(context, ref, program),
                              icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent),
                              label: Text(AppLocalizations.of(context)!.delete, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const AppLoading(),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.black,
        onPressed: () => context.push('/programs/create'),
        icon: const Icon(Icons.add, fontWeight: FontWeight.bold),
        label: Text(AppLocalizations.of(context)!.newProgram, style: TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Program program) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteProgramTitle),
        content: Text(AppLocalizations.of(context)!.areYouSureDelete(program.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppLocalizations.of(context)!.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: Text(AppLocalizations.of(context)!.delete, style: TextStyle(color: Colors.redAccent))
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(programListProvider.notifier).deleteProgram(program.id);
    }
  }

  Widget _buildContextualSuggestion(BuildContext context, WidgetRef ref) {
    final fatigueAsync = ref.watch(fatigueProvider);
    return fatigueAsync.maybeWhen(
      data: (fatigue) {
        if (fatigue.fatigueScore < 0.3) {
          if (fatigue.fatigueScore == 0.0) return const SizedBox.shrink(); // No history yet
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.m),
            child: AppCard(
              showBorder: true,
              padding: const EdgeInsets.all(AppSizes.m),
              child: InkWell(
                onTap: () => context.push('/coach'),
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                child: Row(
                  children: [
                    const Icon(Icons.rocket_launch_rounded, color: AppTheme.primaryLime),
                    const SizedBox(width: AppSizes.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('READY FOR ADVANCED TRAINING', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppTheme.primaryLime)),
                          Text('Your fatigue is low (${(fatigue.fatigueScore*100).toInt()}%). Great window to start a hypertrophy or strength program block.', style: TextStyle(fontSize: 10, color: Colors.white.withAlpha(200))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        
        if (fatigue.recoveryState == FatigueState.overtrained || fatigue.recoveryState == FatigueState.high) {
          final isOvertrained = fatigue.recoveryState == FatigueState.overtrained;
          final color = isOvertrained ? const Color(0xFFEF4444) : const Color(0xFFF97316);
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.m),
            child: AppCard(
              showBorder: true,
              padding: const EdgeInsets.all(AppSizes.m),
              child: InkWell(
                onTap: () => context.push('/coach'),
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: color),
                    const SizedBox(width: AppSizes.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isOvertrained ? 'WARNING: DELOAD SUGGESTED' : 'ADAPTIVE TRAINING RECOMMENDATION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: color)),
                          Text(isOvertrained 
                            ? 'Critical fatigue levels detected. Consider selecting a deload/recovery program block instead of high-intensity programs.'
                            : 'Elevated fatigue levels detected. Keep training program intensity low/moderate this week.', style: TextStyle(fontSize: 10, color: Colors.white.withAlpha(200))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

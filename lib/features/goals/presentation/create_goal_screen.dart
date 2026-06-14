import 'package:workout/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/app_button.dart';
import '../domain/goal.dart';
import '../providers/goal_providers.dart';

class CreateGoalScreen extends ConsumerStatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  ConsumerState<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends ConsumerState<CreateGoalScreen> {
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  GoalType _selectedType = GoalType.workoutsPerWeek;

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.newGoal),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'GOAL TITLE'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSizes.m),
            Text(AppLocalizations.of(context)!.goalType, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38)),
            DropdownButton<GoalType>(
              value: _selectedType,
              isExpanded: true,
              items: GoalType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedType = val);
              },
            ),
            const SizedBox(height: AppSizes.m),
            TextField(
              controller: _targetController,
              decoration: const InputDecoration(labelText: 'TARGET VALUE'),
              keyboardType: TextInputType.number,
            ),
            const Spacer(),
            AppButton(
              text: 'SET GOAL',
              onPressed: () async {
                final target = double.tryParse(_targetController.text) ?? 0;
                if (_titleController.text.isNotEmpty && target > 0) {
                  await ref.read(goalListProvider.notifier).addGoal(
                    _titleController.text,
                    _selectedType,
                    target,
                  );
                  if (context.mounted) context.pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

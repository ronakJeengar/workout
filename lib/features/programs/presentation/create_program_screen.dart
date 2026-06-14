import 'package:workout/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/app_button.dart';
import '../providers/program_providers.dart';

class CreateProgramScreen extends ConsumerStatefulWidget {
  const CreateProgramScreen({super.key});

  @override
  ConsumerState<CreateProgramScreen> createState() => _CreateProgramScreenState();
}

class _CreateProgramScreenState extends ConsumerState<CreateProgramScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.createProgram),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.m),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'PROGRAM NAME'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSizes.m),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'DESCRIPTION (OPTIONAL)'),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
            ),
            const Spacer(),
            AppButton(
              text: 'CREATE PROGRAM',
              onPressed: () async {
                if (_nameController.text.isNotEmpty) {
                  await ref.read(programListProvider.notifier).createProgram(
                    _nameController.text,
                    description: _descController.text,
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

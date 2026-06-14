import 'package:workout/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/app_card.dart';
import '../domain/app_settings.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.m),
        children: [
          _buildSection(
            context,
            title: 'Appearance',
            child: RadioGroup<AppThemeMode>(
              groupValue: settings.themeMode,
              onChanged: (val) => ref.read(settingsProvider.notifier).updateTheme(val!),
              child: Column(
                children: [
                  _buildRadioTile<AppThemeMode>(
                    title: 'System',
                    value: AppThemeMode.system,
                  ),
                  _buildRadioTile<AppThemeMode>(
                    title: 'Light',
                    value: AppThemeMode.light,
                  ),
                  _buildRadioTile<AppThemeMode>(
                    title: 'Dark',
                    value: AppThemeMode.dark,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.m),
          _buildSection(
            context,
            title: 'Units',
            child: RadioGroup<UnitSystem>(
              groupValue: settings.unitSystem,
              onChanged: (val) => ref.read(settingsProvider.notifier).updateUnits(val!),
              child: Column(
                children: [
                  _buildRadioTile<UnitSystem>(
                    title: 'Kilograms (kg)',
                    value: UnitSystem.kg,
                  ),
                  _buildRadioTile<UnitSystem>(
                    title: 'Pounds (lb)',
                    value: UnitSystem.lb,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSizes.m),
          _buildSection(
            context,
            title: 'Workout',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(AppLocalizations.of(context)!.defaultRestTimer),
                  subtitle: Text('${settings.defaultRestSeconds} seconds'),
                ),
                Slider(
                  value: settings.defaultRestSeconds.toDouble(),
                  min: 30,
                  max: 300,
                  divisions: 27,
                  label: '${settings.defaultRestSeconds}s',
                  onChanged: (val) => ref.read(settingsProvider.notifier).updateDefaultRest(val.toInt()),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.m),
          _buildSection(
            context,
            title: 'Diagnostics & Telemetry',
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: const Text('Crash & Stability Logs'),
                  subtitle: const Text('Top crashes, root causes & fix priorities'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/crash-report'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.analytics_outlined),
                  title: const Text('Retention & Behavior Funnels'),
                  subtitle: const Text('Onboarding progression & session drop-offs'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/retention'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSizes.s, bottom: AppSizes.s),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: child,
        ),
      ],
    );
  }

  Widget _buildRadioTile<T>({
    required String title,
    required T value,
  }) {
    return RadioListTile<T>(
      title: Text(title),
      value: value,
    );
  }
}

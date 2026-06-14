import 'package:workout/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../domain/user_profile.dart';
import '../providers/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.myProfile, style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.m),
        children: [
          _buildHero(context, profile),
          const SizedBox(height: AppSizes.l),
          _buildMetricGrid(context, profile),
          const SizedBox(height: AppSizes.l),
          _buildSettings(context),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, UserProfile profile) {
    return AppCard(
      padding: const EdgeInsets.all(AppSizes.l),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: AppTheme.primaryLime,
            child: Icon(Icons.person, size: 40, color: Colors.black),
          ),
          const SizedBox(height: AppSizes.m),
          Text(profile.name.toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          Text(profile.trainingLevel, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryLime)),
        ],
      ),
    );
  }

  Widget _buildMetricGrid(BuildContext context, UserProfile profile) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSizes.s,
      crossAxisSpacing: AppSizes.s,
      childAspectRatio: 2,
      children: [
        _buildMetricCard('WEIGHT', '${profile.weightKg}KG'),
        _buildMetricCard('HEIGHT', '${profile.heightCm}CM'),
        _buildMetricCard('TDEE', '${profile.estimatedTDEE.toInt()} KCAL'),
        _buildMetricCard('EXPERIENCE', '${profile.trainingAgeYears} YEARS'),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value) {
    return AppCard(
      showBorder: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white38)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildSettings(BuildContext context) {
    return Column(
      children: [
        AppButton(
          text: 'EDIT BIOMETRICS',
          variant: AppButtonVariant.secondary,
          onPressed: () {},
        ),
        const SizedBox(height: AppSizes.s),
        AppButton(
          text: 'EXPORT ALL DATA',
          variant: AppButtonVariant.secondary,
          onPressed: () {},
        ),
      ],
    );
  }
}

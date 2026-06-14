import 'package:workout/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../domain/goal.dart';
import '../providers/goal_providers.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalListProvider);
    final achievementsAsync = ref.watch(achievementProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.motivation, 
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 2,
          )
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.m),
              child: _buildSectionHeader(context, 'YOUR GOALS'),
            ),
          ),
          goalsAsync.when(
            data: (goals) => goals.isEmpty
              ? const SliverToBoxAdapter(
                  child: AppEmptyState(
                    icon: Icons.track_changes,
                    title: 'NO ACTIVE GOALS',
                    subtitle: 'Set a target to keep yourself moving.',
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final goal = goals[index];
                      return _GoalCard(goal: goal);
                    },
                    childCount: goals.length,
                  ),
                ),
            loading: () => const SliverToBoxAdapter(child: AppLoading()),
            error: (err, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSizes.l)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.m),
              child: _buildSectionHeader(context, 'ACHIEVEMENTS'),
            ),
          ),
          achievementsAsync.when(
            data: (achievements) => SliverPadding(
              padding: const EdgeInsets.all(AppSizes.m),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: AppSizes.s,
                  crossAxisSpacing: AppSizes.s,
                  childAspectRatio: 0.8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final achievement = achievements[index];
                    return _AchievementBadge(achievement: achievement);
                  },
                  childCount: achievements.length,
                ),
              ),
            ),
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/goals/create'),
        backgroundColor: AppTheme.primaryLime,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add, fontWeight: FontWeight.bold),
        label: Text(AppLocalizations.of(context)!.setGoal, style: TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(title, style: TextStyle(
      fontSize: 11, 
      fontWeight: FontWeight.w900, 
      color: Colors.white.withAlpha(100),
      letterSpacing: 1.2,
    ));
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final double percent = (goal.progress / goal.target).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: AppSizes.xs),
      child: AppCard(
        showBorder: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(goal.title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                if (goal.isCompleted)
                  const Icon(Icons.check_circle, color: AppTheme.primaryLime, size: 16),
              ],
            ),
            const SizedBox(height: AppSizes.s),
            LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.white10,
              color: goal.isCompleted ? AppTheme.primaryLime : Colors.blue,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: AppSizes.s),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${goal.progress.toInt()} / ${goal.target.toInt()}', 
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white38)
                ),
                Text('${(percent * 100).toInt()}%', 
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: goal.isCompleted ? AppTheme.primaryLime : Colors.white)
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  const _AchievementBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final bool unlocked = achievement.isUnlocked;
    final bool isSecret = achievement.isHidden && !unlocked;
    
    final displayTitle = isSecret ? 'SECRET' : achievement.title;
    final displayIcon = isSecret 
        ? Icons.lock_outline 
        : IconData(achievement.iconData, fontFamily: 'MaterialIcons');

    Color tierColor = Colors.white12;
    if (unlocked) {
      switch (achievement.tier) {
        case 'bronze':
          tierColor = const Color(0xFFCD7F32); // Bronze
          break;
        case 'silver':
          tierColor = const Color(0xFFC0C0C0); // Silver
          break;
        case 'gold':
          tierColor = const Color(0xFFFFD700); // Gold
          break;
        case 'elite':
          tierColor = AppTheme.primaryLime; // Elite
          break;
      }
    }

    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 600),
      tween: Tween<double>(begin: unlocked ? 0.8 : 1.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) => Transform.scale(
        scale: value,
        child: Column(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: unlocked ? tierColor.withAlpha(25) : Colors.white.withAlpha(5),
                shape: BoxShape.circle,
                border: Border.all(
                  color: unlocked ? tierColor : Colors.white10,
                  width: 2,
                ),
              ),
              child: Icon(
                displayIcon,
                color: unlocked ? tierColor : Colors.white24,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              displayTitle.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: unlocked ? Colors.white : Colors.white24,
              ),
            ),
            if (achievement.isSeasonal)
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Text(
                  'SEASONAL',
                  style: TextStyle(fontSize: 6, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:workout/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/utils/date_formatter.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../features/coach/providers/coach_providers.dart' hide recoveryScoreProvider;
import '../../../features/profile/providers/profile_providers.dart';
import '../../workout/domain/exercise.dart';
import '../../workout/domain/workout.dart';
import '../../workout/domain/workout_set.dart';
import '../providers/workout_providers.dart';
import '../../daily_hub/domain/daily_recommendation.dart';
import '../../daily_hub/providers/daily_hub_providers.dart';
import '../../fitness_intelligence/providers/fitness_intelligence_providers.dart';
import '../../../shared/assets/fitness_illustrations.dart';

class WorkoutHomeScreen extends StatelessWidget {
  const WorkoutHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(AppLocalizations.of(context)!.dashboard, 
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 2,
                )
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: AppSizes.m, bottom: AppSizes.m),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_month_outlined),
                onPressed: () => context.push('/calendar'),
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () => context.push('/profile'),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _GreetingSection(),
                  SizedBox(height: AppSizes.l),
                  _TodayIntelligenceCard(),
                  SizedBox(height: AppSizes.l),
                  _TodayPlanCard(),
                  SizedBox(height: AppSizes.l),
                  _RecoverySection(),
                  SizedBox(height: AppSizes.m),
                  _CoachInsightSection(),
                  SizedBox(height: AppSizes.l),
                  _SectionHeader(title: 'MOMENTUM'),
                  SizedBox(height: AppSizes.s),
                  _StreakSection(),
                  SizedBox(height: AppSizes.l),
                  _ProgramsButton(),
                  SizedBox(height: AppSizes.l),
                  _SectionHeader(title: 'RETURNING USER QUICK-START'),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: _ReturningUserQuickStart()),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: AppSizes.s),
              child: _SectionHeader(title: 'YOUR WORKOUTS'),
            ),
          ),
          const _WorkoutsSection(),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: AppSizes.s),
              child: _SectionHeader(title: 'RECENT ACTIVITY'),
            ),
          ),
          const _RecentActivitySection(),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.black,
        onPressed: () => context.push('/create-workout'),
        icon: const Icon(Icons.add, fontWeight: FontWeight.bold),
        label: Text(AppLocalizations.of(context)!.newWorkout, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: TextStyle(
      fontSize: 11, 
      fontWeight: FontWeight.w900, 
      color: Colors.white.withAlpha(100),
      letterSpacing: 1.2,
    ));
  }
}

class _GreetingSection extends ConsumerWidget {
  const _GreetingSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final hour = DateTime.now().hour;
    String greeting = 'GOOD MORNING';
    if (hour >= 12 && hour < 17) greeting = 'GOOD AFTERNOON';
    if (hour >= 17) greeting = 'GOOD EVENING';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(greeting, style: TextStyle(
          fontSize: 12, 
          fontWeight: FontWeight.w900, 
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.5,
        )),
        Text('${profile.name.toUpperCase()}.', style: Theme.of(context).textTheme.headlineLarge),
      ],
    );
  }
}

class _RecoverySection extends ConsumerWidget {
  const _RecoverySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recoveryAsync = ref.watch(recoveryScoreProvider);
    return recoveryAsync.maybeWhen(
      data: (status) => AppCard(
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: status.score,
                  strokeWidth: 4,
                  backgroundColor: Colors.white10,
                  color: status.score > 0.6 ? AppTheme.primaryLime : Colors.orange,
                ),
                Text('${(status.score * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
              ],
            ),
            const SizedBox(width: AppSizes.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(status.label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  Text(status.description, style: const TextStyle(fontSize: 10, color: Colors.white38)),
                ],
              ),
            ),
          ],
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _CoachInsightSection extends ConsumerWidget {
  const _CoachInsightSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coachAsync = ref.watch(coachProvider);
    return coachAsync.maybeWhen(
      data: (insights) {
        if (insights.isEmpty) return const SizedBox.shrink();
        final insight = insights.first;
        return AppCard(
          padding: const EdgeInsets.all(AppSizes.m),
          showBorder: true,
          child: Row(
            children: [
              const Icon(Icons.psychology_outlined, color: AppTheme.primaryLime, size: 24),
              const SizedBox(width: AppSizes.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(insight.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    Text(insight.message, style: const TextStyle(fontSize: 10, color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _StreakSection extends ConsumerWidget {
  const _StreakSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(workoutStreakProvider);
    return streakAsync.maybeWhen(
      data: (streak) => AppCard(
        padding: const EdgeInsets.all(AppSizes.m),
        child: Row(
          children: [
            const Icon(Icons.local_fire_department, color: Colors.orange, size: 32),
            const SizedBox(width: AppSizes.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$streak DAY STREAK', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  Text(streak > 0 ? 'KEEP THE MOMENTUM GOING!' : 'START YOUR JOURNEY TODAY', 
                    style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(150), fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _ProgramsButton extends StatelessWidget {
  const _ProgramsButton();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      showBorder: true,
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: AppSizes.s),
        leading: const Icon(Icons.assignment_outlined, color: AppTheme.primaryLime),
        title: Text(AppLocalizations.of(context)!.managePrograms, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        subtitle: const Text('4–8 WEEK TRAINING PLANS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/programs'),
      ),
    );
  }
}

class _ReturningUserQuickStart extends ConsumerWidget {
  const _ReturningUserQuickStart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(workoutHistoryProvider);
    return historyAsync.maybeWhen(
      data: (history) {
        if (history.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.m),
            child: Text('LOG A WORKOUT TO ENABLE QUICK REPEAT.', style: TextStyle(fontSize: 10, color: Colors.white24, fontWeight: FontWeight.bold)),
          );
        }
        final lastSession = history.first;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.m),
          child: AppCard(
            showBorder: true,
            padding: const EdgeInsets.all(AppSizes.m),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('WELCOME BACK', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppTheme.primaryLime, letterSpacing: 1.5)),
                      Text('REPEAT LAST WORKOUT', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text(lastSession.workout.name.toUpperCase(), style: const TextStyle(fontSize: 11, color: Colors.white54)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final active = ref.read(activeSessionProvider);
                    if (active == null) {
                      await ref.read(activeSessionProvider.notifier).startSession(lastSession.workout);
                    }
                    if (context.mounted) {
                      context.push('/session');
                    }
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: const Text('START'),
                ),
              ],
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _WorkoutsSection extends ConsumerWidget {
  const _WorkoutsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutListProvider);

    return workoutsAsync.when(
      data: (workouts) => workouts.isEmpty
        ? SliverToBoxAdapter(
            child: Column(
              children: [
                const AppEmptyState(
                  icon: Icons.fitness_center,
                  title: 'No workouts yet',
                  subtitle: 'Build your first training plan',
                ),
                const SizedBox(height: AppSizes.s),
                ElevatedButton.icon(
                  onPressed: () => _loadSampleTemplates(ref),
                  icon: const Icon(Icons.download_done),
                  label: const Text('LOAD SAMPLE TEMPLATES'),
                ),
              ],
            ),
          )
        : SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final workout = workouts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: AppSizes.xs),
                  child: AppCard(
                    showBorder: true,
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: AppSizes.s),
                      title: Text(workout.name.toUpperCase(), 
                        style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)
                      ),
                      subtitle: Text('${workout.exercises.length} EXERCISES', 
                        style: TextStyle(color: Theme.of(context).colorScheme.primary.withAlpha(180), fontSize: 11, fontWeight: FontWeight.bold)
                      ),
                      trailing: const Icon(Icons.play_arrow_rounded, color: Colors.white70),
                      onTap: () => context.push('/workout', extra: workout.id),
                    ),
                  ),
                );
              },
              childCount: workouts.length,
            ),
          ),
      loading: () => const SliverFillRemaining(child: AppLoading()),
      error: (err, _) => SliverFillRemaining(child: AppErrorWidget(message: 'Error loading workouts')),
    );
  }

  void _loadSampleTemplates(WidgetRef ref) {
    final notifier = ref.read(workoutListProvider.notifier);
    notifier.addWorkout(
      Workout(
        id: 'sample_upper',
        name: 'Upper Body Split',
        exercises: [
          WorkoutExercise(
            exercise: const Exercise(id: 'bench_press', name: 'Bench Press', muscleGroup: 'Chest'),
            sets: [
              const WorkoutSet(reps: 10, weight: 60.0, isCompleted: false),
            ],
          ),
        ],
      ),
    );
    notifier.addWorkout(
      Workout(
        id: 'sample_lower',
        name: 'Lower Body Split',
        exercises: [
          WorkoutExercise(
            exercise: const Exercise(id: 'barbell_squat', name: 'Barbell Squat', muscleGroup: 'Legs'),
            sets: [
              const WorkoutSet(reps: 10, weight: 80.0, isCompleted: false),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentActivitySection extends ConsumerWidget {
  const _RecentActivitySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(workoutHistoryProvider);
    return historyAsync.when(
      data: (history) => history.isEmpty
        ? const SliverToBoxAdapter(child: SizedBox.shrink())
        : SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final session = history[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.history_rounded, size: 20),
                  title: Text(session.workout.name),
                  subtitle: Text(DateFormatter.formatDate(session.startTime)),
                  trailing: const Icon(Icons.chevron_right, size: 16),
                );
              },
              childCount: history.length > 3 ? 3 : history.length,
            ),
          ),
      loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
      error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }
}

class _TodayIntelligenceCard extends ConsumerWidget {
  const _TodayIntelligenceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decisionAsync = ref.watch(dailyDecisionProvider);
    final suggestionAsync = ref.watch(trainingSuggestionProvider);

    return decisionAsync.when(
      data: (recommendation) {
        Color decisionColor;
        String decisionText;
        IconData decisionIcon;

        switch (recommendation.decision) {
          case TrainingDecision.train:
            decisionColor = AppTheme.primaryLime;
            decisionText = 'TRAIN';
            decisionIcon = Icons.fitness_center_rounded;
            break;
          case TrainingDecision.lightDay:
            decisionColor = Colors.orange;
            decisionText = 'LIGHT DAY';
            decisionIcon = Icons.bolt_rounded;
            break;
          case TrainingDecision.rest:
            decisionColor = Colors.lightBlueAccent;
            decisionText = 'REST';
            decisionIcon = Icons.nights_stay_rounded;
            break;
        }

        return AppCard(
          showBorder: true,
          padding: EdgeInsets.zero,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  decisionColor.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
            padding: const EdgeInsets.all(AppSizes.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.psychology_outlined, color: AppTheme.primaryLime, size: 20),
                        const SizedBox(width: AppSizes.xs),
                        Text(
                          'TODAY\'S INTELLIGENCE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white.withAlpha(150),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s, vertical: 4),
                      decoration: BoxDecoration(
                        color: decisionColor.withValues(alpha: 0.15),
                        border: Border.all(color: decisionColor.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(decisionIcon, color: decisionColor, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            decisionText,
                            style: TextStyle(
                              color: decisionColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.m),
                Text(
                  recommendation.recommendedWorkoutType.toUpperCase(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: 0.5,
                  ),
                ),
                if (recommendation.primaryMuscleGroup != 'None') ...[
                  const SizedBox(height: 2),
                  Text(
                    'FOCUS: ${recommendation.primaryMuscleGroup.toUpperCase()}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
                const SizedBox(height: AppSizes.m),
                Text(
                  recommendation.explanation,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSizes.m),
                const Divider(color: Colors.white10),
                const SizedBox(height: AppSizes.s),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 16),
                        const SizedBox(width: AppSizes.xs),
                        const Text(
                          'RECOVERY: ',
                          style: TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold),
                        ),
                        Consumer(
                          builder: (context, ref, child) {
                            final recAsync = ref.watch(recoveryScoreProvider);
                            final recoveryVal = recAsync.maybeWhen(
                              data: (status) => '${(status.score * 100).toInt()}%',
                              orElse: () => '--%',
                            );
                            return Text(
                              recoveryVal,
                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.thumb_up_alt_rounded, color: AppTheme.primaryLime, size: 16),
                        const SizedBox(width: AppSizes.xs),
                        const Text(
                          'CONFIDENCE: ',
                          style: TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${recommendation.confidenceScore}%',
                          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.m),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: decisionColor,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.m),
                    ),
                    onPressed: () async {
                      final suggestion = suggestionAsync.value;
                      if (suggestion != null) {
                        final active = ref.read(activeSessionProvider);
                        if (active == null) {
                          await ref.read(activeSessionProvider.notifier).startSession(suggestion);
                        }
                        if (context.mounted) {
                          context.push('/session');
                        }
                      }
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow_rounded),
                        SizedBox(width: 4),
                        Text(
                          'START RECOMMENDED WORKOUT',
                          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const AppCard(
        showBorder: true,
        child: SizedBox(
          height: 150,
          child: Center(
            child: AppLoading(),
          ),
        ),
      ),
      error: (error, stack) => AppCard(
        showBorder: true,
        child: SizedBox(
          height: 100,
          child: Center(
            child: Text('Error loading intelligence: $error', style: const TextStyle(color: Colors.redAccent)),
          ),
        ),
      ),
    );
  }
}

class _TodayPlanCard extends ConsumerWidget {
  const _TodayPlanCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bodyGoalAsync = ref.watch(bodyGoalProvider);
    final nutritionAsync = ref.watch(nutritionProvider);
    final decisionAsync = ref.watch(dailyDecisionProvider);

    return bodyGoalAsync.when(
      data: (goalRec) {
        final nutrition = nutritionAsync.value;
        final decision = decisionAsync.value;

        if (nutrition == null || decision == null) {
          return const SizedBox.shrink();
        }

        return AppCard(
          showBorder: true,
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: AppSizes.s),
                color: Colors.white.withValues(alpha: 0.02),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryLime, size: 16),
                    const SizedBox(width: AppSizes.xs),
                    Text(
                      'UNIFIED TODAY PLAN (${goalRec.mode.name.replaceAll('BodyGoalMode.', '').toUpperCase()})',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withAlpha(150),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSizes.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSizes.m,
                      crossAxisSpacing: AppSizes.m,
                      childAspectRatio: 1.8,
                      children: [
                        _TodayPlanMetric(
                          icon: FitnessIllustrations.getMuscleIcon(decision.primaryMuscleGroup),
                          title: 'WORKOUT TYPE',
                          value: decision.recommendedWorkoutType,
                          color: AppTheme.primaryLime,
                        ),
                        _TodayPlanMetric(
                          icon: FitnessIllustrations.getFoodIcon('protein'),
                          title: 'DAILY CALORIES',
                          value: '${nutrition.calories.toInt()} kcal',
                          color: Colors.orangeAccent,
                        ),
                        _TodayPlanMetric(
                          icon: FitnessIllustrations.getRecoveryIcon('rest'),
                          title: 'WARMUP PREVIEW',
                          value: decision.decision == TrainingDecision.rest
                              ? 'Active stretching'
                              : '3 dynamic warmup sets',
                          color: Colors.lightBlueAccent,
                        ),
                        _TodayPlanMetric(
                          icon: Icons.track_changes_rounded,
                          title: 'PROGRESSION GOAL',
                          value: goalRec.trainingSplitSuggestion,
                          color: Colors.purpleAccent,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.m),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: AppSizes.s),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _MacroBadge(
                          label: 'PROTEIN',
                          value: '${nutrition.proteinGrams.toInt()}g',
                          color: Colors.redAccent,
                          icon: FitnessIllustrations.getFoodIcon('protein'),
                        ),
                        _MacroBadge(
                          label: 'CARBS',
                          value: '${nutrition.carbsGrams.toInt()}g',
                          color: Colors.amber,
                          icon: FitnessIllustrations.getFoodIcon('carb'),
                        ),
                        _MacroBadge(
                          label: 'FATS',
                          value: '${nutrition.fatsGrams.toInt()}g',
                          color: Colors.greenAccent,
                          icon: FitnessIllustrations.getFoodIcon('fat'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _TodayPlanMetric extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _TodayPlanMetric({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.s),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 12),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withAlpha(120),
                    letterSpacing: 0.8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _MacroBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MacroBadge({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 8, color: Colors.white38, fontWeight: FontWeight.bold)),
            Text(value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70)),
          ],
        ),
      ],
    );
  }
}

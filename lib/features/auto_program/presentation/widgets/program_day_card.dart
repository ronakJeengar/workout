import 'package:flutter/material.dart';
import '../../../../shared/constants/app_sizes.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../core/theme.dart';
import '../../domain/generated_program.dart';

class ProgramDayCard extends StatelessWidget {
  final WorkoutDay workoutDay;
  final VoidCallback? onTap;

  const ProgramDayCard({
    super.key,
    required this.workoutDay,
    this.onTap,
  });

  String _getIntensityBadge() {
    final hasStrength = workoutDay.workout.exercises.any(
      (e) => e.sets.any((s) => (s.restTime?.inSeconds ?? 0) >= 120),
    );
    return hasStrength ? 'HIGH INTENSITY' : 'MODERATE INTENSITY';
  }

  Color _getIntensityColor() {
    final hasStrength = workoutDay.workout.exercises.any(
      (e) => e.sets.any((s) => (s.restTime?.inSeconds ?? 0) >= 120),
    );
    return hasStrength ? const Color(0xFFEF4444) : AppTheme.primaryLime;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final intensityColor = _getIntensityColor();

    // Deduplicate muscle groups from the day's exercises
    final muscleGroups = workoutDay.workout.exercises
        .map((e) => e.exercise.muscleGroup)
        .toSet()
        .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.m),
      child: AppCard(
        showBorder: true,
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.cardPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workoutDay.dayName.toUpperCase(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        muscleGroups.join(' • ').toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withAlpha(150),
                        ),
                      ),
                      const SizedBox(height: AppSizes.s),
                      Text(
                        '${workoutDay.workout.exercises.length} EXERCISES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.s, vertical: AppSizes.xs),
                  decoration: BoxDecoration(
                    color: intensityColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: intensityColor.withAlpha(80), width: 1),
                  ),
                  child: Text(
                    _getIntensityBadge(),
                    style: TextStyle(
                      color: intensityColor,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

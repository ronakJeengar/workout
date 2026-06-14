import 'package:flutter_test/flutter_test.dart';
import 'package:workout/features/daily_hub/domain/daily_decision_engine.dart';
import 'package:workout/features/daily_hub/domain/daily_recommendation.dart';
import 'package:workout/features/progress/domain/volume_point.dart';
import 'package:workout/features/workout/domain/workout.dart';
import 'package:workout/features/workout/domain/workout_session.dart';

void main() {
  group('DailyDecisionEngine Tests', () {
    const engine = DailyDecisionEngine();

    test('Empty history should return training with introductory split', () {
      final recommendation = engine.makeDecision(
        history: [],
        programs: [],
        goals: [],
        recoveryScore: 1.0,
        streak: 0,
        volumeTrends: [],
      );

      expect(recommendation.decision, TrainingDecision.train);
      expect(recommendation.recommendedWorkoutType, 'Introductory Split');
      expect(recommendation.intensityLevel, 'MEDIUM');
      expect(recommendation.primaryMuscleGroup, 'Full Body');
      expect(recommendation.confidenceScore, 90);
    });

    test('Recovery score < 50% should recommend REST', () {
      final dummyWorkout = Workout(id: 'w1', name: 'Leg Day', exercises: const []);
      final session = WorkoutSession(
        id: 's1',
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        workout: dummyWorkout,
      );

      final recommendation = engine.makeDecision(
        history: [session],
        programs: [],
        goals: [],
        recoveryScore: 0.45,
        streak: 1,
        volumeTrends: [],
      );

      expect(recommendation.decision, TrainingDecision.rest);
      expect(recommendation.intensityLevel, 'LOW');
      expect(recommendation.primaryMuscleGroup, 'None');
    });

    test('Fatigue detected (3 consecutive days of volume) should recommend LIGHT DAY', () {
      final dummyWorkout = Workout(id: 'w1', name: 'Leg Day', exercises: const []);
      final session = WorkoutSession(
        id: 's1',
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        workout: dummyWorkout,
      );

      final recommendation = engine.makeDecision(
        history: [session],
        programs: [],
        goals: [],
        recoveryScore: 0.8,
        streak: 3,
        volumeTrends: [
          VolumePoint(date: DateTime.now().subtract(const Duration(days: 2)), volume: 1000.0),
          VolumePoint(date: DateTime.now().subtract(const Duration(days: 1)), volume: 1500.0),
          VolumePoint(date: DateTime.now(), volume: 1200.0),
        ],
      );

      expect(recommendation.decision, TrainingDecision.lightDay);
      expect(recommendation.intensityLevel, 'LOW');
      expect(recommendation.primaryMuscleGroup, 'Core & Mobility');
    });

    test('Active streak + Recovery > 65% should recommend high-intensity TRAIN', () {
      final dummyWorkout = Workout(id: 'w1', name: 'Leg Day', exercises: const []);
      final session = WorkoutSession(
        id: 's1',
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        workout: dummyWorkout,
      );

      final recommendation = engine.makeDecision(
        history: [session],
        programs: [],
        goals: [],
        recoveryScore: 0.7,
        streak: 2,
        volumeTrends: [],
      );

      expect(recommendation.decision, TrainingDecision.train);
      expect(recommendation.intensityLevel, 'HIGH');
      expect(recommendation.recommendedWorkoutType, 'Leg Day');
    });

    test('Stable recovery and no fatigue should suggest medium-intensity TRAIN', () {
      final dummyWorkout = Workout(id: 'w1', name: 'Leg Day', exercises: const []);
      final session = WorkoutSession(
        id: 's1',
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        workout: dummyWorkout,
      );

      final recommendation = engine.makeDecision(
        history: [session],
        programs: [],
        goals: [],
        recoveryScore: 0.6,
        streak: 0,
        volumeTrends: [],
      );

      expect(recommendation.decision, TrainingDecision.train);
      expect(recommendation.intensityLevel, 'MEDIUM');
      expect(recommendation.recommendedWorkoutType, 'Leg Day');
    });
  });
}

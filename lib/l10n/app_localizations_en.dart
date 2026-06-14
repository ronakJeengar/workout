// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Workout App';

  @override
  String get dashboard => 'DASHBOARD';

  @override
  String get managePrograms => 'MANAGE PROGRAMS';

  @override
  String get motivation => 'MOTIVATION';

  @override
  String get trainingPrograms => 'TRAINING PROGRAMS';

  @override
  String get yourWorkouts => 'YOUR WORKOUTS';

  @override
  String get sessions => 'SESSIONS';

  @override
  String get streak => 'STREAK';

  @override
  String get volume => 'VOLUME';

  @override
  String get newWorkout => 'NEW WORKOUT';

  @override
  String get finishWorkout => 'FINISH WORKOUT';

  @override
  String get restFinished => 'REST FINISHED!';

  @override
  String get settings => 'SETTINGS';

  @override
  String get appearance => 'APPEARANCE';

  @override
  String get units => 'UNITS';

  @override
  String get workoutsPerWeek => 'WORKOUTS / WEEK';

  @override
  String get consistency => 'CONSISTENCY';

  @override
  String get totalVolume => 'TOTAL VOLUME';

  @override
  String get trainingCalendar => 'TRAINING CALENDAR';

  @override
  String get newGoal => 'NEW GOAL';

  @override
  String get goalType => 'GOAL TYPE';

  @override
  String get myProfile => 'MY PROFILE';

  @override
  String get createProgram => 'CREATE PROGRAM';

  @override
  String get duplicate => 'DUPLICATE';

  @override
  String get delete => 'DELETE';

  @override
  String get deleteProgramTitle => 'DELETE PROGRAM?';

  @override
  String get cancel => 'CANCEL';

  @override
  String get renameProgram => 'RENAME PROGRAM';

  @override
  String get save => 'SAVE';

  @override
  String get createWorkoutFirst => 'CREATE A WORKOUT FIRST!';

  @override
  String get chooseWorkout => 'CHOOSE WORKOUT';

  @override
  String get progress => 'PROGRESS';

  @override
  String get lifetimeVolume => 'LIFETIME VOLUME';

  @override
  String get monthlyScore => 'MONTHLY SCORE';

  @override
  String get noData => 'NO DATA';

  @override
  String get defaultRestTimer => 'Default Rest Timer';

  @override
  String get addExercise => 'Add Exercise';

  @override
  String get createWorkout => 'Create Workout';

  @override
  String get saveWorkout => 'Save Workout';

  @override
  String get workoutHistory => 'Workout History';

  @override
  String get goalsAchievements => 'GOALS & ACHIEVEMENTS';

  @override
  String get stayOnTrack => 'STAY ON TRACK';

  @override
  String get noActiveSession => 'No active session.';

  @override
  String get workoutSummary => 'Workout Summary';

  @override
  String get seconds => 'seconds';

  @override
  String workoutsCount(int count) {
    return '$count WORKOUTS';
  }

  @override
  String get newProgram => 'NEW PROGRAM';

  @override
  String get excellentProgress => 'EXCELLENT PROGRESS!';

  @override
  String get stayDisciplined => 'STAY DISCIPLINED.';

  @override
  String dayStreak(int streak) {
    return '$streak DAY STREAK';
  }

  @override
  String get keepMomentum => 'KEEP THE MOMENTUM GOING!';

  @override
  String get startJourney => 'START YOUR JOURNEY TODAY';

  @override
  String get setGoal => 'SET GOAL';

  @override
  String areYouSureDelete(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get unknownWorkout => 'Unknown Workout';

  @override
  String error(String error) {
    return 'Error: $error';
  }

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Spanish';

  @override
  String get hindi => 'Hindi';
}

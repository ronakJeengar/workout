import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('hi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout App'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'DASHBOARD'**
  String get dashboard;

  /// No description provided for @managePrograms.
  ///
  /// In en, this message translates to:
  /// **'MANAGE PROGRAMS'**
  String get managePrograms;

  /// No description provided for @motivation.
  ///
  /// In en, this message translates to:
  /// **'MOTIVATION'**
  String get motivation;

  /// No description provided for @trainingPrograms.
  ///
  /// In en, this message translates to:
  /// **'TRAINING PROGRAMS'**
  String get trainingPrograms;

  /// No description provided for @yourWorkouts.
  ///
  /// In en, this message translates to:
  /// **'YOUR WORKOUTS'**
  String get yourWorkouts;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'SESSIONS'**
  String get sessions;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'STREAK'**
  String get streak;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'VOLUME'**
  String get volume;

  /// No description provided for @newWorkout.
  ///
  /// In en, this message translates to:
  /// **'NEW WORKOUT'**
  String get newWorkout;

  /// No description provided for @finishWorkout.
  ///
  /// In en, this message translates to:
  /// **'FINISH WORKOUT'**
  String get finishWorkout;

  /// No description provided for @restFinished.
  ///
  /// In en, this message translates to:
  /// **'REST FINISHED!'**
  String get restFinished;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get appearance;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'UNITS'**
  String get units;

  /// No description provided for @workoutsPerWeek.
  ///
  /// In en, this message translates to:
  /// **'WORKOUTS / WEEK'**
  String get workoutsPerWeek;

  /// No description provided for @consistency.
  ///
  /// In en, this message translates to:
  /// **'CONSISTENCY'**
  String get consistency;

  /// No description provided for @totalVolume.
  ///
  /// In en, this message translates to:
  /// **'TOTAL VOLUME'**
  String get totalVolume;

  /// No description provided for @trainingCalendar.
  ///
  /// In en, this message translates to:
  /// **'TRAINING CALENDAR'**
  String get trainingCalendar;

  /// No description provided for @newGoal.
  ///
  /// In en, this message translates to:
  /// **'NEW GOAL'**
  String get newGoal;

  /// No description provided for @goalType.
  ///
  /// In en, this message translates to:
  /// **'GOAL TYPE'**
  String get goalType;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'MY PROFILE'**
  String get myProfile;

  /// No description provided for @createProgram.
  ///
  /// In en, this message translates to:
  /// **'CREATE PROGRAM'**
  String get createProgram;

  /// No description provided for @duplicate.
  ///
  /// In en, this message translates to:
  /// **'DUPLICATE'**
  String get duplicate;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get delete;

  /// No description provided for @deleteProgramTitle.
  ///
  /// In en, this message translates to:
  /// **'DELETE PROGRAM?'**
  String get deleteProgramTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// No description provided for @renameProgram.
  ///
  /// In en, this message translates to:
  /// **'RENAME PROGRAM'**
  String get renameProgram;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get save;

  /// No description provided for @createWorkoutFirst.
  ///
  /// In en, this message translates to:
  /// **'CREATE A WORKOUT FIRST!'**
  String get createWorkoutFirst;

  /// No description provided for @chooseWorkout.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE WORKOUT'**
  String get chooseWorkout;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'PROGRESS'**
  String get progress;

  /// No description provided for @lifetimeVolume.
  ///
  /// In en, this message translates to:
  /// **'LIFETIME VOLUME'**
  String get lifetimeVolume;

  /// No description provided for @monthlyScore.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY SCORE'**
  String get monthlyScore;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'NO DATA'**
  String get noData;

  /// No description provided for @defaultRestTimer.
  ///
  /// In en, this message translates to:
  /// **'Default Rest Timer'**
  String get defaultRestTimer;

  /// No description provided for @addExercise.
  ///
  /// In en, this message translates to:
  /// **'Add Exercise'**
  String get addExercise;

  /// No description provided for @createWorkout.
  ///
  /// In en, this message translates to:
  /// **'Create Workout'**
  String get createWorkout;

  /// No description provided for @saveWorkout.
  ///
  /// In en, this message translates to:
  /// **'Save Workout'**
  String get saveWorkout;

  /// No description provided for @workoutHistory.
  ///
  /// In en, this message translates to:
  /// **'Workout History'**
  String get workoutHistory;

  /// No description provided for @goalsAchievements.
  ///
  /// In en, this message translates to:
  /// **'GOALS & ACHIEVEMENTS'**
  String get goalsAchievements;

  /// No description provided for @stayOnTrack.
  ///
  /// In en, this message translates to:
  /// **'STAY ON TRACK'**
  String get stayOnTrack;

  /// No description provided for @noActiveSession.
  ///
  /// In en, this message translates to:
  /// **'No active session.'**
  String get noActiveSession;

  /// No description provided for @workoutSummary.
  ///
  /// In en, this message translates to:
  /// **'Workout Summary'**
  String get workoutSummary;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// No description provided for @workoutsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} WORKOUTS'**
  String workoutsCount(int count);

  /// No description provided for @newProgram.
  ///
  /// In en, this message translates to:
  /// **'NEW PROGRAM'**
  String get newProgram;

  /// No description provided for @excellentProgress.
  ///
  /// In en, this message translates to:
  /// **'EXCELLENT PROGRESS!'**
  String get excellentProgress;

  /// No description provided for @stayDisciplined.
  ///
  /// In en, this message translates to:
  /// **'STAY DISCIPLINED.'**
  String get stayDisciplined;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'{streak} DAY STREAK'**
  String dayStreak(int streak);

  /// No description provided for @keepMomentum.
  ///
  /// In en, this message translates to:
  /// **'KEEP THE MOMENTUM GOING!'**
  String get keepMomentum;

  /// No description provided for @startJourney.
  ///
  /// In en, this message translates to:
  /// **'START YOUR JOURNEY TODAY'**
  String get startJourney;

  /// No description provided for @setGoal.
  ///
  /// In en, this message translates to:
  /// **'SET GOAL'**
  String get setGoal;

  /// No description provided for @areYouSureDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String areYouSureDelete(String name);

  /// No description provided for @unknownWorkout.
  ///
  /// In en, this message translates to:
  /// **'Unknown Workout'**
  String get unknownWorkout;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(String error);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

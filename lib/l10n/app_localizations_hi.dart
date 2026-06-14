// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'वर्कआउट ऐप';

  @override
  String get dashboard => 'डैशबोर्ड';

  @override
  String get managePrograms => 'प्रोग्राम प्रबंधित करें';

  @override
  String get motivation => 'प्रेरणा';

  @override
  String get trainingPrograms => 'प्रशिक्षण कार्यक्रम';

  @override
  String get yourWorkouts => 'आपके वर्कआउट';

  @override
  String get sessions => 'सत्र';

  @override
  String get streak => 'सिलसिला';

  @override
  String get volume => 'वॉल्यूम';

  @override
  String get newWorkout => 'नया वर्कआउट';

  @override
  String get finishWorkout => 'वर्कआउट समाप्त करें';

  @override
  String get restFinished => 'विश्राम समाप्त!';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get appearance => 'दिखावट';

  @override
  String get units => 'इकाइयां';

  @override
  String get workoutsPerWeek => 'प्रति सप्ताह वर्कआउट';

  @override
  String get consistency => 'निरंतरता';

  @override
  String get totalVolume => 'कुल वॉल्यूम';

  @override
  String get trainingCalendar => 'प्रशिक्षण कैलेंडर';

  @override
  String get newGoal => 'नया लक्ष्य';

  @override
  String get goalType => 'लक्ष्य का प्रकार';

  @override
  String get myProfile => 'मेरी प्रोफाइल';

  @override
  String get createProgram => 'प्रोग्राम बनाएं';

  @override
  String get duplicate => 'डुप्लिकेट';

  @override
  String get delete => 'हटाएं';

  @override
  String get deleteProgramTitle => 'प्रोग्राम हटाएं?';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get renameProgram => 'प्रोग्राम का नाम बदलें';

  @override
  String get save => 'सहेजें';

  @override
  String get createWorkoutFirst => 'पहले एक वर्कआउट बनाएं!';

  @override
  String get chooseWorkout => 'वर्कआउट चुनें';

  @override
  String get progress => 'प्रगति';

  @override
  String get lifetimeVolume => 'लाइफटाइम वॉल्यूम';

  @override
  String get monthlyScore => 'मासिक स्कोर';

  @override
  String get noData => 'कोई डेटा नहीं';

  @override
  String get defaultRestTimer => 'डिफ़ॉल्ट विश्राम टाइमर';

  @override
  String get addExercise => 'व्यायाम जोड़ें';

  @override
  String get createWorkout => 'वर्कआउट बनाएं';

  @override
  String get saveWorkout => 'वर्कआउट सहेजें';

  @override
  String get workoutHistory => 'वर्कआउट इतिहास';

  @override
  String get goalsAchievements => 'लक्ष्य और उपलब्धियां';

  @override
  String get stayOnTrack => 'ट्रैक पर रहें';

  @override
  String get noActiveSession => 'कोई सक्रिय सत्र नहीं।';

  @override
  String get workoutSummary => 'वर्कआउट सारांश';

  @override
  String get seconds => 'सेकंड';

  @override
  String workoutsCount(int count) {
    return '$count वर्कआउट';
  }

  @override
  String get newProgram => 'नया प्रोग्राम';

  @override
  String get excellentProgress => 'उत्कृष्ट प्रगति!';

  @override
  String get stayDisciplined => 'अनुशासित रहें।';

  @override
  String dayStreak(int streak) {
    return '$streak दिनों का सिलसिला';
  }

  @override
  String get keepMomentum => 'गति बनाए रखें!';

  @override
  String get startJourney => 'आज ही अपनी यात्रा शुरू करें';

  @override
  String get setGoal => 'लक्ष्य निर्धारित करें';

  @override
  String areYouSureDelete(String name) {
    return 'क्या आप वाकई \"$name\" को हटाना चाहते हैं?';
  }

  @override
  String get unknownWorkout => 'अज्ञात वर्कआउट';

  @override
  String error(String error) {
    return 'त्रुटि: $error';
  }

  @override
  String get language => 'भाषा';

  @override
  String get english => 'अंग्रेज़ी';

  @override
  String get spanish => 'स्पेनिश';

  @override
  String get hindi => 'हिंदी';
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'App de Entrenamiento';

  @override
  String get dashboard => 'PANEL';

  @override
  String get managePrograms => 'GESTIONAR PROGRAMAS';

  @override
  String get motivation => 'MOTIVACIÓN';

  @override
  String get trainingPrograms => 'PROGRAMAS DE ENTRENAMIENTO';

  @override
  String get yourWorkouts => 'TUS ENTRENAMIENTOS';

  @override
  String get sessions => 'SESIONES';

  @override
  String get streak => 'RACHA';

  @override
  String get volume => 'VOLUMEN';

  @override
  String get newWorkout => 'NUEVO ENTRENAMIENTO';

  @override
  String get finishWorkout => 'TERMINAR ENTRENAMIENTO';

  @override
  String get restFinished => '¡DESCANSO TERMINADO!';

  @override
  String get settings => 'AJUSTES';

  @override
  String get appearance => 'APARIENCIA';

  @override
  String get units => 'UNIDADES';

  @override
  String get workoutsPerWeek => 'ENTRENAMIENTOS / SEMANA';

  @override
  String get consistency => 'CONSISTENCIA';

  @override
  String get totalVolume => 'VOLUMEN TOTAL';

  @override
  String get trainingCalendar => 'CALENDARIO DE ENTRENAMIENTO';

  @override
  String get newGoal => 'NUEVA META';

  @override
  String get goalType => 'TIPO DE META';

  @override
  String get myProfile => 'MI PERFIL';

  @override
  String get createProgram => 'CREAR PROGRAMA';

  @override
  String get duplicate => 'DUPLICAR';

  @override
  String get delete => 'ELIMINAR';

  @override
  String get deleteProgramTitle => '¿ELIMINAR PROGRAMA?';

  @override
  String get cancel => 'CANCELAR';

  @override
  String get renameProgram => 'RENOMBRAR PROGRAMA';

  @override
  String get save => 'GUARDAR';

  @override
  String get createWorkoutFirst => '¡CREA UN ENTRENAMIENTO PRIMERO!';

  @override
  String get chooseWorkout => 'ELEGIR ENTRENAMIENTO';

  @override
  String get progress => 'PROGRESO';

  @override
  String get lifetimeVolume => 'VOLUMEN DE POR VIDA';

  @override
  String get monthlyScore => 'PUNTUACIÓN MENSUAL';

  @override
  String get noData => 'SIN DATOS';

  @override
  String get defaultRestTimer => 'Temporizador de Descanso Predeterminado';

  @override
  String get addExercise => 'Añadir Ejercicio';

  @override
  String get createWorkout => 'Crear Entrenamiento';

  @override
  String get saveWorkout => 'Guardar Entrenamiento';

  @override
  String get workoutHistory => 'Historial de Entrenamiento';

  @override
  String get goalsAchievements => 'METAS Y LOGROS';

  @override
  String get stayOnTrack => 'MANTENTE EN EL CAMINO';

  @override
  String get noActiveSession => 'No hay sesión activa.';

  @override
  String get workoutSummary => 'Resumen del Entrenamiento';

  @override
  String get seconds => 'segundos';

  @override
  String workoutsCount(int count) {
    return '$count ENTRENAMIENTOS';
  }

  @override
  String get newProgram => 'NUEVO PROGRAMA';

  @override
  String get excellentProgress => '¡EXCELENTE PROGRESO!';

  @override
  String get stayDisciplined => 'MANTÉN LA DISCIPLINA.';

  @override
  String dayStreak(int streak) {
    return '$streak DÍAS DE RACHA';
  }

  @override
  String get keepMomentum => '¡MANTÉN EL IMPULSO!';

  @override
  String get startJourney => 'COMIENZA TU VIAJE HOY';

  @override
  String get setGoal => 'ESTABLECER META';

  @override
  String areYouSureDelete(String name) {
    return '¿Estás seguro de que quieres eliminar \"$name\"?';
  }

  @override
  String get unknownWorkout => 'Entrenamiento Desconocido';

  @override
  String error(String error) {
    return 'Error: $error';
  }

  @override
  String get language => 'Idioma';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get hindi => 'Hindi';
}

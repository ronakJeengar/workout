import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/calendar/presentation/calendar_screen.dart';
import '../features/goals/presentation/create_goal_screen.dart';
import '../features/goals/presentation/goals_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/programs/presentation/create_program_screen.dart';
import '../features/programs/presentation/program_detail_screen.dart';
import '../features/programs/presentation/programs_screen.dart';
import '../features/progress/presentation/progress_dashboard_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/workout/domain/workout_session.dart';
import '../features/workout/presentation/workout_home_screen.dart';
import '../features/workout/presentation/workout_detail_screen.dart';
import '../features/workout/presentation/create_workout_screen.dart';
import '../features/workout/presentation/add_exercise_screen.dart';
import '../features/workout/presentation/workout_session_screen.dart';
import '../features/workout/presentation/workout_summary_screen.dart';
import '../features/workout/presentation/workout_history_screen.dart';
import 'monitoring/crash_report_dashboard.dart';
import 'monitoring/retention_dashboard.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const WorkoutHomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
      ),
    ),
    GoRoute(
      path: '/calendar',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const CalendarScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
      ),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ProfileScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
      ),
    ),
    GoRoute(
      path: '/goals',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const GoalsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
      ),
      routes: [
        GoRoute(
          path: 'create',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const CreateGoalScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/programs',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ProgramsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
      ),
      routes: [
        GoRoute(
          path: 'create',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const CreateProgramScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/program/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return CustomTransitionPage(
          key: state.pageKey,
          child: ProgramDetailScreen(programId: id),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
        );
      },
    ),
    GoRoute(
      path: '/progress',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ProgressDashboardScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
      ),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
      ),
    ),
    GoRoute(
      path: '/create-workout',
      builder: (context, state) => const CreateWorkoutScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const WorkoutHistoryScreen(),
    ),
    GoRoute(
      path: '/add-exercise',
      builder: (context, state) {
        final workoutId = state.extra as String;
        return AddExerciseScreen(workoutId: workoutId);
      },
    ),
    GoRoute(
      path: '/session',
      builder: (context, state) => const WorkoutSessionScreen(),
    ),
    GoRoute(
      path: '/workout-summary',
      builder: (context, state) {
        final session = state.extra as WorkoutSession;
        return WorkoutSummaryScreen(session: session);
      },
    ),
    GoRoute(
      path: '/workout',
      builder: (context, state) {
        final workoutId = state.extra as String;
        return WorkoutDetailScreen(workoutId: workoutId);
      },
    ),
    GoRoute(
      path: '/crash-report',
      builder: (context, state) => const CrashReportDashboard(),
    ),
    GoRoute(
      path: '/retention',
      builder: (context, state) => const RetentionDashboard(),
    ),
  ],
);

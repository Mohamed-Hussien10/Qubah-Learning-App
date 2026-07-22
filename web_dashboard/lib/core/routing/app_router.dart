import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:web_dashboard/core/services/dependency_injection.dart';
import 'package:web_dashboard/features/authentication/data/repositories/auth_repository.dart';
import 'package:web_dashboard/features/authentication/presentation/screens/login_screen.dart';

import 'package:web_dashboard/features/educational_stages/presentation/screens/stages_screen.dart';
import 'package:web_dashboard/features/grades/presentation/screens/grades_screen.dart';
import 'package:web_dashboard/features/sections/presentation/screens/sections_screen.dart';
import 'package:web_dashboard/features/subjects/presentation/screens/subjects_screen.dart';
import 'package:web_dashboard/features/units/presentation/screens/units_screen.dart';
import 'package:web_dashboard/features/lessons/presentation/screens/lessons_screen.dart';
import 'package:web_dashboard/features/lesson_files/presentation/screens/lesson_files_screen.dart';
import 'package:web_dashboard/features/users/presentation/screens/users_screen.dart';
import 'package:web_dashboard/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:web_dashboard/features/settings/presentation/screens/settings_screen.dart';
import 'package:web_dashboard/features/user_profile/presentation/screens/profile_screen.dart';
import 'package:web_dashboard/features/free_trial_stages/presentation/screens/free_trial_stages_screen.dart';
import 'package:web_dashboard/features/free_trial_grades/presentation/screens/free_trial_grades_screen.dart';
import 'package:web_dashboard/features/free_trial_subjects/presentation/screens/free_trial_subjects_screen.dart';
import 'package:web_dashboard/features/free_trial_lesson_files/presentation/screens/free_trial_lesson_files_screen.dart';
import 'package:web_dashboard/features/packages/presentation/screens/packages_screen.dart';
import 'package:web_dashboard/core/widgets/dashboard_shell.dart';

class NavigationState {
  static String? lastStageId;
  static String? lastGradeId;
  static String? lastSectionId;
  static String? lastSubjectId;
  static String? lastUnitId;
  static String? lastLessonId;
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/stages',
  redirect: (BuildContext context, GoRouterState state) async {
    final authRepo = sl<AuthRepository>();
    final loggedIn = await authRepo.isLoggedIn();
    final isLoggingIn = state.uri.toString() == '/login';

    if (!loggedIn) {
      return '/login';
    }

    if (loggedIn && isLoggingIn) {
      return '/stages';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => DashboardShell(child: child),
      routes: [

        GoRoute(
          path: '/stages',
          builder: (context, state) => const StagesScreen(),
        ),
        GoRoute(
          path: '/grades',
          redirect: (context, state) => NavigationState.lastStageId != null ? '/grades/${NavigationState.lastStageId}' : '/stages',
        ),
        GoRoute(
          path: '/grades/:stageId',
          builder: (context, state) {
            final stageId = state.pathParameters['stageId']!;
            NavigationState.lastStageId = stageId;
            return GradesScreen(stageId: stageId);
          },
        ),
        GoRoute(
          path: '/sections',
          redirect: (context, state) => NavigationState.lastGradeId != null ? '/sections/${NavigationState.lastGradeId}' : '/stages',
        ),
        GoRoute(
          path: '/sections/:gradeId',
          builder: (context, state) {
            final gradeId = state.pathParameters['gradeId']!;
            NavigationState.lastGradeId = gradeId;
            return SectionsScreen(gradeId: gradeId);
          },
        ),
        GoRoute(
          path: '/subjects',
          redirect: (context, state) => NavigationState.lastSectionId != null ? '/subjects/${NavigationState.lastSectionId}' : '/stages',
        ),
        GoRoute(
          path: '/subjects/:sectionId',
          builder: (context, state) {
            final sectionId = state.pathParameters['sectionId']!;
            NavigationState.lastSectionId = sectionId;
            return SubjectsScreen(sectionId: sectionId);
          },
        ),
        GoRoute(
          path: '/units',
          redirect: (context, state) => NavigationState.lastSubjectId != null ? '/units/${NavigationState.lastSubjectId}' : '/stages',
        ),
        GoRoute(
          path: '/units/:subjectId',
          builder: (context, state) {
            final subjectId = state.pathParameters['subjectId']!;
            NavigationState.lastSubjectId = subjectId;
            return UnitsScreen(subjectId: subjectId);
          },
        ),
        GoRoute(
          path: '/lessons',
          redirect: (context, state) => NavigationState.lastUnitId != null ? '/lessons/${NavigationState.lastUnitId}' : '/stages',
        ),
        GoRoute(
          path: '/lessons/:unitId',
          builder: (context, state) {
            final unitId = state.pathParameters['unitId']!;
            NavigationState.lastUnitId = unitId;
            return LessonsScreen(unitId: unitId);
          },
        ),
        GoRoute(
          path: '/lesson-files',
          redirect: (context, state) => NavigationState.lastLessonId != null ? '/lesson-files/${NavigationState.lastLessonId}' : '/stages',
        ),
        GoRoute(
          path: '/lesson-files/:lessonId',
          builder: (context, state) {
            final lessonId = state.pathParameters['lessonId']!;
            NavigationState.lastLessonId = lessonId;
            return LessonFilesScreen(lessonId: lessonId);
          },
        ),
        GoRoute(
          path: '/packages',
          builder: (context, state) => const PackagesScreen(),
        ),
        GoRoute(
          path: '/free-trial-stages',
          builder: (context, state) => const FreeTrialStagesScreen(),
        ),
        GoRoute(
          path: '/free-trial-grades',
          redirect: (context, state) => NavigationState.lastStageId != null ? '/free-trial-grades/${NavigationState.lastStageId}' : '/free-trial-stages',
        ),
        GoRoute(
          path: '/free-trial-grades/:stageId',
          builder: (context, state) {
            final stageId = state.pathParameters['stageId']!;
            NavigationState.lastStageId = stageId;
            return FreeTrialGradesScreen(stageId: stageId);
          },
        ),
        GoRoute(
          path: '/free-trial-subjects',
          redirect: (context, state) => NavigationState.lastGradeId != null ? '/free-trial-subjects/${NavigationState.lastGradeId}' : '/free-trial-stages',
        ),
        GoRoute(
          path: '/free-trial-subjects/:gradeId',
          builder: (context, state) {
            final gradeId = state.pathParameters['gradeId']!;
            NavigationState.lastGradeId = gradeId;
            return FreeTrialSubjectsScreen(gradeId: gradeId);
          },
        ),
        GoRoute(
          path: '/free-trial-lesson-files',
          redirect: (context, state) => NavigationState.lastSubjectId != null ? '/free-trial-lesson-files/${NavigationState.lastSubjectId}' : '/free-trial-stages',
        ),
        GoRoute(
          path: '/free-trial-lesson-files/:subjectId',
          builder: (context, state) {
            final subjectId = state.pathParameters['subjectId']!;
            NavigationState.lastSubjectId = subjectId;
            return FreeTrialLessonFilesScreen(subjectId: subjectId);
          },
        ),
        GoRoute(
          path: '/users',
          builder: (context, state) => const UsersScreen(),
        ),
        GoRoute(
          path: '/analytics',
          builder: (context, state) => const AnalyticsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);

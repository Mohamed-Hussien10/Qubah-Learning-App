import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/authentication/presentation/screens/login/login_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/educational_stages/presentation/screens/stages_screen.dart';
import '../../features/grades/presentation/screens/grades_screen.dart';
import '../../features/sections/presentation/screens/sections_screen.dart';
import '../../features/subjects/presentation/screens/subjects_screen.dart';
import '../../features/units/presentation/screens/units_screen.dart';
import '../../features/lessons/presentation/screens/lessons_screen.dart';
import '../../features/lesson_files/presentation/screens/lesson_files_screen.dart';
import '../../features/media_player/presentation/screens/video_player_screen.dart';
import '../../features/media_player/presentation/screens/audio_player_screen.dart';
import '../../features/media_player/presentation/screens/pdf_viewer_screen.dart';
import '../../features/interactive_viewer/presentation/screens/interactive_viewer_screen.dart';
import '../../features/user_profile/presentation/screens/profile_screen.dart';
import '../../features/subscription/presentation/screens/subscription_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/parent_lock/presentation/screens/parent_lock_screen.dart';
import '../../features/parent_lock/presentation/screens/parent_settings_screen.dart';
import '../../features/parent_lock/presentation/screens/change_pin_screen.dart';
import '../../features/subscription/presentation/screens/subscription_expired_screen.dart';
import '../../features/settings/presentation/screens/support_screen.dart';
import '../../features/settings/presentation/screens/privacy_policy_screen.dart';

/// Route name constants.
class AppRoutes {
  AppRoutes._();
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String stages = '/stages';
  static const String grades = '/grades/:stageId';
  static const String sections = '/sections/:gradeId';
  static const String subjects = '/subjects/:sectionId';
  static const String units = '/units/:subjectId';
  static const String lessons = '/lessons/:unitId';
  static const String lessonFiles = '/lesson-files/:lessonId';
  static const String videoPlayer = '/player/video';
  static const String audioPlayer = '/player/audio';
  static const String pdfViewer = '/player/pdf';
  static const String interactiveViewer = '/player/interactive';
  static const String profile = '/profile';
  static const String subscription = '/subscription';
  static const String subscriptionExpired = '/subscription-expired';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String parentLock = '/parent-lock';
  static const String parentSettings = '/parent-settings';
  static const String changePin = '/change-pin';
  static const String appEntryLock = '/app-entry-lock';
  static const String appExitLock = '/app-exit-lock';
  static const String support = '/support';
  static const String privacy = '/privacy';
}

/// Application router configuration using GoRouter.
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.stages,
        name: 'stages',
        builder: (context, state) => const StagesScreen(),
      ),
      GoRoute(
        path: AppRoutes.grades,
        name: 'grades',
        builder: (context, state) {
          final stageId = state.pathParameters['stageId'] ?? '';
          final titlePath =
              (state.extra as Map<String, dynamic>?)?['titlePath']
                  as List<String>? ??
              [];
          final backgroundImageUrl =
              (state.extra as Map<String, dynamic>?)?['backgroundImageUrl'] as String?;
          return GradesScreen(parentId: stageId, titlePath: titlePath, backgroundImageUrl: backgroundImageUrl);
        },
      ),
      GoRoute(
        path: AppRoutes.sections,
        name: 'sections',
        builder: (context, state) {
          final gradeId = state.pathParameters['gradeId'] ?? '';
          final titlePath =
              (state.extra as Map<String, dynamic>?)?['titlePath']
                  as List<String>? ??
              [];
          final backgroundImageUrl =
              (state.extra as Map<String, dynamic>?)?['backgroundImageUrl'] as String?;
          return SectionsScreen(parentId: gradeId, titlePath: titlePath, backgroundImageUrl: backgroundImageUrl);
        },
      ),
      GoRoute(
        path: AppRoutes.subjects,
        name: 'subjects',
        builder: (context, state) {
          final sectionId = state.pathParameters['sectionId'] ?? '';
          final titlePath =
              (state.extra as Map<String, dynamic>?)?['titlePath']
                  as List<String>? ??
              [];
          final backgroundImageUrl =
              (state.extra as Map<String, dynamic>?)?['backgroundImageUrl'] as String?;
          return SubjectsScreen(parentId: sectionId, titlePath: titlePath, backgroundImageUrl: backgroundImageUrl);
        },
      ),
      GoRoute(
        path: AppRoutes.units,
        name: 'units',
        builder: (context, state) {
          final subjectId = state.pathParameters['subjectId'] ?? '';
          final titlePath =
              (state.extra as Map<String, dynamic>?)?['titlePath']
                  as List<String>? ??
              [];
          final backgroundImageUrl =
              (state.extra as Map<String, dynamic>?)?['backgroundImageUrl'] as String?;
          return UnitsScreen(parentId: subjectId, titlePath: titlePath, backgroundImageUrl: backgroundImageUrl);
        },
      ),
      GoRoute(
        path: AppRoutes.lessons,
        name: 'lessons',
        builder: (context, state) {
          final unitId = state.pathParameters['unitId'] ?? '';
          final titlePath =
              (state.extra as Map<String, dynamic>?)?['titlePath']
                  as List<String>? ??
              [];
          final backgroundImageUrl =
              (state.extra as Map<String, dynamic>?)?['backgroundImageUrl'] as String?;
          return LessonsScreen(parentId: unitId, titlePath: titlePath, backgroundImageUrl: backgroundImageUrl);
        },
      ),
      GoRoute(
        path: AppRoutes.lessonFiles,
        name: 'lessonFiles',
        builder: (context, state) {
          final lessonId = state.pathParameters['lessonId'] ?? '';
          final titlePath =
              (state.extra as Map<String, dynamic>?)?['titlePath']
                  as List<String>? ??
              [];
          return LessonFilesScreen(parentId: lessonId, titlePath: titlePath);
        },
      ),
      GoRoute(
        path: AppRoutes.videoPlayer,
        name: 'videoPlayer',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return VideoPlayerScreen(
            videoUrl: extra['videoUrl'] as String? ?? '',
            title: extra['title'] as String? ?? 'Video',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.audioPlayer,
        name: 'audioPlayer',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return AudioPlayerScreen(
            audioUrl: extra['audioUrl'] as String? ?? '',
            title: extra['title'] as String? ?? 'Audio',
            coverImageUrl: extra['coverImageUrl'] as String?,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.pdfViewer,
        name: 'pdfViewer',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return PdfViewerScreen(
            pdfUrl: extra['pdfUrl'] as String? ?? '',
            title: extra['title'] as String? ?? 'Document',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.interactiveViewer,
        name: 'interactiveViewer',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return InteractiveViewerScreen(
            contentUrl: extra['contentUrl'] as String? ?? '',
            title: extra['title'] as String? ?? 'Interactive Lesson',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.subscription,
        name: 'subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: AppRoutes.subscriptionExpired,
        name: 'subscriptionExpired',
        builder: (context, state) => const SubscriptionExpiredScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.parentLock,
        name: 'parentLock',
        builder: (context, state) => const ParentLockScreen(),
      ),
      GoRoute(
        path: AppRoutes.parentSettings,
        name: 'parentSettings',
        builder: (context, state) => const ParentSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.changePin,
        name: 'changePin',
        builder: (context, state) => const ChangePinScreen(),
      ),
      GoRoute(
        path: AppRoutes.appEntryLock,
        name: 'appEntryLock',
        builder: (context, state) => const ParentLockScreen(isAppEntry: true),
      ),
      GoRoute(
        path: AppRoutes.appExitLock,
        name: 'appExitLock',
        builder: (context, state) => const ParentLockScreen(isAppExit: true),
      ),
      GoRoute(
        path: AppRoutes.support,
        name: 'support',
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        name: 'privacy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Page not found: ${state.uri}',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    ),
  );
}

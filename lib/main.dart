import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/routing/app_router.dart';
import 'core/services/dependency_injection.dart';
import 'core/services/logger_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_bloc_observer.dart';
import 'features/authentication/presentation/manager/cubit/auth_cubit.dart';
import 'features/authentication/presentation/manager/state/auth_state.dart';
import 'features/theme/presentation/manager/cubit/theme_cubit.dart';
import 'features/educational_stages/presentation/manager/cubit/stages_cubit.dart';
import 'features/grades/presentation/manager/cubit/grades_cubit.dart';
import 'features/sections/presentation/manager/cubit/sections_cubit.dart';
import 'features/subjects/presentation/manager/cubit/subjects_cubit.dart';
import 'features/units/presentation/manager/cubit/units_cubit.dart';
import 'features/lessons/presentation/manager/cubit/lessons_cubit.dart';
import 'features/lesson_files/presentation/manager/cubit/lesson_files_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies (GetIt)
  await initDependencies();

  // Setup Bloc Observer for state transition & error logging
  Bloc.observer = AppBlocObserver();

  // Handle unhandled Flutter framework errors
  FlutterError.onError = (details) {
    LoggerService.instance.error(
      'Flutter Exception: ${details.exceptionAsString()}',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  // Handle unhandled asynchronous/platform errors
  PlatformDispatcher.instance.onError = (error, stack) {
    LoggerService.instance.error(
      'Platform Exception: $error',
      error: error,
      stackTrace: stack,
    );
    return true;
  };

  // Platform-specific WebView initialization
  if (Platform.isAndroid) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Dark status bar for premium feel
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const QubahLearningApp());
}

class QubahLearningApp extends StatelessWidget {
  const QubahLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthCubit>()),
        BlocProvider(create: (_) => sl<ThemeCubit>()),
        BlocProvider(create: (_) => sl<StagesCubit>()),
        BlocProvider(create: (_) => sl<GradesCubit>()),
        BlocProvider(create: (_) => sl<SectionsCubit>()),
        BlocProvider(create: (_) => sl<SubjectsCubit>()),
        BlocProvider(create: (_) => sl<UnitsCubit>()),
        BlocProvider(create: (_) => sl<LessonsCubit>()),
        BlocProvider(create: (_) => sl<LessonFilesCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthSubscriptionExpired) {
                AppRouter.router.go(AppRoutes.subscriptionExpired);
              } else if (state is AuthUnauthenticated) {
                AppRouter.router.go(AppRoutes.login);
              }
            },
            child: MaterialApp.router(
              title: 'Qubah Learning',
              debugShowCheckedModeBanner: false,

              // Localization
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('ar', '')],
              locale: const Locale('ar', ''),

              // Themes
              theme: AppTheme.lightTheme,
              themeMode: ThemeMode.light,

              // Routing
              routerConfig: AppRouter.router,
            ),
          );
        },
      ),
    );
  }
}

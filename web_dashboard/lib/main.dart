import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:web_dashboard/core/services/dependency_injection.dart';
import 'package:web_dashboard/core/theme/app_theme.dart';
import 'package:web_dashboard/core/theme/theme_cubit.dart';
import 'package:web_dashboard/core/routing/app_router.dart';
import 'package:web_dashboard/features/authentication/presentation/manager/auth_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => sl<ThemeCubit>(),
        ),
        BlocProvider<AuthCubit>(
          create: (_) => sl<AuthCubit>()..checkAuthStatus(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'قبة - لوحة تحكم الإدارة',
            debugShowCheckedModeBanner: false,
            locale: const Locale('ar'),
            supportedLocales: const [
              Locale('ar'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: LightTheme.theme,
            darkTheme: DarkTheme.theme,
            themeMode: themeMode,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}

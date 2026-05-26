import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:web_dashboard/core/network/api_client.dart';
import 'package:web_dashboard/core/storage/local_storage.dart';
import 'package:web_dashboard/core/theme/theme_cubit.dart';

// Repositories
import 'package:web_dashboard/features/authentication/data/repositories/auth_repository.dart';
import 'package:web_dashboard/features/educational_stages/data/repositories/stages_repository.dart';
import 'package:web_dashboard/features/grades/data/repositories/grades_repository.dart';
import 'package:web_dashboard/features/sections/data/repositories/sections_repository.dart';
import 'package:web_dashboard/features/subjects/data/repositories/subjects_repository.dart';
import 'package:web_dashboard/features/units/data/repositories/units_repository.dart';
import 'package:web_dashboard/features/lessons/data/repositories/lessons_repository.dart';
import 'package:web_dashboard/features/lesson_files/data/repositories/lesson_files_repository.dart';
import 'package:web_dashboard/features/users/data/repositories/users_repository.dart';
import 'package:web_dashboard/features/subscriptions/data/repositories/subscriptions_repository.dart';
import 'package:web_dashboard/features/notifications/data/repositories/notifications_repository.dart';
import 'package:web_dashboard/features/analytics/data/repositories/analytics_repository.dart';
import 'package:web_dashboard/features/settings/data/repositories/settings_repository.dart';
import 'package:web_dashboard/features/dashboard/data/repositories/dashboard_repository.dart';

// Cubits
import 'package:web_dashboard/features/authentication/presentation/manager/auth_cubit.dart';
import 'package:web_dashboard/features/educational_stages/presentation/manager/stages_cubit.dart';
import 'package:web_dashboard/features/grades/presentation/manager/grades_cubit.dart';
import 'package:web_dashboard/features/sections/presentation/manager/sections_cubit.dart';
import 'package:web_dashboard/features/subjects/presentation/manager/subjects_cubit.dart';
import 'package:web_dashboard/features/units/presentation/manager/units_cubit.dart';
import 'package:web_dashboard/features/lessons/presentation/manager/lessons_cubit.dart';
import 'package:web_dashboard/features/lesson_files/presentation/manager/lesson_files_cubit.dart';
import 'package:web_dashboard/features/users/presentation/manager/users_cubit.dart';
import 'package:web_dashboard/features/subscriptions/presentation/manager/subscriptions_cubit.dart';
import 'package:web_dashboard/features/notifications/presentation/manager/notifications_cubit.dart';
import 'package:web_dashboard/features/analytics/presentation/manager/analytics_cubit.dart';
import 'package:web_dashboard/features/settings/presentation/manager/settings_cubit.dart';
import 'package:web_dashboard/features/dashboard/presentation/manager/dashboard_cubit.dart';

/// Global service locator instance.
final sl = GetIt.instance;

/// Initializes all dependencies. Must be called before [runApp].
Future<void> initDependencies() async {
  // ── External ────────────────────────────────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // ── Core Services ──────────────────────────────────────────────────────
  sl.registerLazySingleton<LocalStorage>(
    () => LocalStorage(sl<SharedPreferences>()),
  );

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(sl<LocalStorage>()),
  );

  // ── Core Cubits ────────────────────────────────────────────────────────
  sl.registerFactory<ThemeCubit>(
    () => ThemeCubit(sl<LocalStorage>()),
  );

  // ── Feature Repositories (Lazy Singletons) ────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(() => AuthRepository(sl<ApiClient>()));
  sl.registerLazySingleton<StagesRepository>(() => StagesRepository(sl<ApiClient>()));
  sl.registerLazySingleton<GradesRepository>(() => GradesRepository(sl<ApiClient>()));
  sl.registerLazySingleton<SectionsRepository>(() => SectionsRepository(sl<ApiClient>()));
  sl.registerLazySingleton<SubjectsRepository>(() => SubjectsRepository(sl<ApiClient>()));
  sl.registerLazySingleton<UnitsRepository>(() => UnitsRepository(sl<ApiClient>()));
  sl.registerLazySingleton<LessonsRepository>(() => LessonsRepository(sl<ApiClient>()));
  sl.registerLazySingleton<LessonFilesRepository>(() => LessonFilesRepository(sl<ApiClient>()));
  sl.registerLazySingleton<UsersRepository>(() => UsersRepository(sl<ApiClient>()));
  sl.registerLazySingleton<SubscriptionsRepository>(() => SubscriptionsRepository(sl<ApiClient>()));
  sl.registerLazySingleton<NotificationsRepository>(() => NotificationsRepository(sl<ApiClient>()));
  sl.registerLazySingleton<AnalyticsRepository>(() => AnalyticsRepository(sl<ApiClient>()));
  sl.registerLazySingleton<SettingsRepository>(() => SettingsRepository(sl<ApiClient>()));
  sl.registerLazySingleton<DashboardRepository>(() => DashboardRepository(sl<ApiClient>()));

  // ── Feature Cubits (Factories) ──────────────────────────────────────────
  sl.registerFactory<AuthCubit>(
    () => AuthCubit(authRepository: sl<AuthRepository>()),
  );
  sl.registerFactory<StagesCubit>(
    () => StagesCubit(repository: sl<StagesRepository>()),
  );
  sl.registerFactory<GradesCubit>(
    () => GradesCubit(repository: sl<GradesRepository>()),
  );
  sl.registerFactory<SectionsCubit>(
    () => SectionsCubit(repository: sl<SectionsRepository>()),
  );
  sl.registerFactory<SubjectsCubit>(
    () => SubjectsCubit(repository: sl<SubjectsRepository>()),
  );
  sl.registerFactory<UnitsCubit>(
    () => UnitsCubit(repository: sl<UnitsRepository>()),
  );
  sl.registerFactory<LessonsCubit>(
    () => LessonsCubit(repository: sl<LessonsRepository>()),
  );
  sl.registerFactory<LessonFilesCubit>(
    () => LessonFilesCubit(repository: sl<LessonFilesRepository>()),
  );
  sl.registerFactory<UsersCubit>(
    () => UsersCubit(sl<UsersRepository>()),
  );
  sl.registerFactory<SubscriptionsCubit>(
    () => SubscriptionsCubit(sl<SubscriptionsRepository>()),
  );
  sl.registerFactory<NotificationsCubit>(
    () => NotificationsCubit(sl<NotificationsRepository>()),
  );
  sl.registerFactory<AnalyticsCubit>(
    () => AnalyticsCubit(sl<AnalyticsRepository>()),
  );
  sl.registerFactory<SettingsCubit>(
    () => SettingsCubit(sl<SettingsRepository>()),
  );
  sl.registerFactory<DashboardCubit>(
    () => DashboardCubit(repository: sl<DashboardRepository>()),
  );
}

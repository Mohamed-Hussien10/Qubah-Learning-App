import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/error_interceptor.dart';
import '../storage/secure_storage.dart';

// Feature imports - Authentication
import '../../features/authentication/data/data_sources/auth_api_service.dart';
import '../../features/authentication/data/data_sources/auth_local_service.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/domain/usecases/login_usecase.dart';
import '../../features/authentication/domain/usecases/logout_usecase.dart';
import '../../features/authentication/presentation/manager/cubit/auth_cubit.dart';

// Feature imports - Stages
import '../../features/educational_stages/data/data_sources/stages_api_service.dart';
import '../../features/educational_stages/data/repositories/stages_repository_impl.dart';
import '../../features/educational_stages/domain/repositories/stages_repository.dart';
import '../../features/educational_stages/domain/usecases/get_stages_usecase.dart';
import '../../features/educational_stages/presentation/manager/cubit/stages_cubit.dart';

// Feature imports - Subjects
import '../../features/subjects/data/data_sources/subjects_api_service.dart';
import '../../features/subjects/data/repositories/subjects_repository_impl.dart';
import '../../features/subjects/domain/repositories/subjects_repository.dart';
import '../../features/subjects/domain/usecases/get_subjects_usecase.dart';
import '../../features/subjects/presentation/manager/cubit/subjects_cubit.dart';

// Feature imports - Lessons
import '../../features/lessons/data/data_sources/lessons_api_service.dart';
import '../../features/lessons/data/repositories/lessons_repository_impl.dart';
import '../../features/lessons/domain/repositories/lessons_repository.dart';
import '../../features/lessons/domain/usecases/get_lessons_usecase.dart';
import '../../features/lessons/presentation/manager/cubit/lessons_cubit.dart';

// Feature imports - Grades
import '../../features/grades/data/data_sources/grades_api_service.dart';
import '../../features/grades/data/repositories/grades_repository_impl.dart';
import '../../features/grades/domain/repositories/grades_repository.dart';
import '../../features/grades/domain/usecases/get_grades_usecase.dart';
import '../../features/grades/presentation/manager/cubit/grades_cubit.dart';

// Feature imports - Sections
import '../../features/sections/data/data_sources/sections_api_service.dart';
import '../../features/sections/data/repositories/sections_repository_impl.dart';
import '../../features/sections/domain/repositories/sections_repository.dart';
import '../../features/sections/domain/usecases/get_sections_usecase.dart';
import '../../features/sections/presentation/manager/cubit/sections_cubit.dart';

// Feature imports - Units
import '../../features/units/data/data_sources/units_api_service.dart';
import '../../features/units/data/repositories/units_repository_impl.dart';
import '../../features/units/domain/repositories/units_repository.dart';
import '../../features/units/domain/usecases/get_units_usecase.dart';
import '../../features/units/presentation/manager/cubit/units_cubit.dart';

// Feature imports - Lesson Files
import '../../features/lesson_files/data/data_sources/lesson_files_api_service.dart';
import '../../features/lesson_files/data/repositories/lesson_files_repository_impl.dart';
import '../../features/lesson_files/domain/repositories/lesson_files_repository.dart';
import '../../features/lesson_files/domain/usecases/get_lesson_files_usecase.dart';
import '../../features/lesson_files/presentation/manager/cubit/lesson_files_cubit.dart';

import '../../features/theme/presentation/manager/cubit/theme_cubit.dart';

/// Service locator instance.
final GetIt sl = GetIt.instance;

/// Initialises all dependencies in the service locator.
Future<void> initDependencies() async {
  // ── Core Services ───────────────────────────────────────────────────────
  sl.registerLazySingleton<SecureStorage>(() => SecureStorage());
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(InternetConnection()),
  );
  sl.registerLazySingleton<ErrorInterceptor>(() => ErrorInterceptor());
  sl.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(secureStorage: sl()),
  );
  sl.registerLazySingleton<DioClient>(
    () => DioClient(authInterceptor: sl(), errorInterceptor: sl()),
  );

  // ── Authentication Feature ─────────────────────────────────────────────
  sl.registerLazySingleton<AuthApiService>(() => AuthApiService(sl()));
  sl.registerLazySingleton<AuthLocalService>(() => AuthLocalService(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      apiService: sl(),
      localService: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerFactory(() => AuthCubit(loginUseCase: sl(), logoutUseCase: sl()));

  // ── Educational Stages Feature ─────────────────────────────────────────
  sl.registerLazySingleton<StagesApiService>(() => StagesApiService(sl()));
  sl.registerLazySingleton<StagesRepository>(
    () => StagesRepositoryImpl(apiService: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton(() => GetStagesUseCase(sl()));
  sl.registerFactory(() => StagesCubit(getStagesUseCase: sl()));

  // ── Subjects Feature ───────────────────────────────────────────────────
  sl.registerLazySingleton<SubjectsApiService>(() => SubjectsApiService(sl()));
  sl.registerLazySingleton<SubjectsRepository>(
    () => SubjectsRepositoryImpl(apiService: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton(() => GetSubjectsUseCase(sl()));
  sl.registerFactory(() => SubjectsCubit(getSubjectsUseCase: sl()));

  // ── Lessons Feature ────────────────────────────────────────────────────
  sl.registerLazySingleton<LessonsApiService>(() => LessonsApiService(sl()));
  sl.registerLazySingleton<LessonsRepository>(
    () => LessonsRepositoryImpl(apiService: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton(() => GetLessonsUseCase(sl()));
  sl.registerFactory(() => LessonsCubit(getLessonsUseCase: sl()));

  // ── Grades Feature ─────────────────────────────────────────
  sl.registerLazySingleton<GradesApiService>(
    () => GradesApiService(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<GradesRepository>(() => GradesRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetGradesUseCase(sl()));
  sl.registerFactory(() => GradesCubit(getGradesUseCase: sl()));

  // ── Sections Feature ─────────────────────────────────────────
  sl.registerLazySingleton<SectionsApiService>(
    () => SectionsApiService(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<SectionsRepository>(
    () => SectionsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetSectionsUseCase(sl()));
  sl.registerFactory(() => SectionsCubit(getSectionsUseCase: sl()));

  // ── Units Feature ─────────────────────────────────────────
  sl.registerLazySingleton<UnitsApiService>(
    () => UnitsApiService(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<UnitsRepository>(() => UnitsRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetUnitsUseCase(sl()));
  sl.registerFactory(() => UnitsCubit(getUnitsUseCase: sl()));

  // ── Lesson Files Feature ─────────────────────────────────────────
  sl.registerLazySingleton<LessonFilesApiService>(
    () => LessonFilesApiService(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<LessonFilesRepository>(
    () => LessonFilesRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetLessonFilesUseCase(sl()));
  sl.registerFactory(() => LessonFilesCubit(getLessonFilesUseCase: sl()));

  // ── Parent Lock Feature ────────────────────────────────────────────────
  // sl.registerFactory(() => ParentLockCubit(secureStorage: sl()));

  // ── Theme Feature ──────────────────────────────────────────────────────
  sl.registerFactory(() => ThemeCubit(secureStorage: sl()));

  // ── Notifications Feature ──────────────────────────────────────────────
  // sl.registerLazySingleton<NotificationsApiService>(() => NotificationsApiService(sl()));
  // sl.registerLazySingleton<NotificationsRepository>(() => NotificationsRepositoryImpl(apiService: sl(), networkInfo: sl()));
  // sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  // sl.registerFactory(() => NotificationsCubit(getNotificationsUseCase: sl()));

  // ── Subscription Feature ───────────────────────────────────────────────
  // sl.registerLazySingleton<SubscriptionApiService>(() => SubscriptionApiService(sl()));
  // sl.registerLazySingleton<SubscriptionRepository>(() => SubscriptionRepositoryImpl(apiService: sl(), networkInfo: sl(), secureStorage: sl()));
  // sl.registerLazySingleton(() => GetSubscriptionStatusUseCase(sl()));
  // sl.registerFactory(() => SubscriptionCubit(getSubscriptionStatusUseCase: sl()));

  // ── User Profile Feature ───────────────────────────────────────────────
  // sl.registerLazySingleton<ProfileApiService>(() => ProfileApiService(sl()));
  // sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(apiService: sl(), networkInfo: sl()));
  // sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  // sl.registerFactory(() => ProfileCubit(getProfileUseCase: sl()));
}

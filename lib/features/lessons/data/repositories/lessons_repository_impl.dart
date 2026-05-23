import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/lesson_entity.dart';
import '../../domain/repositories/lessons_repository.dart';
import '../data_sources/lessons_api_service.dart';

class LessonsRepositoryImpl implements LessonsRepository {
  final LessonsApiService _apiService;
  final NetworkInfo _networkInfo;

  LessonsRepositoryImpl({
    required LessonsApiService apiService,
    required NetworkInfo networkInfo,
  }) : _apiService = apiService,
       _networkInfo = networkInfo;

  @override
  Future<List<LessonEntity>> getLessons(String subjectId) async {
    if (!await _networkInfo.isConnected) throw const NetworkException();
    final models = await _apiService.getLessons(subjectId);
    return models.map((m) => m.toEntity()).toList();
  }
}

import '../../domain/entities/lesson_file_entity.dart';
import '../../domain/repositories/lesson_files_repository.dart';
import '../data_sources/lesson_files_api_service.dart';

class LessonFilesRepositoryImpl implements LessonFilesRepository {
  final LessonFilesApiService apiService;

  LessonFilesRepositoryImpl(this.apiService);

  @override
  Future<List<LessonFileEntity>> getLessonFiles(String parentId) async {
    final models = await apiService.getLessonFiles(parentId);
    return models.map((e) => e.toEntity()).toList();
  }
}

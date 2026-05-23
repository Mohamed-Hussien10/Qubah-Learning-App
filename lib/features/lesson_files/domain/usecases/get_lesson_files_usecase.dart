import '../../../../core/utils/usecase.dart';
import '../entities/lesson_file_entity.dart';
import '../repositories/lesson_files_repository.dart';

class GetLessonFilesUseCase implements UseCase<List<LessonFileEntity>, String> {
  final LessonFilesRepository repository;

  GetLessonFilesUseCase(this.repository);

  @override
  Future<List<LessonFileEntity>> call(String params) {
    return repository.getLessonFiles(params);
  }
}

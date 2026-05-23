import '../entities/lesson_file_entity.dart';

abstract class LessonFilesRepository {
  Future<List<LessonFileEntity>> getLessonFiles(String parentId);
}

import '../../../../core/utils/usecase.dart';
import '../entities/lesson_entity.dart';
import '../repositories/lessons_repository.dart';

class GetLessonsUseCase implements UseCase<List<LessonEntity>, String> {
  final LessonsRepository _repository;
  GetLessonsUseCase(this._repository);

  @override
  Future<List<LessonEntity>> call(String subjectId) =>
      _repository.getLessons(subjectId);
}

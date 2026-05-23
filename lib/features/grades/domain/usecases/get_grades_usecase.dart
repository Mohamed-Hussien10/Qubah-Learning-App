import '../../../../core/utils/usecase.dart';
import '../entities/grade_entity.dart';
import '../repositories/grades_repository.dart';

class GetGradesUseCase implements UseCase<List<GradeEntity>, String> {
  final GradesRepository repository;

  GetGradesUseCase(this.repository);

  @override
  Future<List<GradeEntity>> call(String params) {
    return repository.getGrades(params);
  }
}

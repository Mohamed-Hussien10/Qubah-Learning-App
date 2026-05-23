import '../../../../core/utils/usecase.dart';
import '../entities/subject_entity.dart';
import '../repositories/subjects_repository.dart';

class GetSubjectsUseCase implements UseCase<List<SubjectEntity>, String> {
  final SubjectsRepository _repository;
  GetSubjectsUseCase(this._repository);

  @override
  Future<List<SubjectEntity>> call(String stageId) =>
      _repository.getSubjects(stageId);
}

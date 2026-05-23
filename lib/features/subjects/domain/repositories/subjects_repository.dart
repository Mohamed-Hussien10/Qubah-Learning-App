import '../entities/subject_entity.dart';

abstract class SubjectsRepository {
  Future<List<SubjectEntity>> getSubjects(String stageId);
}

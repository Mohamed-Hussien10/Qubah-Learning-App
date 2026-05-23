import '../entities/grade_entity.dart';

abstract class GradesRepository {
  Future<List<GradeEntity>> getGrades(String parentId);
}

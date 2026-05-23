import '../../domain/entities/grade_entity.dart';
import '../../domain/repositories/grades_repository.dart';
import '../data_sources/grades_api_service.dart';

class GradesRepositoryImpl implements GradesRepository {
  final GradesApiService apiService;

  GradesRepositoryImpl(this.apiService);

  @override
  Future<List<GradeEntity>> getGrades(String parentId) async {
    final models = await apiService.getGrades(parentId);
    return models.map((e) => e.toEntity()).toList();
  }
}

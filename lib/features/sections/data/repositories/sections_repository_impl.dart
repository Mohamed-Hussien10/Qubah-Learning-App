import '../../domain/entities/section_entity.dart';
import '../../domain/repositories/sections_repository.dart';
import '../data_sources/sections_api_service.dart';

class SectionsRepositoryImpl implements SectionsRepository {
  final SectionsApiService apiService;

  SectionsRepositoryImpl(this.apiService);

  @override
  Future<List<SectionEntity>> getSections(String parentId) async {
    final models = await apiService.getSections(parentId);
    return models.map((e) => e.toEntity()).toList();
  }
}

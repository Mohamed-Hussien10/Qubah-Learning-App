import '../../domain/entities/unit_entity.dart';
import '../../domain/repositories/units_repository.dart';
import '../data_sources/units_api_service.dart';

class UnitsRepositoryImpl implements UnitsRepository {
  final UnitsApiService apiService;

  UnitsRepositoryImpl(this.apiService);

  @override
  Future<List<UnitEntity>> getUnits(String parentId) async {
    final models = await apiService.getUnits(parentId);
    return models.map((e) => e.toEntity()).toList();
  }
}

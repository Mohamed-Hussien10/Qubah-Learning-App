import '../../../../core/utils/usecase.dart';
import '../entities/unit_entity.dart';
import '../repositories/units_repository.dart';

class GetUnitsUseCase implements UseCase<List<UnitEntity>, String> {
  final UnitsRepository repository;

  GetUnitsUseCase(this.repository);

  @override
  Future<List<UnitEntity>> call(String params) {
    return repository.getUnits(params);
  }
}

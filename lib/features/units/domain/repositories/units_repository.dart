import '../entities/unit_entity.dart';

abstract class UnitsRepository {
  Future<List<UnitEntity>> getUnits(String parentId);
}

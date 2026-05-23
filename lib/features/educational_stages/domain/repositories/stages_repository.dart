import '../entities/stage_entity.dart';

/// Abstract stages repository. Pure Dart.
abstract class StagesRepository {
  Future<List<StageEntity>> getStages();
  Future<StageEntity> getStageById(String id);
}

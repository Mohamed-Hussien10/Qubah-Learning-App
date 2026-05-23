import '../../../../core/utils/usecase.dart';
import '../entities/stage_entity.dart';
import '../repositories/stages_repository.dart';

class GetStagesUseCase implements UseCase<List<StageEntity>, NoParams> {
  final StagesRepository _repository;
  GetStagesUseCase(this._repository);

  @override
  Future<List<StageEntity>> call(NoParams params) => _repository.getStages();
}

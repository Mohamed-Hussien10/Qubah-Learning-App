import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/stage_entity.dart';
import '../../domain/repositories/stages_repository.dart';
import '../data_sources/stages_api_service.dart';

class StagesRepositoryImpl implements StagesRepository {
  final StagesApiService _apiService;
  final NetworkInfo _networkInfo;

  StagesRepositoryImpl({
    required StagesApiService apiService,
    required NetworkInfo networkInfo,
  }) : _apiService = apiService,
       _networkInfo = networkInfo;

  @override
  Future<List<StageEntity>> getStages() async {
    if (!await _networkInfo.isConnected) throw const NetworkException();
    final models = await _apiService.getStages();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<StageEntity> getStageById(String id) async {
    if (!await _networkInfo.isConnected) throw const NetworkException();
    final model = await _apiService.getStageById(id);
    return model.toEntity();
  }
}

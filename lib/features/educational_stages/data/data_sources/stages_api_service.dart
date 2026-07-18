import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/stage_model.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/services/dependency_injection.dart';

class StagesApiService {
  final DioClient _dioClient;
  StagesApiService(this._dioClient);

  Future<List<StageModel>> getStages() async {
    final isGuest = await sl<SecureStorage>().isGuest();
    final endpoint = isGuest ? '/free-trial/stages' : '/educational-stages';
    final response = await _dioClient.get(endpoint);
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => StageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<StageModel> getStageById(String id) async {
    final isGuest = await sl<SecureStorage>().isGuest();
    final endpoint = isGuest ? '/free-trial/stages/$id' : ApiEndpoints.stageById(id);
    final response = await _dioClient.get(endpoint);
    return StageModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}

import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/stage_model.dart';

class StagesApiService {
  final DioClient _dioClient;
  StagesApiService(this._dioClient);

  Future<List<StageModel>> getStages() async {
    final response = await _dioClient.get('/educational-stages');
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => StageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<StageModel> getStageById(String id) async {
    final response = await _dioClient.get(ApiEndpoints.stageById(id));
    return StageModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}

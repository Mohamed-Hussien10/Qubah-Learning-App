import 'package:web_dashboard/core/constants/api_endpoints.dart';
import 'package:web_dashboard/core/network/api_client.dart';
import 'package:web_dashboard/features/free_trial_stages/data/models/free_trial_stage_model.dart';

/// Repository handling CRUD operations for educational freeTrialStages.
class FreeTrialStagesRepository {
  final ApiClient _apiClient;

  FreeTrialStagesRepository(this._apiClient);

  // ── Read ─────────────────────────────────────────────────────────────

  Future<List<FreeTrialStageModel>> getAll() async {
    final response = await _apiClient.get(ApiEndpoints.freeTrialStages);
    final data = response.data['data'] ?? response.data;
    if (data is List) {
      return data.map((json) => FreeTrialStageModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<FreeTrialStageModel> getById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.freeTrialStage(int.parse(id)));
    final data = response.data['data'] ?? response.data;
    return FreeTrialStageModel.fromJson(data as Map<String, dynamic>);
  }

  // ── Create ───────────────────────────────────────────────────────────

  Future<FreeTrialStageModel> create(FreeTrialStageModel freeTrialStage, {List<int>? imageBytes, String? imageName, List<int>? bgImageBytes, String? bgImageName}) async {
    final payload = freeTrialStage.toJson()..remove('id')..remove('created_at');
    
    if (imageBytes != null && imageBytes.isNotEmpty && imageName != null) {
      final uploadRes = await _apiClient.uploadFileBytes(
        '/thumbnails/upload',
        fileBytes: imageBytes,
        fileName: imageName,
        fileFieldName: 'thumbnail',
        additionalFields: {'folder': 'free-trial/stages'},
      );
      final path = uploadRes.data['data']['path'];
      payload['thumbnail_path'] = path;
    }

    if (bgImageBytes != null && bgImageBytes.isNotEmpty && bgImageName != null) {
      final uploadRes = await _apiClient.uploadFileBytes(
        '/thumbnails/upload',
        fileBytes: bgImageBytes,
        fileName: bgImageName,
        fileFieldName: 'thumbnail',
        additionalFields: {'folder': 'free-trial/stages'},
      );
      final path = uploadRes.data['data']['path'];
      payload['background_image_path'] = path;
    }

    final response = await _apiClient.post(ApiEndpoints.freeTrialStages, data: payload);
    final data = response.data['data'] ?? response.data;
    return FreeTrialStageModel.fromJson(data as Map<String, dynamic>);
  }

  // ── Update ───────────────────────────────────────────────────────────

  Future<FreeTrialStageModel> update(FreeTrialStageModel freeTrialStage, {List<int>? imageBytes, String? imageName, List<int>? bgImageBytes, String? bgImageName}) async {
    final payload = freeTrialStage.toJson()..remove('created_at');

    if (imageBytes != null && imageBytes.isNotEmpty && imageName != null) {
      final uploadRes = await _apiClient.uploadFileBytes(
        '/thumbnails/upload',
        fileBytes: imageBytes,
        fileName: imageName,
        fileFieldName: 'thumbnail',
        additionalFields: {'folder': 'free-trial/stages'},
      );
      final path = uploadRes.data['data']['path'];
      payload['thumbnail_path'] = path;
    }

    if (bgImageBytes != null && bgImageBytes.isNotEmpty && bgImageName != null) {
      final uploadRes = await _apiClient.uploadFileBytes(
        '/thumbnails/upload',
        fileBytes: bgImageBytes,
        fileName: bgImageName,
        fileFieldName: 'thumbnail',
        additionalFields: {'folder': 'free-trial/stages'},
      );
      final path = uploadRes.data['data']['path'];
      payload['background_image_path'] = path;
    }

    final response = await _apiClient.put(ApiEndpoints.freeTrialStage(int.parse(freeTrialStage.id)), data: payload);
    final data = response.data['data'] ?? response.data;
    return FreeTrialStageModel.fromJson(data as Map<String, dynamic>);
  }

  // ── Delete ───────────────────────────────────────────────────────────

  Future<bool> delete(String id) async {
    await _apiClient.delete(ApiEndpoints.freeTrialStage(int.parse(id)));
    return true;
  }

  // ── Toggle Status ────────────────────────────────────────────────────

  Future<FreeTrialStageModel> toggleStatus(String id) async {
    final freeTrialStage = await getById(id);
    final updated = freeTrialStage.copyWith(isActive: !freeTrialStage.isActive);
    return update(updated);
  }

  // ── Reorder ──────────────────────────────────────────────────────────

  Future<bool> reorder(List<String> orderedIds) async {
    await _apiClient.post('/educational-freeTrialStages/reorder', data: {'ids': orderedIds});
    return true;
  }
}

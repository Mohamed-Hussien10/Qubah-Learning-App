import 'package:web_dashboard/core/constants/api_endpoints.dart';
import 'package:web_dashboard/core/network/api_client.dart';
import 'package:web_dashboard/features/educational_stages/data/models/stage_model.dart';

/// Repository handling CRUD operations for educational stages.
class StagesRepository {
  final ApiClient _apiClient;

  StagesRepository(this._apiClient);

  // ── Read ─────────────────────────────────────────────────────────────

  Future<List<StageModel>> getAll() async {
    final response = await _apiClient.get(ApiEndpoints.stages);
    final data = response.data['data'] ?? response.data;
    if (data is List) {
      return data.map((json) => StageModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<StageModel> getById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.stage(int.parse(id)));
    final data = response.data['data'] ?? response.data;
    return StageModel.fromJson(data as Map<String, dynamic>);
  }

  // ── Create ───────────────────────────────────────────────────────────

  Future<StageModel> create(StageModel stage, {List<int>? imageBytes, String? imageName, List<int>? bgImageBytes, String? bgImageName}) async {
    final payload = stage.toJson()..remove('id')..remove('created_at');
    
    if (imageBytes != null && imageBytes.isNotEmpty && imageName != null) {
      final uploadRes = await _apiClient.uploadFileBytes(
        '/thumbnails/upload',
        fileBytes: imageBytes,
        fileName: imageName,
        fileFieldName: 'thumbnail',
        additionalFields: {'folder': 'stages'},
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
        additionalFields: {'folder': 'stages'},
      );
      final path = uploadRes.data['data']['path'];
      payload['background_image_path'] = path;
    }

    final response = await _apiClient.post(ApiEndpoints.stages, data: payload);
    final data = response.data['data'] ?? response.data;
    return StageModel.fromJson(data as Map<String, dynamic>);
  }

  // ── Update ───────────────────────────────────────────────────────────

  Future<StageModel> update(StageModel stage, {List<int>? imageBytes, String? imageName, List<int>? bgImageBytes, String? bgImageName}) async {
    final payload = stage.toJson()..remove('created_at');

    if (imageBytes != null && imageBytes.isNotEmpty && imageName != null) {
      final uploadRes = await _apiClient.uploadFileBytes(
        '/thumbnails/upload',
        fileBytes: imageBytes,
        fileName: imageName,
        fileFieldName: 'thumbnail',
        additionalFields: {'folder': 'stages'},
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
        additionalFields: {'folder': 'stages'},
      );
      final path = uploadRes.data['data']['path'];
      payload['background_image_path'] = path;
    }

    final response = await _apiClient.put(ApiEndpoints.stage(int.parse(stage.id)), data: payload);
    final data = response.data['data'] ?? response.data;
    return StageModel.fromJson(data as Map<String, dynamic>);
  }

  // ── Delete ───────────────────────────────────────────────────────────

  Future<bool> delete(String id) async {
    await _apiClient.delete(ApiEndpoints.stage(int.parse(id)));
    return true;
  }

  // ── Toggle Status ────────────────────────────────────────────────────

  Future<StageModel> toggleStatus(String id) async {
    final stage = await getById(id);
    final updated = stage.copyWith(isActive: !stage.isActive);
    return update(updated);
  }

  // ── Reorder ──────────────────────────────────────────────────────────

  Future<bool> reorder(List<String> orderedIds) async {
    await _apiClient.post('/educational-stages/reorder', data: {'ids': orderedIds});
    return true;
  }
}

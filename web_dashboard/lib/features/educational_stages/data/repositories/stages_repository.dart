import 'package:web_dashboard/core/network/api_client.dart';
import 'package:web_dashboard/features/educational_stages/data/models/stage_model.dart';

/// Repository handling CRUD operations for educational stages.
class StagesRepository {
  final ApiClient _apiClient;

  StagesRepository(this._apiClient);

  // ── Read ─────────────────────────────────────────────────────────────

  Future<List<StageModel>> getAll() async {
    final response = await _apiClient.get('/stages');
    final data = response.data['data'] ?? response.data;
    if (data is List) {
      return data.map((json) => StageModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<StageModel> getById(String id) async {
    final response = await _apiClient.get('/stages/$id');
    final data = response.data['data'] ?? response.data;
    return StageModel.fromJson(data as Map<String, dynamic>);
  }

  // ── Create ───────────────────────────────────────────────────────────

  Future<StageModel> create(StageModel stage) async {
    final payload = stage.toJson()..remove('id')..remove('created_at');
    final response = await _apiClient.post('/stages', data: payload);
    final data = response.data['data'] ?? response.data;
    return StageModel.fromJson(data as Map<String, dynamic>);
  }

  // ── Update ───────────────────────────────────────────────────────────

  Future<StageModel> update(StageModel stage) async {
    final payload = stage.toJson()..remove('created_at');
    final response = await _apiClient.put('/stages/${stage.id}', data: payload);
    final data = response.data['data'] ?? response.data;
    return StageModel.fromJson(data as Map<String, dynamic>);
  }

  // ── Delete ───────────────────────────────────────────────────────────

  Future<bool> delete(String id) async {
    await _apiClient.delete('/stages/$id');
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
    await _apiClient.post('/stages/reorder', data: {'ids': orderedIds});
    return true;
  }
}

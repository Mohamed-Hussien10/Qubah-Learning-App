import 'package:web_dashboard/core/network/api_client.dart';
import 'package:web_dashboard/features/units/data/models/unit_model.dart';

/// Repository handling CRUD operations for educational units within a subject.
class UnitsRepository {
  final ApiClient _apiClient;

  UnitsRepository(this._apiClient);

  Future<List<UnitModel>> getBySubjectId(String subjectId) async {
    final response = await _apiClient.get('/subjects/$subjectId');
    final data = response.data['data'];
    final units = data?['units'];
    if (units is List) {
      return units
          .map((json) => UnitModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<UnitModel> getById(String id) async {
    final response = await _apiClient.get('/units/$id');
    final data = response.data['data'] ?? response.data;
    return UnitModel.fromJson(data as Map<String, dynamic>);
  }

  Future<UnitModel> create(UnitModel unit) async {
    final payload = unit.toJson()..remove('id')..remove('created_at');
    final response = await _apiClient.post('/units', data: payload);
    final data = response.data['data'] ?? response.data;
    return UnitModel.fromJson(data as Map<String, dynamic>);
  }

  Future<UnitModel> update(UnitModel unit) async {
    final payload = unit.toJson()..remove('created_at');
    final response = await _apiClient.put('/units/${unit.id}', data: payload);
    final data = response.data['data'] ?? response.data;
    return UnitModel.fromJson(data as Map<String, dynamic>);
  }

  Future<bool> delete(String subjectId, String id) async {
    await _apiClient.delete('/units/$id');
    return true;
  }

  Future<UnitModel> toggleStatus(String subjectId, String id) async {
    final unit = await getById(id);
    final updated = unit.copyWith(isActive: !unit.isActive);
    return update(updated);
  }
}
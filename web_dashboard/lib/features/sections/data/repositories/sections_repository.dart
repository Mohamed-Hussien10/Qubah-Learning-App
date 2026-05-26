import 'package:web_dashboard/core/network/api_client.dart';
import 'package:web_dashboard/features/sections/data/models/section_model.dart';

/// Repository handling CRUD operations for sections within a grade.
class SectionsRepository {
  final ApiClient _apiClient;

  SectionsRepository(this._apiClient);

  Future<List<SectionModel>> getByGradeId(String gradeId) async {
    final response = await _apiClient.get('/grades/$gradeId/sections');
    final data = response.data['data'] ?? response.data;
    if (data is List) {
      return data.map((json) => SectionModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<SectionModel> getById(String id) async {
    final response = await _apiClient.get('/sections/$id');
    final data = response.data['data'] ?? response.data;
    return SectionModel.fromJson(data as Map<String, dynamic>);
  }

  Future<SectionModel> create(SectionModel section) async {
    final payload = section.toJson()..remove('id')..remove('created_at');
    final response = await _apiClient.post('/sections', data: payload);
    final data = response.data['data'] ?? response.data;
    return SectionModel.fromJson(data as Map<String, dynamic>);
  }

  Future<SectionModel> update(SectionModel section) async {
    final payload = section.toJson()..remove('created_at');
    final response = await _apiClient.put('/sections/${section.id}', data: payload);
    final data = response.data['data'] ?? response.data;
    return SectionModel.fromJson(data as Map<String, dynamic>);
  }

  Future<bool> delete(String gradeId, String id) async {
    await _apiClient.delete('/sections/$id');
    return true;
  }

  Future<SectionModel> toggleStatus(String gradeId, String id) async {
    final section = await getById(id);
    final updated = section.copyWith(isActive: !section.isActive);
    return update(updated);
  }
}

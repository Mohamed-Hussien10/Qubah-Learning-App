import 'package:web_dashboard/core/network/api_client.dart';
import 'package:web_dashboard/features/subjects/data/models/subject_model.dart';

/// Repository handling CRUD operations for subjects within a section.
class SubjectsRepository {
  final ApiClient _apiClient;

  SubjectsRepository(this._apiClient);

  Future<List<SubjectModel>> getBySectionId(String sectionId) async {
    final response = await _apiClient.get('/sections/$sectionId/subjects');
    final data = response.data['data'] ?? response.data;
    if (data is List) {
      return data.map((json) => SubjectModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<SubjectModel> getById(String id) async {
    final response = await _apiClient.get('/subjects/$id');
    final data = response.data['data'] ?? response.data;
    return SubjectModel.fromJson(data as Map<String, dynamic>);
  }

  Future<SubjectModel> create(SubjectModel subject) async {
    final payload = subject.toJson()..remove('id')..remove('created_at');
    final response = await _apiClient.post('/subjects', data: payload);
    final data = response.data['data'] ?? response.data;
    return SubjectModel.fromJson(data as Map<String, dynamic>);
  }

  Future<SubjectModel> update(SubjectModel subject) async {
    final payload = subject.toJson()..remove('created_at');
    final response = await _apiClient.put('/subjects/${subject.id}', data: payload);
    final data = response.data['data'] ?? response.data;
    return SubjectModel.fromJson(data as Map<String, dynamic>);
  }

  Future<bool> delete(String sectionId, String id) async {
    await _apiClient.delete('/subjects/$id');
    return true;
  }

  Future<SubjectModel> toggleStatus(String sectionId, String id) async {
    final subject = await getById(id);
    final updated = subject.copyWith(isActive: !subject.isActive);
    return update(updated);
  }
}

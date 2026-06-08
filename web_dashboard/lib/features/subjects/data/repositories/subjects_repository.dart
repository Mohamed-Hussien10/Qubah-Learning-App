import 'package:web_dashboard/core/network/api_client.dart';
import 'package:web_dashboard/core/constants/api_endpoints.dart';
import 'package:web_dashboard/features/subjects/data/models/subject_model.dart';

/// Repository handling CRUD operations for subjects within a section.
class SubjectsRepository {
  final ApiClient _apiClient;

  SubjectsRepository(this._apiClient);

  Future<List<SubjectModel>> getBySectionId(String sectionId) async {
    final response = await _apiClient.get('/sections/$sectionId');
    final data = response.data['data'];
    final subjects = data?['subjects'];
    if (subjects is List) {
      return subjects
          .map((json) => SubjectModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<SubjectModel> getById(String id) async {
    final response = await _apiClient.get('/subjects/$id');
    final data = response.data['data'] ?? response.data;
    return SubjectModel.fromJson(data as Map<String, dynamic>);
  }

  Future<SubjectModel> create(SubjectModel subject, {List<int>? imageBytes, String? imageName}) async {
    final payload = subject.toJson()..remove('id')..remove('created_at');
    
    if (imageBytes != null && imageBytes.isNotEmpty && imageName != null) {
      final uploadRes = await _apiClient.uploadFileBytes(
        '/thumbnails/upload',
        fileBytes: imageBytes,
        fileName: imageName,
        fileFieldName: 'thumbnail',
        additionalFields: {'folder': 'subjects'},
      );
      payload['thumbnail_path'] = uploadRes.data['data']['path'];
    }

    final response = await _apiClient.post(ApiEndpoints.subjects, data: payload);
    final data = response.data['data'] ?? response.data;
    return SubjectModel.fromJson(data as Map<String, dynamic>);
  }

  Future<SubjectModel> update(SubjectModel subject, {List<int>? imageBytes, String? imageName}) async {
    final payload = subject.toJson()..remove('created_at');

    if (imageBytes != null && imageBytes.isNotEmpty && imageName != null) {
      final uploadRes = await _apiClient.uploadFileBytes(
        '/thumbnails/upload',
        fileBytes: imageBytes,
        fileName: imageName,
        fileFieldName: 'thumbnail',
        additionalFields: {'folder': 'subjects'},
      );
      payload['thumbnail_path'] = uploadRes.data['data']['path'];
    }

    final response = await _apiClient.put(ApiEndpoints.subject(int.parse(subject.id)), data: payload);
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
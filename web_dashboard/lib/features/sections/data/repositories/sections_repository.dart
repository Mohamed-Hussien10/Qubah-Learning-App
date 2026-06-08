import 'package:web_dashboard/core/network/api_client.dart';
import 'package:web_dashboard/core/constants/api_endpoints.dart';
import 'package:web_dashboard/features/sections/data/models/section_model.dart';

/// Repository handling CRUD operations for sections within a grade.
class SectionsRepository {
  final ApiClient _apiClient;

  SectionsRepository(this._apiClient);

  Future<List<SectionModel>> getByGradeId(String gradeId) async {
    final response = await _apiClient.get('/grades/$gradeId');
    final data = response.data['data'];
    final sections = data?['sections'];
    if (sections is List) {
      return sections
          .map((json) => SectionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<SectionModel> getById(String id) async {
    final response = await _apiClient.get('/sections/$id');
    final data = response.data['data'] ?? response.data;
    return SectionModel.fromJson(data as Map<String, dynamic>);
  }

  Future<SectionModel> create(SectionModel section, {List<int>? imageBytes, String? imageName}) async {
    final payload = section.toJson()..remove('id')..remove('created_at');
    
    if (imageBytes != null && imageBytes.isNotEmpty && imageName != null) {
      final uploadRes = await _apiClient.uploadFileBytes(
        '/thumbnails/upload',
        fileBytes: imageBytes,
        fileName: imageName,
        fileFieldName: 'thumbnail',
        additionalFields: {'folder': 'sections'},
      );
      payload['thumbnail_path'] = uploadRes.data['data']['path'];
    }

    final response = await _apiClient.post(ApiEndpoints.sections, data: payload);
    final data = response.data['data'] ?? response.data;
    return SectionModel.fromJson(data as Map<String, dynamic>);
  }

  Future<SectionModel> update(SectionModel section, {List<int>? imageBytes, String? imageName}) async {
    final payload = section.toJson()..remove('created_at');

    if (imageBytes != null && imageBytes.isNotEmpty && imageName != null) {
      final uploadRes = await _apiClient.uploadFileBytes(
        '/thumbnails/upload',
        fileBytes: imageBytes,
        fileName: imageName,
        fileFieldName: 'thumbnail',
        additionalFields: {'folder': 'sections'},
      );
      payload['thumbnail_path'] = uploadRes.data['data']['path'];
    }

    final response = await _apiClient.put(ApiEndpoints.section(int.parse(section.id)), data: payload);
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
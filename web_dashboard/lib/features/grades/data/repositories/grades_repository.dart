import 'package:web_dashboard/core/network/api_client.dart';
import 'package:web_dashboard/core/constants/api_endpoints.dart';
import 'package:web_dashboard/features/grades/data/models/grade_model.dart';

/// Repository handling CRUD operations for grades within a stage.
class GradesRepository {
  final ApiClient _apiClient;

  GradesRepository(this._apiClient);

  Future<List<GradeModel>> getByStageId(String stageId) async {
    final response = await _apiClient.get('/educational-stages/$stageId');
    final data = response.data['data'];
    final grades = data?['grades'];
    if (grades is List) {
      return grades
          .map((json) => GradeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<GradeModel> getById(String id) async {
    final response = await _apiClient.get('/grades/$id');
    final data = response.data['data'] ?? response.data;
    return GradeModel.fromJson(data as Map<String, dynamic>);
  }

  Future<GradeModel> create(GradeModel grade, {List<int>? imageBytes, String? imageName}) async {
    final payload = grade.toJson()..remove('id')..remove('created_at');
    
    if (imageBytes != null && imageBytes.isNotEmpty && imageName != null) {
      final uploadRes = await _apiClient.uploadFileBytes(
        '/thumbnails/upload',
        fileBytes: imageBytes,
        fileName: imageName,
        fileFieldName: 'thumbnail',
        additionalFields: {'folder': 'grades'},
      );
      payload['thumbnail_path'] = uploadRes.data['data']['path'];
    }

    final response = await _apiClient.post(ApiEndpoints.grades, data: payload);
    final data = response.data['data'] ?? response.data;
    return GradeModel.fromJson(data as Map<String, dynamic>);
  }

  Future<GradeModel> update(GradeModel grade, {List<int>? imageBytes, String? imageName}) async {
    final payload = grade.toJson()..remove('created_at');

    if (imageBytes != null && imageBytes.isNotEmpty && imageName != null) {
      final uploadRes = await _apiClient.uploadFileBytes(
        '/thumbnails/upload',
        fileBytes: imageBytes,
        fileName: imageName,
        fileFieldName: 'thumbnail',
        additionalFields: {'folder': 'grades'},
      );
      payload['thumbnail_path'] = uploadRes.data['data']['path'];
    }

    final response = await _apiClient.put(ApiEndpoints.grade(int.parse(grade.id)), data: payload);
    final data = response.data['data'] ?? response.data;
    return GradeModel.fromJson(data as Map<String, dynamic>);
  }

  Future<bool> delete(String stageId, String id) async {
    await _apiClient.delete('/grades/$id');
    return true;
  }

  Future<GradeModel> toggleStatus(String stageId, String id) async {
    final grade = await getById(id);
    final updated = grade.copyWith(isActive: !grade.isActive);
    return update(updated);
  }
}

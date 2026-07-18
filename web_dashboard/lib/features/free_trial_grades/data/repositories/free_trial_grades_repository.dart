import 'package:web_dashboard/core/network/api_client.dart';
import 'package:web_dashboard/core/constants/api_endpoints.dart';
import 'package:web_dashboard/features/free_trial_grades/data/models/free_trial_grade_model.dart';

/// Repository handling CRUD operations for free_trial_grades within a stage.
class FreeTrialGradesRepository {
  final ApiClient _apiClient;

  FreeTrialGradesRepository(this._apiClient);

  Future<List<FreeTrialGradeModel>> getByStageId(String stageId) async {
    final response = await _apiClient.get('/free-trial/stages/$stageId/grades');
    final data = response.data['data'];
    if (data is List) {
      return data
          .map((json) => FreeTrialGradeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<FreeTrialGradeModel> getById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.free_trial_grade(int.parse(id)));
    final data = response.data['data'] ?? response.data;
    return FreeTrialGradeModel.fromJson(data as Map<String, dynamic>);
  }

  Future<FreeTrialGradeModel> create(FreeTrialGradeModel free_trial_grade, {List<int>? imageBytes, String? imageName}) async {
    final payload = free_trial_grade.toJson()..remove('id')..remove('created_at');
    
    if (imageBytes != null && imageBytes.isNotEmpty && imageName != null) {
      final uploadRes = await _apiClient.uploadFileBytes(
        '/thumbnails/upload',
        fileBytes: imageBytes,
        fileName: imageName,
        fileFieldName: 'thumbnail',
        additionalFields: {'folder': 'free_trial_grades'},
      );
      payload['thumbnail_path'] = uploadRes.data['data']['path'];
    }

    final response = await _apiClient.post(ApiEndpoints.free_trial_grades, data: payload);
    final data = response.data['data'] ?? response.data;
    return FreeTrialGradeModel.fromJson(data as Map<String, dynamic>);
  }

  Future<FreeTrialGradeModel> update(FreeTrialGradeModel free_trial_grade, {List<int>? imageBytes, String? imageName}) async {
    final payload = free_trial_grade.toJson()..remove('created_at');

    if (imageBytes != null && imageBytes.isNotEmpty && imageName != null) {
      final uploadRes = await _apiClient.uploadFileBytes(
        '/thumbnails/upload',
        fileBytes: imageBytes,
        fileName: imageName,
        fileFieldName: 'thumbnail',
        additionalFields: {'folder': 'free_trial_grades'},
      );
      payload['thumbnail_path'] = uploadRes.data['data']['path'];
    }

    final response = await _apiClient.put(ApiEndpoints.free_trial_grade(int.parse(free_trial_grade.id)), data: payload);
    final data = response.data['data'] ?? response.data;
    return FreeTrialGradeModel.fromJson(data as Map<String, dynamic>);
  }

  Future<bool> delete(String stageId, String id) async {
    await _apiClient.delete(ApiEndpoints.free_trial_grade(int.parse(id)));
    return true;
  }

  Future<FreeTrialGradeModel> toggleStatus(String stageId, String id) async {
    final free_trial_grade = await getById(id);
    final updated = free_trial_grade.copyWith(isActive: !free_trial_grade.isActive);
    return update(updated);
  }
}

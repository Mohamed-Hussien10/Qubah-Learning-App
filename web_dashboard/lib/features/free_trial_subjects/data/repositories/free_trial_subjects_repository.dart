import 'package:web_dashboard/core/network/api_client.dart';
import 'package:web_dashboard/core/constants/api_endpoints.dart';
import 'package:web_dashboard/features/free_trial_subjects/data/models/free_trial_subject_model.dart';

/// Repository handling CRUD operations for free_trial_subjects within a grade.
class FreeTrialSubjectsRepository {
  final ApiClient _apiClient;

  FreeTrialSubjectsRepository(this._apiClient);

  Future<List<FreeTrialSubjectModel>> getByGradeId(String gradeId) async {
    final response = await _apiClient.get('/free-trial/grades/$gradeId/subjects');
    final data = response.data['data'];
    if (data is List) {
      return data
          .map((json) => FreeTrialSubjectModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<FreeTrialSubjectModel> getById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.freeTrialSubject(int.parse(id)));
    final data = response.data['data'] ?? response.data;
    return FreeTrialSubjectModel.fromJson(data as Map<String, dynamic>);
  }

  Future<FreeTrialSubjectModel> create(FreeTrialSubjectModel freeTrialSubject, {List<int>? imageBytes, String? imageName}) async {
    final payload = freeTrialSubject.toJson()..remove('id')..remove('created_at');
    
    if (imageBytes != null && imageBytes.isNotEmpty && imageName != null) {
      final uploadRes = await _apiClient.uploadFileBytes(
        '/thumbnails/upload',
        fileBytes: imageBytes,
        fileName: imageName,
        fileFieldName: 'thumbnail',
        additionalFields: {'folder': 'free_trial_subjects'},
      );
      payload['thumbnail_path'] = uploadRes.data['data']['path'];
    }

    final response = await _apiClient.post(ApiEndpoints.freeTrialSubjects, data: payload);
    final data = response.data['data'] ?? response.data;
    return FreeTrialSubjectModel.fromJson(data as Map<String, dynamic>);
  }

  Future<FreeTrialSubjectModel> update(FreeTrialSubjectModel freeTrialSubject, {List<int>? imageBytes, String? imageName}) async {
    final payload = freeTrialSubject.toJson()..remove('created_at');

    if (imageBytes != null && imageBytes.isNotEmpty && imageName != null) {
      final uploadRes = await _apiClient.uploadFileBytes(
        '/thumbnails/upload',
        fileBytes: imageBytes,
        fileName: imageName,
        fileFieldName: 'thumbnail',
        additionalFields: {'folder': 'free_trial_subjects'},
      );
      payload['thumbnail_path'] = uploadRes.data['data']['path'];
    }

    final response = await _apiClient.put(ApiEndpoints.freeTrialSubject(int.parse(freeTrialSubject.id)), data: payload);
    final data = response.data['data'] ?? response.data;
    return FreeTrialSubjectModel.fromJson(data as Map<String, dynamic>);
  }

  Future<bool> delete(String gradeId, String id) async {
    await _apiClient.delete(ApiEndpoints.freeTrialSubject(int.parse(id)));
    return true;
  }

  Future<FreeTrialSubjectModel> toggleStatus(String gradeId, String id) async {
    final freeTrialSubject = await getById(id);
    final updated = freeTrialSubject.copyWith(isActive: !freeTrialSubject.isActive);
    return update(updated);
  }
}
import 'package:web_dashboard/core/network/api_client.dart';
import 'package:web_dashboard/core/constants/api_endpoints.dart';
import 'package:web_dashboard/features/lessons/data/models/lesson_model.dart';

/// Repository handling CRUD operations for lessons within a unit.
class LessonsRepository {
  final ApiClient _apiClient;

  LessonsRepository(this._apiClient);

  Future<List<LessonModel>> getByUnitId(String unitId) async {
    final response = await _apiClient.get('/units/$unitId');
    final data = response.data['data'];
    final lessons = data?['lessons'];
    if (lessons is List) {
      return lessons
          .map((json) => LessonModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<LessonModel> getById(String id) async {
    final response = await _apiClient.get('/lessons/$id');
    final data = response.data['data'] ?? response.data;
    return LessonModel.fromJson(data as Map<String, dynamic>);
  }

  Future<LessonModel> create(LessonModel lesson, {List<int>? imageBytes, String? imageName}) async {
    final payload = lesson.toJson()..remove('id')..remove('created_at');
    
    if (imageBytes != null && imageBytes.isNotEmpty && imageName != null) {
      final uploadRes = await _apiClient.uploadFileBytes(
        '/thumbnails/upload',
        fileBytes: imageBytes,
        fileName: imageName,
        fileFieldName: 'thumbnail',
        additionalFields: {'folder': 'lessons'},
      );
      payload['thumbnail_path'] = uploadRes.data['data']['path'];
    }

    final response = await _apiClient.post(ApiEndpoints.lessons, data: payload);
    final data = response.data['data'] ?? response.data;
    return LessonModel.fromJson(data as Map<String, dynamic>);
  }

  Future<LessonModel> update(LessonModel lesson, {List<int>? imageBytes, String? imageName}) async {
    final payload = lesson.toJson()..remove('created_at');

    if (imageBytes != null && imageBytes.isNotEmpty && imageName != null) {
      final uploadRes = await _apiClient.uploadFileBytes(
        '/thumbnails/upload',
        fileBytes: imageBytes,
        fileName: imageName,
        fileFieldName: 'thumbnail',
        additionalFields: {'folder': 'lessons'},
      );
      payload['thumbnail_path'] = uploadRes.data['data']['path'];
    }

    final response = await _apiClient.put(ApiEndpoints.lesson(int.parse(lesson.id)), data: payload);
    final data = response.data['data'] ?? response.data;
    return LessonModel.fromJson(data as Map<String, dynamic>);
  }

  Future<bool> delete(String unitId, String id) async {
    await _apiClient.delete('/lessons/$id');
    return true;
  }

  Future<LessonModel> toggleStatus(String unitId, String id) async {
    final lesson = await getById(id);
    final updated = lesson.copyWith(isActive: !lesson.isActive);
    return update(updated);
  }
}
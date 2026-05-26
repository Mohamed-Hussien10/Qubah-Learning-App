import 'package:web_dashboard/core/network/api_client.dart';
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

  Future<LessonModel> create(LessonModel lesson) async {
    final payload = lesson.toJson()..remove('id')..remove('created_at');
    final response = await _apiClient.post('/lessons', data: payload);
    final data = response.data['data'] ?? response.data;
    return LessonModel.fromJson(data as Map<String, dynamic>);
  }

  Future<LessonModel> update(LessonModel lesson) async {
    final payload = lesson.toJson()..remove('created_at');
    final response = await _apiClient.put('/lessons/${lesson.id}', data: payload);
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

  Future<LessonModel> togglePublishStatus(String unitId, String id) async {
    final lesson = await getById(id);
    final updated = lesson.copyWith(isPublished: !lesson.isPublished);
    return update(updated);
  }
}
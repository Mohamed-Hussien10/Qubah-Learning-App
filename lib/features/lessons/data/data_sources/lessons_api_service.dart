import '../../../../core/network/dio_client.dart';
import '../models/lesson_model.dart';

class LessonsApiService {
  final DioClient _dioClient;
  LessonsApiService(this._dioClient);

  Future<List<LessonModel>> getLessons(String parentId) async {
    final response = await _dioClient.get('/units/$parentId');
    return (response.data['data']['lessons'] as List)
        .map((e) => LessonModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

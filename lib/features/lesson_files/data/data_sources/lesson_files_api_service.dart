import 'package:dio/dio.dart';
import '../models/lesson_file_model.dart';

class LessonFilesApiService {
  final Dio dio;

  LessonFilesApiService(this.dio);

  Future<List<LessonFileModel>> getLessonFiles(String parentId) async {
    final response = await dio.get('/lessons/$parentId');
    return (response.data['data']['lessonFiles'] as List)
        .map((e) => LessonFileModel.fromJson(e))
        .toList();
  }
}

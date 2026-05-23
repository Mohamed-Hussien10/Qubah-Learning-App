import 'package:dio/dio.dart';
import '../models/grade_model.dart';

class GradesApiService {
  final Dio dio;

  GradesApiService(this.dio);

  Future<List<GradeModel>> getGrades(String parentId) async {
    final response = await dio.get('/educational-stages/$parentId');
    return (response.data['data']['grades'] as List)
        .map((e) => GradeModel.fromJson(e))
        .toList();
  }
}

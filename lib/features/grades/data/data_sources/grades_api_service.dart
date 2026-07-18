import 'package:dio/dio.dart';
import '../models/grade_model.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/services/dependency_injection.dart';

class GradesApiService {
  final Dio dio;

  GradesApiService(this.dio);

  Future<List<GradeModel>> getGrades(String parentId) async {
    final isGuest = await sl<SecureStorage>().isGuest();
    final endpoint = isGuest ? '/free-trial/stages/$parentId/grades' : '/educational-stages/$parentId';
    final response = await dio.get(endpoint);
    
    final list = isGuest 
        ? response.data['data'] as List
        : response.data['data']['grades'] as List;
        
    return list
        .map((e) => GradeModel.fromJson(e))
        .toList();
  }
}

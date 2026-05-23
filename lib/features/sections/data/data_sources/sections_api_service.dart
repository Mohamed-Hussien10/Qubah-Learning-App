import 'package:dio/dio.dart';
import '../models/section_model.dart';

class SectionsApiService {
  final Dio dio;

  SectionsApiService(this.dio);

  Future<List<SectionModel>> getSections(String parentId) async {
    final response = await dio.get('/grades/$parentId');
    return (response.data['data']['sections'] as List)
        .map((e) => SectionModel.fromJson(e))
        .toList();
  }
}

import 'package:dio/dio.dart';
import '../models/unit_model.dart';

class UnitsApiService {
  final Dio dio;

  UnitsApiService(this.dio);

  Future<List<UnitModel>> getUnits(String parentId) async {
    final response = await dio.get('/subjects/$parentId');
    return (response.data['data']['units'] as List)
        .map((e) => UnitModel.fromJson(e))
        .toList();
  }
}

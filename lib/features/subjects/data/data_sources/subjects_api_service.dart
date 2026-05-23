import '../../../../core/network/dio_client.dart';
import '../models/subject_model.dart';

class SubjectsApiService {
  final DioClient _dioClient;
  SubjectsApiService(this._dioClient);

  Future<List<SubjectModel>> getSubjects(String parentId) async {
    final response = await _dioClient.get('/sections/$parentId');
    return (response.data['data']['subjects'] as List)
        .map((e) => SubjectModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

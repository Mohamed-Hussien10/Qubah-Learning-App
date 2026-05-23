import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/subject_entity.dart';
import '../../domain/repositories/subjects_repository.dart';
import '../data_sources/subjects_api_service.dart';

class SubjectsRepositoryImpl implements SubjectsRepository {
  final SubjectsApiService _apiService;
  final NetworkInfo _networkInfo;

  SubjectsRepositoryImpl({
    required SubjectsApiService apiService,
    required NetworkInfo networkInfo,
  }) : _apiService = apiService,
       _networkInfo = networkInfo;

  @override
  Future<List<SubjectEntity>> getSubjects(String stageId) async {
    if (!await _networkInfo.isConnected) throw const NetworkException();
    final models = await _apiService.getSubjects(stageId);
    return models.map((m) => m.toEntity()).toList();
  }
}

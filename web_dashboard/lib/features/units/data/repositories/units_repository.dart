import 'package:web_dashboard/core/network/api_client.dart';
import 'package:web_dashboard/core/constants/api_endpoints.dart';
import 'package:web_dashboard/features/units/data/models/unit_model.dart';

/// Repository handling CRUD operations for educational units within a subject.
class UnitsRepository {
  final ApiClient _apiClient;

  UnitsRepository(this._apiClient);

  Future<List<UnitModel>> getBySubjectId(String subjectId) async {
    final response = await _apiClient.get('/subjects/$subjectId');
    final data = response.data['data'];
    final units = data?['units'];
    if (units is List) {
      return units
          .map((json) => UnitModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<UnitModel> getById(String id) async {
    final response = await _apiClient.get('/units/$id');
    final data = response.data['data'] ?? response.data;
    return UnitModel.fromJson(data as Map<String, dynamic>);
  }

  Future<UnitModel> create(UnitModel unit, {List<int>? imageBytes, String? imageName}) async {
    final payload = unit.toJson()..remove('id')..remove('created_at');
    
    if (imageBytes != null && imageBytes.isNotEmpty && imageName != null) {
      final uploadRes = await _apiClient.uploadFileBytes(
        '/thumbnails/upload',
        fileBytes: imageBytes,
        fileName: imageName,
        fileFieldName: 'thumbnail',
        additionalFields: {'folder': 'units'},
      );
      payload['thumbnail_path'] = uploadRes.data['data']['path'];
    }

    final response = await _apiClient.post(ApiEndpoints.units, data: payload);
    final data = response.data['data'] ?? response.data;
    return UnitModel.fromJson(data as Map<String, dynamic>);
  }

  Future<UnitModel> update(UnitModel unit, {List<int>? imageBytes, String? imageName}) async {
    final payload = unit.toJson()..remove('created_at');

    if (imageBytes != null && imageBytes.isNotEmpty && imageName != null) {
      final uploadRes = await _apiClient.uploadFileBytes(
        '/thumbnails/upload',
        fileBytes: imageBytes,
        fileName: imageName,
        fileFieldName: 'thumbnail',
        additionalFields: {'folder': 'units'},
      );
      payload['thumbnail_path'] = uploadRes.data['data']['path'];
    }

    final response = await _apiClient.put(ApiEndpoints.unit(int.parse(unit.id)), data: payload);
    final data = response.data['data'] ?? response.data;
    return UnitModel.fromJson(data as Map<String, dynamic>);
  }

  Future<bool> delete(String subjectId, String id) async {
    await _apiClient.delete('/units/$id');
    return true;
  }

  Future<UnitModel> toggleStatus(String subjectId, String id) async {
    final unit = await getById(id);
    final updated = unit.copyWith(isActive: !unit.isActive);
    return update(updated);
  }
}
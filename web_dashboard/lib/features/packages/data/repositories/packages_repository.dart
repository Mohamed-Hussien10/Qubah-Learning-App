import 'package:web_dashboard/core/constants/api_endpoints.dart';
import 'package:web_dashboard/core/network/api_client.dart';
import 'package:web_dashboard/features/packages/data/models/package_model.dart';

/// Repository handling API calls for subscription packages.
class PackagesRepository {
  final ApiClient _apiClient;

  PackagesRepository(this._apiClient);

  Future<List<PackageModel>> getPackages({String? search, bool? isActive}) async {
    final Map<String, dynamic> queryParams = {};
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (isActive != null) {
      queryParams['is_active'] = isActive;
    }

    final response = await _apiClient.get(
      ApiEndpoints.packages,
      queryParameters: queryParams,
    );

    final data = response.data['data'] ?? response.data;
    if (data is List) {
      return data
          .map((json) => PackageModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<PackageModel> getById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.package(id));
    final data = response.data['data'] ?? response.data;
    return PackageModel.fromJson(data as Map<String, dynamic>);
  }

  Future<PackageModel> create(PackageModel package) async {
    final payload = package.toJson()..remove('id');
    final response = await _apiClient.post(
      ApiEndpoints.packages,
      data: payload,
    );
    final data = response.data['data'] ?? response.data;
    return PackageModel.fromJson(data as Map<String, dynamic>);
  }

  Future<PackageModel> update(PackageModel package) async {
    final payload = package.toJson();
    final response = await _apiClient.put(
      ApiEndpoints.package(package.id),
      data: payload,
    );
    final data = response.data['data'] ?? response.data;
    return PackageModel.fromJson(data as Map<String, dynamic>);
  }

  Future<bool> delete(String id) async {
    await _apiClient.delete(ApiEndpoints.package(id));
    return true;
  }
}

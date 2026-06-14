import 'package:web_dashboard/core/network/api_client.dart';
import 'package:web_dashboard/features/users/data/models/user_model.dart';

class UsersRepository {
  final ApiClient _apiClient;

  UsersRepository(this._apiClient);

  Future<List<UserModel>> getAll() async {
    final response = await _apiClient.get('/users');
    final data = response.data['data'] ?? response.data;
    if (data is List) {
      return data.map((json) => UserModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<UserModel?> getById(int id) async {
    try {
      final response = await _apiClient.get('/users/$id');
      final data = response.data['data'] ?? response.data;
      return UserModel.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<UserModel> create({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    bool isActive = true,
    int? stageId,
    int? gradeId,
    DateTime? subscriptionExpiry,
  }) async {
    final payload = {
      'name': name,
      'email': email,
      'password': password,
      'role': role.name,
      'is_active': isActive,
      if (stageId != null) 'stage_id': stageId,
      if (gradeId != null) 'grade_id': gradeId,
      if (subscriptionExpiry != null) 'subscription_expiry': subscriptionExpiry.toIso8601String(),
    };
    final response = await _apiClient.post('/users', data: payload);
    final data = response.data['data'] ?? response.data;
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<UserModel> update(UserModel user) async {
    final payload = user.toJson()..remove('created_at')..remove('last_login');
    final response = await _apiClient.put('/users/${user.id}', data: payload);
    final data = response.data['data'] ?? response.data;
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _apiClient.delete('/users/$id');
  }

  Future<UserModel> toggleStatus(int id) async {
    final response = await _apiClient.post('/users/$id/toggle-status');
    final data = response.data['data'] ?? response.data;
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<UserModel> assignSubscription(int userId, String subscriptionStatus) async {
    final response = await _apiClient.post(
      '/users/$userId/assign-subscription',
      data: {'subscription_status': subscriptionStatus},
    );
    final data = response.data['data'] ?? response.data;
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<UserModel>> searchUsers(String query) async {
    final response = await _apiClient.get('/users', queryParameters: {'search': query});
    final data = response.data['data'] ?? response.data;
    if (data is List) {
      return data.map((json) => UserModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<UserModel>> filterByRole(UserRole? role) async {
    final Map<String, dynamic> params = {};
    if (role != null) {
      params['role'] = role.name;
    }
    final response = await _apiClient.get('/users', queryParameters: params);
    final data = response.data['data'] ?? response.data;
    if (data is List) {
      return data.map((json) => UserModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }
}

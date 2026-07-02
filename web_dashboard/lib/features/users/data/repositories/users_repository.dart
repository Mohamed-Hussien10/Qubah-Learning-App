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
  }) async {
    final payload = {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
      'role': role.name,
      'is_active': isActive ? 1 : 0,
      if (stageId != null) 'stage_id': stageId,
      if (gradeId != null) 'grade_id': gradeId,
    };
    
    print('DEBUG: Creating user with payload: $payload');
    
    try {
      final response = await _apiClient.post('/users', data: payload);
      print('DEBUG: Create user response data: ${response.data}');
      
      final data = response.data['data'] ?? response.data;
      return UserModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      print('DEBUG: Create user ERROR: $e');
      rethrow;
    }
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

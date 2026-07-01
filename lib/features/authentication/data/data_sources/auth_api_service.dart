import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';
import 'package:qubah_learning_app/core/errors/error_handler.dart';

/// Remote data source for authentication API calls.
class AuthApiService {
  final DioClient _dioClient;
  AuthApiService(this._dioClient);

  /// Authenticates user with email/password. Returns [UserModel] and tokens.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    print('DEBUG: Attempting login with email: $email');
    try {
      final response = await _dioClient.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      print('DEBUG: Login response data: ${response.data}');
      final data = response.data as Map<String, dynamic>;
      return {
        'user': UserModel.fromJson(
          data['data']['user'] as Map<String, dynamic>,
        ),
        'access_token': data['data']['access_token'] as String,
        'refresh_token': data['data']['refresh_token'] as String,
      };
    } catch (e) {
      print('DEBUG: Login ERROR: $e');
      if (e is ServerException ||
          e is NetworkException ||
          e is AuthenticationException)
        rethrow;
      throw ServerException(message: ErrorHandler.handle(e));
    }
  }

  /// Logs out the user on the server side.
  Future<void> logout() async {
    try {
      await _dioClient.post(ApiEndpoints.logout);
    } catch (e) {
      // Logout should succeed locally even if server call fails
    }
  }
}

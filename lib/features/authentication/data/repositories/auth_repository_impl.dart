import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_api_service.dart';
import '../data_sources/auth_local_service.dart';
import '../models/user_model.dart';

/// Implementation of [AuthRepository] connecting data sources to domain.
class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _apiService;
  final AuthLocalService _localService;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl({
    required AuthApiService apiService,
    required AuthLocalService localService,
    required NetworkInfo networkInfo,
  }) : _apiService = apiService,
       _localService = localService,
       _networkInfo = networkInfo;

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected) {
      throw const NetworkException();
    }
    final result = await _apiService.login(email: email, password: password);
    final user = result['user'] as UserModel;
    final accessToken = result['access_token'] as String;
    final refreshToken = result['refresh_token'] as String;

    // Cache tokens and user locally
    await _localService.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await _localService.saveUser(user);

    return user.toEntity();
  }

  @override
  Future<void> logout() async {
    await _apiService.logout();
    await _localService.clearAuth();
  }

  @override
  Future<UserEntity?> getCachedUser() async {
    final user = await _localService.getCachedUser();
    return user?.toEntity();
  }

  @override
  Future<bool> isAuthenticated() async {
    return _localService.isAuthenticated();
  }
}

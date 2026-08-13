import '../../../../core/utils/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for user login.
class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  final AuthRepository _repository;
  LoginUseCase(this._repository);

  @override
  Future<UserEntity> call(LoginParams params) {
    return _repository.login(username: params.username, password: params.password);
  }
}

/// Parameters for the login use case.
class LoginParams {
  final String username;
  final String password;
  const LoginParams({required this.username, required this.password});
}

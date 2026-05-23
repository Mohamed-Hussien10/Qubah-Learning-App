import '../../../../core/utils/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for user login.
class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  final AuthRepository _repository;
  LoginUseCase(this._repository);

  @override
  Future<UserEntity> call(LoginParams params) {
    return _repository.login(email: params.email, password: params.password);
  }
}

/// Parameters for the login use case.
class LoginParams {
  final String email;
  final String password;
  const LoginParams({required this.email, required this.password});
}

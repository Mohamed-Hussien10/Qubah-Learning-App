import '../../../../core/utils/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case for user logout.
class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository _repository;
  LogoutUseCase(this._repository);

  @override
  Future<void> call(NoParams params) {
    return _repository.logout();
  }
}

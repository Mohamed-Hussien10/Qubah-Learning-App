import 'package:equatable/equatable.dart';

/// Base use case contract. All use cases must implement this.
/// [Type] is the return type, [Params] is the parameter type.
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Used when a use case does not require any parameters.
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Generic pagination parameters.
class PaginationParams extends Equatable {
  final int page;
  final int limit;

  const PaginationParams({this.page = 1, this.limit = 20});

  @override
  List<Object?> get props => [page, limit];
}

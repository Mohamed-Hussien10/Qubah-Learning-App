import '../../../domain/entities/unit_entity.dart';

abstract class UnitsState {}

class UnitsInitial extends UnitsState {}

class UnitsLoading extends UnitsState {}

class UnitsLoaded extends UnitsState {
  final List<UnitEntity> units;
  UnitsLoaded(this.units);
}

class UnitsError extends UnitsState {
  final String message;
  UnitsError(this.message);
}

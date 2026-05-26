import 'package:equatable/equatable.dart';
import 'package:web_dashboard/features/units/data/models/unit_model.dart';

abstract class UnitsState extends Equatable {
  const UnitsState();

  @override
  List<Object?> get props => [];
}

class UnitsInitial extends UnitsState {
  const UnitsInitial();
}

class UnitsLoading extends UnitsState {
  const UnitsLoading();
}

class UnitsLoaded extends UnitsState {
  final List<UnitModel> units;
  final List<UnitModel> filteredUnits;
  final String subjectId;
  final String subjectName;
  final String searchQuery;

  const UnitsLoaded({
    required this.units,
    required this.filteredUnits,
    required this.subjectId,
    required this.subjectName,
    this.searchQuery = '',
  });

  UnitsLoaded copyWith({
    List<UnitModel>? units,
    List<UnitModel>? filteredUnits,
    String? subjectId,
    String? subjectName,
    String? searchQuery,
  }) {
    return UnitsLoaded(
      units: units ?? this.units,
      filteredUnits: filteredUnits ?? this.filteredUnits,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [units, filteredUnits, subjectId, subjectName, searchQuery];
}

class UnitsError extends UnitsState {
  final String message;

  const UnitsError(this.message);

  @override
  List<Object?> get props => [message];
}

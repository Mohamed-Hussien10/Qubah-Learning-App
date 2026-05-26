import 'package:equatable/equatable.dart';
import 'package:web_dashboard/features/grades/data/models/grade_model.dart';

abstract class GradesState extends Equatable {
  const GradesState();
  @override
  List<Object?> get props => [];
}

class GradesInitial extends GradesState {
  const GradesInitial();
}

class GradesLoading extends GradesState {
  const GradesLoading();
}

class GradesLoaded extends GradesState {
  final List<GradeModel> grades;
  final List<GradeModel> filteredGrades;
  final String searchQuery;
  final String stageId;
  final String stageName;

  const GradesLoaded({
    required this.grades,
    required this.filteredGrades,
    this.searchQuery = '',
    required this.stageId,
    this.stageName = '',
  });

  @override
  List<Object?> get props =>
      [grades, filteredGrades, searchQuery, stageId, stageName];

  GradesLoaded copyWith({
    List<GradeModel>? grades,
    List<GradeModel>? filteredGrades,
    String? searchQuery,
    String? stageId,
    String? stageName,
  }) {
    return GradesLoaded(
      grades: grades ?? this.grades,
      filteredGrades: filteredGrades ?? this.filteredGrades,
      searchQuery: searchQuery ?? this.searchQuery,
      stageId: stageId ?? this.stageId,
      stageName: stageName ?? this.stageName,
    );
  }
}

class GradesError extends GradesState {
  final String message;
  const GradesError(this.message);
  @override
  List<Object?> get props => [message];
}

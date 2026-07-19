import 'package:equatable/equatable.dart';
import 'package:web_dashboard/features/free_trial_grades/data/models/free_trial_grade_model.dart';

abstract class FreeTrialGradesState extends Equatable {
  const FreeTrialGradesState();
  @override
  List<Object?> get props => [];
}

class FreeTrialGradesInitial extends FreeTrialGradesState {
  const FreeTrialGradesInitial();
}

class FreeTrialGradesLoading extends FreeTrialGradesState {
  const FreeTrialGradesLoading();
}

class FreeTrialGradesLoaded extends FreeTrialGradesState {
  final List<FreeTrialGradeModel> freeTrialGrades;
  final List<FreeTrialGradeModel> filteredFreeTrialGrades;
  final String searchQuery;
  final String stageId;
  final String stageName;

  const FreeTrialGradesLoaded({
    required this.freeTrialGrades,
    required this.filteredFreeTrialGrades,
    this.searchQuery = '',
    required this.stageId,
    this.stageName = '',
  });

  @override
  List<Object?> get props =>
      [freeTrialGrades, filteredFreeTrialGrades, searchQuery, stageId, stageName];

  FreeTrialGradesLoaded copyWith({
    List<FreeTrialGradeModel>? freeTrialGrades,
    List<FreeTrialGradeModel>? filteredFreeTrialGrades,
    String? searchQuery,
    String? stageId,
    String? stageName,
  }) {
    return FreeTrialGradesLoaded(
      freeTrialGrades: freeTrialGrades ?? this.freeTrialGrades,
      filteredFreeTrialGrades: filteredFreeTrialGrades ?? this.filteredFreeTrialGrades,
      searchQuery: searchQuery ?? this.searchQuery,
      stageId: stageId ?? this.stageId,
      stageName: stageName ?? this.stageName,
    );
  }
}

class FreeTrialGradesError extends FreeTrialGradesState {
  final String message;
  const FreeTrialGradesError(this.message);
  @override
  List<Object?> get props => [message];
}

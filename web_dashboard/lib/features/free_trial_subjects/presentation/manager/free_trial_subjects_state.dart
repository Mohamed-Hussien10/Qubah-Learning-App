import 'package:equatable/equatable.dart';
import 'package:web_dashboard/features/free_trial_subjects/data/models/free_trial_subject_model.dart';

abstract class FreeTrialSubjectsState extends Equatable {
  const FreeTrialSubjectsState();
  @override
  List<Object?> get props => [];
}

class FreeTrialSubjectsInitial extends FreeTrialSubjectsState {
  const FreeTrialSubjectsInitial();
}

class FreeTrialSubjectsLoading extends FreeTrialSubjectsState {
  const FreeTrialSubjectsLoading();
}

class FreeTrialSubjectsLoaded extends FreeTrialSubjectsState {
  final List<FreeTrialSubjectModel> free_trial_subjects;
  final List<FreeTrialSubjectModel> filteredFreeTrialSubjects;
  final String searchQuery;
  final String gradeId;
  final String gradeName;

  const FreeTrialSubjectsLoaded({
    required this.free_trial_subjects,
    required this.filteredFreeTrialSubjects,
    this.searchQuery = '',
    required this.gradeId,
    this.gradeName = '',
  });

  @override
  List<Object?> get props =>
      [free_trial_subjects, filteredFreeTrialSubjects, searchQuery, gradeId, gradeName];

  FreeTrialSubjectsLoaded copyWith({
    List<FreeTrialSubjectModel>? free_trial_subjects,
    List<FreeTrialSubjectModel>? filteredFreeTrialSubjects,
    String? searchQuery,
    String? gradeId,
    String? gradeName,
  }) {
    return FreeTrialSubjectsLoaded(
      free_trial_subjects: free_trial_subjects ?? this.free_trial_subjects,
      filteredFreeTrialSubjects: filteredFreeTrialSubjects ?? this.filteredFreeTrialSubjects,
      searchQuery: searchQuery ?? this.searchQuery,
      gradeId: gradeId ?? this.gradeId,
      gradeName: gradeName ?? this.gradeName,
    );
  }
}

class FreeTrialSubjectsError extends FreeTrialSubjectsState {
  final String message;
  const FreeTrialSubjectsError(this.message);
  @override
  List<Object?> get props => [message];
}

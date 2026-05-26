import 'package:equatable/equatable.dart';
import 'package:web_dashboard/features/subjects/data/models/subject_model.dart';

abstract class SubjectsState extends Equatable {
  const SubjectsState();
  @override
  List<Object?> get props => [];
}

class SubjectsInitial extends SubjectsState {
  const SubjectsInitial();
}

class SubjectsLoading extends SubjectsState {
  const SubjectsLoading();
}

class SubjectsLoaded extends SubjectsState {
  final List<SubjectModel> subjects;
  final List<SubjectModel> filteredSubjects;
  final String searchQuery;
  final String sectionId;
  final String sectionName;

  const SubjectsLoaded({
    required this.subjects,
    required this.filteredSubjects,
    this.searchQuery = '',
    required this.sectionId,
    this.sectionName = '',
  });

  @override
  List<Object?> get props =>
      [subjects, filteredSubjects, searchQuery, sectionId, sectionName];

  SubjectsLoaded copyWith({
    List<SubjectModel>? subjects,
    List<SubjectModel>? filteredSubjects,
    String? searchQuery,
    String? sectionId,
    String? sectionName,
  }) {
    return SubjectsLoaded(
      subjects: subjects ?? this.subjects,
      filteredSubjects: filteredSubjects ?? this.filteredSubjects,
      searchQuery: searchQuery ?? this.searchQuery,
      sectionId: sectionId ?? this.sectionId,
      sectionName: sectionName ?? this.sectionName,
    );
  }
}

class SubjectsError extends SubjectsState {
  final String message;
  const SubjectsError(this.message);
  @override
  List<Object?> get props => [message];
}

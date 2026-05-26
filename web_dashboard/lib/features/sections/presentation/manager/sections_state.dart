import 'package:equatable/equatable.dart';
import 'package:web_dashboard/features/sections/data/models/section_model.dart';

abstract class SectionsState extends Equatable {
  const SectionsState();
  @override
  List<Object?> get props => [];
}

class SectionsInitial extends SectionsState {
  const SectionsInitial();
}

class SectionsLoading extends SectionsState {
  const SectionsLoading();
}

class SectionsLoaded extends SectionsState {
  final List<SectionModel> sections;
  final List<SectionModel> filteredSections;
  final String searchQuery;
  final String gradeId;
  final String gradeName;

  const SectionsLoaded({
    required this.sections,
    required this.filteredSections,
    this.searchQuery = '',
    required this.gradeId,
    this.gradeName = '',
  });

  @override
  List<Object?> get props =>
      [sections, filteredSections, searchQuery, gradeId, gradeName];

  SectionsLoaded copyWith({
    List<SectionModel>? sections,
    List<SectionModel>? filteredSections,
    String? searchQuery,
    String? gradeId,
    String? gradeName,
  }) {
    return SectionsLoaded(
      sections: sections ?? this.sections,
      filteredSections: filteredSections ?? this.filteredSections,
      searchQuery: searchQuery ?? this.searchQuery,
      gradeId: gradeId ?? this.gradeId,
      gradeName: gradeName ?? this.gradeName,
    );
  }
}

class SectionsError extends SectionsState {
  final String message;
  const SectionsError(this.message);
  @override
  List<Object?> get props => [message];
}

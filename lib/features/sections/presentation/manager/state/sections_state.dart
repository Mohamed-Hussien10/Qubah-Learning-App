import '../../../domain/entities/section_entity.dart';

abstract class SectionsState {}

class SectionsInitial extends SectionsState {}

class SectionsLoading extends SectionsState {}

class SectionsLoaded extends SectionsState {
  final List<SectionEntity> sections;
  SectionsLoaded(this.sections);
}

class SectionsError extends SectionsState {
  final String message;
  SectionsError(this.message);
}

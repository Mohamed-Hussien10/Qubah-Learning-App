import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dashboard/features/sections/data/models/section_model.dart';
import 'package:web_dashboard/features/subjects/data/models/subject_model.dart';
import 'package:web_dashboard/features/subjects/data/repositories/subjects_repository.dart';
import 'package:web_dashboard/features/subjects/presentation/manager/subjects_state.dart';
import 'package:web_dashboard/core/errors/error_handler.dart';

class SubjectsCubit extends Cubit<SubjectsState> {
  final SubjectsRepository _repository;
  late String _sectionId;

  SubjectsCubit({required SubjectsRepository repository})
      : _repository = repository,
        super(const SubjectsInitial());

  Future<void> loadSubjects(String sectionId) async {
    _sectionId = sectionId;
    emit(const SubjectsLoading());
    try {
      final subjects = await _repository.getBySectionId(sectionId);
      String sectionName = 'القسم';
      for (final sections in SectionModel.dummyMap.values) {
        for (final s in sections) {
          if (s.id == sectionId) {
            sectionName = s.title;
            break;
          }
        }
      }
      emit(SubjectsLoaded(
        subjects: subjects,
        filteredSubjects: subjects,
        sectionId: sectionId,
        sectionName: sectionName,
      ));
    } catch (e) {
      emit(SubjectsError(ErrorHandler.handle(e)));
    }
  }

  Future<void> createSubject(SubjectModel subject, {List<int>? imageBytes, String? imageName}) async {
    try {
      await _repository.create(subject, imageBytes: imageBytes, imageName: imageName);
      await loadSubjects(_sectionId);
    } catch (e) {
      emit(SubjectsError(ErrorHandler.handle(e)));
    }
  }

  Future<void> updateSubject(SubjectModel subject, {List<int>? imageBytes, String? imageName}) async {
    try {
      await _repository.update(subject, imageBytes: imageBytes, imageName: imageName);
      await loadSubjects(_sectionId);
    } catch (e) {
      emit(SubjectsError(ErrorHandler.handle(e)));
    }
  }

  Future<void> deleteSubject(String id) async {
    try {
      await _repository.delete(_sectionId, id);
      await loadSubjects(_sectionId);
    } catch (e) {
      emit(SubjectsError(ErrorHandler.handle(e)));
    }
  }

  Future<void> toggleStatus(String id) async {
    try {
      await _repository.toggleStatus(_sectionId, id);
      await loadSubjects(_sectionId);
    } catch (e) {
      emit(SubjectsError(ErrorHandler.handle(e)));
    }
  }

  void search(String query) {
    final currentState = state;
    if (currentState is SubjectsLoaded) {
      if (query.isEmpty) {
        emit(currentState.copyWith(
          filteredSubjects: currentState.subjects,
          searchQuery: '',
        ));
      } else {
        final filtered = currentState.subjects.where((s) {
          final q = query.toLowerCase();
          return s.title.toLowerCase().contains(q) ||
              (s.description?.toLowerCase().contains(q) ?? false);
        }).toList();
        emit(currentState.copyWith(
          filteredSubjects: filtered,
          searchQuery: query,
        ));
      }
    }
  }
}

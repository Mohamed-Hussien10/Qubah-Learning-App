import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dashboard/features/grades/data/models/grade_model.dart';
import 'package:web_dashboard/features/sections/data/models/section_model.dart';
import 'package:web_dashboard/features/sections/data/repositories/sections_repository.dart';
import 'package:web_dashboard/features/sections/presentation/manager/sections_state.dart';
import 'package:web_dashboard/core/errors/error_handler.dart';

class SectionsCubit extends Cubit<SectionsState> {
  final SectionsRepository _repository;
  late String _gradeId;

  SectionsCubit({required SectionsRepository repository})
      : _repository = repository,
        super(const SectionsInitial());

  Future<void> loadSections(String gradeId) async {
    _gradeId = gradeId;
    emit(const SectionsLoading());
    try {
      final sections = await _repository.getByGradeId(gradeId);
      // Resolve parent grade name from dummy data.
      String gradeName = 'الصف';
      for (final grades in GradeModel.dummyMap.values) {
        for (final g in grades) {
          if (g.id == gradeId) {
            gradeName = g.title;
            break;
          }
        }
      }
      emit(SectionsLoaded(
        sections: sections,
        filteredSections: sections,
        gradeId: gradeId,
        gradeName: gradeName,
      ));
    } catch (e) {
      emit(SectionsError(ErrorHandler.handle(e)));
    }
  }

  Future<void> createSection(SectionModel section, {List<int>? imageBytes, String? imageName}) async {
    try {
      await _repository.create(section, imageBytes: imageBytes, imageName: imageName);
      await loadSections(_gradeId);
    } catch (e) {
      emit(SectionsError(ErrorHandler.handle(e)));
    }
  }

  Future<void> updateSection(SectionModel section, {List<int>? imageBytes, String? imageName}) async {
    try {
      await _repository.update(section, imageBytes: imageBytes, imageName: imageName);
      await loadSections(_gradeId);
    } catch (e) {
      emit(SectionsError(ErrorHandler.handle(e)));
    }
  }

  Future<void> deleteSection(String id) async {
    try {
      await _repository.delete(_gradeId, id);
      await loadSections(_gradeId);
    } catch (e) {
      emit(SectionsError(ErrorHandler.handle(e)));
    }
  }

  Future<void> toggleStatus(String id) async {
    try {
      await _repository.toggleStatus(_gradeId, id);
      await loadSections(_gradeId);
    } catch (e) {
      emit(SectionsError(ErrorHandler.handle(e)));
    }
  }

  void search(String query) {
    final currentState = state;
    if (currentState is SectionsLoaded) {
      if (query.isEmpty) {
        emit(currentState.copyWith(
          filteredSections: currentState.sections,
          searchQuery: '',
        ));
      } else {
        final filtered = currentState.sections.where((s) {
          final q = query.toLowerCase();
          return s.title.toLowerCase().contains(q) ||
              (s.description?.toLowerCase().contains(q) ?? false);
        }).toList();
        emit(currentState.copyWith(
          filteredSections: filtered,
          searchQuery: query,
        ));
      }
    }
  }
}

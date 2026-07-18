import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dashboard/core/errors/error_handler.dart';
import 'package:web_dashboard/features/free_trial_subjects/data/models/free_trial_subject_model.dart';
import 'package:web_dashboard/features/free_trial_subjects/data/repositories/free_trial_subjects_repository.dart';
import 'package:web_dashboard/features/free_trial_grades/data/models/free_trial_grade_model.dart';
import 'package:web_dashboard/core/services/dependency_injection.dart';
import 'package:web_dashboard/features/free_trial_lesson_files/data/repositories/free_trial_lesson_files_repository.dart';

import 'free_trial_subjects_state.dart';

class FreeTrialSubjectsCubit extends Cubit<FreeTrialSubjectsState> {
  final FreeTrialSubjectsRepository _repository;
  late String _gradeId;

  FreeTrialSubjectsCubit({required FreeTrialSubjectsRepository repository})
      : _repository = repository,
        super(const FreeTrialSubjectsInitial());

  Future<void> loadFreeTrialSubjects(String gradeId) async {
    _gradeId = gradeId;
    emit(const FreeTrialSubjectsLoading());
    try {
      final free_trial_subjects = await _repository.getByGradeId(gradeId);
      final gradeName = FreeTrialGradeModel.dummyMap.values
              .expand((e) => e)
              .where((g) => g.id == gradeId)
              .map((g) => g.title)
              .firstOrNull ??
          'الصف';
      
      List<FreeTrialSubjectModel> updatedSubjects = [];
      for (final subject in free_trial_subjects) {
        try {
          final files = await sl<FreeTrialLessonFilesRepository>().getBySubjectId(subject.id);
          updatedSubjects.add(subject.copyWith(lessonFilesCount: files.length));
        } catch (e) {
          updatedSubjects.add(subject.copyWith(lessonFilesCount: -99));
        }
      }

      emit(FreeTrialSubjectsLoaded(
        free_trial_subjects: updatedSubjects,
        filteredFreeTrialSubjects: updatedSubjects,
        gradeId: gradeId,
        gradeName: gradeName,
      ));
    } catch (e) {
      emit(FreeTrialSubjectsError(ErrorHandler.handle(e)));
    }
  }

  Future<void> createFreeTrialSubject(FreeTrialSubjectModel free_trial_subject, {List<int>? imageBytes, String? imageName}) async {
    try {
      await _repository.create(free_trial_subject, imageBytes: imageBytes, imageName: imageName);
      await loadFreeTrialSubjects(_gradeId);
    } catch (e) {
      emit(FreeTrialSubjectsError(ErrorHandler.handle(e)));
    }
  }

  Future<void> updateFreeTrialSubject(FreeTrialSubjectModel free_trial_subject, {List<int>? imageBytes, String? imageName}) async {
    try {
      await _repository.update(free_trial_subject, imageBytes: imageBytes, imageName: imageName);
      await loadFreeTrialSubjects(_gradeId);
    } catch (e) {
      emit(FreeTrialSubjectsError(ErrorHandler.handle(e)));
    }
  }

  Future<void> deleteFreeTrialSubject(String id) async {
    try {
      await _repository.delete(_gradeId, id);
      await loadFreeTrialSubjects(_gradeId);
    } catch (e) {
      emit(FreeTrialSubjectsError(ErrorHandler.handle(e)));
    }
  }

  void search(String query) {
    if (state is FreeTrialSubjectsLoaded) {
      final currentState = state as FreeTrialSubjectsLoaded;
      if (query.isEmpty) {
        emit(currentState.copyWith(filteredFreeTrialSubjects: currentState.free_trial_subjects));
        return;
      }
      final filtered = currentState.free_trial_subjects.where((free_trial_subject) {
        return free_trial_subject.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
      emit(currentState.copyWith(filteredFreeTrialSubjects: filtered));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dashboard/core/errors/error_handler.dart';
import 'package:web_dashboard/features/free_trial_grades/data/models/free_trial_grade_model.dart';
import 'package:web_dashboard/features/free_trial_grades/data/repositories/free_trial_grades_repository.dart';

import 'package:web_dashboard/core/services/dependency_injection.dart';
import 'package:web_dashboard/features/free_trial_subjects/data/repositories/free_trial_subjects_repository.dart';

import 'free_trial_grades_state.dart';

class FreeTrialGradesCubit extends Cubit<FreeTrialGradesState> {
  final FreeTrialGradesRepository _repository;
  late String _stageId;

  FreeTrialGradesCubit({required FreeTrialGradesRepository repository})
      : _repository = repository,
        super(const FreeTrialGradesInitial());

  Future<void> loadFreeTrialGrades(String stageId) async {
    _stageId = stageId;
    emit(const FreeTrialGradesLoading());
    try {
      final free_trial_grades = await _repository.getByStageId(stageId);
      final stageName = 'المرحلة';
      
      List<FreeTrialGradeModel> updatedGrades = [];
      for (final grade in free_trial_grades) {
        try {
          final subjects = await sl<FreeTrialSubjectsRepository>().getByGradeId(grade.id);
          updatedGrades.add(grade.copyWith(subjectsCount: subjects.length));
        } catch (e) {
          // If it fails, set to -99 so the user can visibly see there was an error
          updatedGrades.add(grade.copyWith(subjectsCount: -99));
        }
      }

      emit(FreeTrialGradesLoaded(
        free_trial_grades: updatedGrades,
        filteredFreeTrialGrades: updatedGrades,
        stageId: stageId,
        stageName: stageName,
      ));
    } catch (e) {
      emit(FreeTrialGradesError(ErrorHandler.handle(e)));
    }
  }

  Future<void> createFreeTrialGrade(FreeTrialGradeModel free_trial_grade, {List<int>? imageBytes, String? imageName}) async {
    try {
      await _repository.create(free_trial_grade, imageBytes: imageBytes, imageName: imageName);
      await loadFreeTrialGrades(_stageId);
    } catch (e) {
      emit(FreeTrialGradesError(ErrorHandler.handle(e)));
    }
  }

  Future<void> updateFreeTrialGrade(FreeTrialGradeModel free_trial_grade, {List<int>? imageBytes, String? imageName}) async {
    try {
      await _repository.update(free_trial_grade, imageBytes: imageBytes, imageName: imageName);
      await loadFreeTrialGrades(_stageId);
    } catch (e) {
      emit(FreeTrialGradesError(ErrorHandler.handle(e)));
    }
  }

  Future<void> deleteFreeTrialGrade(String id) async {
    try {
      await _repository.delete(_stageId, id);
      await loadFreeTrialGrades(_stageId);
    } catch (e) {
      emit(FreeTrialGradesError(ErrorHandler.handle(e)));
    }
  }

  void search(String query) {
    if (state is FreeTrialGradesLoaded) {
      final currentState = state as FreeTrialGradesLoaded;
      if (query.isEmpty) {
        emit(currentState.copyWith(filteredFreeTrialGrades: currentState.free_trial_grades));
        return;
      }
      final filtered = currentState.free_trial_grades.where((free_trial_grade) {
        return free_trial_grade.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
      emit(currentState.copyWith(filteredFreeTrialGrades: filtered));
    }
  }
}

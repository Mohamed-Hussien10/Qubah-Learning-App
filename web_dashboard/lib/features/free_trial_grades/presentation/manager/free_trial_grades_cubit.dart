import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dashboard/features/educational_stages/data/models/stage_model.dart';
import 'package:web_dashboard/features/free_trial_grades/data/models/free_trial_grade_model.dart';
import 'package:web_dashboard/features/free_trial_grades/data/repositories/free_trial_grades_repository.dart';
import 'package:web_dashboard/features/free_trial_grades/presentation/manager/free_trial_grades_state.dart';
import 'package:web_dashboard/core/errors/error_handler.dart';

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
      // Resolve parent stage name from dummy data.
      final stageName = StageModel.dummyList
              .where((s) => s.id == stageId)
              .map((s) => s.title)
              .firstOrNull ??
          'المرحلة';
      emit(FreeTrialGradesLoaded(
        free_trial_grades: free_trial_grades,
        filteredFreeTrialGrades: free_trial_grades,
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

  Future<void> toggleStatus(String id) async {
    try {
      await _repository.toggleStatus(_stageId, id);
      await loadFreeTrialGrades(_stageId);
    } catch (e) {
      emit(FreeTrialGradesError(ErrorHandler.handle(e)));
    }
  }

  void search(String query) {
    final currentState = state;
    if (currentState is FreeTrialGradesLoaded) {
      if (query.isEmpty) {
        emit(currentState.copyWith(
          filteredFreeTrialGrades: currentState.free_trial_grades,
          searchQuery: '',
        ));
      } else {
        final filtered = currentState.free_trial_grades.where((g) {
          final q = query.toLowerCase();
          return g.title.toLowerCase().contains(q) ||
              (g.description?.toLowerCase().contains(q) ?? false);
        }).toList();
        emit(currentState.copyWith(
          filteredFreeTrialGrades: filtered,
          searchQuery: query,
        ));
      }
    }
  }
}

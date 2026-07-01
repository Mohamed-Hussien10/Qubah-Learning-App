import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dashboard/features/educational_stages/data/models/stage_model.dart';
import 'package:web_dashboard/features/grades/data/models/grade_model.dart';
import 'package:web_dashboard/features/grades/data/repositories/grades_repository.dart';
import 'package:web_dashboard/features/grades/presentation/manager/grades_state.dart';
import 'package:web_dashboard/core/errors/error_handler.dart';

class GradesCubit extends Cubit<GradesState> {
  final GradesRepository _repository;
  late String _stageId;

  GradesCubit({required GradesRepository repository})
      : _repository = repository,
        super(const GradesInitial());

  Future<void> loadGrades(String stageId) async {
    _stageId = stageId;
    emit(const GradesLoading());
    try {
      final grades = await _repository.getByStageId(stageId);
      // Resolve parent stage name from dummy data.
      final stageName = StageModel.dummyList
              .where((s) => s.id == stageId)
              .map((s) => s.title)
              .firstOrNull ??
          'المرحلة';
      emit(GradesLoaded(
        grades: grades,
        filteredGrades: grades,
        stageId: stageId,
        stageName: stageName,
      ));
    } catch (e) {
      emit(GradesError(ErrorHandler.handle(e)));
    }
  }

  Future<void> createGrade(GradeModel grade, {List<int>? imageBytes, String? imageName}) async {
    try {
      await _repository.create(grade, imageBytes: imageBytes, imageName: imageName);
      await loadGrades(_stageId);
    } catch (e) {
      emit(GradesError(ErrorHandler.handle(e)));
    }
  }

  Future<void> updateGrade(GradeModel grade, {List<int>? imageBytes, String? imageName}) async {
    try {
      await _repository.update(grade, imageBytes: imageBytes, imageName: imageName);
      await loadGrades(_stageId);
    } catch (e) {
      emit(GradesError(ErrorHandler.handle(e)));
    }
  }

  Future<void> deleteGrade(String id) async {
    try {
      await _repository.delete(_stageId, id);
      await loadGrades(_stageId);
    } catch (e) {
      emit(GradesError(ErrorHandler.handle(e)));
    }
  }

  Future<void> toggleStatus(String id) async {
    try {
      await _repository.toggleStatus(_stageId, id);
      await loadGrades(_stageId);
    } catch (e) {
      emit(GradesError(ErrorHandler.handle(e)));
    }
  }

  void search(String query) {
    final currentState = state;
    if (currentState is GradesLoaded) {
      if (query.isEmpty) {
        emit(currentState.copyWith(
          filteredGrades: currentState.grades,
          searchQuery: '',
        ));
      } else {
        final filtered = currentState.grades.where((g) {
          final q = query.toLowerCase();
          return g.title.toLowerCase().contains(q) ||
              (g.description?.toLowerCase().contains(q) ?? false);
        }).toList();
        emit(currentState.copyWith(
          filteredGrades: filtered,
          searchQuery: query,
        ));
      }
    }
  }
}

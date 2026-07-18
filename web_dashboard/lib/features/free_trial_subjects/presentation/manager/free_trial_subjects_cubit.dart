import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dashboard/features/grades/data/models/grade_model.dart';
import 'package:web_dashboard/features/free_trial_subjects/data/models/free_trial_subject_model.dart';
import 'package:web_dashboard/features/free_trial_subjects/data/repositories/free_trial_subjects_repository.dart';
import 'package:web_dashboard/features/free_trial_subjects/presentation/manager/free_trial_subjects_state.dart';
import 'package:web_dashboard/core/errors/error_handler.dart';

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
      String gradeName = 'القسم';
      for (final grades in GradeModel.dummyMap.values) {
        for (final s in grades) {
          if (s.id == gradeId) {
            gradeName = s.title;
            break;
          }
        }
      }
      emit(FreeTrialSubjectsLoaded(
        free_trial_subjects: free_trial_subjects,
        filteredFreeTrialSubjects: free_trial_subjects,
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

  Future<void> toggleStatus(String id) async {
    try {
      await _repository.toggleStatus(_gradeId, id);
      await loadFreeTrialSubjects(_gradeId);
    } catch (e) {
      emit(FreeTrialSubjectsError(ErrorHandler.handle(e)));
    }
  }

  void search(String query) {
    final currentState = state;
    if (currentState is FreeTrialSubjectsLoaded) {
      if (query.isEmpty) {
        emit(currentState.copyWith(
          filteredFreeTrialSubjects: currentState.free_trial_subjects,
          searchQuery: '',
        ));
      } else {
        final filtered = currentState.free_trial_subjects.where((s) {
          final q = query.toLowerCase();
          return s.title.toLowerCase().contains(q) ||
              (s.description?.toLowerCase().contains(q) ?? false);
        }).toList();
        emit(currentState.copyWith(
          filteredFreeTrialSubjects: filtered,
          searchQuery: query,
        ));
      }
    }
  }
}

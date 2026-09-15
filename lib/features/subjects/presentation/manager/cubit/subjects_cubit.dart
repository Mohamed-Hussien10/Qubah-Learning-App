import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_subjects_usecase.dart';
import '../state/subjects_state.dart';
import 'package:qubah_learning_app/core/errors/error_handler.dart';

class SubjectsCubit extends Cubit<SubjectsState> {
  final GetSubjectsUseCase _getSubjectsUseCase;
  String? _lastParentId;

  SubjectsCubit({required GetSubjectsUseCase getSubjectsUseCase})
    : _getSubjectsUseCase = getSubjectsUseCase,
      super(SubjectsInitial());

  Future<void> loadSubjects(String stageId, {bool forceRefresh = false}) async {
    // Skip reload if same parent's data is already loaded
    if (_lastParentId == stageId && state is SubjectsLoaded && !forceRefresh) return;

    emit(SubjectsLoading());
    try {
      final subjects = await _getSubjectsUseCase(stageId);
      _lastParentId = stageId;
      emit(SubjectsLoaded(subjects));
    } catch (e) {
      emit(SubjectsError(ErrorHandler.handle(e)));
    }
  }
}

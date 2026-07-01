import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_subjects_usecase.dart';
import '../state/subjects_state.dart';
import 'package:qubah_learning_app/core/errors/error_handler.dart';

class SubjectsCubit extends Cubit<SubjectsState> {
  final GetSubjectsUseCase _getSubjectsUseCase;

  SubjectsCubit({required GetSubjectsUseCase getSubjectsUseCase})
    : _getSubjectsUseCase = getSubjectsUseCase,
      super(SubjectsInitial());

  Future<void> loadSubjects(String stageId) async {
    emit(SubjectsLoading());
    try {
      final subjects = await _getSubjectsUseCase(stageId);
      emit(SubjectsLoaded(subjects));
    } catch (e) {
      emit(SubjectsError(ErrorHandler.handle(e)));
    }
  }
}

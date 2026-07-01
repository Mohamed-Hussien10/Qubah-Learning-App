import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_grades_usecase.dart';
import '../state/grades_state.dart';
import 'package:qubah_learning_app/core/errors/error_handler.dart';

class GradesCubit extends Cubit<GradesState> {
  final GetGradesUseCase _getGradesUseCase;

  GradesCubit({required GetGradesUseCase getGradesUseCase})
    : _getGradesUseCase = getGradesUseCase,
      super(GradesInitial());

  Future<void> loadGrades(String parentId) async {
    emit(GradesLoading());
    try {
      final data = await _getGradesUseCase(parentId);
      emit(GradesLoaded(data));
    } catch (e) {
      emit(GradesError(ErrorHandler.handle(e)));
    }
  }
}

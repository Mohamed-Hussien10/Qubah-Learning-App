import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_lesson_files_usecase.dart';
import '../state/lesson_files_state.dart';
import 'package:qubah_learning_app/core/errors/error_handler.dart';

class LessonFilesCubit extends Cubit<LessonFilesState> {
  final GetLessonFilesUseCase _getLessonFilesUseCase;

  LessonFilesCubit({required GetLessonFilesUseCase getLessonFilesUseCase})
    : _getLessonFilesUseCase = getLessonFilesUseCase,
      super(LessonFilesInitial());

  Future<void> loadLessonFiles(String parentId) async {
    emit(LessonFilesLoading());
    try {
      final data = await _getLessonFilesUseCase(parentId);
      emit(LessonFilesLoaded(data));
    } catch (e) {
      emit(LessonFilesError(ErrorHandler.handle(e)));
    }
  }
}

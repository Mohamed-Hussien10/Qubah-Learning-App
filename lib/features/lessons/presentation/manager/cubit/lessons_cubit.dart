import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_lessons_usecase.dart';
import '../state/lessons_state.dart';

class LessonsCubit extends Cubit<LessonsState> {
  final GetLessonsUseCase _getLessonsUseCase;

  LessonsCubit({required GetLessonsUseCase getLessonsUseCase})
    : _getLessonsUseCase = getLessonsUseCase,
      super(LessonsInitial());

  Future<void> loadLessons(String subjectId) async {
    emit(LessonsLoading());
    try {
      final lessons = await _getLessonsUseCase(subjectId);
      emit(LessonsLoaded(lessons));
    } catch (e) {
      emit(LessonsError(e.toString()));
    }
  }
}

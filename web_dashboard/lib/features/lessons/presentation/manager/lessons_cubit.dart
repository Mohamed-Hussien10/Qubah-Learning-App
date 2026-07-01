import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dashboard/features/units/data/models/unit_model.dart';
import 'package:web_dashboard/features/lessons/data/models/lesson_model.dart';
import 'package:web_dashboard/features/lessons/data/repositories/lessons_repository.dart';
import 'package:web_dashboard/features/lessons/presentation/manager/lessons_state.dart';
import 'package:web_dashboard/core/errors/error_handler.dart';

class LessonsCubit extends Cubit<LessonsState> {
  final LessonsRepository _repository;
  late String _unitId;

  LessonsCubit({required LessonsRepository repository})
      : _repository = repository,
        super(const LessonsInitial());

  Future<void> loadLessons(String unitId) async {
    _unitId = unitId;
    emit(const LessonsLoading());
    try {
      final lessons = await _repository.getByUnitId(unitId);
      String unitName = 'الوحدة';
      for (final units in UnitModel.dummyMap.values) {
        for (final u in units) {
          if (u.id == unitId) {
            unitName = u.title;
            break;
          }
        }
      }
      emit(LessonsLoaded(
        lessons: lessons,
        filteredLessons: lessons,
        unitId: unitId,
        unitName: unitName,
      ));
    } catch (e) {
      emit(LessonsError(ErrorHandler.handle(e)));
    }
  }

  Future<void> createLesson(LessonModel lesson, {List<int>? imageBytes, String? imageName}) async {
    try {
      await _repository.create(lesson, imageBytes: imageBytes, imageName: imageName);
      await loadLessons(_unitId);
    } catch (e) {
      emit(LessonsError(ErrorHandler.handle(e)));
    }
  }

  Future<void> updateLesson(LessonModel lesson, {List<int>? imageBytes, String? imageName}) async {
    try {
      await _repository.update(lesson, imageBytes: imageBytes, imageName: imageName);
      await loadLessons(_unitId);
    } catch (e) {
      emit(LessonsError(ErrorHandler.handle(e)));
    }
  }

  Future<void> deleteLesson(String id) async {
    try {
      await _repository.delete(_unitId, id);
      await loadLessons(_unitId);
    } catch (e) {
      emit(LessonsError(ErrorHandler.handle(e)));
    }
  }

  Future<void> toggleStatus(String id) async {
    try {
      await _repository.toggleStatus(_unitId, id);
      await loadLessons(_unitId);
    } catch (e) {
      emit(LessonsError(ErrorHandler.handle(e)));
    }
  }



  void search(String query) {
    final currentState = state;
    if (currentState is LessonsLoaded) {
      if (query.isEmpty) {
        emit(currentState.copyWith(
          filteredLessons: currentState.lessons,
          searchQuery: '',
        ));
      } else {
        final filtered = currentState.lessons.where((l) {
          final q = query.toLowerCase();
          return l.title.toLowerCase().contains(q) ||
              (l.description?.toLowerCase().contains(q) ?? false);
        }).toList();
        emit(currentState.copyWith(
          filteredLessons: filtered,
          searchQuery: query,
        ));
      }
    }
  }
}

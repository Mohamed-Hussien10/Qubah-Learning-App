import 'package:equatable/equatable.dart';
import 'package:web_dashboard/features/lessons/data/models/lesson_model.dart';

abstract class LessonsState extends Equatable {
  const LessonsState();

  @override
  List<Object?> get props => [];
}

class LessonsInitial extends LessonsState {
  const LessonsInitial();
}

class LessonsLoading extends LessonsState {
  const LessonsLoading();
}

class LessonsLoaded extends LessonsState {
  final List<LessonModel> lessons;
  final List<LessonModel> filteredLessons;
  final String unitId;
  final String unitName;
  final String searchQuery;

  const LessonsLoaded({
    required this.lessons,
    required this.filteredLessons,
    required this.unitId,
    required this.unitName,
    this.searchQuery = '',
  });

  LessonsLoaded copyWith({
    List<LessonModel>? lessons,
    List<LessonModel>? filteredLessons,
    String? unitId,
    String? unitName,
    String? searchQuery,
  }) {
    return LessonsLoaded(
      lessons: lessons ?? this.lessons,
      filteredLessons: filteredLessons ?? this.filteredLessons,
      unitId: unitId ?? this.unitId,
      unitName: unitName ?? this.unitName,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [lessons, filteredLessons, unitId, unitName, searchQuery];
}

class LessonsError extends LessonsState {
  final String message;

  const LessonsError(this.message);

  @override
  List<Object?> get props => [message];
}

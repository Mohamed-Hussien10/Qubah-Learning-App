import '../../../domain/entities/lesson_file_entity.dart';

abstract class LessonFilesState {}

class LessonFilesInitial extends LessonFilesState {}

class LessonFilesLoading extends LessonFilesState {}

class LessonFilesLoaded extends LessonFilesState {
  final List<LessonFileEntity> lessonFiles;
  LessonFilesLoaded(this.lessonFiles);
}

class LessonFilesError extends LessonFilesState {
  final String message;
  LessonFilesError(this.message);
}

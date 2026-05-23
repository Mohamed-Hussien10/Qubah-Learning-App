import 'package:equatable/equatable.dart';
import '../../../domain/entities/lesson_entity.dart';

abstract class LessonsState extends Equatable {
  const LessonsState();
  @override
  List<Object?> get props => [];
}

class LessonsInitial extends LessonsState {}

class LessonsLoading extends LessonsState {}

class LessonsLoaded extends LessonsState {
  final List<LessonEntity> lessons;
  const LessonsLoaded(this.lessons);
  @override
  List<Object?> get props => [lessons];
}

class LessonsError extends LessonsState {
  final String message;
  const LessonsError(this.message);
  @override
  List<Object?> get props => [message];
}

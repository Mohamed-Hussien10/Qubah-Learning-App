import 'package:equatable/equatable.dart';
import 'package:web_dashboard/features/lesson_files/data/models/lesson_file_model.dart';

abstract class LessonFilesState extends Equatable {
  const LessonFilesState();

  @override
  List<Object?> get props => [];
}

class LessonFilesInitial extends LessonFilesState {
  const LessonFilesInitial();
}

class LessonFilesLoading extends LessonFilesState {
  const LessonFilesLoading();
}

class LessonFilesLoaded extends LessonFilesState {
  final List<LessonFileModel> files;
  final String lessonId;
  final String lessonName;
  final double? uploadProgress; // If non-null, shows progress bar

  const LessonFilesLoaded({
    required this.files,
    required this.lessonId,
    required this.lessonName,
    this.uploadProgress,
  });

  LessonFilesLoaded copyWith({
    List<LessonFileModel>? files,
    String? lessonId,
    String? lessonName,
    double? uploadProgress,
    bool clearUploadProgress = false,
  }) {
    return LessonFilesLoaded(
      files: files ?? this.files,
      lessonId: lessonId ?? this.lessonId,
      lessonName: lessonName ?? this.lessonName,
      uploadProgress: clearUploadProgress ? null : (uploadProgress ?? this.uploadProgress),
    );
  }

  @override
  List<Object?> get props => [files, lessonId, lessonName, uploadProgress];
}

class LessonFilesError extends LessonFilesState {
  final String message;

  const LessonFilesError(this.message);

  @override
  List<Object?> get props => [message];
}

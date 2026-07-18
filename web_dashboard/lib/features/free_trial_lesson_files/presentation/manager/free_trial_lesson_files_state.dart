import 'package:equatable/equatable.dart';
import 'package:web_dashboard/features/free_trial_lesson_files/data/models/free_trial_lesson_file_model.dart';

abstract class FreeTrialLessonFilesState extends Equatable {
  const FreeTrialLessonFilesState();

  @override
  List<Object?> get props => [];
}

class FreeTrialLessonFilesInitial extends FreeTrialLessonFilesState {
  const FreeTrialLessonFilesInitial();
}

class FreeTrialLessonFilesLoading extends FreeTrialLessonFilesState {
  const FreeTrialLessonFilesLoading();
}

class FreeTrialLessonFilesLoaded extends FreeTrialLessonFilesState {
  final List<FreeTrialLessonFileModel> files;
  final String subjectId;
  final String subjectName;
  final double? uploadProgress; // If non-null, shows progress bar

  const FreeTrialLessonFilesLoaded({
    required this.files,
    required this.subjectId,
    required this.subjectName,
    this.uploadProgress,
  });

  FreeTrialLessonFilesLoaded copyWith({
    List<FreeTrialLessonFileModel>? files,
    String? subjectId,
    String? subjectName,
    double? uploadProgress,
    bool clearUploadProgress = false,
  }) {
    return FreeTrialLessonFilesLoaded(
      files: files ?? this.files,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      uploadProgress: clearUploadProgress ? null : (uploadProgress ?? this.uploadProgress),
    );
  }

  @override
  List<Object?> get props => [files, subjectId, subjectName, uploadProgress];
}

class FreeTrialLessonFilesError extends FreeTrialLessonFilesState {
  final String message;

  const FreeTrialLessonFilesError(this.message);

  @override
  List<Object?> get props => [message];
}

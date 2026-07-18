import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dashboard/features/subjects/data/models/subject_model.dart';
import 'package:web_dashboard/features/free_trial_lesson_files/data/repositories/free_trial_lesson_files_repository.dart';
import 'package:web_dashboard/features/free_trial_lesson_files/presentation/manager/free_trial_lesson_files_state.dart';
import 'package:web_dashboard/core/errors/error_handler.dart';

class FreeTrialLessonFilesCubit extends Cubit<FreeTrialLessonFilesState> {
  final FreeTrialLessonFilesRepository _repository;
  late String _subjectId;

  FreeTrialLessonFilesCubit({required FreeTrialLessonFilesRepository repository})
      : _repository = repository,
        super(const FreeTrialLessonFilesInitial());

  Future<void> loadFiles(String subjectId) async {
    _subjectId = subjectId;
    emit(const FreeTrialLessonFilesLoading());
    try {
      final files = await _repository.getBySubjectId(subjectId);
      String subjectName = 'الدرس';
      for (final subjects in SubjectModel.dummyMap.values) {
        for (final l in subjects) {
          if (l.id == subjectId) {
            subjectName = l.title;
            break;
          }
        }
      }
      emit(FreeTrialLessonFilesLoaded(
        files: files,
        subjectId: subjectId,
        subjectName: subjectName,
      ));
    } catch (e) {
      emit(FreeTrialLessonFilesError(ErrorHandler.handle(e)));
    }
  }

  Future<void> deleteFile(String id) async {
    final currentState = state;
    if (currentState is FreeTrialLessonFilesLoaded) {
      try {
        await _repository.delete(_subjectId, id);
        await loadFiles(_subjectId);
      } catch (e) {
        emit(FreeTrialLessonFilesError(ErrorHandler.handle(e)));
      }
    }
  }

  Future<void> uploadFile({
    required String title,
    required String type,
    required String fileName,
    required int bytesCount,
    List<int>? fileBytes,
  }) async {
    final currentState = state;
    if (currentState is FreeTrialLessonFilesLoaded) {
      emit(currentState.copyWith(uploadProgress: 0.0));
      try {
        await _repository.uploadFile(
          subjectId: _subjectId,
          title: title,
          type: type,
          fileName: fileName,
          bytesCount: bytesCount,
          fileBytes: fileBytes,
          onProgress: (progress) {
            final latestState = state;
            if (latestState is FreeTrialLessonFilesLoaded) {
              emit(latestState.copyWith(uploadProgress: progress));
            }
          },
        );
        final freshFiles = await _repository.getBySubjectId(_subjectId);
        emit(FreeTrialLessonFilesLoaded(
          files: freshFiles,
          subjectId: _subjectId,
          subjectName: currentState.subjectName,
          uploadProgress: null,
        ));
      } catch (e) {
        emit(FreeTrialLessonFilesError(ErrorHandler.handle(e)));
      }
    }
  }

  Future<bool> uploadThumbnail({
    required String fileId,
    required List<int> thumbnailBytes,
    required String thumbnailFileName,
  }) async {
    final currentState = state;
    if (currentState is FreeTrialLessonFilesLoaded) {
      try {
        await _repository.uploadThumbnail(
          fileId: fileId,
          thumbnailBytes: thumbnailBytes,
          thumbnailFileName: thumbnailFileName,
        );
        // Reload files to show new thumbnail
        final freshFiles = await _repository.getBySubjectId(_subjectId);
        emit(FreeTrialLessonFilesLoaded(
          files: freshFiles,
          subjectId: _subjectId,
          subjectName: currentState.subjectName,
          uploadProgress: null,
        ));
        return true;
      } catch (e) {
        emit(FreeTrialLessonFilesError(ErrorHandler.handle(e)));
        return false;
      }
    }
    return false;
  }
}

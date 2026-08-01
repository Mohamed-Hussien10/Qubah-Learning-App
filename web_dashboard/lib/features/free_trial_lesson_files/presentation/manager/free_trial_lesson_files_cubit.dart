import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dashboard/features/subjects/data/models/subject_model.dart';
import 'package:web_dashboard/features/free_trial_lesson_files/data/repositories/free_trial_lesson_files_repository.dart';
import 'package:web_dashboard/features/free_trial_lesson_files/presentation/manager/free_trial_lesson_files_state.dart';
import 'package:web_dashboard/core/errors/error_handler.dart';
import 'package:web_dashboard/features/lesson_files/presentation/manager/lesson_files_cubit.dart' show BatchUploadItem;

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
    await uploadMultipleFiles([
      BatchUploadItem(
        title: title,
        type: type,
        fileName: fileName,
        bytesCount: bytesCount,
        fileBytes: fileBytes,
      )
    ]);
  }

  Future<void> uploadMultipleFiles(List<BatchUploadItem> items) async {
    final currentState = state;
    if (currentState is FreeTrialLessonFilesLoaded && items.isNotEmpty) {
      final total = items.length;
      emit(currentState.copyWith(uploadProgress: 0.0));

      for (int i = 0; i < total; i++) {
        final item = items[i];
        try {
          await _repository.uploadFile(
            subjectId: _subjectId,
            title: item.title,
            type: item.type,
            fileName: item.fileName,
            bytesCount: item.bytesCount,
            fileBytes: item.fileBytes,
            onProgress: (progress) {
              final latestState = state;
              if (latestState is FreeTrialLessonFilesLoaded) {
                final overall = (i + progress) / total;
                emit(latestState.copyWith(uploadProgress: overall));
              }
            },
          );
        } catch (e) {
          // Log error or continue with remaining files
        }
      }

      final freshFiles = await _repository.getBySubjectId(_subjectId);
      emit(FreeTrialLessonFilesLoaded(
        files: freshFiles,
        subjectId: _subjectId,
        subjectName: currentState.subjectName,
        uploadProgress: null,
      ));
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


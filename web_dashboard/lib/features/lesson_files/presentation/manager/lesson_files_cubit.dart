import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dashboard/features/lessons/data/models/lesson_model.dart';
import 'package:web_dashboard/features/lesson_files/data/repositories/lesson_files_repository.dart';
import 'package:web_dashboard/features/lesson_files/presentation/manager/lesson_files_state.dart';
import 'package:web_dashboard/core/errors/error_handler.dart';

class LessonFilesCubit extends Cubit<LessonFilesState> {
  final LessonFilesRepository _repository;
  late String _lessonId;

  LessonFilesCubit({required LessonFilesRepository repository})
      : _repository = repository,
        super(const LessonFilesInitial());

  Future<void> loadFiles(String lessonId) async {
    _lessonId = lessonId;
    emit(const LessonFilesLoading());
    try {
      final files = await _repository.getByLessonId(lessonId);
      String lessonName = 'الدرس';
      for (final lessons in LessonModel.dummyMap.values) {
        for (final l in lessons) {
          if (l.id == lessonId) {
            lessonName = l.title;
            break;
          }
        }
      }
      emit(LessonFilesLoaded(
        files: files,
        lessonId: lessonId,
        lessonName: lessonName,
      ));
    } catch (e) {
      emit(LessonFilesError(ErrorHandler.handle(e)));
    }
  }

  Future<void> deleteFile(String id) async {
    final currentState = state;
    if (currentState is LessonFilesLoaded) {
      try {
        await _repository.delete(_lessonId, id);
        await loadFiles(_lessonId);
      } catch (e) {
        emit(LessonFilesError(ErrorHandler.handle(e)));
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
    if (currentState is LessonFilesLoaded) {
      emit(currentState.copyWith(uploadProgress: 0.0));
      try {
        await _repository.uploadFile(
          lessonId: _lessonId,
          title: title,
          type: type,
          fileName: fileName,
          bytesCount: bytesCount,
          fileBytes: fileBytes,
          onProgress: (progress) {
            final latestState = state;
            if (latestState is LessonFilesLoaded) {
              emit(latestState.copyWith(uploadProgress: progress));
            }
          },
        );
        final freshFiles = await _repository.getByLessonId(_lessonId);
        emit(LessonFilesLoaded(
          files: freshFiles,
          lessonId: _lessonId,
          lessonName: currentState.lessonName,
          uploadProgress: null,
        ));
      } catch (e) {
        emit(LessonFilesError(ErrorHandler.handle(e)));
      }
    }
  }

  Future<bool> uploadThumbnail({
    required String fileId,
    required List<int> thumbnailBytes,
    required String thumbnailFileName,
  }) async {
    final currentState = state;
    if (currentState is LessonFilesLoaded) {
      try {
        await _repository.uploadThumbnail(
          fileId: fileId,
          thumbnailBytes: thumbnailBytes,
          thumbnailFileName: thumbnailFileName,
        );
        // Reload files to show new thumbnail
        final freshFiles = await _repository.getByLessonId(_lessonId);
        emit(LessonFilesLoaded(
          files: freshFiles,
          lessonId: _lessonId,
          lessonName: currentState.lessonName,
          uploadProgress: null,
        ));
        return true;
      } catch (e) {
        emit(LessonFilesError(ErrorHandler.handle(e)));
        return false;
      }
    }
    return false;
  }
}

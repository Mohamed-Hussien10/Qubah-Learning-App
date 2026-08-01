import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dashboard/features/lessons/data/models/lesson_model.dart';
import 'package:web_dashboard/features/lesson_files/data/repositories/lesson_files_repository.dart';
import 'package:web_dashboard/features/lesson_files/presentation/manager/lesson_files_state.dart';
import 'package:web_dashboard/core/errors/error_handler.dart';

class BatchUploadItem {
  final String title;
  final String type;
  final String fileName;
  final int bytesCount;
  final List<int>? fileBytes;

  BatchUploadItem({
    required this.title,
    required this.type,
    required this.fileName,
    required this.bytesCount,
    this.fileBytes,
  });
}

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
    if (currentState is LessonFilesLoaded && items.isNotEmpty) {
      final total = items.length;
      emit(currentState.copyWith(uploadProgress: 0.0));

      for (int i = 0; i < total; i++) {
        final item = items[i];
        try {
          await _repository.uploadFile(
            lessonId: _lessonId,
            title: item.title,
            type: item.type,
            fileName: item.fileName,
            bytesCount: item.bytesCount,
            fileBytes: item.fileBytes,
            onProgress: (progress) {
              final latestState = state;
              if (latestState is LessonFilesLoaded) {
                final overall = (i + progress) / total;
                emit(latestState.copyWith(uploadProgress: overall));
              }
            },
          );
        } catch (e) {
          // Log error or continue with remaining files
        }
      }

      final freshFiles = await _repository.getByLessonId(_lessonId);
      emit(LessonFilesLoaded(
        files: freshFiles,
        lessonId: _lessonId,
        lessonName: currentState.lessonName,
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


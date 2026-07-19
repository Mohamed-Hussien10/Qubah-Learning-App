
import 'package:flutter/foundation.dart';
import 'package:web_dashboard/core/network/api_client.dart';
import 'package:web_dashboard/features/lesson_files/data/models/lesson_file_model.dart';

/// Repository handling CRUD operations for lesson files and uploading attachments.
class LessonFilesRepository {
  final ApiClient _apiClient;

  LessonFilesRepository(this._apiClient);

  Future<List<LessonFileModel>> getByLessonId(String lessonId) async {
    final response = await _apiClient.get('/lessons/$lessonId');
    final data = response.data['data'];
    final lessonFiles = data?['lessonFiles'];
    if (lessonFiles is List) {
      return lessonFiles
          .map((json) => LessonFileModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<LessonFileModel> getById(String id) async {
    final response = await _apiClient.get('/lesson-files/$id');
    final data = response.data['data'] ?? response.data;
    return LessonFileModel.fromJson(data as Map<String, dynamic>);
  }

  Future<LessonFileModel> create(LessonFileModel file) async {
    final payload = file.toJson()..remove('id')..remove('created_at');
    final response = await _apiClient.post('/lesson-files', data: payload);
    final data = response.data['data'] ?? response.data;
    return LessonFileModel.fromJson(data as Map<String, dynamic>);
  }

  Future<LessonFileModel> update(LessonFileModel file) async {
    final payload = file.toJson()..remove('created_at');
    final response = await _apiClient.put('/lesson-files/${file.id}', data: payload);
    final data = response.data['data'] ?? response.data;
    return LessonFileModel.fromJson(data as Map<String, dynamic>);
  }

  Future<bool> delete(String lessonId, String id) async {
    await _apiClient.delete('/lesson-files/$id');
    return true;
  }

  /// Upload file content to backend using multipart form bytes.
  Future<LessonFileModel> uploadFile({
    required String lessonId,
    required String title,
    required String type,
    required String fileName,
    required int bytesCount,
    List<int>? fileBytes,
    required void Function(double progress) onProgress,
  }) async {
    if (fileBytes != null && fileBytes.isNotEmpty) {
      final response = await _apiClient.uploadFileBytes(
        '/lesson-files/upload',
        fileBytes: fileBytes,
        fileName: fileName,
        fileFieldName: 'file',
        additionalFields: {
          'lesson_id': lessonId,
          'title': title,
          'type': type,
        },
        onProgress: (sent, total) {
          if (total > 0) {
            onProgress(sent / total);
          }
        },
      );
      final data = response.data['data'] ?? response.data;
      return LessonFileModel.fromJson(data as Map<String, dynamic>);
    } else {
      // If no file bytes are present, send metadata only
      final payload = {
        'lesson_id': lessonId,
        'title': title,
        'type': type,
        'file_name': fileName,
        'file_size': '${(bytesCount / (1024 * 1024)).toStringAsFixed(1)} MB',
      };
      final response = await _apiClient.post('/lesson-files', data: payload);
      final data = response.data['data'] ?? response.data;
      return LessonFileModel.fromJson(data as Map<String, dynamic>);
    }
  }

  /// Upload a thumbnail for a specific lesson file
  Future<LessonFileModel> uploadThumbnail({
    required String fileId,
    required List<int> thumbnailBytes,
    required String thumbnailFileName,
  }) async {
    try {
      debugPrint('DEBUG: Starting thumbnail upload for fileId: $fileId');
      
      // 1. Upload thumbnail to generic thumbnail endpoint
      final uploadResponse = await _apiClient.uploadFileBytes(
        '/thumbnails/upload',
        fileBytes: thumbnailBytes,
        fileName: thumbnailFileName,
        fileFieldName: 'thumbnail',
        additionalFields: {'folder': 'files'},
      );
      debugPrint('DEBUG: Upload response: ${uploadResponse.data}');
      
      final uploadData = uploadResponse.data['data'] ?? uploadResponse.data;
      final String thumbnailPath = uploadData['path'];
      debugPrint('DEBUG: Thumbnail path received: $thumbnailPath');

      // 2. Fetch current file
      final fileModel = await getById(fileId);
      debugPrint('DEBUG: Fetched current file: ${fileModel.toJson()}');

      // 3. Update file with new thumbnail path
      final updatedModel = fileModel.copyWith(thumbnailUrl: thumbnailPath);
      final updateResult = await update(updatedModel);
      debugPrint('DEBUG: Update successful');
      return updateResult;
    } catch (e) {
      debugPrint('DEBUG: Error in uploadThumbnail: $e');
      rethrow;
    }
  }
}
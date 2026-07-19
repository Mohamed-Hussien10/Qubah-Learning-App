
import 'package:flutter/foundation.dart';
import 'package:web_dashboard/core/network/api_client.dart';
import 'package:web_dashboard/features/free_trial_lesson_files/data/models/free_trial_lesson_file_model.dart';

/// Repository handling CRUD operations for subject files and uploading attachments.
class FreeTrialLessonFilesRepository {
  final ApiClient _apiClient;

  FreeTrialLessonFilesRepository(this._apiClient);

  Future<List<FreeTrialLessonFileModel>> getBySubjectId(String subjectId) async {
    final response = await _apiClient.get('/free-trial/subjects/$subjectId/lesson-files');
    final data = response.data['data'];
    if (data is List) {
      return data
          .map((json) => FreeTrialLessonFileModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<FreeTrialLessonFileModel> getById(String id) async {
    final response = await _apiClient.get('/free-trial/lesson-files/$id');
    final data = response.data['data'] ?? response.data;
    return FreeTrialLessonFileModel.fromJson(data as Map<String, dynamic>);
  }

  Future<FreeTrialLessonFileModel> create(FreeTrialLessonFileModel file) async {
    final payload = file.toJson()..remove('id')..remove('created_at');
    final response = await _apiClient.post('/free-trial/lesson-files', data: payload);
    final data = response.data['data'] ?? response.data;
    return FreeTrialLessonFileModel.fromJson(data as Map<String, dynamic>);
  }

  Future<FreeTrialLessonFileModel> update(FreeTrialLessonFileModel file) async {
    final payload = file.toJson()..remove('created_at');
    final response = await _apiClient.put('/free-trial/lesson-files/${file.id}', data: payload);
    final data = response.data['data'] ?? response.data;
    return FreeTrialLessonFileModel.fromJson(data as Map<String, dynamic>);
  }

  Future<bool> delete(String subjectId, String id) async {
    await _apiClient.delete('/free-trial/lesson-files/$id');
    return true;
  }

  /// Upload file content to backend using multipart form bytes.
  Future<FreeTrialLessonFileModel> uploadFile({
    required String subjectId,
    required String title,
    required String type,
    required String fileName,
    required int bytesCount,
    List<int>? fileBytes,
    required void Function(double progress) onProgress,
  }) async {
    if (fileBytes != null && fileBytes.isNotEmpty) {
      final response = await _apiClient.uploadFileBytes(
        '/free-trial/lesson-files/upload',
        fileBytes: fileBytes,
        fileName: fileName,
        fileFieldName: 'file',
        additionalFields: {
          'free_trial_subject_id': subjectId,
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
      return FreeTrialLessonFileModel.fromJson(data as Map<String, dynamic>);
    } else {
      // If no file bytes are present, send metadata only
      final payload = {
        'free_trial_subject_id': subjectId,
        'title': title,
        'type': type,
        'file_name': fileName,
        'file_size': '${(bytesCount / (1024 * 1024)).toStringAsFixed(1)} MB',
      };
      final response = await _apiClient.post('/free-trial/lesson-files', data: payload);
      final data = response.data['data'] ?? response.data;
      return FreeTrialLessonFileModel.fromJson(data as Map<String, dynamic>);
    }
  }

  /// Upload a thumbnail for a specific subject file
  Future<FreeTrialLessonFileModel> uploadThumbnail({
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
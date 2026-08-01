import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_dashboard/core/network/api_client.dart';

/// Repository managing default file format thumbnails for each educational stage.
class StageFileThumbnailsRepository {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;

  StageFileThumbnailsRepository(this._apiClient, this._prefs);

  /// Fetch configured thumbnails for a specific stage as a Map of format to thumbnailUrl.
  Future<Map<String, String>> getThumbnailsForStage(String stageId) async {
    final map = <String, String>{};
    const formats = ['pdf', 'video', 'audio', 'image', 'scorm', 'html5'];

    // 1. Read from SharedPreferences cache/fallback first
    for (final fmt in formats) {
      final key = 'stage_file_thumb_${stageId}_$fmt';
      final url = _prefs.getString(key);
      if (url != null && url.isNotEmpty) {
        map[fmt] = url;
      }
    }

    // 2. Try fetching from backend
    try {
      final response = await _apiClient.get('/stages/$stageId/file-thumbnails');
      final data = response.data['data'] ?? response.data;
      if (data is Map) {
        for (final entry in data.entries) {
          final fmt = entry.key.toString();
          final url = entry.value.toString();
          map[fmt] = url;
          _prefs.setString('stage_file_thumb_${stageId}_$fmt', url);
        }
      }
    } catch (e) {
      // Endpoint not present or offline fallback
    }

    return map;
  }

  /// Upload and set a thumbnail for a specific stage and file format.
  Future<String> saveThumbnail({
    required String stageId,
    required String format,
    required List<int> imageBytes,
    required String fileName,
  }) async {
    String path = '';
    try {
      final uploadRes = await _apiClient.uploadFileBytes(
        '/thumbnails/upload',
        fileBytes: imageBytes,
        fileName: fileName,
        fileFieldName: 'thumbnail',
        additionalFields: {'folder': 'stages'},
      );
      final data = uploadRes.data['data'] ?? uploadRes.data;
      path = data['path']?.toString() ?? '';

      // Persist to backend API endpoint if supported
      await _apiClient.post('/stages/$stageId/file-thumbnails', data: {
        'format': format,
        'thumbnail_url': path,
      });
    } catch (e) {
      debugPrint('API upload fallback: $e');
    }

    // Fallback to Base64 data URI if path is empty (e.g. offline mode or API endpoint missing)
    if (path.isEmpty && imageBytes.isNotEmpty) {
      final ext = fileName.split('.').last.toLowerCase();
      final mime = (ext == 'png') ? 'image/png' : (ext == 'gif' ? 'image/gif' : 'image/jpeg');
      path = 'data:$mime;base64,${base64Encode(imageBytes)}';
    }

    // Save in local storage cache (both stage-specific and format-default fallback)
    final key = 'stage_file_thumb_${stageId}_$format';
    final defaultKey = 'stage_file_thumb_$format';
    if (path.isNotEmpty) {
      await _prefs.setString(key, path);
      await _prefs.setString(defaultKey, path);
    }
    return path;
  }

  /// Remove/reset default thumbnail for a specific stage and format.
  Future<void> removeThumbnail({
    required String stageId,
    required String format,
  }) async {
    try {
      await _apiClient.delete('/stages/$stageId/file-thumbnails/$format');
    } catch (e) {
      debugPrint('Deleting thumbnail API fallback: $e');
    }
    final key = 'stage_file_thumb_${stageId}_$format';
    final defaultKey = 'stage_file_thumb_$format';
    await _prefs.remove(key);
    await _prefs.remove(defaultKey);
  }
}

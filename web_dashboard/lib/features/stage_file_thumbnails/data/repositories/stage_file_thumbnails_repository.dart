import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_dashboard/core/network/api_client.dart';

/// Repository managing default file format thumbnails for each educational stage.
class StageFileThumbnailsRepository {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;

  StageFileThumbnailsRepository(this._apiClient, this._prefs);

  /// Fetch configured thumbnails for a specific stage as a Map of format to thumbnailUrl.
  Future<Map<String, String>> getThumbnailsForStage(String stageId, {bool isFreeTrial = false}) async {
    final map = <String, String>{};
    
    final formats = isFreeTrial
        ? ['free_trial_pdf', 'free_trial_video', 'free_trial_audio', 'free_trial_scorm']
        : ['pdf', 'video', 'audio', 'scorm'];

    // 1. Read instantly from SharedPreferences cache
    for (final fmt in formats) {
      final key = 'stage_file_thumb_${stageId}_$fmt';
      String? url = _prefs.getString(key);
      if (url == null || url.isEmpty) {
        final defaultKey = 'stage_file_thumb_$fmt';
        url = _prefs.getString(defaultKey);
      }
      if (url != null && url.isNotEmpty) {
        map[fmt] = url;
      }
    }

    // Return immediately if all formats are already cached
    if (map.length == formats.length) {
      return map;
    }

    // 2. Fetch from backend
    try {
      final response = await _apiClient.get(
        '/educational-stages/$stageId/file-thumbnails',
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      final data = response.data['data'] ?? response.data;
      if (data is Map) {
        for (final entry in data.entries) {
          final fmt = entry.key.toString();
          if (formats.contains(fmt)) {
            final url = entry.value.toString();
            if (url.isNotEmpty && url != 'null') {
              map[fmt] = url;
              _prefs.setString('stage_file_thumb_${stageId}_$fmt', url);
              _prefs.setString('stage_file_thumb_$fmt', url);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching thumbnails for stage $stageId: $e');
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
      
      // Persist to backend API endpoint
      if (path.isNotEmpty) {
        unawaited(() async {
          try {
            await _apiClient.post(
              '/educational-stages/$stageId/file-thumbnails',
              data: {
                'format': format,
                'thumbnail_url': path,
              },
              options: Options(
                sendTimeout: const Duration(seconds: 3),
                receiveTimeout: const Duration(seconds: 3),
              ),
            );
          } catch (_) {}
        }());
      }
    } catch (e) {
      debugPrint('API upload fallback: $e');
    }

    // Fallback to Base64 data URI if path is empty
    if (path.isEmpty && imageBytes.isNotEmpty) {
      final ext = fileName.split('.').last.toLowerCase();
      final mime = (ext == 'png') ? 'image/png' : (ext == 'gif' ? 'image/gif' : 'image/jpeg');
      path = 'data:$mime;base64,${base64Encode(imageBytes)}';
    }

    // Save in local storage cache immediately
    final key = 'stage_file_thumb_${stageId}_$format';
    final defaultKey = 'stage_file_thumb_$format';
    if (path.isNotEmpty) {
      await _prefs.setString(key, path);
      await _prefs.setString(defaultKey, path);
    }

    if (path.isNotEmpty) {
      // Fire-and-forget background update of lesson files without blocking UI
      unawaited(_updateAllFilesOfFormatInStage(stageId, format, path));
    }

    return path;
  }

  /// Remove/reset default thumbnail for a specific stage and format.
  Future<void> removeThumbnail({
    required String stageId,
    required String format,
  }) async {
    final key = 'stage_file_thumb_${stageId}_$format';
    final defaultKey = 'stage_file_thumb_$format';
    await _prefs.remove(key);
    await _prefs.remove(defaultKey);

    unawaited(() async {
      try {
        await _apiClient.delete(
          '/educational-stages/$stageId/file-thumbnails/$format',
          options: Options(
            receiveTimeout: const Duration(seconds: 3),
          ),
        );
      } catch (_) {}
    }());
  }


  Future<void> _updateAllFilesOfFormatInStage(String stageId, String format, String thumbnailPath) async {
    try {
      final isFreeTrial = format.startsWith('free_trial_');
      final actualFormat = isFreeTrial ? format.replaceFirst('free_trial_', '') : format;

      if (isFreeTrial) {
        // Free Trial Hierarchy: Stage -> Grades -> Subjects -> Files
        final gradesRes = await _apiClient.get('/free-trial/stages/$stageId/grades');
        final gradesData = gradesRes.data['data'];
        final grades = (gradesData is List) ? gradesData : [];

        for (final grade in grades) {
          final gradeId = grade['id'].toString();
          
          final subjectsRes = await _apiClient.get('/free-trial/grades/$gradeId/subjects');
          final subjectsData = subjectsRes.data['data'];
          final subjects = (subjectsData is List) ? subjectsData : [];

          for (final subject in subjects) {
            final subjectId = subject['id'].toString();

            final filesRes = await _apiClient.get('/free-trial/subjects/$subjectId/lesson-files');
            final filesData = filesRes.data['data'];
            final files = (filesData is List) ? filesData : [];

            for (final file in files) {
              if (file['type'] == actualFormat) {
                final fileId = file['id'].toString();
                final payload = Map<String, dynamic>.from(file);
                payload.remove('id');
                payload.remove('created_at');
                payload.remove('updated_at');
                payload.remove('deleted_at');
                payload.remove('thumbnail_url');
                payload.remove('file_url');
                payload['thumbnail_path'] = thumbnailPath;

                try {
                  await _apiClient.put('/free-trial/lesson-files/$fileId', data: payload);
                } catch (e) {
                  debugPrint('Error updating free trial file $fileId: $e');
                }
              }
            }
          }
        }
      } else {
        // Standard Hierarchy: Stage -> Grades -> Sections -> Subjects -> Units -> Lessons -> Files
        final stageRes = await _apiClient.get('/educational-stages/$stageId');
        final stageData = stageRes.data['data'] ?? stageRes.data;
        final grades = stageData['grades'] as List? ?? [];
        
        for (final grade in grades) {
          final gradeId = grade['id'].toString();
          
          final gradeRes = await _apiClient.get('/grades/$gradeId');
          final gradeData = gradeRes.data['data'] ?? gradeRes.data;
          final sections = gradeData['sections'] as List? ?? [];

          for (final section in sections) {
            final sectionId = section['id'].toString();
            
            final sectionRes = await _apiClient.get('/sections/$sectionId');
            final sectionData = sectionRes.data['data'] ?? sectionRes.data;
            final subjects = sectionData['subjects'] as List? ?? [];

            for (final subject in subjects) {
              final subjectId = subject['id'].toString();
              
              final subjectRes = await _apiClient.get('/subjects/$subjectId');
              final fullSubjectData = subjectRes.data['data'] ?? subjectRes.data;
              final units = fullSubjectData['units'] as List? ?? [];

              for (final unit in units) {
                final unitId = unit['id'].toString();
                
                final unitRes = await _apiClient.get('/units/$unitId');
                final unitData = unitRes.data['data'] ?? unitRes.data;
                final lessons = unitData['lessons'] as List? ?? [];

                for (final lesson in lessons) {
                  final lessonId = lesson['id'].toString();
                  
                  final lessonRes = await _apiClient.get('/lessons/$lessonId');
                  final lessonData = lessonRes.data['data'] ?? lessonRes.data;
                  final files = lessonData['lessonFiles'] as List? ?? [];

                  for (final file in files) {
                    if (file['type'] == actualFormat) {
                      final fileId = file['id'].toString();
                      
                      final payload = Map<String, dynamic>.from(file);
                      payload.remove('id');
                      payload.remove('created_at');
                      payload.remove('updated_at');
                      payload.remove('deleted_at');
                      payload.remove('thumbnail_url');
                      payload.remove('file_url');
                      payload['thumbnail_path'] = thumbnailPath;
                      
                      try {
                        await _apiClient.put('/lesson-files/$fileId', data: payload);
                      } catch (e) {
                        debugPrint('Error updating file $fileId: $e');
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error during background file update: $e');
    }
  }
}

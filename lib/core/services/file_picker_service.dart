import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/debug_logger.dart';

/// ──────────────────────────────────────────────────────────────────────────────
/// Handles runtime permission requests and file picking.
/// ──────────────────────────────────────────────────────────────────────────────
class FilePickerService {
  /// Request storage permissions (Android only).
  /// On Android 13+ (API 33), granular media permissions are used instead.
  static Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      // Desktop platforms don't need explicit permission
      DebugLogger.info('Desktop platform – no storage permission needed.');
      return true;
    }

    if (Platform.isAndroid) {
      // file_picker uses the system Storage Access Framework (SAF) which doesn't
      // require runtime permissions on Android 10+ (API 29+).
      // For legacy Android versions (API <= 32), we check Permission.storage if needed.
      final isGranted = await Permission.storage.isGranted;
      if (isGranted) {
        return true;
      }
      final status = await Permission.storage.request();
      if (status.isGranted || status.isLimited) {
        DebugLogger.success('Storage permission granted.');
        return true;
      }
      // On Android 13+ (API 33+), Permission.storage is deprecated / denied by default,
      // but file_picker (SAF) works directly without permissions.
      DebugLogger.info('Proceeding with file picker SAF.');
      return true;
    }

    // iOS and other platforms don't need explicit storage permission for file_picker
    return true;
  }

  /// Open file picker to select a ZIP file.
  /// Returns the file path or null if cancelled.
  static Future<String?> pickZipFile() async {
    try {
      DebugLogger.info('Opening file picker for ZIP selection…');

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.single.path;
        DebugLogger.success('File selected: $path');
        return path;
      }

      DebugLogger.info('File picker cancelled by user.');
      return null;
    } catch (e, st) {
      DebugLogger.error('File picker error', e, st);
      return null;
    }
  }
}

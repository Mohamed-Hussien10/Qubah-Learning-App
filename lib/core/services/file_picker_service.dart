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
      // For Android 13+ (API 33), we don't need READ_EXTERNAL_STORAGE
      // file_picker handles the SAF-based picking internally
      final status = await Permission.storage.request();
      if (status.isGranted) {
        DebugLogger.success('Storage permission granted.');
        return true;
      }

      // Try manage external storage for broader access
      if (await Permission.manageExternalStorage.request().isGranted) {
        DebugLogger.success('Manage external storage permission granted.');
        return true;
      }

      DebugLogger.warning('Storage permission denied.');
      return false;
    }

    // iOS
    final status = await Permission.storage.request();
    DebugLogger.info('iOS storage permission: $status');
    return status.isGranted || status.isLimited;
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

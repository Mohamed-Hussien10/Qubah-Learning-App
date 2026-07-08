import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// ──────────────────────────────────────────────────────────────────────────────
/// Application Helpers
///
/// Utility functions used across the application for formatting,
/// validation, responsive layout, and common operations.
/// ──────────────────────────────────────────────────────────────────────────────
class AppHelpers {
  AppHelpers._();

  // ── Date & Time Formatting ─────────────────────────────────────────────

  /// Formats a DateTime to a readable date string (e.g., "Jan 15, 2025").
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Formats a DateTime to a short date string (e.g., "15/01/2025").
  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Formats a Duration to "MM:SS" for media player display.
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      final hours = duration.inHours.toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  /// Returns a human-readable relative time string (e.g., "2 hours ago").
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year(s) ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month(s) ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }

  // ── Validation ─────────────────────────────────────────────────────────

  /// Validates an email address format.
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  /// Validates a password (minimum 8 chars, 1 upper, 1 lower, 1 digit).
  static bool isValidPassword(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    return true;
  }

  /// Validates an activation code format.
  static bool isValidActivationCode(String code) {
    final cleaned = code.replaceAll('-', '').replaceAll(' ', '');
    return cleaned.length >= 8 && RegExp(r'^[A-Z0-9]+$').hasMatch(cleaned);
  }

  /// Validates a parent PIN (4 digits).
  static bool isValidPin(String pin) {
    return pin.length == 4 && RegExp(r'^\d{4}$').hasMatch(pin);
  }

  // ── Responsive Layout ─────────────────────────────────────────────────

  /// Returns the number of grid columns based on screen width.
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1200) return 4;
    if (width >= 900) return 3;
    if (width >= 600) return 2;
    return 2;
  }

  /// Returns true if the device is a tablet-sized screen.
  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).shortestSide >= 600;
  }

  /// Returns true if the device is in landscape mode.
  static bool isLandscape(BuildContext context) {
    return MediaQuery.orientationOf(context) == Orientation.landscape;
  }

  /// Returns responsive padding based on screen size.
  static EdgeInsets responsivePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1200)
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 24);
    if (width >= 900)
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    if (width >= 600)
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  }

  // ── String Utilities ──────────────────────────────────────────────────

  /// Truncates a string to maxLength and appends '...'
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Capitalises the first letter of a string.
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Returns the file extension from a file path.
  static String getFileExtension(String filePath) {
    final dotIndex = filePath.lastIndexOf('.');
    if (dotIndex == -1) return '';
    return filePath.substring(dotIndex + 1).toLowerCase();
  }

  /// Returns an appropriate icon for a lesson content type.
  static IconData getLessonTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return Icons.play_circle_filled_rounded;
      case 'audio':
        return Icons.headphones_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'interactive':
        return Icons.touch_app_rounded;
      case 'game':
        return Icons.sports_esports_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  /// Returns a colour associated with a lesson content type.
  static Color getLessonTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return const Color(0xFFE17055);
      case 'audio':
        return const Color(0xFF00CEC9);
      case 'pdf':
        return const Color(0xFF6C5CE7);
      case 'interactive':
        return const Color(0xFFFDCB6E);
      case 'game':
        return const Color(0xFF00B894);
      default:
        return const Color(0xFF74B9FF);
    }
  }

  static String resolveMediaUrl(String path) {
    if (path.isEmpty) return '';
    
    const String host = 'https://qubahom.com';
        
    if (path.contains('thumbnails/')) {
      final fileName = path.split('thumbnails/').last;
      return '$host/api/v1/thumbnails/' + fileName;
    }
    if (path.startsWith('http')) {
      if (path.contains('localhost') || path.contains('127.0.0.1') || path.contains('10.0.2.2') || path.contains('192.168.1.190')) {
        path = path.replaceAll(RegExp(r'http://(?:localhost|127\.0\.0\.1|10\.0\.2\.2|192\.168\.1\.190)(:\d+)?'), host);
      }
      
      // Proxy storage files to bypass CORS
      if (path.contains('/storage/')) {
        final filePath = path.split('/storage/').last;
        if (filePath.startsWith('thumbnails/')) {
          final fileName = filePath.split('thumbnails/').last;
          return '$host/api/v1/thumbnails/' + fileName;
        }
        return '$host/api/v1/files/' + filePath;
      }
      return path;
    }
    if (path.startsWith('/')) {
      return '$host$path';
    } else if (path.startsWith('storage/')) {
      final filePath = path.split('storage/').last;
      return '$host/api/v1/files/$filePath';
    } else {
      return '$host/api/v1/files/$path';
    }
  }
}

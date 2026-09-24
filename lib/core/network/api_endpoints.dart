/// ──────────────────────────────────────────────────────────────────────────────
/// API Endpoints
///
/// Centralised API endpoint constants. All API paths are defined here
/// to maintain a single source of truth and avoid magic strings.
/// ──────────────────────────────────────────────────────────────────────────────
class ApiEndpoints {
  ApiEndpoints._();

  static String get domainUrl {
    return 'https://qubahom.com';
  }

  // ── Base Configuration ──────────────────────────────────────────────────
  static String get baseUrl => '$domainUrl/api/v1/'; // Live backend
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ── Authentication ──────────────────────────────────────────────────────
  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String logout = 'auth/logout';
  static const String refreshToken = 'auth/refresh';
  static const String forgotPassword = 'auth/forgot-password';
  static const String resetPassword = 'auth/reset-password';
  static const String verifyEmail = 'auth/verify-email';

  // ── User Profile ───────────────────────────────────────────────────────
  static const String profile = 'user/profile';
  static const String updateProfile = 'user/profile/update';
  static const String changePassword = 'user/change-password';

  // ── Educational Stages ─────────────────────────────────────────────────
  static const String stages = 'educational-stages';
  static String stageById(String id) => 'educational-stages/$id';
  static String stageSubjects(String stageId) => 'educational-stages/$stageId'; // Returns subject with topics

  // ── Subjects ───────────────────────────────────────────────────────────
  static const String subjects = 'subjects';
  static String subjectById(String id) => 'subjects/$id';
  static String subjectLessons(String subjectId) => 'topics/$subjectId'; // Returns topic with contents

  // ── Lessons ────────────────────────────────────────────────────────────
  static const String lessons = 'contents';
  static String lessonById(String id) => 'contents/$id';
  static String lessonContent(String lessonId) => 'contents/$lessonId';
  static String lessonProgress(String lessonId) => 'progress/$lessonId';

  // ── Media / Content ────────────────────────────────────────────────────
  static String mediaStream(String mediaId) => 'media/$mediaId/stream';
  static String mediaDownload(String mediaId) => 'media/$mediaId/download';

  // ── Settings ──────────────────────────────────────────────────────────
  static const String settings = 'settings';
  static const String appConfig = 'settings/config';
}


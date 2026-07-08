
/// ──────────────────────────────────────────────────────────────────────────────
/// API Endpoints
///
/// Centralised API endpoint constants. All API paths are defined here
/// to maintain a single source of truth and avoid magic strings.
/// ──────────────────────────────────────────────────────────────────────────────
class ApiEndpoints {
  ApiEndpoints._();

  // ── Base Configuration ──────────────────────────────────────────────────
  static const String baseUrl = 'https://qubahom.com/api/v1'; // Production backend
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ── Authentication ──────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';

  // ── Activation Codes ───────────────────────────────────────────────────
  static const String activateCode = '/activation/activate';
  static const String validateCode = '/activation/validate';
  static const String activationStatus = '/activation/status';

  // ── User Profile ───────────────────────────────────────────────────────
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile/update';
  static const String changePassword = '/user/change-password';
  static const String uploadAvatar = '/user/avatar';

  // ── Educational Stages ─────────────────────────────────────────────────
  static const String stages = '/stages';
  static String stageById(String id) => '/stages/$id';
  static String stageSubjects(String stageId) =>
      '/stages/$stageId'; // Returns subject with topics

  // ── Subjects ───────────────────────────────────────────────────────────
  static const String subjects = '/subjects';
  static String subjectById(String id) => '/subjects/$id';
  static String subjectLessons(String subjectId) =>
      '/topics/$subjectId'; // Returns topic with contents

  // ── Lessons ────────────────────────────────────────────────────────────
  static const String lessons = '/contents';
  static String lessonById(String id) => '/contents/$id';
  static String lessonContent(String lessonId) => '/contents/$lessonId';
  static String lessonProgress(String lessonId) => '/progress/$lessonId';

  // ── Media / Content ────────────────────────────────────────────────────
  static String mediaStream(String mediaId) => '/media/$mediaId/stream';
  static String mediaDownload(String mediaId) => '/media/$mediaId/download';

  // ── Subscription ──────────────────────────────────────────────────────
  static const String subscriptions = '/subscriptions';
  static const String subscriptionPlans = '/subscriptions/plans';
  static String subscriptionById(String id) => '/subscriptions/$id';
  static const String subscriptionStatus = '/subscriptions/status';

  // ── Notifications ─────────────────────────────────────────────────────
  static const String notifications = '/notifications';
  static String notificationById(String id) => '/notifications/$id';
  static const String notificationsMarkAllRead = '/notifications/mark-all-read';

  // ── Admin Sync ────────────────────────────────────────────────────────
  static const String syncData = '/admin/sync';
  static const String syncStatus = '/admin/sync/status';

  // ── Settings ──────────────────────────────────────────────────────────
  static const String settings = '/settings';
  static const String appConfig = '/settings/config';
}


/// API endpoint constants for the Laravel backend.
class ApiEndpoints {
  ApiEndpoints._();

  // ── Base URL ──────────────────────────────────────────────────────────
  static const String baseUrl = 'http://localhost:8000/api/v1';

  // ── Auth ──────────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String refreshToken = '/auth/refresh';

  // ── Stages (المراحل التعليمية) ────────────────────────────────────────
  static const String stages = '/stages';
  static String stage(int id) => '/stages/$id';

  // ── Grades (الصفوف) ──────────────────────────────────────────────────
  static const String grades = '/grades';
  static String grade(int id) => '/grades/$id';
  static String gradesByStage(int stageId) => '/stages/$stageId/grades';

  // ── Sections (الأقسام) ──────────────────────────────────────────────
  static const String sections = '/sections';
  static String section(int id) => '/sections/$id';
  static String sectionsByGrade(int gradeId) => '/grades/$gradeId/sections';

  // ── Subjects (المواد) ────────────────────────────────────────────────
  static const String subjects = '/subjects';
  static String subject(int id) => '/subjects/$id';
  static String subjectsBySection(int sectionId) =>
      '/sections/$sectionId/subjects';

  // ── Units (الوحدات) ──────────────────────────────────────────────────
  static const String units = '/units';
  static String unit(int id) => '/units/$id';
  static String unitsBySubject(int subjectId) => '/subjects/$subjectId/units';

  // ── Lessons (الدروس) ─────────────────────────────────────────────────
  static const String lessons = '/lessons';
  static String lesson(int id) => '/lessons/$id';
  static String lessonsByUnit(int unitId) => '/units/$unitId/lessons';

  // ── Lesson Files (ملفات الدروس) ──────────────────────────────────────
  static const String lessonFiles = '/lesson-files';
  static String lessonFile(int id) => '/lesson-files/$id';
  static String lessonFilesByLesson(int lessonId) =>
      '/lessons/$lessonId/files';

  // ── Users (المستخدمون) ──────────────────────────────────────────────
  static const String users = '/users';
  static String user(int id) => '/users/$id';
  static String userToggleStatus(int id) => '/users/$id/toggle-status';
  static String userSubscriptions(int id) => '/users/$id/subscriptions';

  // ── Subscriptions (الاشتراكات) ────────────────────────────────────────
  static const String subscriptions = '/subscriptions';
  static String subscription(int id) => '/subscriptions/$id';
  static String subscriptionToggle(int id) =>
      '/subscriptions/$id/toggle-status';

  // ── Notifications (الإشعارات) ────────────────────────────────────────
  static const String notifications = '/notifications';
  static String notification(int id) => '/notifications/$id';
  static const String notificationsSend = '/notifications/send';
  static const String notificationsSendAll = '/notifications/send-all';

  // ── Analytics (التقارير) ──────────────────────────────────────────────
  static const String analytics = '/analytics';
  static const String analyticsOverview = '/analytics/overview';
  static const String analyticsUsers = '/analytics/users';
  static const String analyticsRevenue = '/analytics/revenue';
  static const String analyticsSubscriptions = '/analytics/subscriptions';
  static const String analyticsContent = '/analytics/content';

  // ── Settings (الإعدادات) ──────────────────────────────────────────────
  static const String settings = '/settings';
  static String setting(String key) => '/settings/$key';
  static const String settingsGeneral = '/settings/general';
  static const String settingsNotifications = '/settings/notifications';
  static const String settingsPayment = '/settings/payment';
}

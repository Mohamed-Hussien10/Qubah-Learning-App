/// API endpoint constants for the Laravel backend.
class ApiEndpoints {
  ApiEndpoints._();

  // ── Base URL ──────────────────────────────────────────────────────────
  static const String baseUrl = 'https://qubahom.com/api/v1';
  static const String storageUrl = 'https://qubahom.com/storage';

  // ── Auth ──────────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String refreshToken = '/auth/refresh';

  // ── Stages (المراحل التعليمية) ────────────────────────────────────────
  static const String stages = '/educational-stages';
  static String stage(int id) => '/educational-stages/$id';

  // ── Grades (الصفوف) ──────────────────────────────────────────────────
  static const String grades = '/grades';
  static String grade(int id) => '/grades/$id';

  // ── Sections (الأقسام) ──────────────────────────────────────────────
  static const String sections = '/sections';
  static String section(int id) => '/sections/$id';

  // ── Subjects (المواد) ────────────────────────────────────────────────
  static const String subjects = '/subjects';
  static String subject(int id) => '/subjects/$id';

  // ── Units (الوحدات) ──────────────────────────────────────────────────
  static const String units = '/units';
  static String unit(int id) => '/units/$id';

  // ── Lessons (الدروس) ─────────────────────────────────────────────────
  static const String lessons = '/lessons';
  static String lesson(int id) => '/lessons/$id';

  // ── Lesson Files (ملفات الدروس) ──────────────────────────────────────
  static const String lessonFiles = '/lesson-files';
  static String lessonFile(int id) => '/lesson-files/$id';

  // ── Free Trial Features (التجربة المجانية) ───────────────────────────
  static const String free_trial_stages = '/free-trial/stages';
  static String free_trial_stage(int id) => '/free-trial/stages/$id';

  static const String free_trial_grades = '/free-trial/grades';
  static String free_trial_grade(int id) => '/free-trial/grades/$id';

  static const String free_trial_subjects = '/free-trial/subjects';
  static String free_trial_subject(int id) => '/free-trial/subjects/$id';

  // ── Users (المستخدمون) ──────────────────────────────────────────────
  static const String users = '/users';
  static String user(int id) => '/users/$id';
  static String userToggleStatus(int id) => '/users/$id/toggle-status';

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
/// ──────────────────────────────────────────────────────────────────────────────
/// Application Constants
///
/// Global constants used throughout the application.
/// ──────────────────────────────────────────────────────────────────────────────
class AppConstants {
  AppConstants._();

  // ── App Info ────────────────────────────────────────────────────────────
  static const String appName = 'Qubah Learning';
  static const String appTagline = 'Learn, Play & Grow!';
  static const String appVersion = '1.0.0';

  // ── Animation Durations ────────────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration animVerySlow = Duration(milliseconds: 800);

  // ── Layout ─────────────────────────────────────────────────────────────
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;
  static const double borderRadiusRound = 100.0;

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double iconSizeSmall = 18.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // ── Breakpoints (Responsive) ──────────────────────────────────────────
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // ── Parent Lock ───────────────────────────────────────────────────────
  static const int parentPinLength = 4;

  // ── Subscription ──────────────────────────────────────────────────────
  static const int trialDurationDays = 7;
  static const int activationCodeLength = 12;

  // ── Media ─────────────────────────────────────────────────────────────
  static const int maxVideoBufferMs = 5000;
  static const double defaultPlaybackSpeed = 1.0;
  static const List<double> playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  // ── Cache ─────────────────────────────────────────────────────────────
  static const Duration cacheMaxAge = Duration(hours: 24);
  static const int maxCacheItems = 100;

  // ── Pagination ────────────────────────────────────────────────────────
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // ── Lesson Types ──────────────────────────────────────────────────────
  static const String lessonTypeVideo = 'video';
  static const String lessonTypeAudio = 'audio';
  static const String lessonTypePdf = 'pdf';
  static const String lessonTypeInteractive = 'interactive';
  static const String lessonTypeGame = 'game';
}

/// ──────────────────────────────────────────────────────────────────────────────
/// Centralised string constants.
/// ──────────────────────────────────────────────────────────────────────────────
class AppStrings {
  AppStrings._();

  static const String appName = 'Qubah Learning';
  static const String appTagline = 'Interactive SCORM Learning Player';

  // ── Home Screen ───────────────────────────────────────────────────────────
  static const String pickScormZip = 'تحميل حزمة سكورم';
  static const String recentPackages = 'الحزم الأخيرة';
  static const String noRecentPackages = 'لا توجد حزم محملة بعد';
  static const String openPackage = 'فتح';
  static const String deletePackage = 'حذف';

  // ── Player Screen ─────────────────────────────────────────────────────────
  static const String loading = 'جاري التحميل…';
  static const String extracting = 'جاري استخراج الحزمة…';
  static const String loadingWebView = 'جاري تهيئة العرض…';
  static const String reload = 'إعادة تحميل';
  static const String fullscreen = 'ملء الشاشة';

  // ── Errors ────────────────────────────────────────────────────────────────
  static const String errorNoHtmlFound =
      'لم يتم العثور على ملف HTML في الحزمة.';
  static const String errorExtraction = 'فشل استخراج حزمة السكورم.';
  static const String errorFileRead = 'فشل قراءة الملف المحدد.';
  static const String errorInvalidZip = 'الملف المحدد ليس أرشيف ZIP صالحاً.';
  static const String errorWebView = 'فشل عرض المحتوى في المتصفح الداخلي.';

  // ── Security Placeholders ─────────────────────────────────────────────────
  static const String securityZipEncryption = '[عنصر نائب] التحقق من تشفير ZIP';
  static const String securityTokenValidation =
      '[عنصر نائب] التحقق من صلاحية الوصول';
  static const String securityScreenshotProtection =
      '[عنصر نائب] تم تفعيل حماية تصوير الشاشة';
}

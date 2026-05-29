/// Utility for mapping technical exception messages to user-friendly Arabic strings.
class ErrorUtils {
  ErrorUtils._();

  /// Converts a technical exception string into a friendly Arabic message.
  static String getFriendlyMessage(String technicalMessage) {
    final lower = technicalMessage.toLowerCase();
    
    if (lower.contains('socket') || lower.contains('connection') || lower.contains('network') || lower.contains('host')) {
      return 'عذراً، يبدو أن هناك مشكلة في الاتصال بالإنترنت. يرجى التحقق من الشبكة والمحاولة مرة أخرى.';
    }
    
    if (lower.contains('timeout')) {
      return 'انتهى وقت الاتصال بالخادم. يرجى المحاولة مرة أخرى.';
    }
    
    if (lower.contains('unauthorized') || lower.contains('401') || lower.contains('403')) {
      return 'عذراً، جلسة الدخول انتهت أو لا تملك صلاحية الوصول. يرجى تسجيل الدخول مجدداً.';
    }
    
    if (lower.contains('not found') || lower.contains('404')) {
      return 'عذراً، لم نتمكن من العثور على البيانات المطلوبة.';
    }
    
    if (lower.contains('server') || lower.contains('500') || lower.contains('502')) {
      return 'حدث خطأ في خوادمنا. نحن نعمل على إصلاحه، يرجى المحاولة لاحقاً.';
    }
    
    if (lower.contains('format') || lower.contains('parse')) {
      return 'حدث خطأ غير متوقع أثناء معالجة البيانات.';
    }

    // Default friendly fallback
    return 'عذراً، حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى لاحقاً.';
  }
}

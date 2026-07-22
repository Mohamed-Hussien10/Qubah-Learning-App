import '../../features/authentication/domain/entities/user_entity.dart';

/// Helper utility for verifying student package access and scope restrictions.
class PackageAccessHelper {
  PackageAccessHelper._();

  /// Determines whether the user's subscription is currently active.
  static bool isSubscriptionActive(UserEntity? user) {
    if (user == null) return false;
    return user.isSubscriptionValid;
  }

  /// Determines whether the user's subscription from raw JSON is active.
  static bool isSubscriptionActiveFromJson(Map<String, dynamic>? userData) {
    if (userData == null) return false;
    final status = userData['subscription_status']?.toString().toLowerCase();
    if (status == 'active' || status == 'valid') return true;

    final expiryStr = userData['subscription_expiry']?.toString();
    if (expiryStr != null && expiryStr.isNotEmpty) {
      final expiry = DateTime.tryParse(expiryStr);
      if (expiry != null && expiry.isAfter(DateTime.now())) {
        return true;
      }
    }
    return false;
  }

  /// Checks whether a student can access a specific Educational Stage.
  static bool canAccessStage({
    required Map<String, dynamic>? userData,
    required String stageId,
  }) {
    if (userData == null) return true; // Guest/default fallback
    if (!isSubscriptionActiveFromJson(userData)) return false;

    // Check package or user stage scope
    final package = userData['package'] as Map<String, dynamic>?;
    final pkgStageId = package?['educational_stage_id']?.toString() ??
        package?['stage_id']?.toString() ??
        userData['stage_id']?.toString();

    if (pkgStageId == null || pkgStageId.isEmpty) return true;
    return pkgStageId == stageId;
  }

  /// Checks whether a student can access a specific Grade.
  static bool canAccessGrade({
    required Map<String, dynamic>? userData,
    required String stageId,
    required String gradeId,
  }) {
    if (userData == null) return true;
    if (!isSubscriptionActiveFromJson(userData)) return false;

    // Stage level check first
    if (!canAccessStage(userData: userData, stageId: stageId)) return false;

    final package = userData['package'] as Map<String, dynamic>?;
    final pkgGradeId = package?['grade_id']?.toString() ?? userData['grade_id']?.toString();

    if (pkgGradeId == null || pkgGradeId.isEmpty) return true;
    return pkgGradeId == gradeId;
  }

  /// Checks whether a student can access a specific Section.
  static bool canAccessSection({
    required Map<String, dynamic>? userData,
    required String sectionId,
  }) {
    if (userData == null) return true;
    if (!isSubscriptionActiveFromJson(userData)) return false;

    final package = userData['package'] as Map<String, dynamic>?;
    final pkgSectionId = package?['section_id']?.toString();

    if (pkgSectionId == null || pkgSectionId.isEmpty) return true;
    return pkgSectionId == sectionId;
  }

  /// Checks whether a student can access a specific Subject.
  static bool canAccessSubject({
    required Map<String, dynamic>? userData,
    required String subjectId,
  }) {
    if (userData == null) return true;
    if (!isSubscriptionActiveFromJson(userData)) return false;

    final package = userData['package'] as Map<String, dynamic>?;
    final pkgSubjectId = package?['subject_id']?.toString();

    if (pkgSubjectId == null || pkgSubjectId.isEmpty) return true;
    return pkgSubjectId == subjectId;
  }

  /// Returns user friendly package description text from raw user json.
  static String getPackageDisplayName(Map<String, dynamic>? userData) {
    if (userData == null) return 'لا يوجد باقة';
    final package = userData['package'] as Map<String, dynamic>?;
    if (package != null && package['name'] != null) {
      return package['name'].toString();
    }
    if (userData['package_name'] != null) {
      return userData['package_name'].toString();
    }
    return 'باقة غير محددة';
  }
}

import 'dart:convert';
import '../../features/authentication/domain/entities/user_entity.dart';
import '../services/logger_service.dart';

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

  /// Extracts embedded scope metadata tag from package description JSON if available.
  static Map<String, dynamic>? _getScopeMeta(Map<String, dynamic>? userData) {
    if (userData == null) return null;
    final package = userData['package'] as Map<String, dynamic>?;

    // Check if package map already contains deserialized array keys
    if (package != null) {
      if (package.containsKey('is_all_stages') || package.containsKey('stage_ids')) {
        return package;
      }
      if (package['scope_meta'] is Map<String, dynamic>) {
        return package['scope_meta'] as Map<String, dynamic>;
      }
    }

    // Check raw or description strings for embedded HTML comment tag
    final desc = package?['description']?.toString() ??
        package?['raw_description']?.toString() ??
        userData['package_description']?.toString();
    if (desc != null && desc.contains('<!--SCOPE_META:')) {
      try {
        final regExp = RegExp(r'<!--SCOPE_META:(.*?)-->', dotAll: true);
        final match = regExp.firstMatch(desc);
        if (match != null && match.group(1) != null) {
          return jsonDecode(match.group(1)!) as Map<String, dynamic>;
        }
      } catch (_) {}
    }
    return null;
  }

  /// Extracts the target Stage ID from userData JSON.
  static String? getPackageStageId(Map<String, dynamic>? userData) {
    if (userData == null) return null;
    final package = userData['package'] as Map<String, dynamic>?;
    final id = package?['educational_stage_id']?.toString() ??
        package?['stage_id']?.toString() ??
        package?['educational_stage']?['id']?.toString() ??
        package?['stage']?['id']?.toString() ??
        userData['stage_id']?.toString();
    return (id != null && id.isNotEmpty) ? id : null;
  }

  /// Extracts the target Grade ID from userData JSON.
  static String? getPackageGradeId(Map<String, dynamic>? userData) {
    if (userData == null) return null;
    final package = userData['package'] as Map<String, dynamic>?;
    final id = package?['grade_id']?.toString() ??
        package?['grade']?['id']?.toString() ??
        package?['section']?['grade_id']?.toString() ??
        package?['subject']?['section']?['grade_id']?.toString() ??
        userData['grade_id']?.toString();
    return (id != null && id.isNotEmpty) ? id : null;
  }

  /// Extracts the target Section ID from userData JSON.
  static String? getPackageSectionId(Map<String, dynamic>? userData) {
    if (userData == null) return null;
    final package = userData['package'] as Map<String, dynamic>?;
    final id = package?['section_id']?.toString() ??
        package?['section']?['id']?.toString() ??
        package?['subject']?['section_id']?.toString() ??
        userData['section_id']?.toString();
    return (id != null && id.isNotEmpty) ? id : null;
  }

  /// Extracts the target Section title from userData JSON.
  static String? getPackageSectionTitle(Map<String, dynamic>? userData) {
    if (userData == null) return null;
    final package = userData['package'] as Map<String, dynamic>?;
    final title = package?['section_title']?.toString() ??
        package?['section']?['title']?.toString() ??
        package?['section']?['name']?.toString() ??
        package?['subject']?['section']?['title']?.toString() ??
        package?['subject']?['section']?['name']?.toString();
    return (title != null && title.isNotEmpty) ? title : null;
  }

  /// Extracts the target Subject ID from userData JSON.
  static String? getPackageSubjectId(Map<String, dynamic>? userData) {
    if (userData == null) return null;
    final package = userData['package'] as Map<String, dynamic>?;
    final id = package?['subject_id']?.toString() ??
        package?['subject']?['id']?.toString() ??
        userData['subject_id']?.toString();
    return (id != null && id.isNotEmpty) ? id : null;
  }

  /// Extracts the target Subject title from userData JSON.
  static String? getPackageSubjectTitle(Map<String, dynamic>? userData) {
    if (userData == null) return null;
    final package = userData['package'] as Map<String, dynamic>?;
    final title = package?['subject_title']?.toString() ??
        package?['subject']?['title']?.toString() ??
        package?['subject']?['name']?.toString();
    return (title != null && title.isNotEmpty) ? title : null;
  }

  static String _normalizeArabic(String input) {
    return input
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .toLowerCase();
  }

  /// Checks whether a student can access a specific Educational Stage.
  static bool canAccessStage({
    required Map<String, dynamic>? userData,
    required String stageId,
  }) {
    if (userData == null) return true; // Guest/default fallback
    if (!isSubscriptionActiveFromJson(userData)) {
      LoggerService.instance.debug('🔒 [canAccessStage] Access DENIED (Subscription Expired) for Stage ID: $stageId');
      return false;
    }

    final meta = _getScopeMeta(userData);
    if (meta != null) {
      if (meta['is_all_stages'] == true) {
        LoggerService.instance.debug('🔓 [canAccessStage] Access ALLOWED (All Stages) for Stage ID: $stageId');
        return true;
      }
      final stageIds = List<String>.from(meta['stage_ids'] ?? []);
      if (stageIds.isNotEmpty) {
        final allowed = stageIds.contains(stageId);
        LoggerService.instance.debug(
          '🔍 [canAccessStage] Stage ID: $stageId | Target Stage IDs: $stageIds | Access: $allowed',
        );
        return allowed;
      }
    }

    final pkgStageId = getPackageStageId(userData);
    if (pkgStageId == null) return true;
    final allowed = (pkgStageId == stageId);
    LoggerService.instance.debug(
      '🔍 [canAccessStage Legacy] Stage ID: $stageId | Pkg Stage ID: $pkgStageId | Access: $allowed',
    );
    return allowed;
  }

  /// Checks whether a student can access a specific Grade.
  static bool canAccessGrade({
    required Map<String, dynamic>? userData,
    String? stageId,
    required String gradeId,
  }) {
    if (userData == null) return true;
    if (!isSubscriptionActiveFromJson(userData)) return false;

    // Stage level check first (if stageId provided)
    if (stageId != null && !canAccessStage(userData: userData, stageId: stageId)) {
      LoggerService.instance.debug('🔒 [canAccessGrade] Stage $stageId not allowed -> Grade $gradeId DENIED');
      return false;
    }

    final meta = _getScopeMeta(userData);
    if (meta != null) {
      if (meta['is_all_grades'] == true) {
        LoggerService.instance.debug('🔓 [canAccessGrade] Access ALLOWED (All Grades) for Grade ID: $gradeId');
        return true;
      }
      final gradeIds = List<String>.from(meta['grade_ids'] ?? []);
      if (gradeIds.isNotEmpty) {
        final allowed = gradeIds.contains(gradeId);
        LoggerService.instance.debug(
          '🔍 [canAccessGrade] Grade ID: $gradeId | Subset Grade IDs: $gradeIds | Access: $allowed',
        );
        return allowed;
      }
      LoggerService.instance.debug('🔓 [canAccessGrade] Access ALLOWED (No Grade Restrictions) for Grade ID: $gradeId');
      return true;
    }

    final pkgGradeId = getPackageGradeId(userData);
    if (pkgGradeId == null) return true;
    final allowed = (pkgGradeId == gradeId);
    LoggerService.instance.debug(
      '🔍 [canAccessGrade Legacy] Grade ID: $gradeId | Pkg Grade ID: $pkgGradeId | Access: $allowed',
    );
    return allowed;
  }

  /// Checks whether a student can access a specific Section.
  static bool canAccessSection({
    required Map<String, dynamic>? userData,
    required String sectionId,
    String? sectionName,
    String? gradeId,
    String? stageId,
  }) {
    if (userData == null) return true;
    if (!isSubscriptionActiveFromJson(userData)) return false;

    if (gradeId != null &&
        !canAccessGrade(
          userData: userData,
          stageId: stageId,
          gradeId: gradeId,
        )) {
      LoggerService.instance.debug('🔒 [canAccessSection] Grade $gradeId not allowed -> Section $sectionId DENIED');
      return false;
    }

    final meta = _getScopeMeta(userData);
    if (meta != null) {
      if (meta['is_all_sections'] == true) {
        LoggerService.instance.debug('🔓 [canAccessSection] Access ALLOWED (All Sections) for Section ID: $sectionId');
        return true;
      }
      final sectionIds = List<String>.from(meta['section_ids'] ?? []);
      if (sectionIds.isNotEmpty) {
        final allowed = sectionIds.contains(sectionId);
        LoggerService.instance.debug(
          '🔍 [canAccessSection] Section ID: $sectionId | Subset Section IDs: $sectionIds | Access: $allowed',
        );
        return allowed;
      }
      LoggerService.instance.debug('🔓 [canAccessSection] Access ALLOWED (No Section Restrictions) for Section ID: $sectionId');
      return true;
    }

    final pkgSectionId = getPackageSectionId(userData);
    final pkgSectionTitle = getPackageSectionTitle(userData);
    final pkgName = getPackageDisplayName(userData);

    final normSectionName = sectionName != null ? _normalizeArabic(sectionName) : null;
    final normPkgSectionTitle = pkgSectionTitle != null ? _normalizeArabic(pkgSectionTitle) : null;
    final normPkgName = _normalizeArabic(pkgName);

    if (pkgSectionId != null) {
      if (pkgSectionId == sectionId) return true;
      if (normSectionName != null && normPkgSectionTitle != null && normPkgSectionTitle == normSectionName) return true;
      if (normSectionName != null && normPkgName.contains(normSectionName)) return true;
      return false;
    }

    if (normPkgSectionTitle != null && normSectionName != null) {
      if (normPkgSectionTitle == normSectionName || normPkgSectionTitle.contains(normSectionName)) return true;
      return false;
    }

    if (normSectionName != null && normPkgName.isNotEmpty) {
      if (normPkgName.contains('فصل')) {
        return normPkgName.contains(normSectionName);
      }
    }

    return true;
  }

  /// Checks whether a student can access a specific Subject.
  static bool canAccessSubject({
    required Map<String, dynamic>? userData,
    required String subjectId,
    String? subjectName,
    String? sectionId,
    String? gradeId,
    String? stageId,
  }) {
    if (userData == null) return true;
    if (!isSubscriptionActiveFromJson(userData)) return false;

    if (sectionId != null &&
        !canAccessSection(
          userData: userData,
          sectionId: sectionId,
          gradeId: gradeId,
          stageId: stageId,
        )) {
      LoggerService.instance.debug('🔒 [canAccessSubject] Section $sectionId not allowed -> Subject $subjectId DENIED');
      return false;
    }

    final meta = _getScopeMeta(userData);
    if (meta != null) {
      if (meta['is_all_subjects'] == true) {
        LoggerService.instance.debug('🔓 [canAccessSubject] Access ALLOWED (All Subjects) for Subject ID: $subjectId');
        return true;
      }
      final subjectIds = List<String>.from(meta['subject_ids'] ?? []);
      if (subjectIds.isNotEmpty) {
        final allowed = subjectIds.contains(subjectId);
        LoggerService.instance.debug(
          '🔍 [canAccessSubject] Subject ID: $subjectId | Subset Subject IDs: $subjectIds | Access: $allowed',
        );
        return allowed;
      }
      LoggerService.instance.debug('🔓 [canAccessSubject] Access ALLOWED (No Subject Restrictions) for Subject ID: $subjectId');
      return true;
    }

    final pkgSubjectId = getPackageSubjectId(userData);
    final pkgSubjectTitle = getPackageSubjectTitle(userData);
    final pkgName = getPackageDisplayName(userData);

    final normSubjectName = subjectName != null ? _normalizeArabic(subjectName) : null;
    final normPkgSubjectTitle = pkgSubjectTitle != null ? _normalizeArabic(pkgSubjectTitle) : null;
    final normPkgName = _normalizeArabic(pkgName);

    if (pkgSubjectId != null) {
      if (pkgSubjectId == subjectId) return true;
      if (normSubjectName != null && normPkgSubjectTitle != null && normPkgSubjectTitle == normSubjectName) return true;
      if (normSubjectName != null && normPkgName.contains(normSubjectName)) return true;
      return false;
    }

    if (normPkgSubjectTitle != null && normSubjectName != null) {
      if (normPkgSubjectTitle == normSubjectName || normPkgSubjectTitle.contains(normSubjectName)) return true;
      return false;
    }

    if (normSubjectName != null && normPkgName.isNotEmpty) {
      if (normPkgName.contains('مادة') || normPkgName.contains('كورس')) {
        return normPkgName.contains(normSubjectName);
      }
    }

    return true;
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

import 'dart:convert';
import 'package:equatable/equatable.dart';

/// Model representing a Subscription Package in the platform.
class PackageModel extends Equatable {
  final String id;
  final String name;
  final double price;
  final String educationalStageId;
  final String? gradeId;
  final String? sectionId;
  final String? subjectId;
  final String? description;
  final DateTime? expiryDate;
  final bool isActive;
  final DateTime? createdAt;

  // Eager loaded title helpers (legacy single selection)
  final String? educationalStageTitle;
  final String? gradeTitle;
  final String? sectionTitle;
  final String? subjectTitle;

  // Multi-subset fields
  final bool isAllStages;
  final List<String> stageIds;
  final bool isAllGrades;
  final List<String> gradeIds;
  final bool isAllSections;
  final List<String> sectionIds;
  final bool isAllSubjects;
  final List<String> subjectIds;

  final List<String> stageTitles;
  final List<String> gradeTitles;
  final List<String> sectionTitles;
  final List<String> subjectTitles;

  const PackageModel({
    required this.id,
    required this.name,
    required this.price,
    required this.educationalStageId,
    this.gradeId,
    this.sectionId,
    this.subjectId,
    this.description,
    this.expiryDate,
    this.isActive = true,
    this.createdAt,
    this.educationalStageTitle,
    this.gradeTitle,
    this.sectionTitle,
    this.subjectTitle,
    this.isAllStages = false,
    this.stageIds = const [],
    this.isAllGrades = false,
    this.gradeIds = const [],
    this.isAllSections = false,
    this.sectionIds = const [],
    this.isAllSubjects = false,
    this.subjectIds = const [],
    this.stageTitles = const [],
    this.gradeTitles = const [],
    this.sectionTitles = const [],
    this.subjectTitles = const [],
  });

  @override
  List<Object?> get props => [
        id,
        name,
        price,
        educationalStageId,
        gradeId,
        sectionId,
        subjectId,
        description,
        expiryDate,
        isActive,
        createdAt,
        educationalStageTitle,
        gradeTitle,
        sectionTitle,
        subjectTitle,
        isAllStages,
        stageIds,
        isAllGrades,
        gradeIds,
        isAllSections,
        sectionIds,
        isAllSubjects,
        subjectIds,
        stageTitles,
        gradeTitles,
        sectionTitles,
        subjectTitles,
      ];

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    String? getRelationTitle(dynamic rel) {
      if (rel == null) return null;
      if (rel is Map<String, dynamic>) {
        return rel['title']?.toString() ?? rel['name']?.toString();
      }
      return null;
    }

    final rawStageId = json['educational_stage_id']?.toString() ?? '';
    final rawGradeId = json['grade_id']?.toString();
    final rawSectionId = json['section_id']?.toString();
    final rawSubjectId = json['subject_id']?.toString();

    final stageTitle = getRelationTitle(json['educational_stage']);
    final gradeTitle = getRelationTitle(json['grade']);
    final sectionTitle = getRelationTitle(json['section']);
    final subjectTitle = getRelationTitle(json['subject']);

    final rawDesc = json['description']?.toString();
    String? cleanDesc = rawDesc;

    bool isAllStages = false;
    List<String> stageIds = rawStageId.isNotEmpty ? [rawStageId] : [];
    bool isAllGrades = rawGradeId == null || rawGradeId.isEmpty;
    List<String> gradeIds = (rawGradeId != null && rawGradeId.isNotEmpty) ? [rawGradeId] : [];
    bool isAllSections = rawSectionId == null || rawSectionId.isEmpty;
    List<String> sectionIds = (rawSectionId != null && rawSectionId.isNotEmpty) ? [rawSectionId] : [];
    bool isAllSubjects = rawSubjectId == null || rawSubjectId.isEmpty;
    List<String> subjectIds = (rawSubjectId != null && rawSubjectId.isNotEmpty) ? [rawSubjectId] : [];

    List<String> stageTitles = stageTitle != null && stageTitle.isNotEmpty ? [stageTitle] : [];
    List<String> gradeTitles = gradeTitle != null && gradeTitle.isNotEmpty ? [gradeTitle] : [];
    List<String> sectionTitles = sectionTitle != null && sectionTitle.isNotEmpty ? [sectionTitle] : [];
    List<String> subjectTitles = subjectTitle != null && subjectTitle.isNotEmpty ? [subjectTitle] : [];

    if (rawDesc != null && rawDesc.contains('<!--SCOPE_META:')) {
      final regExp = RegExp(r'<!--SCOPE_META:(.*?)-->', dotAll: true);
      final match = regExp.firstMatch(rawDesc);
      if (match != null) {
        final metaJsonStr = match.group(1);
        if (metaJsonStr != null) {
          try {
            final Map<String, dynamic> meta = jsonDecode(metaJsonStr);
            isAllStages = meta['is_all_stages'] == true;
            stageIds = List<String>.from(meta['stage_ids'] ?? []);
            isAllGrades = meta['is_all_grades'] == true;
            gradeIds = List<String>.from(meta['grade_ids'] ?? []);
            isAllSections = meta['is_all_sections'] == true;
            sectionIds = List<String>.from(meta['section_ids'] ?? []);
            isAllSubjects = meta['is_all_subjects'] == true;
            subjectIds = List<String>.from(meta['subject_ids'] ?? []);

            stageTitles = List<String>.from(meta['stage_titles'] ?? []);
            gradeTitles = List<String>.from(meta['grade_titles'] ?? []);
            sectionTitles = List<String>.from(meta['section_titles'] ?? []);
            subjectTitles = List<String>.from(meta['subject_titles'] ?? []);
          } catch (_) {}
        }
        cleanDesc = rawDesc.replaceAll(regExp, '').trim();
        if (cleanDesc.isEmpty) cleanDesc = null;
      }
    }

    return PackageModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      educationalStageId: rawStageId,
      gradeId: rawGradeId,
      sectionId: rawSectionId,
      subjectId: rawSubjectId,
      description: cleanDesc,
      expiryDate: json['expiry_date'] != null
          ? DateTime.tryParse(json['expiry_date'].toString())
          : null,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      educationalStageTitle: stageTitle,
      gradeTitle: gradeTitle,
      sectionTitle: sectionTitle,
      subjectTitle: subjectTitle,
      isAllStages: isAllStages,
      stageIds: stageIds,
      isAllGrades: isAllGrades,
      gradeIds: gradeIds,
      isAllSections: isAllSections,
      sectionIds: sectionIds,
      isAllSubjects: isAllSubjects,
      subjectIds: subjectIds,
      stageTitles: stageTitles,
      gradeTitles: gradeTitles,
      sectionTitles: sectionTitles,
      subjectTitles: subjectTitles,
    );
  }

  Map<String, dynamic> toJson() {
    final metaData = {
      'is_all_stages': isAllStages,
      'stage_ids': stageIds,
      'is_all_grades': isAllGrades,
      'grade_ids': gradeIds,
      'is_all_sections': isAllSections,
      'section_ids': sectionIds,
      'is_all_subjects': isAllSubjects,
      'subject_ids': subjectIds,
      'stage_titles': stageTitles,
      'grade_titles': gradeTitles,
      'section_titles': sectionTitles,
      'subject_titles': subjectTitles,
    };

    final scopeMetaJson = jsonEncode(metaData);
    final String fullDesc = (description != null && description!.trim().isNotEmpty)
        ? "${description!.trim()}\n<!--SCOPE_META:$scopeMetaJson-->"
        : "<!--SCOPE_META:$scopeMetaJson-->";

    final effectiveStageId = stageIds.isNotEmpty ? stageIds.first : educationalStageId;
    final effectiveGradeId = (!isAllGrades && gradeIds.length == 1) ? gradeIds.first : null;
    final effectiveSectionId = (!isAllSections && sectionIds.length == 1) ? sectionIds.first : null;
    final effectiveSubjectId = (!isAllSubjects && subjectIds.length == 1) ? subjectIds.first : null;

    return {
      'id': id,
      'name': name,
      'price': price,
      'educational_stage_id': effectiveStageId,
      'grade_id': effectiveGradeId,
      'section_id': effectiveSectionId,
      'subject_id': effectiveSubjectId,
      'description': fullDesc,
      'expiry_date': expiryDate != null
          ? "${expiryDate!.year.toString().padLeft(4, '0')}-${expiryDate!.month.toString().padLeft(2, '0')}-${expiryDate!.day.toString().padLeft(2, '0')}"
          : null,
      'is_active': isActive ? 1 : 0,
    };
  }

  /// Returns readable hierarchical scope string.
  String get scopeText {
    if (isAllStages) return 'كل المراحل التعليمية';

    final List<String> parts = [];

    // Stage part
    if (stageTitles.isNotEmpty) {
      parts.add(stageTitles.join(' + '));
    } else if (stageIds.isNotEmpty) {
      parts.add('${stageIds.length} مرحلة');
    } else if (educationalStageTitle != null && educationalStageTitle!.isNotEmpty) {
      parts.add(educationalStageTitle!);
    }

    // Grade part
    if (isAllGrades) {
      parts.add('كل الصفوف');
    } else if (gradeTitles.isNotEmpty) {
      parts.add(gradeTitles.join(' + '));
    } else if (gradeIds.isNotEmpty) {
      parts.add('${gradeIds.length} صفوف');
    } else if (gradeTitle != null && gradeTitle!.isNotEmpty) {
      parts.add(gradeTitle!);
    }

    // Section part
    if (isAllSections) {
      parts.add('كل الفصول');
    } else if (sectionTitles.isNotEmpty) {
      parts.add(sectionTitles.join(' + '));
    } else if (sectionIds.isNotEmpty) {
      parts.add('${sectionIds.length} فصول');
    } else if (sectionTitle != null && sectionTitle!.isNotEmpty) {
      parts.add(sectionTitle!);
    }

    // Subject part
    if (isAllSubjects) {
      parts.add('كل المواد');
    } else if (subjectTitles.isNotEmpty) {
      parts.add(subjectTitles.join(' + '));
    } else if (subjectIds.isNotEmpty) {
      parts.add('${subjectIds.length} مواد');
    } else if (subjectTitle != null && subjectTitle!.isNotEmpty) {
      parts.add(subjectTitle!);
    }

    if (parts.isEmpty) return 'غير محدد';
    return parts.join(' ➔ ');
  }

  /// Label indicating at what level the package scope is structured.
  String get scopeLevelLabel {
    if (isAllStages) return 'شامل كل المراحل';
    if (!isAllSubjects && (subjectIds.isNotEmpty || subjectId != null)) return 'مواد محددة';
    if (!isAllSections && (sectionIds.isNotEmpty || sectionId != null)) return 'فصول محددة';
    if (!isAllGrades && (gradeIds.isNotEmpty || gradeId != null)) return 'صفوف محددة';
    return 'مراحل محددة';
  }

  PackageModel copyWith({
    String? id,
    String? name,
    double? price,
    String? educationalStageId,
    String? gradeId,
    String? sectionId,
    String? subjectId,
    String? description,
    DateTime? expiryDate,
    bool? isActive,
    DateTime? createdAt,
    String? educationalStageTitle,
    String? gradeTitle,
    String? sectionTitle,
    String? subjectTitle,
    bool? isAllStages,
    List<String>? stageIds,
    bool? isAllGrades,
    List<String>? gradeIds,
    bool? isAllSections,
    List<String>? sectionIds,
    bool? isAllSubjects,
    List<String>? subjectIds,
    List<String>? stageTitles,
    List<String>? gradeTitles,
    List<String>? sectionTitles,
    List<String>? subjectTitles,
  }) {
    return PackageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      educationalStageId: educationalStageId ?? this.educationalStageId,
      gradeId: gradeId ?? this.gradeId,
      sectionId: sectionId ?? this.sectionId,
      subjectId: subjectId ?? this.subjectId,
      description: description ?? this.description,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      educationalStageTitle: educationalStageTitle ?? this.educationalStageTitle,
      gradeTitle: gradeTitle ?? this.gradeTitle,
      sectionTitle: sectionTitle ?? this.sectionTitle,
      subjectTitle: subjectTitle ?? this.subjectTitle,
      isAllStages: isAllStages ?? this.isAllStages,
      stageIds: stageIds ?? this.stageIds,
      isAllGrades: isAllGrades ?? this.isAllGrades,
      gradeIds: gradeIds ?? this.gradeIds,
      isAllSections: isAllSections ?? this.isAllSections,
      sectionIds: sectionIds ?? this.sectionIds,
      isAllSubjects: isAllSubjects ?? this.isAllSubjects,
      subjectIds: subjectIds ?? this.subjectIds,
      stageTitles: stageTitles ?? this.stageTitles,
      gradeTitles: gradeTitles ?? this.gradeTitles,
      sectionTitles: sectionTitles ?? this.sectionTitles,
      subjectTitles: subjectTitles ?? this.subjectTitles,
    );
  }
}

import 'dart:convert';
import '../../domain/entities/package_entity.dart';

/// Data model for Package JSON serialization and deserialization.
class PackageModel {
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

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    String? getRelationTitle(dynamic rel) {
      if (rel == null) return null;
      if (rel is Map<String, dynamic>) {
        return rel['title']?.toString() ?? rel['name']?.toString();
      }
      return null;
    }

    final rawStageId = json['educational_stage_id']?.toString() ??
        json['stage_id']?.toString() ??
        json['educational_stage']?['id']?.toString() ??
        json['stage']?['id']?.toString() ??
        '';

    final rawGradeId = json['grade_id']?.toString() ??
        json['grade']?['id']?.toString() ??
        json['section']?['grade_id']?.toString() ??
        json['subject']?['section']?['grade_id']?.toString();

    final rawSectionId = json['section_id']?.toString() ??
        json['section']?['id']?.toString() ??
        json['subject']?['section_id']?.toString();

    final rawSubjectId = json['subject_id']?.toString() ??
        json['subject']?['id']?.toString();

    final stageTitle = getRelationTitle(json['educational_stage'] ?? json['stage']);
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

    // Direct JSON keys check first
    if (json.containsKey('is_all_stages') || json.containsKey('stage_ids')) {
      isAllStages = json['is_all_stages'] == true;
      stageIds = List<String>.from(json['stage_ids'] ?? stageIds);
      isAllGrades = json['is_all_grades'] == true;
      gradeIds = List<String>.from(json['grade_ids'] ?? gradeIds);
      isAllSections = json['is_all_sections'] == true;
      sectionIds = List<String>.from(json['section_ids'] ?? sectionIds);
      isAllSubjects = json['is_all_subjects'] == true;
      subjectIds = List<String>.from(json['subject_ids'] ?? subjectIds);

      stageTitles = List<String>.from(json['stage_titles'] ?? stageTitles);
      gradeTitles = List<String>.from(json['grade_titles'] ?? gradeTitles);
      sectionTitles = List<String>.from(json['section_titles'] ?? sectionTitles);
      subjectTitles = List<String>.from(json['subject_titles'] ?? subjectTitles);
    } else if (rawDesc != null && rawDesc.contains('<!--SCOPE_META:')) {
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

    return {
      'id': id,
      'name': name,
      'price': price,
      'educational_stage_id': educationalStageId,
      'grade_id': gradeId,
      'section_id': sectionId,
      'subject_id': subjectId,
      'description': fullDesc,
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
      'expiry_date': expiryDate?.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'educational_stage_title': educationalStageTitle,
      'grade_title': gradeTitle,
      'section_title': sectionTitle,
      'subject_title': subjectTitle,
      if (sectionId != null) 'section': {'id': sectionId, 'title': sectionTitle},
      if (subjectId != null) 'subject': {'id': subjectId, 'title': subjectTitle},
      if (gradeId != null) 'grade': {'id': gradeId, 'title': gradeTitle},
      if (educationalStageId.isNotEmpty) 'educational_stage': {'id': educationalStageId, 'title': educationalStageTitle},
    };
  }

  PackageEntity toEntity() {
    return PackageEntity(
      id: id,
      name: name,
      price: price,
      educationalStageId: educationalStageId,
      gradeId: gradeId,
      sectionId: sectionId,
      subjectId: subjectId,
      description: description,
      expiryDate: expiryDate,
      isActive: isActive,
      createdAt: createdAt,
      educationalStageTitle: educationalStageTitle,
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

  factory PackageModel.fromEntity(PackageEntity entity) {
    return PackageModel(
      id: entity.id,
      name: entity.name,
      price: entity.price,
      educationalStageId: entity.educationalStageId,
      gradeId: entity.gradeId,
      sectionId: entity.sectionId,
      subjectId: entity.subjectId,
      description: entity.description,
      expiryDate: entity.expiryDate,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      educationalStageTitle: entity.educationalStageTitle,
      gradeTitle: entity.gradeTitle,
      sectionTitle: entity.sectionTitle,
      subjectTitle: entity.subjectTitle,
      isAllStages: entity.isAllStages,
      stageIds: entity.stageIds,
      isAllGrades: entity.isAllGrades,
      gradeIds: entity.gradeIds,
      isAllSections: entity.isAllSections,
      sectionIds: entity.sectionIds,
      isAllSubjects: entity.isAllSubjects,
      subjectIds: entity.subjectIds,
      stageTitles: entity.stageTitles,
      gradeTitles: entity.gradeTitles,
      sectionTitles: entity.sectionTitles,
      subjectTitles: entity.subjectTitles,
    );
  }
}

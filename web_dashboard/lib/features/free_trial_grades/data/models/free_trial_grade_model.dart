import 'package:web_dashboard/features/shared/models/base_entity.dart';

/// Model representing a freeTrialGrade (صف) within a stage.
class FreeTrialGradeModel extends BaseEntity {
  final String stageId;
  final int subjectsCount;
  final String? thumbnailUrl;

  const FreeTrialGradeModel({
    required super.id,
    required this.stageId,
    required super.title,
    super.description,
    this.thumbnailUrl,
    super.isActive = true,
    super.order = 0,
    this.subjectsCount = 0,
    super.createdAt,
  });

  @override
  List<Object?> get props => [...super.props, stageId, subjectsCount, thumbnailUrl];

  factory FreeTrialGradeModel.fromJson(Map<String, dynamic> json) {
    return FreeTrialGradeModel(
      id: json['id']?.toString() ?? '',
      stageId: json['free_trial_educational_stage_id']?.toString() ?? json['educational_stage_id']?.toString() ?? json['stage_id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      thumbnailUrl: json['thumbnail_url'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      order: json['order'] != null ? int.tryParse(json['order'].toString()) ?? 0 : 0,
      subjectsCount: int.tryParse(json['subjects_count']?.toString() ?? '') ?? (json['subjects'] as List?)?.length ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'free_trial_educational_stage_id': stageId,
      'title': title,
      'description': description,
      'thumbnail_path': thumbnailUrl,
      'is_active': isActive ? 1 : 0,
      'order': order,
      'subjects_count': subjectsCount,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  FreeTrialGradeModel copyWith({
    String? id,
    String? stageId,
    String? title,
    String? description,
    String? thumbnailUrl,
    bool? isActive,
    int? order,
    int? subjectsCount,
    DateTime? createdAt,
  }) {
    return FreeTrialGradeModel(
      id: id ?? this.id,
      stageId: stageId ?? this.stageId,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      subjectsCount: subjectsCount ?? this.subjectsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Dummy data keyed by stageId.
  static Map<String, List<FreeTrialGradeModel>> get dummyMap => {
        'stage-1': [
          FreeTrialGradeModel(id: 'freeTrialGrade-1', stageId: 'stage-1', title: 'الصف الأول الابتدائي', description: 'الصف الأول من المرحلة الابتدائية', order: 1, subjectsCount: 2, createdAt: DateTime(2025, 1, 20)),
          FreeTrialGradeModel(id: 'freeTrialGrade-2', stageId: 'stage-1', title: 'الصف الثاني الابتدائي', description: 'الصف الثاني من المرحلة الابتدائية', order: 2, subjectsCount: 2, createdAt: DateTime(2025, 1, 20)),
          FreeTrialGradeModel(id: 'freeTrialGrade-3', stageId: 'stage-1', title: 'الصف الثالث الابتدائي', description: 'الصف الثالث من المرحلة الابتدائية', order: 3, subjectsCount: 2, createdAt: DateTime(2025, 1, 20)),
          FreeTrialGradeModel(id: 'freeTrialGrade-4', stageId: 'stage-1', title: 'الصف الرابع الابتدائي', description: 'الصف الرابع من المرحلة الابتدائية', order: 4, subjectsCount: 1, createdAt: DateTime(2025, 1, 20)),
          FreeTrialGradeModel(id: 'freeTrialGrade-5', stageId: 'stage-1', title: 'الصف الخامس الابتدائي', description: 'الصف الخامس من المرحلة الابتدائية', order: 5, subjectsCount: 1, createdAt: DateTime(2025, 1, 20)),
          FreeTrialGradeModel(id: 'freeTrialGrade-6', stageId: 'stage-1', title: 'الصف السادس الابتدائي', description: 'الصف السادس من المرحلة الابتدائية', order: 6, subjectsCount: 2, createdAt: DateTime(2025, 1, 20)),
        ],
        'stage-2': [
          FreeTrialGradeModel(id: 'freeTrialGrade-7', stageId: 'stage-2', title: 'الصف الأول المتوسط', description: 'الصف الأول من المرحلة المتوسطة', order: 1, subjectsCount: 2, createdAt: DateTime(2025, 2, 15)),
          FreeTrialGradeModel(id: 'freeTrialGrade-8', stageId: 'stage-2', title: 'الصف الثاني المتوسط', description: 'الصف الثاني من المرحلة المتوسطة', order: 2, subjectsCount: 2, createdAt: DateTime(2025, 2, 15)),
          FreeTrialGradeModel(id: 'freeTrialGrade-9', stageId: 'stage-2', title: 'الصف الثالث المتوسط', description: 'الصف الثالث من المرحلة المتوسطة', order: 3, subjectsCount: 2, createdAt: DateTime(2025, 2, 15)),
        ],
        'stage-3': [
          FreeTrialGradeModel(id: 'freeTrialGrade-10', stageId: 'stage-3', title: 'الصف الأول الثانوي', description: 'الصف الأول من المرحلة الثانوية', order: 1, subjectsCount: 2, createdAt: DateTime(2025, 3, 10)),
          FreeTrialGradeModel(id: 'freeTrialGrade-11', stageId: 'stage-3', title: 'الصف الثاني الثانوي', description: 'الصف الثاني من المرحلة الثانوية', order: 2, subjectsCount: 2, createdAt: DateTime(2025, 3, 10)),
          FreeTrialGradeModel(id: 'freeTrialGrade-12', stageId: 'stage-3', title: 'الصف الثالث الثانوي', description: 'الصف الثالث من المرحلة الثانوية', order: 3, subjectsCount: 2, createdAt: DateTime(2025, 3, 10)),
        ],
      };
}

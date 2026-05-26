import 'package:web_dashboard/features/shared/models/base_entity.dart';

/// Model representing a grade (صف) within a stage.
class GradeModel extends BaseEntity {
  final String stageId;
  final int sectionsCount;

  const GradeModel({
    required super.id,
    required this.stageId,
    required super.title,
    super.description,
    super.isActive = true,
    super.order = 0,
    this.sectionsCount = 0,
    super.createdAt,
  });

  @override
  List<Object?> get props => [...super.props, stageId, sectionsCount];

  factory GradeModel.fromJson(Map<String, dynamic> json) {
    return GradeModel(
      id: json['id']?.toString() ?? '',
      stageId: json['stage_id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      isActive: json['is_active'] ?? true,
      order: json['order'] ?? 0,
      sectionsCount: json['sections_count'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stage_id': stageId,
      'title': title,
      'description': description,
      'is_active': isActive,
      'order': order,
      'sections_count': sectionsCount,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  GradeModel copyWith({
    String? id,
    String? stageId,
    String? title,
    String? description,
    bool? isActive,
    int? order,
    int? sectionsCount,
    DateTime? createdAt,
  }) {
    return GradeModel(
      id: id ?? this.id,
      stageId: stageId ?? this.stageId,
      title: title ?? this.title,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      sectionsCount: sectionsCount ?? this.sectionsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Dummy data keyed by stageId.
  static Map<String, List<GradeModel>> get dummyMap => {
        'stage-1': [
          GradeModel(id: 'grade-1', stageId: 'stage-1', title: 'الصف الأول الابتدائي', description: 'الصف الأول من المرحلة الابتدائية', order: 1, sectionsCount: 2, createdAt: DateTime(2025, 1, 20)),
          GradeModel(id: 'grade-2', stageId: 'stage-1', title: 'الصف الثاني الابتدائي', description: 'الصف الثاني من المرحلة الابتدائية', order: 2, sectionsCount: 2, createdAt: DateTime(2025, 1, 20)),
          GradeModel(id: 'grade-3', stageId: 'stage-1', title: 'الصف الثالث الابتدائي', description: 'الصف الثالث من المرحلة الابتدائية', order: 3, sectionsCount: 2, createdAt: DateTime(2025, 1, 20)),
          GradeModel(id: 'grade-4', stageId: 'stage-1', title: 'الصف الرابع الابتدائي', description: 'الصف الرابع من المرحلة الابتدائية', order: 4, sectionsCount: 1, createdAt: DateTime(2025, 1, 20)),
          GradeModel(id: 'grade-5', stageId: 'stage-1', title: 'الصف الخامس الابتدائي', description: 'الصف الخامس من المرحلة الابتدائية', order: 5, sectionsCount: 1, createdAt: DateTime(2025, 1, 20)),
          GradeModel(id: 'grade-6', stageId: 'stage-1', title: 'الصف السادس الابتدائي', description: 'الصف السادس من المرحلة الابتدائية', order: 6, sectionsCount: 2, createdAt: DateTime(2025, 1, 20)),
        ],
        'stage-2': [
          GradeModel(id: 'grade-7', stageId: 'stage-2', title: 'الصف الأول المتوسط', description: 'الصف الأول من المرحلة المتوسطة', order: 1, sectionsCount: 2, createdAt: DateTime(2025, 2, 15)),
          GradeModel(id: 'grade-8', stageId: 'stage-2', title: 'الصف الثاني المتوسط', description: 'الصف الثاني من المرحلة المتوسطة', order: 2, sectionsCount: 2, createdAt: DateTime(2025, 2, 15)),
          GradeModel(id: 'grade-9', stageId: 'stage-2', title: 'الصف الثالث المتوسط', description: 'الصف الثالث من المرحلة المتوسطة', order: 3, sectionsCount: 2, createdAt: DateTime(2025, 2, 15)),
        ],
        'stage-3': [
          GradeModel(id: 'grade-10', stageId: 'stage-3', title: 'الصف الأول الثانوي', description: 'الصف الأول من المرحلة الثانوية', order: 1, sectionsCount: 2, createdAt: DateTime(2025, 3, 10)),
          GradeModel(id: 'grade-11', stageId: 'stage-3', title: 'الصف الثاني الثانوي', description: 'الصف الثاني من المرحلة الثانوية', order: 2, sectionsCount: 2, createdAt: DateTime(2025, 3, 10)),
          GradeModel(id: 'grade-12', stageId: 'stage-3', title: 'الصف الثالث الثانوي', description: 'الصف الثالث من المرحلة الثانوية', order: 3, sectionsCount: 2, createdAt: DateTime(2025, 3, 10)),
        ],
      };
}

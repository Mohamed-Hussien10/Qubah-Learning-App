import 'package:web_dashboard/features/shared/models/base_entity.dart';

/// Model representing a free_trial_subject (مادة) within a grade.
class FreeTrialSubjectModel extends BaseEntity {
  final String gradeId;
  final String? thumbnailUrl;
  final int lessonFilesCount;

  const FreeTrialSubjectModel({
    required super.id,
    required this.gradeId,
    required super.title,
    super.description,
    this.thumbnailUrl,
    super.isActive = true,
    super.order = 0,
    this.lessonFilesCount = 0,
    super.createdAt,
  });

  @override
  List<Object?> get props => [...super.props, gradeId, thumbnailUrl, lessonFilesCount];

  factory FreeTrialSubjectModel.fromJson(Map<String, dynamic> json) {
    return FreeTrialSubjectModel(
      id: json['id']?.toString() ?? '',
      gradeId: json['free_trial_grade_id']?.toString() ?? json['grade_id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      thumbnailUrl: json['thumbnail_url'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      order: json['order'] != null ? int.tryParse(json['order'].toString()) ?? 0 : 0,
      lessonFilesCount: int.tryParse(json['lesson_files_count']?.toString() ?? json['topics_count']?.toString() ?? '') ?? (json['lesson_files'] as List?)?.length ?? (json['topics'] as List?)?.length ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'free_trial_grade_id': gradeId,
      'title': title,
      'description': description,
      'thumbnail_path': thumbnailUrl,
      'is_active': isActive ? 1 : 0,
      'order': order,
      'lesson_files_count': lessonFilesCount,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  FreeTrialSubjectModel copyWith({
    String? id,
    String? gradeId,
    String? title,
    String? description,
    String? thumbnailUrl,
    bool? isActive,
    int? order,
    int? lessonFilesCount,
    DateTime? createdAt,
  }) {
    return FreeTrialSubjectModel(
      id: id ?? this.id,
      gradeId: gradeId ?? this.gradeId,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      lessonFilesCount: lessonFilesCount ?? this.lessonFilesCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Dummy data keyed by gradeId.
  static Map<String, List<FreeTrialSubjectModel>> get dummyMap => {
        'grade-1': [
          FreeTrialSubjectModel(id: 'free_trial_subject-1', gradeId: 'grade-1', title: 'الرياضيات', description: 'الأعداد والعمليات الحسابية الأساسية', thumbnailUrl: 'https://via.placeholder.com/100/6C5CE7/FFFFFF?text=رياضيات', order: 1, lessonFilesCount: 5, createdAt: DateTime(2025, 2, 5)),
          FreeTrialSubjectModel(id: 'free_trial_subject-2', gradeId: 'grade-1', title: 'العلوم', description: 'العلوم الطبيعية والتجارب العملية', thumbnailUrl: 'https://via.placeholder.com/100/10B981/FFFFFF?text=علوم', order: 2, lessonFilesCount: 4, createdAt: DateTime(2025, 2, 5)),
          FreeTrialSubjectModel(id: 'free_trial_subject-3', gradeId: 'grade-1', title: 'الفيزياء', description: 'أساسيات الفيزياء والميكانيكا', order: 3, lessonFilesCount: 3, createdAt: DateTime(2025, 2, 5)),
          FreeTrialSubjectModel(id: 'free_trial_subject-4', gradeId: 'grade-1', title: 'الكيمياء', description: 'أساسيات الكيمياء العامة', order: 4, lessonFilesCount: 3, createdAt: DateTime(2025, 2, 5)),
        ],
        'grade-2': [
          FreeTrialSubjectModel(id: 'free_trial_subject-5', gradeId: 'grade-2', title: 'اللغة العربية', description: 'النحو والصرف والبلاغة', order: 1, lessonFilesCount: 6, createdAt: DateTime(2025, 2, 5)),
          FreeTrialSubjectModel(id: 'free_trial_subject-6', gradeId: 'grade-2', title: 'اللغة الإنجليزية', description: 'القواعد والمحادثة والقراءة', order: 2, lessonFilesCount: 5, createdAt: DateTime(2025, 2, 5)),
          FreeTrialSubjectModel(id: 'free_trial_subject-7', gradeId: 'grade-2', title: 'التاريخ', description: 'التاريخ الإسلامي والعالمي', order: 3, lessonFilesCount: 4, createdAt: DateTime(2025, 2, 5)),
        ],
        'grade-5': [
          FreeTrialSubjectModel(id: 'free_trial_subject-8', gradeId: 'grade-5', title: 'الرياضيات المتقدمة', description: 'التفاضل والتكامل', order: 1, lessonFilesCount: 7, createdAt: DateTime(2025, 4, 5)),
          FreeTrialSubjectModel(id: 'free_trial_subject-9', gradeId: 'grade-5', title: 'الفيزياء', description: 'الديناميكا الحرارية والكهرباء', order: 2, lessonFilesCount: 6, createdAt: DateTime(2025, 4, 5)),
          FreeTrialSubjectModel(id: 'free_trial_subject-10', gradeId: 'grade-5', title: 'الكيمياء', description: 'الكيمياء العضوية وغير العضوية', order: 3, lessonFilesCount: 5, createdAt: DateTime(2025, 4, 5)),
          FreeTrialSubjectModel(id: 'free_trial_subject-11', gradeId: 'grade-5', title: 'الأحياء', description: 'علم الأحياء الخلوي والوراثة', order: 4, lessonFilesCount: 4, createdAt: DateTime(2025, 4, 5)),
          FreeTrialSubjectModel(id: 'free_trial_subject-12', gradeId: 'grade-5', title: 'الحاسب الآلي', description: 'البرمجة وعلوم الحاسب', order: 5, lessonFilesCount: 3, createdAt: DateTime(2025, 4, 5)),
          FreeTrialSubjectModel(id: 'free_trial_subject-13', gradeId: 'grade-5', title: 'اللغة الإنجليزية', description: 'اللغة الإنجليزية المتقدمة', order: 6, lessonFilesCount: 5, createdAt: DateTime(2025, 4, 5)),
        ],
      };
}
import 'package:web_dashboard/features/shared/models/base_entity.dart';

/// Model representing a subject (مادة) within a section.
class SubjectModel extends BaseEntity {
  final String sectionId;
  final String? thumbnailUrl;
  final int unitsCount;

  const SubjectModel({
    required super.id,
    required this.sectionId,
    required super.title,
    super.description,
    this.thumbnailUrl,
    super.isActive = true,
    super.order = 0,
    this.unitsCount = 0,
    super.createdAt,
  });

  @override
  List<Object?> get props => [...super.props, sectionId, thumbnailUrl, unitsCount];

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id']?.toString() ?? '',
      sectionId: json['section_id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      thumbnailUrl: json['thumbnail_url'],
      isActive: json['is_active'] ?? true,
      order: json['order'] ?? 0,
      unitsCount: json['units_count'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section_id': sectionId,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'is_active': isActive,
      'order': order,
      'units_count': unitsCount,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  SubjectModel copyWith({
    String? id,
    String? sectionId,
    String? title,
    String? description,
    String? thumbnailUrl,
    bool? isActive,
    int? order,
    int? unitsCount,
    DateTime? createdAt,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      sectionId: sectionId ?? this.sectionId,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      unitsCount: unitsCount ?? this.unitsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Dummy data keyed by sectionId.
  static Map<String, List<SubjectModel>> get dummyMap => {
        'section-1': [
          SubjectModel(id: 'subject-1', sectionId: 'section-1', title: 'الرياضيات', description: 'الأعداد والعمليات الحسابية الأساسية', thumbnailUrl: 'https://via.placeholder.com/100/6C5CE7/FFFFFF?text=رياضيات', order: 1, unitsCount: 5, createdAt: DateTime(2025, 2, 5)),
          SubjectModel(id: 'subject-2', sectionId: 'section-1', title: 'العلوم', description: 'العلوم الطبيعية والتجارب العملية', thumbnailUrl: 'https://via.placeholder.com/100/10B981/FFFFFF?text=علوم', order: 2, unitsCount: 4, createdAt: DateTime(2025, 2, 5)),
          SubjectModel(id: 'subject-3', sectionId: 'section-1', title: 'الفيزياء', description: 'أساسيات الفيزياء والميكانيكا', order: 3, unitsCount: 3, createdAt: DateTime(2025, 2, 5)),
          SubjectModel(id: 'subject-4', sectionId: 'section-1', title: 'الكيمياء', description: 'أساسيات الكيمياء العامة', order: 4, unitsCount: 3, createdAt: DateTime(2025, 2, 5)),
        ],
        'section-2': [
          SubjectModel(id: 'subject-5', sectionId: 'section-2', title: 'اللغة العربية', description: 'النحو والصرف والبلاغة', order: 1, unitsCount: 6, createdAt: DateTime(2025, 2, 5)),
          SubjectModel(id: 'subject-6', sectionId: 'section-2', title: 'اللغة الإنجليزية', description: 'القواعد والمحادثة والقراءة', order: 2, unitsCount: 5, createdAt: DateTime(2025, 2, 5)),
          SubjectModel(id: 'subject-7', sectionId: 'section-2', title: 'التاريخ', description: 'التاريخ الإسلامي والعالمي', order: 3, unitsCount: 4, createdAt: DateTime(2025, 2, 5)),
        ],
        'section-5': [
          SubjectModel(id: 'subject-8', sectionId: 'section-5', title: 'الرياضيات المتقدمة', description: 'التفاضل والتكامل', order: 1, unitsCount: 7, createdAt: DateTime(2025, 4, 5)),
          SubjectModel(id: 'subject-9', sectionId: 'section-5', title: 'الفيزياء', description: 'الديناميكا الحرارية والكهرباء', order: 2, unitsCount: 6, createdAt: DateTime(2025, 4, 5)),
          SubjectModel(id: 'subject-10', sectionId: 'section-5', title: 'الكيمياء', description: 'الكيمياء العضوية وغير العضوية', order: 3, unitsCount: 5, createdAt: DateTime(2025, 4, 5)),
          SubjectModel(id: 'subject-11', sectionId: 'section-5', title: 'الأحياء', description: 'علم الأحياء الخلوي والوراثة', order: 4, unitsCount: 4, createdAt: DateTime(2025, 4, 5)),
          SubjectModel(id: 'subject-12', sectionId: 'section-5', title: 'الحاسب الآلي', description: 'البرمجة وعلوم الحاسب', order: 5, unitsCount: 3, createdAt: DateTime(2025, 4, 5)),
          SubjectModel(id: 'subject-13', sectionId: 'section-5', title: 'اللغة الإنجليزية', description: 'اللغة الإنجليزية المتقدمة', order: 6, unitsCount: 5, createdAt: DateTime(2025, 4, 5)),
        ],
      };
}

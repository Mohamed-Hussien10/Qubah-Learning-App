import 'package:web_dashboard/features/shared/models/base_entity.dart';

/// Model representing a file (ملف) attached to a subject.
class FreeTrialLessonFileModel extends BaseEntity {
  final String subjectId;
  final String type; // video, audio, pdf, image, scorm, html5
  final String fileUrl;
  final String fileSize;
  final String? thumbnailUrl;

  const FreeTrialLessonFileModel({
    required super.id,
    required this.subjectId,
    required super.title,
    required this.type,
    required this.fileUrl,
    required this.fileSize,
    this.thumbnailUrl,
    super.isActive = true,
    super.order = 0,
    super.createdAt,
  });

  @override
  List<Object?> get props =>
      [...super.props, subjectId, type, fileUrl, fileSize, thumbnailUrl];

  factory FreeTrialLessonFileModel.fromJson(Map<String, dynamic> json) {
    return FreeTrialLessonFileModel(
      id: json['id']?.toString() ?? '',
      subjectId: json['free_trial_subject_id']?.toString() ?? json['subject_id']?.toString() ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? 'pdf',
      fileUrl: json['file_url'] ?? json['file_path'] ?? '',
      fileSize: json['file_size'] ?? (json['metadata'] is Map ? json['metadata']['file_size'] : null) ?? '0 KB',
      thumbnailUrl: json['thumbnail_url'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      order: json['order'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'free_trial_subject_id': subjectId,
      'title': title,
      'type': type,
      'file_url': fileUrl,
      'file_size': fileSize,
      'thumbnail_path': thumbnailUrl,
      'is_active': isActive,
      'order': order,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  FreeTrialLessonFileModel copyWith({
    String? id,
    String? subjectId,
    String? title,
    String? description,
    String? type,
    String? fileUrl,
    String? fileSize,
    String? thumbnailUrl,
    bool? isActive,
    int? order,
    DateTime? createdAt,
  }) {
    return FreeTrialLessonFileModel(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      type: type ?? this.type,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Dummy data keyed by subjectId.
  static Map<String, List<FreeTrialLessonFileModel>> get dummyMap => {
        'subject-1': [
          FreeTrialLessonFileModel(
            id: 'file-1',
            subjectId: 'subject-1',
            title: 'فيديو الشرح الأساسي',
            type: 'video',
            fileUrl: 'https://www.w3schools.com/html/mov_bbb.mp4',
            fileSize: '45.2 MB',
            order: 1,
            createdAt: DateTime(2025, 2, 14),
          ),
          FreeTrialLessonFileModel(
            id: 'file-2',
            subjectId: 'subject-1',
            title: 'كراسة الأنشطة - الأعداد الحقيقية',
            type: 'pdf',
            fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
            fileSize: '2.4 MB',
            order: 2,
            createdAt: DateTime(2025, 2, 14),
          ),
        ],
        'subject-2': [
          FreeTrialLessonFileModel(
            id: 'file-3',
            subjectId: 'subject-2',
            title: 'ورقة عمل - المقارنة والترتيب',
            type: 'pdf',
            fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
            fileSize: '1.8 MB',
            order: 1,
            createdAt: DateTime(2025, 2, 14),
          ),
        ],
        'subject-4': [
          FreeTrialLessonFileModel(
            id: 'file-4',
            subjectId: 'subject-4',
            title: 'فيديو تعليمي - الجمع والطرح الجبري',
            type: 'video',
            fileUrl: 'https://www.w3schools.com/html/mov_bbb.mp4',
            fileSize: '32.1 MB',
            order: 1,
            createdAt: DateTime(2025, 2, 14),
          ),
        ],
        'subject-5': [
          FreeTrialLessonFileModel(
            id: 'file-5',
            subjectId: 'subject-5',
            title: 'أوراق العمل والتمارين المتطورة',
            type: 'pdf',
            fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
            fileSize: '3.5 MB',
            order: 1,
            createdAt: DateTime(2025, 2, 14),
          ),
          FreeTrialLessonFileModel(
            id: 'file-6',
            subjectId: 'subject-5',
            title: 'عرض تقديمي توضيحي - HTML5',
            type: 'html5',
            fileUrl: 'https://qubah.com/files/subjects/5/presentation/index.html',
            fileSize: '12.4 MB',
            order: 2,
            createdAt: DateTime(2025, 2, 14),
          ),
        ],
      };
}

import 'package:web_dashboard/features/shared/models/base_entity.dart';

/// Model representing an educational free_trial_stage (e.g. Primary, Middle, Secondary).
class FreeTrialStageModel extends BaseEntity {
  final String? thumbnailUrl;
  final String? backgroundImageUrl;
  final int gradesCount;

  const FreeTrialStageModel({
    required super.id,
    required super.title,
    super.description,
    this.thumbnailUrl,
    this.backgroundImageUrl,
    super.isActive = true,
    super.order = 0,
    this.gradesCount = 0,
    super.createdAt,
  });

  @override
  List<Object?> get props => [...super.props, thumbnailUrl, backgroundImageUrl, gradesCount];

  factory FreeTrialStageModel.fromJson(Map<String, dynamic> json) {
    return FreeTrialStageModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      thumbnailUrl: json['thumbnail_url'],
      backgroundImageUrl: json['background_image_url'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      order: json['order'] != null ? int.tryParse(json['order'].toString()) ?? 0 : 0,
      gradesCount: int.tryParse(json['grades_count']?.toString() ?? json['levels_count']?.toString() ?? '') ?? (json['grades'] as List?)?.length ?? (json['levels'] as List?)?.length ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail_path': thumbnailUrl,
      'background_image_path': backgroundImageUrl,
      'is_active': isActive ? 1 : 0,
      'order': order,
      'grades_count': gradesCount,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  FreeTrialStageModel copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? backgroundImageUrl,
    bool? isActive,
    int? order,
    int? gradesCount,
    DateTime? createdAt,
  }) {
    return FreeTrialStageModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      gradesCount: gradesCount ?? this.gradesCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Dummy data for development / demo purposes.
  static List<FreeTrialStageModel> get dummyList => [
        FreeTrialStageModel(
          id: 'free_trial_stage-1',
          title: 'المرحلة الابتدائية',
          description: 'تشمل الصفوف من الأول إلى السادس الابتدائي',
          thumbnailUrl: 'https://via.placeholder.com/150/6C5CE7/FFFFFF?text=ابتدائي',
          isActive: true,
          order: 1,
          gradesCount: 6,
          createdAt: DateTime(2025, 1, 15),
        ),
        FreeTrialStageModel(
          id: 'free_trial_stage-2',
          title: 'المرحلة المتوسطة',
          description: 'تشمل الصفوف من الأول إلى الثالث المتوسط',
          thumbnailUrl: 'https://via.placeholder.com/150/00D2D3/FFFFFF?text=متوسط',
          isActive: true,
          order: 2,
          gradesCount: 3,
          createdAt: DateTime(2025, 2, 10),
        ),
        FreeTrialStageModel(
          id: 'free_trial_stage-3',
          title: 'المرحلة الثانوية',
          description: 'تشمل الصفوف من الأول إلى الثالث الثانوي',
          thumbnailUrl: 'https://via.placeholder.com/150/FF6B6B/FFFFFF?text=ثانوي',
          isActive: true,
          order: 3,
          gradesCount: 3,
          createdAt: DateTime(2025, 3, 5),
        ),
        FreeTrialStageModel(
          id: 'free_trial_stage-4',
          title: 'المرحلة الجامعية',
          description: 'تشمل المقررات الجامعية والتخصصات المختلفة',
          thumbnailUrl: 'https://via.placeholder.com/150/10B981/FFFFFF?text=جامعي',
          isActive: false,
          order: 4,
          gradesCount: 0,
          createdAt: DateTime(2025, 4, 20),
        ),
      ];
}

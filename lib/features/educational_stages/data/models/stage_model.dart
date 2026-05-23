import '../../domain/entities/stage_entity.dart';

class StageModel {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int order;
  final int subjectCount;

  const StageModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.order,
    this.subjectCount = 0,
  });

  factory StageModel.fromJson(Map<String, dynamic> json) => StageModel(
    id: json['id'].toString(),
    name: json['title'] ?? json['name'] ?? '',
    description: json['description'] as String?,
    imageUrl: json['thumbnail_url'] ?? json['image_url'] as String?,
    order: json['order'] as int? ?? 0,
    subjectCount: json['topics_count'] ?? json['subject_count'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'image_url': imageUrl,
    'order': order,
    'subject_count': subjectCount,
  };

  StageEntity toEntity() => StageEntity(
    id: id,
    name: name,
    description: description,
    imageUrl: imageUrl,
    order: order,
    subjectCount: subjectCount,
  );
}

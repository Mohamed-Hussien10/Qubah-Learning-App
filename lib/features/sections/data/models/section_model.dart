import '../../domain/entities/section_entity.dart';

class SectionModel {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int order;
  final int childCount;

  const SectionModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.order,
    this.childCount = 0,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) => SectionModel(
    id: json['id'].toString(),
    name: json['title'] ?? '',
    description: json['description'] as String?,
    imageUrl: json['thumbnail_url'] as String?,
    order: json['order'] as int? ?? 0,
    childCount: 0,
  );

  SectionEntity toEntity() => SectionEntity(
    id: id,
    name: name,
    description: description,
    imageUrl: imageUrl,
    order: order,
    childCount: childCount,
  );
}

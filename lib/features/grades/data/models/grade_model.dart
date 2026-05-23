import '../../domain/entities/grade_entity.dart';

class GradeModel {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int order;
  final int childCount;

  const GradeModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.order,
    this.childCount = 0,
  });

  factory GradeModel.fromJson(Map<String, dynamic> json) => GradeModel(
    id: json['id'].toString(),
    name: json['title'] ?? '',
    description: json['description'] as String?,
    imageUrl: json['thumbnail_url'] as String?,
    order: json['order'] as int? ?? 0,
    childCount: 0,
  );

  GradeEntity toEntity() => GradeEntity(
    id: id,
    name: name,
    description: description,
    imageUrl: imageUrl,
    order: order,
    childCount: childCount,
  );
}

import '../../domain/entities/unit_entity.dart';

class UnitModel {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int order;
  final int childCount;

  const UnitModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.order,
    this.childCount = 0,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) => UnitModel(
    id: json['id'].toString(),
    name: json['title'] ?? '',
    description: json['description'] as String?,
    imageUrl: json['thumbnail_url'] as String?,
    order: json['order'] as int? ?? 0,
    childCount: 0,
  );

  UnitEntity toEntity() => UnitEntity(
    id: id,
    name: name,
    description: description,
    imageUrl: imageUrl,
    order: order,
    childCount: childCount,
  );
}

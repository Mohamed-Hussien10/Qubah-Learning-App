import 'package:equatable/equatable.dart';

/// Domain entity for an educational stage (e.g., Grade 1, Grade 2).
class StageEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? backgroundImageUrl;
  final int order;
  final int subjectCount;

  const StageEntity({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.backgroundImageUrl,
    required this.order,
    this.subjectCount = 0,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    imageUrl,
    backgroundImageUrl,
    order,
    subjectCount,
  ];
}

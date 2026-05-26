import 'package:equatable/equatable.dart';

/// Abstract base entity for all educational content models.
///
/// Provides common fields shared across the hierarchy:
/// Stages > Grades > Sections > Subjects > Units > Lessons > Lesson Files.
abstract class BaseEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final bool isActive;
  final int order;
  final DateTime? createdAt;

  const BaseEntity({
    required this.id,
    required this.title,
    this.description,
    this.isActive = true,
    this.order = 0,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, description, isActive, order, createdAt];

  /// Copy-with pattern to be implemented by subclasses.
  BaseEntity copyWith({
    String? id,
    String? title,
    String? description,
    bool? isActive,
    int? order,
    DateTime? createdAt,
  });
}

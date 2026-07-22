import 'package:equatable/equatable.dart';
import '../../../subscriptions/domain/entities/package_entity.dart';

/// Pure Dart entity representing a user in the domain layer.
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? phone;
  final String? stageId;
  final String? stageName;
  final String? gradeId;
  final String? gradeName;
  final String? packageId;
  final PackageEntity? package;
  final String? subscriptionStatus;
  final DateTime? subscriptionExpiry;
  final bool isActive;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.phone,
    this.stageId,
    this.stageName,
    this.gradeId,
    this.gradeName,
    this.packageId,
    this.package,
    this.subscriptionStatus,
    this.subscriptionExpiry,
    this.isActive = true,
    required this.createdAt,
  });

  bool get isSubscriptionValid =>
      (subscriptionStatus == 'active' || subscriptionStatus == 'valid') ||
      (subscriptionExpiry != null && subscriptionExpiry!.isAfter(DateTime.now()));

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        avatarUrl,
        phone,
        stageId,
        stageName,
        gradeId,
        gradeName,
        packageId,
        package,
        subscriptionStatus,
        subscriptionExpiry,
        isActive,
        createdAt,
      ];
}


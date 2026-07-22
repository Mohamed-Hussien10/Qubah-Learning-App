import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';
import '../../../subscriptions/data/models/package_model.dart';

part 'user_model.g.dart';

String _parseString(dynamic value) => value?.toString() ?? '';
String? _parseStringNullable(dynamic value) => value?.toString();
bool _parseBool(dynamic value) {
  if (value == null) return true;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value.toLowerCase() == 'true' || value == '1';
  return true;
}

String _parseDate(dynamic value) {
  if (value == null || value.toString().isEmpty) {
    return DateTime.now().toIso8601String();
  }
  return value.toString();
}

/// Data layer model for API serialization/deserialization.
@JsonSerializable()
class UserModel {
  @JsonKey(fromJson: _parseString)
  final String id;
  @JsonKey(fromJson: _parseString)
  final String name;
  @JsonKey(fromJson: _parseString)
  final String email;
  @JsonKey(name: 'avatar_url', fromJson: _parseStringNullable)
  final String? avatarUrl;
  @JsonKey(fromJson: _parseStringNullable)
  final String? phone;
  @JsonKey(name: 'stage_id', fromJson: _parseStringNullable)
  final String? stageId;
  final String? stageName;
  @JsonKey(name: 'grade_id', fromJson: _parseStringNullable)
  final String? gradeId;
  final String? gradeName;
  @JsonKey(name: 'package_id', fromJson: _parseStringNullable)
  final String? packageId;
  final PackageModel? package;
  @JsonKey(name: 'subscription_status', fromJson: _parseStringNullable)
  final String? subscriptionStatus;
  @JsonKey(name: 'subscription_expiry', fromJson: _parseStringNullable)
  final String? subscriptionExpiry;
  @JsonKey(name: 'is_active', fromJson: _parseBool)
  final bool isActive;
  @JsonKey(name: 'created_at', fromJson: _parseDate)
  final String createdAt;

  const UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final model = _$UserModelFromJson(json);

    String? sName = model.stageName;
    if (json['stage'] != null && json['stage']['title'] != null) {
      sName = json['stage']['title'].toString();
    }

    String? gName = model.gradeName;
    if (json['grade'] != null && json['grade']['title'] != null) {
      gName = json['grade']['title'].toString();
    }

    PackageModel? pkg;
    if (json['package'] != null && json['package'] is Map<String, dynamic>) {
      pkg = PackageModel.fromJson(json['package'] as Map<String, dynamic>);
    } else if (model.package != null) {
      pkg = model.package;
    }

    return UserModel(
      id: model.id,
      name: model.name,
      email: model.email,
      avatarUrl: model.avatarUrl,
      phone: model.phone,
      stageId: model.stageId,
      stageName: sName,
      gradeId: model.gradeId,
      gradeName: gName,
      packageId: model.packageId ?? json['package_id']?.toString(),
      package: pkg,
      subscriptionStatus: model.subscriptionStatus,
      subscriptionExpiry: model.subscriptionExpiry,
      isActive: model.isActive,
      createdAt: model.createdAt,
    );
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Converts data model to domain entity.
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      phone: phone,
      stageId: stageId,
      stageName: stageName,
      gradeId: gradeId,
      gradeName: gradeName,
      packageId: packageId,
      package: package?.toEntity(),
      subscriptionStatus: subscriptionStatus,
      subscriptionExpiry: subscriptionExpiry != null
          ? DateTime.tryParse(subscriptionExpiry!)
          : null,
      isActive: isActive,
      createdAt: DateTime.parse(createdAt),
    );
  }

  /// Creates model from domain entity.
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      avatarUrl: entity.avatarUrl,
      phone: entity.phone,
      stageId: entity.stageId,
      stageName: entity.stageName,
      gradeId: entity.gradeId,
      gradeName: entity.gradeName,
      packageId: entity.packageId,
      package: entity.package != null
          ? PackageModel.fromEntity(entity.package!)
          : null,
      subscriptionStatus: entity.subscriptionStatus,
      subscriptionExpiry: entity.subscriptionExpiry?.toIso8601String(),
      isActive: entity.isActive,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }
}

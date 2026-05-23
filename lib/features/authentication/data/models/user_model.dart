import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

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
  @JsonKey(name: 'subscription_expiry', fromJson: _parseStringNullable)
  final String? subscriptionExpiry;
  @JsonKey(name: 'is_active', fromJson: _parseBool)
  final bool isActive;
  @JsonKey(name: 'created_at', fromJson: _parseString)
  final String createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.phone,
    this.stageId,
    this.subscriptionExpiry,
    this.isActive = true,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
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
      subscriptionExpiry: entity.subscriptionExpiry?.toIso8601String(),
      isActive: entity.isActive,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }
}

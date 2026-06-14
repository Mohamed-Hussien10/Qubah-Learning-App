// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: _parseString(json['id']),
  name: _parseString(json['name']),
  email: _parseString(json['email']),
  avatarUrl: _parseStringNullable(json['avatar_url']),
  phone: _parseStringNullable(json['phone']),
  stageId: _parseStringNullable(json['stage_id']),
  stageName: json['stageName'] as String?,
  gradeId: _parseStringNullable(json['grade_id']),
  gradeName: json['gradeName'] as String?,
  subscriptionStatus: _parseStringNullable(json['subscription_status']),
  subscriptionExpiry: _parseStringNullable(json['subscription_expiry']),
  isActive: json['is_active'] == null ? true : _parseBool(json['is_active']),
  createdAt: _parseString(json['created_at']),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'avatar_url': instance.avatarUrl,
  'phone': instance.phone,
  'stage_id': instance.stageId,
  'stageName': instance.stageName,
  'grade_id': instance.gradeId,
  'gradeName': instance.gradeName,
  'subscription_status': instance.subscriptionStatus,
  'subscription_expiry': instance.subscriptionExpiry,
  'is_active': instance.isActive,
  'created_at': instance.createdAt,
};

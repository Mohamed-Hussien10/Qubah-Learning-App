import 'package:equatable/equatable.dart';

enum UserRole { admin, student }

class UserModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;
  final int? stageId;
  final int? gradeId;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final DateTime? subscriptionExpiry;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    this.stageId,
    this.gradeId,
    required this.createdAt,
    this.lastLogin,
    this.subscriptionExpiry,
  });

  String get roleLabel {
    switch (role) {
      case UserRole.admin:
        return 'مدير';
      case UserRole.student:
        return 'طالب';
    }
  }

  String get statusLabel => isActive ? 'نشط' : 'غير نشط';

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    UserRole? role,
    bool? isActive,
    int? stageId,
    int? gradeId,
    DateTime? createdAt,
    DateTime? lastLogin,
    DateTime? subscriptionExpiry,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      stageId: stageId ?? this.stageId,
      gradeId: gradeId ?? this.gradeId,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.student,
      ),
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      stageId: json['stage_id'] as int?,
      gradeId: json['grade_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLogin: json['last_login'] != null
          ? DateTime.tryParse(json['last_login'] as String)
          : null,
      subscriptionExpiry: json['subscription_expiry'] != null
          ? DateTime.tryParse(json['subscription_expiry'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'is_active': isActive,
      'stage_id': stageId,
      'grade_id': gradeId,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'subscription_expiry': subscriptionExpiry?.toIso8601String(),
    };
  }

  static List<UserModel> dummyList = [
    UserModel(
      id: 1,
      name: 'أحمد محمد علي',
      email: 'ahmed@example.com',
      role: UserRole.admin,
      isActive: true,
      createdAt: DateTime(2024, 1, 15),
      lastLogin: DateTime(2026, 5, 26, 10, 30),
      subscriptionExpiry: DateTime(2026, 12, 31),
    ),
  ];

  @override
  List<Object?> get props => [id, name, email, role, isActive, stageId, gradeId, createdAt, lastLogin, subscriptionExpiry];
}
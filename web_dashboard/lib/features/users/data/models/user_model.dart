import 'package:equatable/equatable.dart';
import 'package:web_dashboard/features/packages/data/models/package_model.dart';

enum UserRole { admin, student }

class UserModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;
  final int? stageId;
  final int? gradeId;
  final int? packageId;
  final PackageModel? package;
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
    this.packageId,
    this.package,
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

  String get packageName {
    if (package != null && package!.name.isNotEmpty) {
      return package!.name;
    }
    return 'بدون باقة';
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    UserRole? role,
    bool? isActive,
    int? stageId,
    int? gradeId,
    int? packageId,
    PackageModel? package,
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
      packageId: packageId ?? this.packageId,
      package: package ?? this.package,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    PackageModel? pkg;
    if (json['package'] != null && json['package'] is Map<String, dynamic>) {
      pkg = PackageModel.fromJson(json['package'] as Map<String, dynamic>);
    }

    return UserModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.student,
      ),
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      stageId: int.tryParse(json['stage_id']?.toString() ?? ''),
      gradeId: int.tryParse(json['grade_id']?.toString() ?? ''),
      packageId: int.tryParse(json['package_id']?.toString() ?? ''),
      package: pkg,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
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
      'package_id': packageId,
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
  List<Object?> get props => [
        id,
        name,
        email,
        role,
        isActive,
        stageId,
        gradeId,
        packageId,
        package,
        createdAt,
        lastLogin,
        subscriptionExpiry
      ];
}
import 'package:equatable/equatable.dart';

enum UserRole { admin, student }

class UserModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;
  final String subscriptionStatus;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.subscriptionStatus,
    required this.createdAt,
    this.lastLogin,
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
    String? subscriptionStatus,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
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
      subscriptionStatus: json['subscription_status'] as String? ?? 'none',
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
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
      'subscription_status': subscriptionStatus,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  static List<UserModel> dummyList = [
    UserModel(
      id: 1,
      name: 'أحمد محمد علي',
      email: 'ahmed@example.com',
      role: UserRole.admin,
      isActive: true,
      subscriptionStatus: 'active',
      createdAt: DateTime(2024, 1, 15),
      lastLogin: DateTime(2026, 5, 26, 10, 30),
    ),
    UserModel(
      id: 2,
      name: 'فاطمة حسن إبراهيم',
      email: 'fatima@example.com',
      role: UserRole.student,
      isActive: true,
      subscriptionStatus: 'active',
      createdAt: DateTime(2024, 2, 20),
      lastLogin: DateTime(2026, 5, 25, 14, 0),
    ),
    UserModel(
      id: 3,
      name: 'عمر خالد الصالح',
      email: 'omar@example.com',
      role: UserRole.student,
      isActive: true,
      subscriptionStatus: 'active',
      createdAt: DateTime(2024, 3, 10),
      lastLogin: DateTime(2026, 5, 24, 9, 15),
    ),
    UserModel(
      id: 4,
      name: 'مريم عبدالله الشمري',
      email: 'mariam@example.com',
      role: UserRole.student,
      isActive: false,
      subscriptionStatus: 'expired',
      createdAt: DateTime(2024, 4, 5),
      lastLogin: DateTime(2026, 4, 10, 16, 45),
    ),
    UserModel(
      id: 5,
      name: 'يوسف سعيد القحطاني',
      email: 'yousef@example.com',
      role: UserRole.student,
      isActive: true,
      subscriptionStatus: 'active',
      createdAt: DateTime(2024, 5, 18),
      lastLogin: DateTime(2026, 5, 23, 11, 0),
    ),
    UserModel(
      id: 6,
      name: 'نورة محمد العتيبي',
      email: 'noura@example.com',
      role: UserRole.student,
      isActive: true,
      subscriptionStatus: 'active',
      createdAt: DateTime(2024, 6, 22),
      lastLogin: DateTime(2026, 5, 22, 8, 30),
    ),
    UserModel(
      id: 7,
      name: 'سلطان عبدالرحمن الدوسري',
      email: 'sultan@example.com',
      role: UserRole.student,
      isActive: true,
      subscriptionStatus: 'cancelled',
      createdAt: DateTime(2024, 7, 14),
      lastLogin: DateTime(2026, 5, 20, 13, 20),
    ),
    UserModel(
      id: 8,
      name: 'هند ناصر الحربي',
      email: 'hind@example.com',
      role: UserRole.student,
      isActive: false,
      subscriptionStatus: 'expired',
      createdAt: DateTime(2024, 8, 3),
      lastLogin: DateTime(2026, 3, 15, 17, 0),
    ),
    UserModel(
      id: 9,
      name: 'خالد فهد المالكي',
      email: 'khaled@example.com',
      role: UserRole.admin,
      isActive: true,
      subscriptionStatus: 'active',
      createdAt: DateTime(2024, 9, 11),
      lastLogin: DateTime(2026, 5, 26, 9, 0),
    ),
    UserModel(
      id: 10,
      name: 'ريم عادل السبيعي',
      email: 'reem@example.com',
      role: UserRole.student,
      isActive: true,
      subscriptionStatus: 'active',
      createdAt: DateTime(2024, 10, 25),
      lastLogin: DateTime(2026, 5, 21, 15, 10),
    ),
  ];

  @override
  List<Object?> get props => [id, name, email, role, isActive, subscriptionStatus, createdAt, lastLogin];
}
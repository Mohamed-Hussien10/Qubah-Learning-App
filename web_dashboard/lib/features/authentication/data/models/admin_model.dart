import 'package:equatable/equatable.dart';

/// Data model representing an authenticated admin user.
class AdminModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String role;
  final String token;
  final DateTime createdAt;

  const AdminModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
    required this.createdAt,
  });

  /// Create an [AdminModel] from a JSON map (typically from the API).
  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'admin',
      token: json['token'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Convert this model to a JSON map for storage or API calls.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'token': token,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy of this model with some fields replaced.
  AdminModel copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? token,
    DateTime? createdAt,
  }) {
    return AdminModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, email, role, token, createdAt];
}

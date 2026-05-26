import 'package:equatable/equatable.dart';

/// Data model for a login request payload.
class LoginRequest extends Equatable {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  /// Convert this request to a JSON map for sending to the API.
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  @override
  List<Object?> get props => [email, password];
}

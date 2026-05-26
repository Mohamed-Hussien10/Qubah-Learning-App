import 'package:equatable/equatable.dart';

import 'package:web_dashboard/features/authentication/data/models/admin_model.dart';

/// Base class for all authentication states.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state – auth status has not yet been determined.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Authentication is in progress (login call or session check).
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated and we have their profile.
class AuthAuthenticated extends AuthState {
  final AdminModel admin;

  const AuthAuthenticated({required this.admin});

  @override
  List<Object?> get props => [admin];
}

/// An authentication error occurred.
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

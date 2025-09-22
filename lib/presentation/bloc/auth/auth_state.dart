import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthenState {}

class AuthInitial extends AuthenState {}
class AuthLoading extends AuthenState {}
class AuthAuthenticated extends AuthenState {
  final User user;
  AuthAuthenticated(this.user);
}
class AuthUnauthenticated extends AuthenState {}
class AuthError extends AuthenState {
  final String message;
  AuthError(this.message);
}